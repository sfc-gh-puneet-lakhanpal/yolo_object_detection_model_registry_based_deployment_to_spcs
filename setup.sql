create database if not exists X;
use database X;
create schema if not exists Y;
use schema Y;
CREATE COMPUTE POOL object_detection_gpu_nv_s_cp
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = GPU_NV_S
  AUTO_RESUME = TRUE
  AUTO_SUSPEND_SECS = 300;
show services in compute pool object_detection_gpu_nv_s_cp;
alter compute pool object_detection_gpu_nv_s_cp stop all;

use role accountadmin;
CREATE STORAGE INTEGRATION modelregistrytospcsyolo_s3int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::MYACCOUNT:role/MYROLE'
  STORAGE_ALLOWED_LOCATIONS = ('s3://MYS3BUCKET/');

DESC INTEGRATION modelregistrytospcsyolo_s3int;

GRANT USAGE ON INTEGRATION modelregistrytospcsyolo_s3int TO ROLE sysadmin;

use role sysadmin;

CREATE or replace STAGE modelregistrytospcsyolo_s3stage
  STORAGE_INTEGRATION = modelregistrytospcsyolo_s3int
  URL = 's3://MYS3BUCKET/'
  DIRECTORY = ( ENABLE = true );

alter stage modelregistrytospcsyolo_s3stage refresh;
ls @modelregistrytospcsyolo_s3stage;

select * from directory(@modelregistrytospcsyolo_s3stage);

create or replace view modelregistrytospcsyolo_presignedurls as
SELECT
   relative_path,
   last_modified,
   get_presigned_url(@modelregistrytospcsyolo_s3stage, relative_path) AS presigned_url
  FROM
    directory(@modelregistrytospcsyolo_s3stage);

select * from modelregistrytospcsyolo_presignedurls;

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE NETWORK RULE nr_allow_s3_access_to_download_images
MODE= 'EGRESS'
TYPE = 'HOST_PORT'
VALUE_LIST = ('mys3bucket.s3.us-west-2.amazonaws.com');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION eai_allow_s3_access_to_download_images
ALLOWED_NETWORK_RULES = (nr_allow_s3_access_to_download_images)
ENABLED = true;

GRANT USAGE ON INTEGRATION eai_allow_s3_access_to_download_images TO ROLE SYSADMIN;

use role sysadmin;

