/* CI pipeline */
pipeline {
    environment {
    registry = "elitesolutionsit/fbreactapp"
    registryCredential = 'dockerhub_id'
    dockerImage = ''
    }

    agent any
    stages {
            stage('Cloning our Git') {
                steps {
                git 'https://github.com/ArerepadeBenagha/elite-buildRelease_fbreactapp.git'
                }
            }

            stage('Building image') {
                steps {
                    script {
                        dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    }
                }
            }

            stage('Push to Dockerhub') {
                steps {
                    script {
                        docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                        }
                    }
                }
            }

            // stage('Cleaning Up') {
            //     steps{
            //       sh "docker rmi --force $registry:$BUILD_NUMBER"
            //     }
            // }
            stage('Build app') {
                steps{
                //   sh "docker rmi --force $registry:$BUILD_NUMBER"
                  sh "docker run -itd -p 3000:3000 --rm $registry:$BUILD_NUMBER"
                }
            }
        }
    }