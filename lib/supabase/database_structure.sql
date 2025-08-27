

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."certificationStatus" AS ENUM (
    'draft',
    'accepted',
    'rejected'
);


ALTER TYPE "public"."certificationStatus" OWNER TO "postgres";


CREATE TYPE "public"."legalEntityStatus" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE "public"."legalEntityStatus" OWNER TO "postgres";


CREATE TYPE "public"."userGender" AS ENUM (
    'male',
    'female',
    'other',
    'prefer_not_to_say',
    'non_binary'
);


ALTER TYPE "public"."userGender" OWNER TO "postgres";


CREATE TYPE "public"."userType" AS ENUM (
    'user',
    'legal_entity',
    'certifier',
    'admin'
);


ALTER TYPE "public"."userType" OWNER TO "postgres";


CREATE TYPE "public"."walletCreatedBy" AS ENUM (
    'application',
    'user'
);


ALTER TYPE "public"."walletCreatedBy" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_user_row_on_auth"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    BEGIN
        INSERT INTO public."user"
            ("idUser", "fullName", "profilePicture", "email", "idUserHash")
        VALUES (
            NEW.id,
            COALESCE(jsonb_extract_path_text(NEW.raw_user_meta_data, 'full_name'), NULL),
            COALESCE(
                jsonb_extract_path_text(NEW.raw_user_meta_data, 'picture'),
                jsonb_extract_path_text(NEW.raw_user_meta_data, 'avatar_url'),
                NULL
            ),
            NEW.email,
            encode(extensions.digest(NEW.id::text, 'sha256'), 'hex')
        );
    EXCEPTION WHEN OTHERS THEN
        -- Log only errors
        RAISE LOG 'ERROR create_user_row_on_auth for NEW.id=%: % (SQLSTATE=%)',
            NEW.id, SQLERRM, SQLSTATE;
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."create_user_row_on_auth"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."gen_codice_6"() RETURNS "text"
    LANGUAGE "sql"
    AS $$
  SELECT string_agg(
           substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                  (trunc(random() * 36 + 1))::int, 1),
           ''
         )
  FROM generate_series(1,6);
$$;


ALTER FUNCTION "public"."gen_codice_6"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_profile_picture_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'storage', 'pg_temp'
    AS $$
declare
  base_url text := 'https://ammryjdbnqedwlguhqpv.supabase.co';
  file_path text := NEW.name;               -- es: "files/xyz.png"
  bucket    text := NEW.bucket_id;          -- es: "profilopictures"
  public_url text;
  target_user uuid;
  uuid_from_name uuid;
begin
  -- Considera solo il bucket/percorsi desiderati
  if bucket = 'profilopictures' and file_path like 'files/%' then

    -- 1) Prova a usare l’owner del file (utente che ha fatto l’upload)
    target_user := NEW.owner;

    -- 2) Fallback: se non c'è owner, prova a estrarre un UUID nel filename
    --    es. files/9f5d2b0b-1234-4a1b-9f3a-0a1b2c3d4e5f.png
    if target_user is null then
      select (regexp_matches(file_path,
              '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12})'))[1]::uuid
      into uuid_from_name;
      target_user := uuid_from_name;
    end if;

    -- Se abbiamo un utente valido, aggiorna la sua foto profilo
    if target_user is not null then
      public_url := base_url
        || '/storage/v1/object/public/'
        || bucket || '/' || file_path;

      update public."user"
         set "profilePicture" = public_url
       where id = target_user;
    end if;
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION "public"."handle_profile_picture_upload"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text" DEFAULT 'https://ammryjdbnqedwlguhqpv.supabase.co'::"text") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'storage', 'pg_temp'
    AS $_$
/*
  Aggiorna public."user".profilePicture con la public URL
  dell’ultima immagine (png/jpg/jpeg/webp/gif) trovata in:
    profilepictures / files / <user_id> / *
  Ritorna il numero di righe aggiornate.
*/
declare
  v_updated integer := 0;
