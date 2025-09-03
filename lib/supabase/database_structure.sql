

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



CREATE TYPE "public"."certification_category_type" AS ENUM (
    'standard',
    'custom'
);


ALTER TYPE "public"."certification_category_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_information_scope" AS ENUM (
    'certification',
    'certification_user'
);


ALTER TYPE "public"."certification_information_scope" OWNER TO "postgres";


CREATE TYPE "public"."certification_information_type" AS ENUM (
    'standard',
    'custom'
);


ALTER TYPE "public"."certification_information_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_media_acquisition_type" AS ENUM (
    'realtime',
    'deferred'
);


ALTER TYPE "public"."certification_media_acquisition_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_media_file_type" AS ENUM (
    'image',
    'video',
    'document'
);


ALTER TYPE "public"."certification_media_file_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_status" AS ENUM (
    'draft',
    'sent',
    'closed'
);


ALTER TYPE "public"."certification_status" OWNER TO "postgres";


CREATE TYPE "public"."certification_user_status" AS ENUM (
    'draft',
    'pending',
    'accepted',
    'rejected'
);


ALTER TYPE "public"."certification_user_status" OWNER TO "postgres";


CREATE TYPE "public"."legal_entity_status" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE "public"."legal_entity_status" OWNER TO "postgres";


CREATE TYPE "public"."user_gender" AS ENUM (
    'male',
    'female',
    'other',
    'prefer_not_to_say',
    'non_binary'
);


ALTER TYPE "public"."user_gender" OWNER TO "postgres";


CREATE TYPE "public"."user_type" AS ENUM (
    'user',
    'legal_entity',
    'certifier',
    'admin'
);


ALTER TYPE "public"."user_type" OWNER TO "postgres";


CREATE TYPE "public"."wallet_created_by" AS ENUM (
    'application',
    'user'
);


ALTER TYPE "public"."wallet_created_by" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."base36_10_readable"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  b   bytea := gen_random_bytes(8); -- 64 bits of randomness
  val numeric := 0;
  chars text := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  code  text := '';
  i int;
  digit int;
BEGIN
  -- Convert 8 random bytes into a big integer
  FOR i IN 0..7 LOOP
    val := val * 256 + get_byte(b, i);
  END LOOP;

  -- Build 10 base36 digits (most significant padded by division chain)
  FOR i IN 1..10 LOOP
    digit := (val % 36)::int;
    code := substr(chars, digit + 1, 1) || code; -- prepend
    val := trunc(val / 36);
  END LOOP;

  RETURN substr(code, 1, 5) || '-' || substr(code, 6, 5);
END;
$$;


ALTER FUNCTION "public"."base36_10_readable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."base64url_encode"("input" "bytea") RETURNS "text"
    LANGUAGE "sql"
    AS $_$
  SELECT regexp_replace(
           replace(replace(encode($1, 'base64'), '+', '-'), '/', '_'),
           '=+$', ''
         )
$_$;


ALTER FUNCTION "public"."base64url_encode"("input" "bytea") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."gen_url_token_256"() RETURNS "text"
    LANGUAGE "sql"
    AS $$
  SELECT base64url_encode(gen_random_bytes(32))
$$;


ALTER FUNCTION "public"."gen_url_token_256"() OWNER TO "postgres";


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
    "id_certification" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_certification_hash" "text" NOT NULL,
    "id_certifier" "uuid" NOT NULL,
    "id_legal_entity" "uuid" NOT NULL,
    "status" "public"."certification_status" DEFAULT 'draft'::"public"."certification_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_t" timestamp with time zone,
    "serial_number" "text" DEFAULT "public"."base36_10_readable"() NOT NULL,
    "id_location" "uuid" NOT NULL,
    "n_users" smallint NOT NULL,
    "sent_at" timestamp with time zone,
    "draft_at" timestamp with time zone,
    "closed_at" timestamp with time zone,
    "id_certification_category" "uuid" NOT NULL,
    CONSTRAINT "cert_serial_number_format_ck" CHECK (("serial_number" ~ '^[A-Z0-9]{5}-[A-Z0-9]{5}$'::"text"))
);


