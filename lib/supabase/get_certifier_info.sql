-- Funzione per recuperare le informazioni del certificatore
-- Basata sulla query SQL fornita dall'utente
CREATE OR REPLACE FUNCTION get_certifier_info(certifier_id UUID)
RETURNS TABLE(
  cf_id_certifier UUID,
  cert_id UUID,
  id_certification_user UUID,
  user_id UUID,
  firstName TEXT,
  lastName TEXT
) 
LANGUAGE SQL
AS $$
  SELECT
    cf.id_certifier        AS cf_id_certifier,
    c.id_certification     AS cert_id,
    cu.id_certification_user,
    u."idUser"             AS user_id,
    u."firstName"          AS firstName,
    u."lastName"           AS lastName
  FROM public.certifier AS cf
  INNER JOIN public.certification AS c
    ON c.id_certifier = cf.id_certifier
  LEFT JOIN public.certification_user AS cu
    ON cu.id_certification = c.id_certification
  LEFT JOIN public."user" AS u
    ON u."idUser" = cu.id_user
  WHERE cf.id_certifier = certifier_id
  LIMIT 1;
$$;