begin
  -- Aggiorna in blocco tutti gli utenti che hanno almeno un file idoneo
  with latest_per_user as (
    select
      u.id as user_id,
      so.name as object_name,
      row_number() over (partition by u.id order by so.created_at desc) as rn
    from public."user" u
    join storage.objects so
      on so.bucket_id = 'profilepictures'
     and so.name like ('files/' || u.id::text || '/%')
     and lower(so.name) ~ '\.(png|jpe?g|webp|gif)$'
  )
  update public."user" u
     set "profilePicture" =
         p_base_url || '/storage/v1/object/public/profilepictures/' || l.object_name
  from latest_per_user l
  where l.user_id = u.id
    and l.rn = 1;  -- solo l'ultima immagine per utente

  get diagnostics v_updated = row_count;
  return v_updated;
end;
$_$;


ALTER FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_profile_picture"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    public_url text;
BEGIN
    -- Check if the file is in the profilopictures/files/ bucket
    -- and the owner matches the currently authenticated user
    IF NEW.bucket_id = 'profilopictures' AND 
       NEW.name LIKE 'files/%' AND 
       NEW.owner_id = auth.uid()::text THEN
        
        -- Generate public URL for the uploaded file
        public_url := (
            SELECT url 
            FROM storage.objects 
            WHERE id = NEW.id
        );
        
        -- Update user's profile picture
        UPDATE public.user 
        SET "profilePicture" = public_url,
            "updatedAt" = NOW()
        WHERE "idUser" = auth.uid();
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_profile_picture"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."certification" (
    "idCertification" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "idCertificationHash" "text" NOT NULL,
    "idUser" "uuid" NOT NULL,
    "idCertifier" "uuid" NOT NULL,
    "idLegalEntity" "uuid" NOT NULL,
    "status" "public"."certificationStatus" DEFAULT 'draft'::"public"."certificationStatus" NOT NULL,
    "statusUpdatedAtByUser" timestamp with time zone,
    "rejectionReason" "text",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone
);


ALTER TABLE "public"."certification" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certifier" (
    "idCertifier" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "idCertifierHash" "text",
    "idUser" "uuid",
    "idLegalEntity" "uuid",
    "active" boolean,
    "roleCompany" "text",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone
);


ALTER TABLE "public"."certifier" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."country" (
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "emoji" "text"
);


ALTER TABLE "public"."country" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cv" (
    "idCv" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "idUser" "uuid" NOT NULL,
    "idWallet" "uuid" NOT NULL,
    "nftTokenId" "text",
    "nftMintTransactionUrl" "text",
    "nftMintTransactionHash" "text",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "firstName" "text",
    "firstNameHash" "text",
    "lastName" "text",
    "lastNameHash" "text",
    "email" "text",
    "emailHash" "text",
    "phone" "text",
    "phoneHash" "text",
    "dateOfBirth" "text",
    "dateOfBirthHash" "text",
    "address" "text",
    "addressHash" "text",
    "city" "text",
    "cityHash" "text",
    "state" "text",
    "stateHash" "text",
    "postalCode" "text",
    "postalCodeHash" "text",
    "country" "text",
    "countryHash" "text",
    "profilePicture" "text",
    "profilePictureHash" "text",
    "gender" "text",
    "genderHash" "text",
    "ipfsCid" "text",
    "ipfsUrl" "text",
    "idCvHash" "text",
    "firstNameSalt" "text",
    "lastNameSalt" "text",
    "emailSalt" "text",
    "phoneSalt" "text",
    "dateOfBirthSalt" "text",
    "addressSalt" "text",
    "citySalt" "text",
    "stateSalt" "text",
    "postalCodeSalt" "text",
    "countrySalt" "text",
    "profilePictureSalt" "text",
    "genderSalt" "text",
    "serial" "text" DEFAULT "public"."gen_codice_6"() NOT NULL,
    CONSTRAINT "serial_chk" CHECK (("serial" ~ '^[A-Za-z0-9]{6}$'::"text"))
);