ALTER TABLE "public"."certification" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_category" (
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "type" "public"."certification_category_type" NOT NULL,
    "order" smallint,
    "id_legal_entity" "uuid",
    "id_certification_category" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."certification_category" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_category_has_information" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "id_certification_category" "uuid" NOT NULL,
    "id_certification_information" "uuid" NOT NULL,
    "id_certification_category_has_information" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."certification_category_has_information" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_has_media" (
    "id_certification_has_media" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "id_certification" "uuid",
    "id_certification_user" "uuid",
    "id_certification_media" "uuid" NOT NULL
);


ALTER TABLE "public"."certification_has_media" OWNER TO "postgres";


ALTER TABLE "public"."certification_has_media" ALTER COLUMN "id_certification_has_media" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."certification_has_media_id_certification_has_media_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."certification_information" (
    "name" "text" NOT NULL,
    "order" smallint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "label" "text" NOT NULL,
    "type" "public"."certification_information_type",
    "id_certification_information" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_legal_entity" "uuid",
    "scope" "public"."certification_information_scope"
);


ALTER TABLE "public"."certification_information" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_information_value" (
    "id_certification_information_value" bigint NOT NULL,
    "id_certification_information" "uuid" NOT NULL,
    "value" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."certification_information_value" OWNER TO "postgres";


ALTER TABLE "public"."certification_information_value" ALTER COLUMN "id_certification_information_value" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."certification_information_val_id_certification_information__seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."certification_media" (
    "id_certification_media" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_media_hash" "text" NOT NULL,
    "id_certification" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text",
    "description" "text",
    "acquisition_type" "public"."certification_media_acquisition_type" NOT NULL,
    "captured_at" timestamp with time zone NOT NULL,
    "id_location" "uuid",
    "file_type" "public"."certification_media_file_type" NOT NULL
);


ALTER TABLE "public"."certification_media" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_user" (
    "id_certification" "uuid" NOT NULL,
    "id_user" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "status" "public"."certification_user_status" DEFAULT 'draft'::"public"."certification_user_status" NOT NULL,
    "id_certification_user" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "serial_number" "text" DEFAULT "public"."base36_10_readable"() NOT NULL,
    "rejection_reason" "text",
    "id_otp" "uuid" NOT NULL
);


ALTER TABLE "public"."certification_user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certifier" (
    "id_certifier" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_certifier_hash" "text" NOT NULL,
    "id_legal_entity" "uuid" NOT NULL,
    "id_user" "uuid",
    "active" boolean DEFAULT true NOT NULL,
    "role" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "invitation_token" "text" DEFAULT "public"."gen_url_token_256"(),
    "kyc_passed" boolean,
    "id_kyc_attempt" "uuid",
    CONSTRAINT "certifier_invitation_token_format_ck" CHECK (("invitation_token" ~ '^[A-Za-z0-9_-]{43}$'::"text"))
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
    "countryCode" "text",
    "countryCodeHash" "text",
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
    "countryCodeSalt" "text",
    "profilePictureSalt" "text",
    "genderSalt" "text",
    "publicId" "text",
    "serial_number" "text" DEFAULT "public"."base36_10_readable"() NOT NULL,
    "serial_number_hash" "text",
    "serial_number_salt" "text",
    "nationality_codes" "text"[],
    "nationality_codes_hash" "text"[],
    "nationality_codes_salt" "text"[],
    "language_codes" "text"[],
    "language_codes_hash" "text"[],
    "language_codes_salt" "text"[],
    CONSTRAINT "cv_serial_number_format_ck" CHECK (("serial_number" ~ '^[A-Z0-9]{5}-[A-Z0-9]{5}$'::"text"))
);


