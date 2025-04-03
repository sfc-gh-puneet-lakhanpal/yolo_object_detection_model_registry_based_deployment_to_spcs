# Model registry based Yolo object deployment to SPCS

This repo shows how to deploy Yolo object detection model into SPCS via model registry deployment technique as documented here.https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/container


### Setup instructions
1. Run `setup.sql` to setup basic objects.
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