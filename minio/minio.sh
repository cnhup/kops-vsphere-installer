#!/bin/bash

docker run -d \
    --name minio \
    -p 9000:9000 \
    -v ${VCS_PATH}/minio/minio-data:/export \
    minio/minio server /export
echo "Wait till Minio service is up"
sleep 5
if [ $? -ne 0 ] || [ -z $(docker ps | awk '{print $NF}' | grep -w minio) ]; then
echo "Minio container is not running. Exit"
exit 1
fi
minioLog=$(docker logs minio 2> ${VCS_PATH}/minio/error.log)
re1="AccessKey: ([^ ]+) "
re2="SecretKey: ([^ ]+) "
re3="Region:([ ]+)([^ ]+)
"
if [[ $minioLog =~ $re1 ]]; then accessKey=${BASH_REMATCH[1]}; fi
if [[ $minioLog =~ $re2 ]]; then secretAccessKey=${BASH_REMATCH[1]}; fi
if [[ $minioLog =~ $re3 ]]; then region=${BASH_REMATCH[2]}; fi

${VCS_PATH}/minio/mc config host add myminio http://127.0.0.1:9000 $accessKey $secretAccessKey > ${VCS_PATH}/minio/minio.log
if [ $? -ne 0 ]; then
  echo "Failed to config host for Minio server"
  exit 1
fi
${VCS_PATH}/minio/mc mb myminio/vcs-state-store >> minio.log
if [ $? -ne 0 ]; then
  echo "Failed to create bucket vcs-state-store for Minio"
  exit 1
fi
echo "export KOPS_STATE_STORE=s3://vcs-state-store" >> ${VCS_PATH}/set_env
echo "export S3_ACCESS_KEY_ID=$accessKey" >> ${VCS_PATH}/set_env
echo "export S3_SECRET_ACCESS_KEY=$secretAccessKey" >> ${VCS_PATH}/set_env
echo "export S3_REGION=$region" >> ${VCS_PATH}/set_env