ALTER TABLE "public"."cv" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."cv_view" AS
 SELECT "idCv",
    "idCvHash",
    "idUser",
    "idWallet",
    "nftTokenId",
    "nftMintTransactionUrl",
    "nftMintTransactionHash",
    "createdAt",
    "updatedAt",
    "ipfsCid",
    "ipfsUrl",
    "firstName",
    "firstNameHash",
    "firstNameSalt",
    "lastName",
    "lastNameHash",
    "lastNameSalt",
    "email",
    "emailHash",
    "emailSalt",
    "phone",
    "phoneHash",
    "phoneSalt",
    "dateOfBirth",
    "dateOfBirthHash",
    "dateOfBirthSalt",
    "address",
    "addressHash",
    "addressSalt",
    "city",
    "cityHash",
    "citySalt",
    "state",
    "stateHash",
    "stateSalt",
    "postalCode",
    "postalCodeHash",
    "postalCodeSalt",
    "country",
    "countryHash",
    "countrySalt",
    "profilePicture",
    "profilePictureHash",
    "profilePictureSalt",
    "gender",
    "genderHash",
    "genderSalt"
   FROM "public"."cv";


ALTER VIEW "public"."cv_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."debug_log" (
    "ts" timestamp with time zone DEFAULT "now"(),
    "message" "text"
);


ALTER TABLE "public"."debug_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kyc_attempt" (
    "idKycAttempt" bigint NOT NULL,
    "idUser" "uuid" NOT NULL,
    "requestBody" "text",
    "success" "text",
    "message" "text",
    "receivedParams" "text",
    "responseStatus" "text",
    "responseVerificationId" "text",
    "responseVerificationUrl" "text",
    "responseVerificationSessionToken" "text",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "sessionId" "text",
    "verificated" boolean,
    "verificatedAt" timestamp with time zone
);


ALTER TABLE "public"."kyc_attempt" OWNER TO "postgres";


ALTER TABLE "public"."kyc_attempt" ALTER COLUMN "idKycAttempt" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."kyc_attempts_idKycAttempts_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."legal_entity" (
    "idLegalEntity" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "idLegalEntityHash" "text" NOT NULL,
    "legalName" "text" NOT NULL,
    "identifierCode" "text" NOT NULL,
    "operationalAddress" "text" NOT NULL,
    "headquartersAddress" "text" NOT NULL,
    "legalRepresentative" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone" "text" NOT NULL,
    "pec" "text",
    "website" "text",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "statusUpdatedAt" timestamp with time zone,
    "statusUpdatedByIdUser" "uuid",
    "requestingIdUser" "uuid" NOT NULL,
    "status" "public"."legalEntityStatus" DEFAULT 'pending'::"public"."legalEntityStatus" NOT NULL,
    "logoPictureUrl" "text",
    "companyPictureUrl" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "postalcode" "text",
    "countrycode" "text"
);


ALTER TABLE "public"."legal_entity" OWNER TO "postgres";


COMMENT ON COLUMN "public"."legal_entity"."address" IS 'address';



COMMENT ON COLUMN "public"."legal_entity"."city" IS 'city';



COMMENT ON COLUMN "public"."legal_entity"."state" IS 'state';



COMMENT ON COLUMN "public"."legal_entity"."postalcode" IS 'postalcode';



COMMENT ON COLUMN "public"."legal_entity"."countrycode" IS 'countrycode';



CREATE TABLE IF NOT EXISTS "public"."user" (
    "idUser" "uuid" NOT NULL,
    "firstName" "text",
    "lastName" "text",
    "email" "text",
    "phone" "text",
    "dateOfBirth" "date",
    "address" "text",
    "city" "text",
    "state" "text",
    "postalCode" "text",
    "countryCode" "text",
    "profilePicture" "text",
    "gender" "public"."userGender",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "fullName" "text",
    "type" "public"."userType",
    "hasWallet" boolean DEFAULT false NOT NULL,
    "idWallet" "uuid",
    "hasCv" boolean DEFAULT false NOT NULL,
    "idCv" "uuid",
    "idUserHash" "text" NOT NULL,
    "profileCompleted" boolean DEFAULT false NOT NULL,
    "kycCompleted" boolean,
    "kycPassed" boolean
);


