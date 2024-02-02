pipeline {
    agent any
    parameters {
        booleanParam(name: "use_github", defaultValue: false, description: "use github repos")
        booleanParam(name: "publish", defaultValue: true, description: "publish new builds to gitea")
        booleanParam(name: "force_publish", defaultValue: false, description: "always publish succesful builds to gitea")
    }
    options {
        timestamps()
        ansiColor("xterm-256color")
        disableConcurrentBuilds()
        buildDiscarder(logRotator(daysToKeepStr: '30', numToKeepStr: '10', artifactNumToKeepStr: '1'))
    }
    environment {
        GITEA_URL = "git.sudo.is"
        GIT_CONFIG_PARAMETERS = "'color.ui=always' 'advice.detachedHead=false'"
        VALETUDO_USE_GITHUB = params.use_github.toString()
        VALETUDO_PUBLISH = params.publish.toString()
        VALETUDO_FORCE_PUBLISH = params.force_publish.toString()
        valetudo_MAIN_BRANCH = "master"
        FORCE_COLOR="1"
    }
    stages {
        stage('checkout') {
            steps {
                script {
                    env.GITEA_USER = sh(script: "echo $GIT_URL | cut -d'/' -f4", returnStdout: true).trim()

                    env.VALETUDO_GIT_URL = params.use_guithub ? "https://github.com/Hypfer" : "https://git.sudo.is/mirrors"
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
    }
    post {
        always {
            sh "env | grep --color=always VALETUDO"
        }
        success {
            archiveArtifacts(artifacts: "dist/*.tar.gz,dist/*.deb,dist/*.zip,dist/valetudo_version.txt,dist/sha256sums.txt", fingerprint: true)
            script {
                if (params.publish == true || params.force_publish == true) {
                    withCredentials([string(credentialsId: "gitea-user-${env.GITEA_USER}-full-token", variable: 'GITEA_SECRET')]) {
                        // sh ".pipeline/publish.sh"
                        echo "Not doing anything yet"
                    }

                    // sh "cp -v dist/valetudo_${env.VALETUDO_VERSION}_${env.VALETUDO_ARCH}.deb ${env.JENKINS_HOME}/artifacts"
                    // build(
                    //     job: "/utils/apt",
                    //     wait: true,
                    //     propagate: true,
                    //     parameters: [[
                    //         $class: 'StringParameterValue',
                    //         name: 'filename',
                    //         value: deb
                    //     ]]
                    // )
                }
            }
        }
        cleanup {
            cleanWs(deleteDirs: true, disableDeferredWipeout: true, notFailBuild: true)
            sh "docker container rm valetudo-build || true"
            sh "docker iamge rm valetudo-builder:${VALETUDO_VERSION} || true"
            sh "docker image rm valetudo:${VALETUDO_VERSION} || true"
            sh "docker image rm ${GITEA_URL}/${GITEA_USER}/valetudo:${VALETUDO_VERSION} || true"
            sh "docker image rm  ${GITEA_URL}/${GITEA_USER}/valetudo:latest || true"
        }
   }
}
