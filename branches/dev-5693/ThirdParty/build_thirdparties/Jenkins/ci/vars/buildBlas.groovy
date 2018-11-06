def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, bitness=["32", "64"], stash=false, archive=true) {
    if (JM_CHECKOUT_PATH != null) {
        checkoutJM(${JM_BRANCH})
    }
    INSTALL_PATH_UNIX=unixpath("${INSTALL_PATH}")
    for (bit in bitness) {
        stage ("Blas ${bit} bit") {
            runMSYSWithEnv("""\
            export JM_HOME="\$(pwd)/JModelica/"
            JENKINS_BUILD_DIR="\$(pwd)/build"
            cd \${JM_HOME}/ThirdParty/nuild_thirdparties/build/blas
            make clean_install USER_CONFIG=\${JM_HOME}/ThirdParty/build_thirdparties/configurations/blas/windows/win${bit} BUILD_DIR=\${JENKINS_BUILD_DIR} BLAS_INSTALL_DIR=${INSTALL_PATH_UNIX}/blas_install${bit}
            """);
            if (stash || archive) {
                dir("${INSTALL_PATH}") {
                    if (stash) {
                        stash includes: "blas_install${bit}/**", name: "blas_install${bit}"
                    }
                    if (archive) {
                        archiveArtifacts artifacts: "blas_install${bit}/**", fingerprint: false
                    }
                }
            }
        }
    }
}