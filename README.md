# newspace-deploy
<img src="https://github.com/user-attachments/assets/04d415b7-b379-4a0b-9aba-ff1d3609db85" width="300" />

<br>
newspace-deploy 입니다.
<br>
해당 레포지토리에는 CI/CD에 필요한 Jenkinsfile과 무중단 배포 스크립트가 포함되어있습니다. 
<br>

## 📽️ CI/CD 배포 시연 영상
[https://youtu.be/yXdEaNA0_rc](https://youtu.be/yXdEaNA0_rc)

## 📍 프로젝트 설명
LG CNS AM Inspire Camp
<br>
미니프로젝트 2 - 9조

## 🛠️ 기술 스택

<img src="https://img.shields.io/badge/Spring%20Boot-6DB33F?style=for-the-badge&logo=SpringBoot&logoColor=white"> <img src="https://img.shields.io/badge/Spring%20Security-6DB33F?style=for-the-badge&logo=SpringSecurity&logoColor=white"> <img src="https://img.shields.io/badge/Gradle-02303A?style=for-the-badge&logo=Gradle&logoColor=white"> <img src="https://img.shields.io/badge/Spring%20Cloud-6DB33F?style=for-the-badge&logo=Spring&logoColor=white"> <img src="https://img.shields.io/badge/Spring%20AI-6DB33F?style=for-the-badge&logo=Spring&logoColor=white"> <img src="https://img.shields.io/badge/Spring%20WebFlux-6DB33F?style=for-the-badge&logo=SpringWebFlux&logoColor=white"> <img src="https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=MariaDB&logoColor=white"> <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=Docker&logoColor=white"> <img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white"> <img src="https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=Postman&logoColor=white"> <img src="https://img.shields.io/badge/Swagger-85EA2D?style=for-the-badge&logo=Swagger&logoColor=white"> <img src="https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=Notion&logoColor=white"> <img src="https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=NGINX&logoColor=white"> 

<br/>

## 📂 폴더 구조

```
.
├── Jenkinsfile_aws // AWS 백엔드 통합 프로젝트 CI/CD 파이프라인
├── Jenkinsfile_aws_reload // AWS 백엔드 프로젝트 재부팅
├── Jenkinsfile_frontend // AWS 프론트엔드 CI/CD 파이프라인
├── Jenkinsfile_legacy // 홈서버용 CI/CD 파이프라인
├── news-service
│   └── deploy.sh // 블루-그린 무중단 배포 스크립트 (뉴스 서비스)
├── notice-service
│   └── deploy.sh // 블루-그린 무중단 배포 스크립트 (알림 서비스)
└── user-service
    └── deploy.sh // 블루-그린 무중단 배포 스크립트 (유저 서비스)
```
<br/>

## 🏗️ 시스템 아키텍처
![image](https://www.notion.so/image/attachment%3A872366d9-198d-45e3-bba3-071f16620a81%3Aimage.png?table=block&id=1c75254c-d716-801e-aab6-d346d727e76b&spaceId=105e484e-4347-4f5c-8957-58e7ba82645b&width=2000&userId=66ebfac6-ec70-42fc-abe0-b6a4536eea1e&cache=v2)

## 📦 Github Repository
전체 : https://github.com/orgs/newspace-msa/repositories
<br>
frontend : https://github.com/newspace-msa/newspace-frontend
<br>
Config-Server : https://github.com/newspace-msa/newspace-config-service
<br>
Gateway : https://github.com/newspace-msa/newspace-gateway
<br>
Eureka : https://github.com/newspace-msa/newspace-eureka
<br>
User-Service : https://github.com/newspace-msa/newspace-user-service
<br>
Notice-Service : https://github.com/newspace-msa/newspace-notice-service
<br>
News-Service : https://github.com/newspace-msa/newspace-news-service

## 📚 Notion
https://www.notion.so/LG-CNS-2-9-1c35254cd71680b490c6f7d3a8a0b2e6


