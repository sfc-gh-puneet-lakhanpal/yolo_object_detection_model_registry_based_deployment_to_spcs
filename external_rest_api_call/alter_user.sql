use role securityadmin;

ALTER USER plakhanpal SET RSA_PUBLIC_KEY='X';

DESC USER plakhanpal;
SELECT SUBSTR((SELECT "value" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
  WHERE "property" = 'RSA_PUBLIC_KEY_FP'), LEN('SHA256:') + 1);

-- verify that above matches the result of the following:
--openssl rsa -pubin -in rsa_key.pub -outform DER | openssl dgst -sha256 -binary | openssl enc -base64