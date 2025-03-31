#!/bin/bash
currentDir=$(pwd -P);
server_starting_wait_time=20
service_name="newspace-user-service"
new_service_color="none"

REMOTE_USER="ubuntu"
REMOTE_HOST="54.210.26.236"

source /root/.bashrc
# USER-SERVICE blue 인지 확인 
RUNNING_DEPLOY_COLOR=$USER_SERVICE_STATUS

chmod +x gradlew
./gradlew clean build -x test
docker buildx build --no-cache -t ${service_name}:latest .

#AWS 오류시 Jenkins 에서 aws configure를 수행했는지 확인
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 803691999553.dkr.ecr.us-east-1.amazonaws.com
docker tag newspace-user-service:latest 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-user-service:latest
docker push 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-user-service:latest

echo "RUNNING_DEPLOY_STATUS => ${RUNNING_DEPLOY_COLOR}"

if [ $RUNNING_DEPLOY_COLOR = "blue" ]
then
    #기존에 BLUE 가 실행되어 있어 도커 컴포즈 BLUE 실행 
ssh ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 803691999553.dkr.ecr.us-east-1.amazonaws.com
    docker pull 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-user-service:latest
    docker compose -f docker-compose-user-green.yml up -d --scale newspace-user-service-green=2
EOT
    new_service_color="green"
else
    #기존에 GREEN 가 실행되어 있어 도커 컴포즈 BLUE 실행 
ssh ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 803691999553.dkr.ecr.us-east-1.amazonaws.com
    docker pull 803691999553.dkr.ecr.us-east-1.amazonaws.com/mini-project-9/newspace-user-service:latest
    docker compose -f docker-compose-user-blue.yml up -d --scale newspace-user-service-blue=2
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
service_port=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "docker ps -a --filter \"name=${service_name}-${new_service_color}\" --format '{{.Ports}}' | sed 's/.*:\([0-9]*\)->.*/\1/' | head -n 1")
echo "Find Service Port => ${service_port}"
response=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "curl -s http://localhost:${service_port}/actuator/health")
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
    echo 'export USER_SERVICE_STATUS="green"' >> ~/.bashrc
    source /root/.bashrc
    
    echo "Shut down blue service..."
    #기존 BLUE를 내립니다. <Remote>
ssh ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    docker compose -f docker-compose-user-blue.yml down
EOT

else
    #Config 서버의 환경변수를 변경합니다. <Jenkins>
    echo 'export USER_SERVICE_STATUS="blue"' >> ~/.bashrc
    source /root/.bashrc

    echo "Shut down green service..."
    #기존 GREEN을 내립니다. <Remote>
ssh ${REMOTE_USER}@${REMOTE_HOST} /bin/bash << EOT
    docker compose -f docker-compose-user-green.yml down
EOT

fi