def call(PLATFORM, TARGET, USER_CONFIG, ARTIFACT_FILE="${WORKSPACE}/JModelica/artifacts_assimulo") {
    stage("Assimulo ${TARGET} ${PLATFORM}") {
        dir ('JModelica/external/build_externals/docker/src/components/Assimulo') {
            try{ 
                sh "make docker_assimulo_${TARGET} USER_CONFIG=${USER_CONFIG} ARTIFACT_FILE=${ARTIFACT_FILE}"
                dir("${WORKSPACE}/JModelica") {
                    artifact_list = sh returnStdout: true, script: "cat ${ARTIFACT_FILE}"
                    archiveArtifacts artifacts: artifact_list, fingerprint: false
                    sh "rm ${ARTIFACT_FILE}"
                }
            } finally {
                sh "make clean_in_docker USER_CONFIG=${USER_CONFIG}"
            }
        }
    }
}