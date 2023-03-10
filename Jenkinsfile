pipeline {
    agent any
    environment {
        registry = 'deekshithy/pipeline'
        registryCredential = 'dockerhub_id'
        // dockerSwarmManager = ''
        // dockerhost = ''
        dockerImage = ''
        PACKER_BUILD = 'NO'
    }
    tools {
        maven 'Maven3'
    }
    stages {
        // stage('git checkout') {
        //     steps {
        //         checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/boxfuse/boxfuse-sample-java-war-hello.git']])
        //     }
        // }
        stage('Maven build') {
            steps {
                //sh 'mvn clean install -f Mywebapps/pom.xml'
                sh 'mvn clean install -f pom.xml'
                sh 'mv target/*.war target/hello-${BUILD_NUMBER}.war' 
            }
        }
        stage('Unit Test') {
            steps {
                echo '<--------------- Unit Testing started  --------------->'
                sh 'mvn surefire-report:report'
                echo '<------------- Unit Testing stopped  --------------->'
            }
        }
        stage('Nexus artifact upload') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'hello', classifier: '', file: 'target/hello-${BUILD_NUMBER}.war', type: 'war']], credentialsId: 'nexus', groupId: 'com.boxfuse.samples', nexusUrl: 'ec2-54-226-148-204.compute-1.amazonaws.com:8081/', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOT'
            }
        }
        stage('s3 artifact upload') {
            steps {
                sh 'aws s3 ls'
                s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'dees3devops', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'us-east-1', showDirectlyInBrowser: false, sourceFile: 'target/*.war', storageClass: 'STANDARD_IA', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 's3-profile-role', userMetadata: []
            }
        }
        stage('code quality') {
            steps {
                withSonarQubeEnv('SonarQube') { 
                    sh 'mvn sonar:sonar -f pom.xml'
                }
            }
        }
        // stage("Quality Gate") {
        //     steps {
        //         script {
        //           echo '<--------------- Sonar Gate Analysis Started --------------->'
        //             timeout(time: 1, unit: 'HOURS'){
        //                def qg = waitForQualityGate()
        //                 if(qg.status !='OK') {
        //                     error "Pipeline failed due to quality gate failures: ${qg.status}"
        //                 }
        //             }  
        //           echo '<--------------- Sonar Gate Analysis Ends  --------------->'
        //         }
        //     }
        // }
        stage('Building docker image') {
            steps{
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    }
                }
        }
        stage('Push docker image') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                    dockerImage.push()
                    }
                }
            }
        }
        stage('Performing packer build') {
            when {
                expression {
                    env.PACKER_BUILD == 'YES'
                }
            }
            steps{
                sh 'packer build -var-file packer-vars.json packer.json | tee output.txt'
                sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                sh "echo \$(cat ami.txt) > ami.txt"
                script{
                    def AMIID = readFile('ami.txt').trim()
                    sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                }
            }
        }
        stage('Default packer ami') {
            when {
                expression {
                    env.PACKER_BUILD == 'NO'
                }
            }
            steps{
                script{
                    def AMIID = 'ami-0e3031cfde1489854'
                    sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                }
            }
        }
    }
}