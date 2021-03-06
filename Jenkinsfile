pipeline {
    agent any
    environment {
        DOCKER_REPOSITORY = 'ascendcorp/hello-world'
        REPOSITORY = 'hello-world'
        TAGS = "latest"
        REPOSITORY_TAGS = " ${DOCKER_REPOSITORY}:${TAGS}"
        REGISTRY_CREDENTIAL = 'login_for_nexus_repository_docker'
        CHART_REPO_URL = "http://35.184.252.55/chartrepo"
        CHART_REPO_NAME = "developers-private-project"
        NAMESPACE = "supplier-connect-dev"
        EXPOSE_PORT= "8080"
        VAULT_ADDRESS="192.168.19.84"
        VAULT_PORT="8200"
        EXECUTE_USER=""
        TAGS2 = "latest2"
    }
    stages {
        stage('Poll scm') {
            steps {
                deleteDir()
                checkout scm
                script {
                    TAGS = "${checkout(scm).GIT_COMMIT}"
                    TAGS2 = "${checkout(scm).GIT_COMMIT}"
                }
            }
        }
        stage('Clean and Compile Project') {
            steps {
                sh 'java -version'
                sh "mvn -v"
                sh 'mvn clean'
                sh "mvn compile"
            }
        }
        stage('Build JAR file') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Build Docker Images') {
            steps {
                echo "${DOCKER_REPOSITORY}:${TAGS}"
                dir("${env.WORKSPACE}"){
                    script {
                        docker.build("${DOCKER_REPOSITORY}:latest")
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps{
                echo ' push docker image'
                script {
                    docker.withRegistry('http://192.168.19.15:8082', REGISTRY_CREDENTIAL){
                        docker.image("${DOCKER_REPOSITORY}").push("${TAGS}")
                    }
                }
            }
        }

        stage('Deploy kubernetes') {
            steps{
                withCredentials([kubeconfigFile(credentialsId: 'kubeconfig_dev', variable: 'KUBECONFIG')]) {
                    sh """
                        helm repo add ${CHART_REPO_NAME} \
                        --ca-file=/usr/share/jenkins/ca.crt \
                        --username=admin \
                        --password=admin ${CHART_REPO_URL}/${CHART_REPO_NAME}
                    """
                    sh 'helm repo update'
                    sh """
                        helm install ${REPOSITORY} \
                        ${CHART_REPO_NAME}/${REPOSITORY} \
                        --ca-file=/usr/share/jenkins/ca.crt -n ${NAMESPACE} \
                        --set image.tag=${TAGS} \
                        || exit 0
                    """
                    sh """
                        helm upgrade ${REPOSITORY} --wait --recreate-pods \
                        ${CHART_REPO_NAME}/${REPOSITORY} \
                        --ca-file=ca.crt -n ${NAMESPACE} \
                        --set image.tag=${TAGS}
                    """
                }
            }
        }
    }
}

