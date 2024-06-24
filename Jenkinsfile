pipeline {
    agent {
        // 이 섹션은 Kubernetes 환경과 Jenkins 에이전트용 Pod 템플릿을 정의
        // python, docker, dind 컨테이너 존재
        // 'docker-daemon' 컨테이너는 Docker in Docker(DIND) 모드를 사용하여 도커 데몬을 실행
        // 'workspace-volume'와 'docker-socket' 볼륨은 컨테이너 간에 데이터를 공유하는 데 사용
        kubernetes {
            cloud 'team5-eks'
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              serviceAccountName: jenkins-admin
              containers:
              - name: python
                image: python:3.9-slim
                command:
                - sleep
                args:
                - 99d
                tty: true
                volumeMounts:
                - name: workspace-volume
                  mountPath: /home/jenkins/agent
              - name: docker
                image: docker
                command:
                - sleep
                args:
                - 99d
                tty: true
                volumeMounts:
                - name: workspace-volume
                  mountPath: /home/jenkins/agent
                - name: docker-socket
                  mountPath: /var/run
              - name: docker-daemon
                image: docker:dind
                securityContext:
                  privileged: true
                volumeMounts:
                - name: docker-socket
                  mountPath: /var/run
              volumes:
              - name: workspace-volume
                emptyDir: {}
              - name: docker-socket
                emptyDir: {}
            """
        }
    }

    environment {
        APP_NAME = "flask-app" // 애플리케이션 이름
        RELEASE = "1.0.0" // 릴리즈 버전
        DOCKER_USER = "ksi05298" // Docker Hub 사용자 이름
        DOCKERHUB_CREDENTIALS = credentials('pjt-dockerhubtoken') // Jenkins Credentials에 저장된 Docker Hub 자격증명 ID
        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}" // 이미지 이름
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}" // 이미지 태그
    }

    stages {
        stage("Checkout from SCM") { // 소스 코드 관리(SCM)에서 체크아웃 단계
            steps {
                script {
                    sh 'pwd'
                    sh 'ls -al'
                    sh 'ls -al test-python'
                    git credentialsId: 'pjt-githubtoken', // GitHub 자격증명 사용
                        url: 'https://github.com/ciscocloud03-team5/code-integration', // GitHub 리포지토리 URL
                        branch: 'ocr' // 브랜치 이름
                    sh 'ls -al'
                    sh 'ls -al test-python'
                }
            }
        }

        stage('Run Tests') { // 테스트 실행 단계
            steps {
                container('python') {
                    script {
                        dir('/home/jenkins/agent/workspace/test-python/test-python') { // 작업 디렉토리 설정
                            sh 'pwd'
                            sh 'ls -al'
                            sh '''
                            python -m venv venv
                            . venv/bin/activate
                            pip install -r requirements.txt
                            pytest
                            '''
                        }
                    }
                }
            }
        }

        stage('Build and Push Docker Image') { // Docker 이미지 빌드 및 푸시 단계
            steps {
                container('docker') {
                    script {
                        dir('/home/jenkins/agent/workspace/test-python/test-python') { // 작업 디렉토리 설정
                            sh 'docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_TAG} .' // Docker 이미지 빌드
                            sh 'docker build --no-cache -t ${IMAGE_NAME}:latest .' // Docker 이미지 빌드(latest 태그)
                            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin' // Docker 로그인
                            sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}' // Docker 이미지 푸시
                            sh 'docker push ${IMAGE_NAME}:latest' // Docker 이미지 푸시(latest 태그)
                        }
                    }
                }
            }
        }
    }
}