ALTER TABLE "public"."cv" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."debug_log" (
    "ts" timestamp with time zone DEFAULT "now"(),
    "message" "text",
    "id_debug_log" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."debug_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kyc_attempt" (
    "id_user" "uuid" NOT NULL,
    "request_body" "text",
    "success" "text",
    "message" "text",
    "received_params" "text",
    "response_status" "text",
    "response_verification_id" "text",
    "response_verification_url" "text",
    "response_verification_session_token" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "session_id" "text",
    "verificated" boolean,
    "verificated_at" timestamp with time zone,
    "id_kyc_attempt" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."kyc_attempt" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_entity" (
    "id_legal_entity" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_legal_entity_hash" "text" NOT NULL,
    "legal_name" "text",
    "identifier_code" "text",
    "operational_address" "text",
    "operational_city" "text",
    "operational_postal_code" "text",
    "operational_state" "text",
    "operational_country" "text",
    "headquarter_address" "text",
    "headquarter_city" "text",
    "headquarter_postal_code" "text",
    "headquarter_state" "text",
    "headquarter_country" "text",
    "legal_rapresentative" "text",
    "email" "text",
    "phone" "text",
    "pec" "text",
    "website" "text",
    "status" "public"."legal_entity_status" NOT NULL,
    "logo_picture" "text",
    "company_picture" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "created_by_id_user" "uuid" NOT NULL
);


ALTER TABLE "public"."legal_entity" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_entity_invitation" (
    "id_legal_entity" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "invitation_token" "text" DEFAULT "public"."gen_url_token_256"() NOT NULL,
    "sent_at" timestamp with time zone,
    "expires_at" timestamp with time zone NOT NULL,
    "accepted_at" timestamp with time zone,
    "id_legal_entity_invitation" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "valid" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."legal_entity_invitation" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."location" (
    "id_location" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "aquired_at" timestamp with time zone NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "accuracy_m" real,
    "is_moked" boolean,
    "altitude" double precision,
    "altitude_accuracy_m" real,
    "name" "text",
    "street" "text",
    "locality" "text",
    "sub_locality" "text",
    "administrative_area" "text",
    "sub_administrative_area" "text",
    "postal_code" "text",
    "iso_country_code" "text",
    "country" "text",
    "thoroughfare" "text",
    "sub_thoroughfare" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."location" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."otp" (
    "id_otp" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "code" "text" NOT NULL,
    "code_hash" "text" NOT NULL,
    "tag" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "expires_at" timestamp with time zone NOT NULL,
    "used_at" timestamp with time zone,
    "used_by_id_user" "uuid",
    "burned_at" timestamp with time zone
);


ALTER TABLE "public"."otp" OWNER TO "postgres";


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
    "gender" "public"."user_gender",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "fullName" "text",
    "type" "public"."user_type",
    "hasWallet" boolean DEFAULT false NOT NULL,
    "idWallet" "uuid",
    "hasCv" boolean DEFAULT false NOT NULL,
    "idCv" "uuid",
    "idUserHash" "text" NOT NULL,
    "profileCompleted" boolean DEFAULT false NOT NULL,
    "languageCodeApp" "text",
    "nationalityCodes" "text"[],
    "languageCodes" "text"[]
);


ALTER TABLE "public"."user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wallet" (
    "idUser" "uuid" NOT NULL,
    "secretKey" "text" NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "createdBy" "public"."wallet_created_by" NOT NULL,
    "publicAddress" "text" NOT NULL,
    "idWallet" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."wallet" OWNER TO "postgres";


ALTER TABLE ONLY "public"."certification_category_has_information"
    ADD CONSTRAINT "certification_category_has_information_pkey" PRIMARY KEY ("id_certification_category_has_information");



ALTER TABLE ONLY "public"."certification_category"
    ADD CONSTRAINT "certification_category_id_cat_uuid_uc" UNIQUE ("id_certification_category");



ALTER TABLE ONLY "public"."certification_category"
    ADD CONSTRAINT "certification_category_pkey" PRIMARY KEY ("id_certification_category");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_pkey" PRIMARY KEY ("id_certification_has_media");



ALTER TABLE ONLY "public"."certification_information"
    ADD CONSTRAINT "certification_information_pkey" PRIMARY KEY ("id_certification_information");



ALTER TABLE ONLY "public"."certification_information"
    ADD CONSTRAINT "certification_information_uuid_uc" UNIQUE ("id_certification_information");



ALTER TABLE ONLY "public"."certification_information_value"
    ADD CONSTRAINT "certification_information_value_pkey" PRIMARY KEY ("id_certification_information_value");



ALTER TABLE ONLY "public"."certification_media"
    ADD CONSTRAINT "certification_media_pkey" PRIMARY KEY ("id_certification_media");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_pkey" PRIMARY KEY ("id_certification");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_pkey" PRIMARY KEY ("id_certification_user");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_serial_key" UNIQUE ("serial_number");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_invitation_id_key" UNIQUE ("invitation_token");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_pkey1" PRIMARY KEY ("id_certifier");



ALTER TABLE ONLY "public"."country"
    ADD CONSTRAINT "country_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_iduser_key" UNIQUE ("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_pkey" PRIMARY KEY ("idCv");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_serial_number_key" UNIQUE ("serial_number");



ALTER TABLE ONLY "public"."kyc_attempt"
    ADD CONSTRAINT "kyc_attempt_pkey" PRIMARY KEY ("id_kyc_attempt");



ALTER TABLE ONLY "public"."legal_entity_invitation"
    ADD CONSTRAINT "legal_entity_invitation_pkey" PRIMARY KEY ("id_legal_entity_invitation");



ALTER TABLE ONLY "public"."legal_entity_invitation"
    ADD CONSTRAINT "legal_entity_invitations_invitation_token_key" UNIQUE ("invitation_token");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_pkey1" PRIMARY KEY ("id_legal_entity");



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "location_pkey" PRIMARY KEY ("id_location");



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_pkey" PRIMARY KEY ("id_otp");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("idUser");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_pkey" PRIMARY KEY ("idWallet");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_publicaddress_key" UNIQUE ("publicAddress");



CREATE INDEX "legal_entity_invitations_email_idx" ON "public"."legal_entity_invitation" USING "btree" ("email");



CREATE INDEX "legal_entity_invitations_id_legal_entity_idx" ON "public"."legal_entity_invitation" USING "btree" ("id_legal_entity");



ALTER TABLE ONLY "public"."certification_category_has_information"
    ADD CONSTRAINT "certification_category_has_in_id_certification_information_fkey" FOREIGN KEY ("id_certification_information") REFERENCES "public"."certification_information"("id_certification_information");



ALTER TABLE ONLY "public"."certification_category_has_information"
    ADD CONSTRAINT "certification_category_has_infor_id_certification_category_fkey" FOREIGN KEY ("id_certification_category") REFERENCES "public"."certification_category"("id_certification_category");



ALTER TABLE ONLY "public"."certification_category"
    ADD CONSTRAINT "certification_category_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_id_certification_media_fkey" FOREIGN KEY ("id_certification_media") REFERENCES "public"."certification_media"("id_certification_media");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_id_certification_user_fkey" FOREIGN KEY ("id_certification_user") REFERENCES "public"."certification_user"("id_certification_user");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_certification_category_fkey" FOREIGN KEY ("id_certification_category") REFERENCES "public"."certification_category"("id_certification_category");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_certifier_fkey" FOREIGN KEY ("id_certifier") REFERENCES "public"."certifier"("id_certifier");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_location_fkey" FOREIGN KEY ("id_location") REFERENCES "public"."location"("id_location");



ALTER TABLE ONLY "public"."certification_information"
    ADD CONSTRAINT "certification_information_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certification_information_value"
    ADD CONSTRAINT "certification_information_val_id_certification_information_fkey" FOREIGN KEY ("id_certification_information") REFERENCES "public"."certification_information"("id_certification_information");



ALTER TABLE ONLY "public"."certification_media"
    ADD CONSTRAINT "certification_media_id_location_fkey" FOREIGN KEY ("id_location") REFERENCES "public"."location"("id_location");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_id_otp_fkey" FOREIGN KEY ("id_otp") REFERENCES "public"."otp"("id_otp");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_id_kyc_attempt_fkey" FOREIGN KEY ("id_kyc_attempt") REFERENCES "public"."kyc_attempt"("id_kyc_attempt");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_idWallet_fkey" FOREIGN KEY ("idWallet") REFERENCES "public"."wallet"("idWallet");



ALTER TABLE ONLY "public"."kyc_attempt"
    ADD CONSTRAINT "kyc_attempts_idUser_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_created_by_id_user_fkey" FOREIGN KEY ("created_by_id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."legal_entity_invitation"
    ADD CONSTRAINT "legal_entity_invitations_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "location_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."certification_media"
    ADD CONSTRAINT "media_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_used_by_id_user_fkey" FOREIGN KEY ("used_by_id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_countryCode_fkey" FOREIGN KEY ("countryCode") REFERENCES "public"."country"("code");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_idCv_fkey" FOREIGN KEY ("idCv") REFERENCES "public"."cv"("idCv");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_idWallet_fkey" FOREIGN KEY ("idWallet") REFERENCES "public"."wallet"("idWallet");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE "public"."certification" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_category_has_information" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_has_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_information" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_information_value" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certifier" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."country" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cv" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."debug_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kyc_attempt" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_entity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_entity_invitation" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."location" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."otp" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."wallet" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."base36_10_readable"() TO "anon";
GRANT ALL ON FUNCTION "public"."base36_10_readable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."base36_10_readable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."base64url_encode"("input" "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."base64url_encode"("input" "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."base64url_encode"("input" "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "anon";
GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gen_url_token_256"() TO "anon";
GRANT ALL ON FUNCTION "public"."gen_url_token_256"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gen_url_token_256"() TO "service_role";



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



GRANT ALL ON TABLE "public"."certification_category" TO "anon";
GRANT ALL ON TABLE "public"."certification_category" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_category" TO "service_role";



GRANT ALL ON TABLE "public"."certification_category_has_information" TO "anon";
GRANT ALL ON TABLE "public"."certification_category_has_information" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_category_has_information" TO "service_role";



GRANT ALL ON TABLE "public"."certification_has_media" TO "anon";
GRANT ALL ON TABLE "public"."certification_has_media" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_has_media" TO "service_role";



GRANT ALL ON SEQUENCE "public"."certification_has_media_id_certification_has_media_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."certification_has_media_id_certification_has_media_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."certification_has_media_id_certification_has_media_seq" TO "service_role";



GRANT ALL ON TABLE "public"."certification_information" TO "anon";
GRANT ALL ON TABLE "public"."certification_information" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_information" TO "service_role";



GRANT ALL ON TABLE "public"."certification_information_value" TO "anon";
GRANT ALL ON TABLE "public"."certification_information_value" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_information_value" TO "service_role";



GRANT ALL ON SEQUENCE "public"."certification_information_val_id_certification_information__seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."certification_information_val_id_certification_information__seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."certification_information_val_id_certification_information__seq" TO "service_role";



GRANT ALL ON TABLE "public"."certification_media" TO "anon";
GRANT ALL ON TABLE "public"."certification_media" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_media" TO "service_role";



GRANT ALL ON TABLE "public"."certification_user" TO "anon";
GRANT ALL ON TABLE "public"."certification_user" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_user" TO "service_role";



GRANT ALL ON TABLE "public"."certifier" TO "anon";
GRANT ALL ON TABLE "public"."certifier" TO "authenticated";
GRANT ALL ON TABLE "public"."certifier" TO "service_role";



GRANT ALL ON TABLE "public"."country" TO "anon";
GRANT ALL ON TABLE "public"."country" TO "authenticated";
GRANT ALL ON TABLE "public"."country" TO "service_role";



GRANT ALL ON TABLE "public"."cv" TO "anon";
GRANT ALL ON TABLE "public"."cv" TO "authenticated";
GRANT ALL ON TABLE "public"."cv" TO "service_role";



GRANT ALL ON TABLE "public"."debug_log" TO "anon";
GRANT ALL ON TABLE "public"."debug_log" TO "authenticated";
GRANT ALL ON TABLE "public"."debug_log" TO "service_role";



GRANT ALL ON TABLE "public"."kyc_attempt" TO "anon";
GRANT ALL ON TABLE "public"."kyc_attempt" TO "authenticated";
GRANT ALL ON TABLE "public"."kyc_attempt" TO "service_role";



GRANT ALL ON TABLE "public"."legal_entity" TO "anon";
GRANT ALL ON TABLE "public"."legal_entity" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_entity" TO "service_role";



GRANT ALL ON TABLE "public"."legal_entity_invitation" TO "anon";
GRANT ALL ON TABLE "public"."legal_entity_invitation" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_entity_invitation" TO "service_role";



GRANT ALL ON TABLE "public"."location" TO "anon";
GRANT ALL ON TABLE "public"."location" TO "authenticated";
GRANT ALL ON TABLE "public"."location" TO "service_role";



GRANT ALL ON TABLE "public"."otp" TO "anon";
GRANT ALL ON TABLE "public"."otp" TO "authenticated";
GRANT ALL ON TABLE "public"."otp" TO "service_role";



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
