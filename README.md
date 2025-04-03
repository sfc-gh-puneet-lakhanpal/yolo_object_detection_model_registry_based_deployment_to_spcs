# Model registry based Yolo object deployment to SPCS

This repo shows how to deploy Yolo object detection model into SPCS via model registry deployment technique as documented here.https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/container

Note that AWS Setup is not required. In this repo, I start with images sitting in S3 and use Storage integration and presigned urls to perform inferencing using model registry route. Note that presigned urls created on S3 expire in 1 hour, but presigned urls created on snowflake stage expire in 7 days. If images are put in snowflake stage rather than S3, AWS setup and Snowflake S3 integration setup can be ignored.


### Setup instructions
1. Perform AWS setup: Create S3 bucket in AWS and upload images from sample_images folder into S3 bucket. Also create iam policy and role as highlighted in `aws_setup` folder. 
1. Run `setup.sql` to setup basic objects. Then go back and update trust relationship for the IAM role. Full guidelines on how to setup S3 storage integration is here: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration
2. Import `Object Detection Yolo.ipynb` as a container based Snowflake notebook, select a warehouse and choose `object_detection_gpu_nv_s_cp` compute pool created in the above step. Use the external access integration `allow_all_integration`. Run the above notebook which will deploy the trained Yolo model into Model registry using SPCS.
3. The notebook above will show how to do batch inferencing. 
4. For REST API, get the REST API endpoint from the notebook above. Go to the folder `external_rest_api_call` by cding into it and then run the following statements on the terminal.
    ```
        openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
        openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
    ```
5. Now copy the key from rsa_key.pub and then run the following statements in snowflake.
    ```
    use role securityadmin;
    ALTER USER plakhanpal SET RSA_PUBLIC_KEY='X';
    ```
6. Now execute `Defect detection with JWT.ipynb` from outside Snowflake. This will get the JWT token and make the call to the REST API endpoint deployed on SPCS.