ALTER TABLE "public"."user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wallet" (
    "idUser" "uuid" NOT NULL,
    "secretKey" "text" NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "createdBy" "public"."walletCreatedBy" NOT NULL,
    "publicAddress" "text" NOT NULL,
    "idWallet" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."wallet" OWNER TO "postgres";


ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_pkey" PRIMARY KEY ("idCertification");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_pkey" PRIMARY KEY ("idCertifier");



ALTER TABLE ONLY "public"."country"
    ADD CONSTRAINT "country_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_iduser_key" UNIQUE ("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_pkey" PRIMARY KEY ("idCv");



ALTER TABLE ONLY "public"."kyc_attempt"
    ADD CONSTRAINT "kyc_attempt_pkey" PRIMARY KEY ("idKycAttempt");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_pkey" PRIMARY KEY ("idLegalEntity");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("idUser");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_pkey" PRIMARY KEY ("idWallet");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_idCertifier_fkey" FOREIGN KEY ("idCertifier") REFERENCES "public"."certifier"("idCertifier");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_idLegalEntity_fkey" FOREIGN KEY ("idLegalEntity") REFERENCES "public"."legal_entity"("idLegalEntity");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_idLegalEntity_fkey" FOREIGN KEY ("idLegalEntity") REFERENCES "public"."legal_entity"("idLegalEntity");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_idWallet_fkey" FOREIGN KEY ("idWallet") REFERENCES "public"."wallet"("idWallet");



ALTER TABLE ONLY "public"."kyc_attempt"
    ADD CONSTRAINT "kyc_attempts_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_approvedByIdUser_fkey" FOREIGN KEY ("statusUpdatedByIdUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_requestingIdUser_fkey" FOREIGN KEY ("requestingIdUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_countryCode_fkey" FOREIGN KEY ("countryCode") REFERENCES "public"."country"("code");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_idCv_fkey" FOREIGN KEY ("idCv") REFERENCES "public"."cv"("idCv");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_idWallet_fkey" FOREIGN KEY ("idWallet") REFERENCES "public"."wallet"("idWallet");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "anon";
GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_profile_picture_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_profile_picture_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_profile_picture_upload"() TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_profile_picture"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_profile_picture"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_profile_picture"() TO "service_role";



GRANT ALL ON TABLE "public"."certification" TO "anon";
GRANT ALL ON TABLE "public"."certification" TO "authenticated";
GRANT ALL ON TABLE "public"."certification" TO "service_role";



GRANT ALL ON TABLE "public"."certifier" TO "anon";
GRANT ALL ON TABLE "public"."certifier" TO "authenticated";
GRANT ALL ON TABLE "public"."certifier" TO "service_role";



GRANT ALL ON TABLE "public"."country" TO "anon";
GRANT ALL ON TABLE "public"."country" TO "authenticated";
GRANT ALL ON TABLE "public"."country" TO "service_role";



GRANT ALL ON TABLE "public"."cv" TO "anon";
GRANT ALL ON TABLE "public"."cv" TO "authenticated";
GRANT ALL ON TABLE "public"."cv" TO "service_role";



GRANT ALL ON TABLE "public"."cv_view" TO "anon";
GRANT ALL ON TABLE "public"."cv_view" TO "authenticated";
GRANT ALL ON TABLE "public"."cv_view" TO "service_role";



GRANT ALL ON TABLE "public"."debug_log" TO "anon";
GRANT ALL ON TABLE "public"."debug_log" TO "authenticated";
GRANT ALL ON TABLE "public"."debug_log" TO "service_role";



GRANT ALL ON TABLE "public"."kyc_attempt" TO "anon";
GRANT ALL ON TABLE "public"."kyc_attempt" TO "authenticated";
GRANT ALL ON TABLE "public"."kyc_attempt" TO "service_role";



GRANT ALL ON SEQUENCE "public"."kyc_attempts_idKycAttempts_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."kyc_attempts_idKycAttempts_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."kyc_attempts_idKycAttempts_seq" TO "service_role";



GRANT ALL ON TABLE "public"."legal_entity" TO "anon";
GRANT ALL ON TABLE "public"."legal_entity" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_entity" TO "service_role";



GRANT ALL ON TABLE "public"."user" TO "anon";
GRANT ALL ON TABLE "public"."user" TO "authenticated";
GRANT ALL ON TABLE "public"."user" TO "service_role";



GRANT ALL ON TABLE "public"."wallet" TO "anon";
GRANT ALL ON TABLE "public"."wallet" TO "authenticated";
GRANT ALL ON TABLE "public"."wallet" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






RESET ALL;
