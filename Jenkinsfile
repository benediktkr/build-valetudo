pipeline {
    agent any
    parameters {
        booleanParam(name: "use_github", defaultValue: true, description: "use github repos")
        booleanParam(name: "BUILD_SNAPSHOT", defaultValue: false, description: "build current version at HEAD")
    }
    options {
        timestamps()
        ansiColor("xterm-256color")
        disableConcurrentBuilds()
        buildDiscarder(logRotator(daysToKeepStr: '30', numToKeepStr: '10', artifactNumToKeepStr: '1'))
    }
    triggers {
        cron('@weekly')
    }
    environment {
        GITEA_URL = "git.sudo.is"
        GIT_CONFIG_PARAMETERS = "'color.ui=always' 'advice.detachedHead=false'"
        VALETUDO_MAIN_BRANCH = "master"
        FORCE_COLOR="1"
    }
    stages {
        stage('checkout') {
            steps {
                script {
                    // used in post success
                    env.GITEA_USER = env.JOB_NAME.split('/')[0]
                    env.VALETUDO_GIT_URL = params.use_github ? "https://github.com/Hypfer" : "https://git.sudo.is/mirrors"
                    sh "env"

                    dir('Valetudo') {
                        git(url: env.VALETUDO_GIT_URL + "/Valetudo", branch: env.VALETUDO_MAIN_BRANCH)
                        sh("git fetch --tags")
                        env.VALETUDO_VERSION = sh(script: "../.pipeline/version.sh", returnStdout: true).trim()
                        sh "git checkout ${env.VALETUDO_VERSION}"
                    }
                    currentBuild.displayName += " - v${env.VALETUDO_VERSION}"
                    currentBuild.description = "Valetudo v${env.VALETUDO_VERSION}"
                    writeFile(file: "dist/valetudo_version.txt", text: env.VALETUDO_VERSION)
                }
                sh "ls --color=always -l"
            }
        }
        stage('build') {
            steps {
                sh ".pipeline/build.sh"
            }
        }
        stage('Checksums') {
            steps {
                sh ".pipeline/check-sha256sums.sh"
            }
        }
        stage('package') {
            steps {
                sh ".pipeline/package.sh"
            }
        }
    }
    post {
        always {
            sh "env | grep --color=always VALETUDO"
        }
        success {
            archiveArtifacts(artifacts: "dist/*", fingerprint: true)
            withCredentials([string(credentialsId: "gitea-user-${env.GITEA_USER}-full-token", variable: 'GITEA_SECRET')]) {
                sh ".pipeline/publish.sh"
            }
        }
        cleanup {
            sh ".pipeline/clean.sh"
            cleanWs(deleteDirs: true, disableDeferredWipeout: true, notFailBuild: true)
        }
   }
}
