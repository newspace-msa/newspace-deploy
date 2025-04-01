#!/bin/bash

echo "######################################"
echo "                                      "
echo "       NEWSPACE-NOTICE-SERVICE        "
echo "     Blue-Green 무중단 배포 스크립트     "
echo "                                      "
echo "######################################"

currentDir=$(pwd -P);
server_starting_wait_time=50
service_name="newspace-notice-service"
new_service_color="none"

REMOTE_USER="ubuntu"
REMOTE_HOST="54.210.46.170"

source /root/.bashrc
# NOTICE-SERVICE blue 인지 확인 
RUNNING_DEPLOY_COLOR=$NOTICE_SERVICE_STATUS

chmod +x ./gradlew
./gradlew clean build -x test
docker buildx build --no-cache -t ${service_name}:latest .

#AWS 오류시 Jenkins 에서 aws configure를 수행했는지 확인
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 803691999553.dkr.ecr.us-east-1.amazonaws.com
docker tag newspace-notice-service:latest 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-notice-service:latest
docker push 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-notice-service:latest

echo "RUNNING_DEPLOY_STATUS => ${RUNNING_DEPLOY_COLOR}"

if [ $RUNNING_DEPLOY_COLOR = "blue" ]
then
    #기존에 BLUE 가 실행되어 있어 도커 컴포즈 BLUE 실행 
ssh -i /var/jenkins_home/aws.pem ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 803691999553.dkr.ecr.us-east-1.amazonaws.com
    docker pull 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-notice-service:latest
    cd /deploy/ec2-domain/notice
    docker compose -f docker-compose-notice-green.yml up -d 
EOT
    new_service_color="green"
else
    #기존에 GREEN 가 실행되어 있어 도커 컴포즈 BLUE 실행 
ssh -i /var/jenkins_home/aws.pem ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 803691999553.dkr.ecr.us-east-1.amazonaws.com
    docker pull 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-notice-service:latest
    cd /deploy/ec2-domain/notice
    docker compose -f docker-compose-notice-blue.yml up -d 
EOT
    new_service_color="blue"
fi

for sec in $(eval echo {1..$server_starting_wait_time})
do
   echo Wait Server Starting.... $(expr ${server_starting_wait_time} + 1 - ${sec}) Seconds .....
   sleep 1;
done

#유저 서비스가 살아 있는지 확인 <Remote>
echo "Find New Service... => ${service_name}-${new_service_color}"
service_port=$(ssh -i /var/jenkins_home/aws.pem ${REMOTE_USER}@${REMOTE_HOST} "docker ps -a --filter \"name=${service_name}-${new_service_color}\" --format '{{.Ports}}' | sed 's/.*:\([0-9]*\)->.*/\1/' | head -n 1")
echo "Find Service Port => ${service_port}"
response=$(ssh -i /var/jenkins_home/aws.pem ${REMOTE_USER}@${REMOTE_HOST} "curl -s http://localhost:${service_port}/actuator/health")
echo "Response => ${response}"
up_count=$(echo $response | grep 'UP' | wc -l)

if [ $up_count -ge 1 ]
then # $up_count >= 1 ("UP" 문자열이 있는지 검증)
    echo ">> Health check 성공"
else
    echo ">> Health check의 응답을 알 수 없거나 혹은 status가 UP이 아닙니다."
    exit 1
fi

#구버전이 돌고있는게 blue 라면
if [ $RUNNING_DEPLOY_COLOR = "blue" ]
then
    #Config 서버의 환경변수를 변경합니다. <Jenkins>
    # echo 'export NOTICE_SERVICE_STATUS="green"' >> ~/.bashrc

    var_name="NOTICE_SERVICE_STATUS"
    new_value="green"
    # .bashrc 파일에서 변수 변경
    sed -i "s/^export $var_name=.*/export $var_name=\"$new_value\"/" ~/.bashrc
    source /root/.bashrc
    
    echo "Shut down blue service..."
    #기존 BLUE를 내립니다. <Remote>
ssh -i /var/jenkins_home/aws.pem ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    cd /deploy/ec2-domain/notice
    docker compose -f docker-compose-notice-blue.yml down
EOT

else
    #Config 서버의 환경변수를 변경합니다. <Jenkins>
    # echo 'export NOTICE_SERVICE_STATUS="blue"' >> ~/.bashrc

    var_name="NOTICE_SERVICE_STATUS"
    new_value="blue"
    # .bashrc 파일에서 변수 변경
    sed -i "s/^export $var_name=.*/export $var_name=\"$new_value\"/" ~/.bashrc

    source /root/.bashrc

    echo "Shut down green service..."
    #기존 GREEN을 내립니다. <Remote>
ssh -i /var/jenkins_home/aws.pem ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    cd /deploy/ec2-domain/notice
    docker compose -f docker-compose-notice-green.yml down
EOT

fi