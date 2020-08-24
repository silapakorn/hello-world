pipeline {

    agent any

     environment {
            DOCKER_REPOSITORY = 'ascendcorp/hello-world'
            REPOSITORY = 'hello-world'
            TAGS = "latest"
            REPOSITORY_TAGS = " ${DOCKER_REPOSITORY}:${TAGS}"
            REGISTRY_CREDENTIAL = 'central_login_for_dockerhub'
            CHART_REPO_URL = "http://35.184.252.55/chartrepo"
            CHART_REPO_NAME = "developers-private-project"
            NAMESPACE = "supplier-connect-dev"
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
                    TAGS = "${checkout(scm).GIT_COMMIT}"
                }
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
                dir("${env.WORKSPACE}"){
                    docker.build("${REPOSITORY}:latest")
                }
            }
        }
        stage('Push Docker Image') {
            steps{
                echo ' push docker image'
//                 script {
//                     catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
//                          docker.withRegistry( '', REGISTRY_CREDENTIAL ){
//                             sh "docker push ${DOCKER_REPOSITORY}:${TAGS}"
//                          }
//                     }
//                 }
            }
        }

        stage('Deploy kubernetes') {
            steps{
                withCredentials([kubeconfigFile(credentialsId: 'kubeconfig_dev', variable: 'KUBECONFIG')]) {
                    sh 'ls -l /usr/share/jenkins/'
                    sh '''
                        helm repo add ${CHART_REPO_NAME} \
                        --ca-file=/usr/share/jenkins/ca.crt \
                        --username=admin \
                        --password=admin ${CHART_REPO_URL}/${CHART_REPO_NAME}
                    '''
                    sh 'helm repo update'
                    sh '''
                        helm install ${REPOSITORY} \
                        ${CHART_REPO_NAME}/${REPOSITORY} \
                        --ca-file=ca.crt -n ${NAMESPACE} \
                        || exit 0
                    '''
                    sh '''
                        helm upgrade ${REPOSITORY} --wait --recreate-pods \
                        ${CHART_REPO_NAME}/${REPOSITORY} \
                        --ca-file=ca.crt -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}

