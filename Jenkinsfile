pipeline {

    agent any

     environment {
            DOCKER_REPOSITORY = 'ascendcorp/hello-world'
            REPOSITORY = 'hello-world'
            TAGS = "latest"
            REPOSITORY_TAGS =" ${DOCKER_REPOSITORY}:${TAGS}"
            REGISTRY_CREDENTIAL = 'central_login_for_dockerhub'
            SERVER_DEPLOY_DEV = "centos@192.168.19.87"
            SERVER_DEPLOY_STG= "centos@192.168.19.93"
            SERVER_DEPLOY_UAT= "centos@192.168.19.102"
            EXPOSE_PORT= "8080"
            VAULT_ADDRESS="192.168.19.84"
            VAULT_PORT="8200"
            EXECUTE_USER=""
        }
    stages {
        stage('Poll scm') {
            steps {
                deleteDir()
                checkout scm
                    script {
//                         TAGS = getTag()
                        TAGS = "${checkout(scm).GIT_COMMIT}"
                    }
//                 final scmVars = checkout(scm)
//                 TAGS = "${checkout(scm).GIT_COMMIT}"
            }
        }
        stage('Clean and Compile Project') {
            steps {
                sh 'java -version'
                sh 'mvn clean'
                sh 'mvn compile'
            }
        }
        stage('Build JAR file') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Build Docker Images') {

//             docker.withRegistry("${ECRLink}", 'ecr:ap-southeast-2:helloworld-ecr'){
//                 docker.image("${ImageName}").push("${ImageTag}")
//             }
            steps {
                echo "${DOCKER_REPOSITORY}:${TAGS}"
//                 script {
//                    sh "docker build  -t ${DOCKER_REPOSITORY}:${TAGS}  -f Dockerfile ."
//                    sh 'docker images'
//                 }
                script {
                    dir("${env.WORKSPACE}"){
                        docker.build("${DOCKER_REPOSITORY}:${TAGS}")
                    }
                }
//                 dir("${env.WORKSPACE}"){
//                     docker.build("${DOCKER_REPOSITORY}:${TAGS}")
//                 }
            }
        }
        stage('Push Docker Image') {
            steps{
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                         docker.withRegistry( '', REGISTRY_CREDENTIAL ){
                            sh "docker push ${DOCKER_REPOSITORY}:${TAGS}"
                         }
                    }
                }
            }
        }
    }
}

