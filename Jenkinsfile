#!/usr/bin/env groovy

def INPUT_PARAMS = null

def GET_NAMEPSPACE = null

pipeline {
    environment {
        APP_NAME = "cb-attendance"
        GIT_COMMIT_ID = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        IMAGE_BUILD_TAG = "$BRANCH_NAME-$GIT_COMMIT_ID"
        IMAGE_PUSH_TAG = "$IMAGE_BUILD_TAG"
  }
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1 
            kind: Pod 
            metadata: 
              name: dind 
            spec: 
              containers: 
              - name: dind-daemon 
                image: docker:dind 
                resources: 
                  requests: 
                    cpu: 20m 
                    memory: 512Mi 
                securityContext: 
                  privileged: true 
                volumeMounts: 
                - name: docker-graph-storage 
                  mountPath: /var/lib/docker 
              volumes: 
              - name: docker-graph-storage 
                emptyDir: {}
            '''
        }
    }
    stages {
        stage('Build & Push Image') {
            when{
                branch 'main'
            }
            steps {
                container('dind-daemon') {
                    
                    script {
                        def vars = checkout scm
                        vars.each { k,v -> env.setProperty(k, v) }
                        GET_NAMESPACE = input message: 'Proceed to Build & Push Image?', ok: 'Build Image!',
                            parameters: [choice(name: 'namespace', choices: 'dev\nqa', description: 'Please select the environment!')]
                    }
                    
                    dockerBuildAndPushtoRegistry "${GET_NAMESPACE}/${APP_NAME}", [IMAGE_PUSH_TAG]
                    
                    script {
                        INPUT_PARAMS = input message: 'Proceed to Deploy?', ok: 'Deploy!',
                            parameters: [choice(name: 'namespace', choices: 'dev\nqa', description: 'Which environment to deploy?'), string(name: 'dockerImageTag', defaultValue: "${IMAGE_BUILD_TAG}", description: 'Which Image to deploy?')]  
                    }
                    
                    sh 'apk update'
                    sh 'apk add --no-cache bash'
                    
                    sh 'apk add curl'
                    sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl'
                    sh 'chmod +x ./kubectl'
                    sh 'mv ./kubectl /usr/local/bin/kubectl'
                    sh 'kubectl version --client'
                    sh("sed -i 's,INPUT_PARAMS,registrycoffeebeans.azurecr.io/${INPUT_PARAMS.namespace}/${APP_NAME}:${INPUT_PARAMS.dockerImageTag},' ./manifest/${INPUT_PARAMS.namespace}-deployment.yaml")
                    
                    withKubeConfig([credentialsId: 'kubefile', serverUrl: 'https://cb-69f63dae.hcp.centralindia.azmk8s.io:443']) {
                        sh "kubectl apply -f ./manifest/${INPUT_PARAMS.namespace}-deployment.yaml"
                    }
                }
            }
        }
    }
}


def dockerBuildAndPushtoRegistry(
        String image,
        tags = [],
        dockerfile = 'Dockerfile',
        context = '.') {

  def dockerRoot = "registrycoffeebeans.azurecr.io/"
  def imageName = image.startsWith(dockerRoot) ? image : dockerRoot + image

  def buildArgs = tags.collect { "-t $imageName:$it" }.join(" ")



  withCredentials([usernamePassword(credentialsId: 'acr-token', usernameVariable: 'username', passwordVariable: 'password')]) {
    sh 'docker login -u ${username} -p ${password} registrycoffeebeans.azurecr.io'
    sh "docker build -f $dockerfile $buildArgs $context"
    tags.each {
      sh "docker push $imageName:$it"
    }
  }
}
