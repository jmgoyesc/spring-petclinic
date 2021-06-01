pipeline {
    agent any
    tools {
        maven "maven-3.6.3"
    }
    environment {
        registryCredential = 'docker-login'
        MAVEN_OPTS = '-Xmx8g -Xms1024m -Djava.awt.headless=true'
    }
  
    stages {

        stage("test") {
            steps {
                echo "building application"
                sh 'printenv'
                sh 'mvn test'
            }
        }

        stage('build-jvm | quality-checks') {
            environment {
                scannerHome = tool 'sonarqube-scanner'
            }
            steps {
                withSonarQubeEnv('minikube-sonarqube') {
                    sh 'mvn package -DskipTests'
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=spring-petclinic  -Dsonar.sources=. -Dsonar.java.binaries=target/classes"
                }
                sh 'mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)'
            }
        }
    
        stage("build-image") {
            steps {
                echo "creating image"
                script {
                    docker.withTool('docker-exec') {
                        image = docker.build("jmgoyesc/juan-goyes-petclinic:${BUILD_NUMBER}", "-f ./src/docker/Dockerfile .")
                        docker.withRegistry( '', registryCredential ) {
                            image.push("${BUILD_NUMBER}")
                        }
                    }
                }
            }
        }

        stage("deploy") {
            steps {
                echo "deploying application"
                withKubeConfig([credentialsId: 'minikube-config-file']) {
                    sh "curl -LO https://dl.k8s.io/release/v1.21.1/bin/linux/amd64/kubectl"
                    sh "chmod +x ./kubectl"
                    sh './kubectl set image deployments/petclinic petclinic=jmgoyesc/juan-goyes-petclinic:${BUILD_NUMBER} --record'
                }
            }
        }
    
    }

    post {
        always {
            echo 'Cleaning sonar to about check-style issues'
            sh 'rm -rf .scannerwork'
            sh 'rm -rf kubectl'
        }
    }
  
}
