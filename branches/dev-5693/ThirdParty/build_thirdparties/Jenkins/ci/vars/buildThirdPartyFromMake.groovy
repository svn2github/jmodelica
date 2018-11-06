def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, module,bitness=["32", "64"], stash=false, archive=true) {
    if (JM_CHECKOUT_PATH != null) {
        checkoutJM(${JM_BRANCH})
    }
    INSTALL_PATH_UNIX=unixpath("${INSTALL_PATH}")
    for (bit in bitness) {
        stage ("${module} ${bit} bit") {
            runMSYSWithEnv("""\
            export JM_HOME="\$(pwd)/JModelica/"
            JENKINS_BUILD_DIR="\$(pwd)/build"
            cd \${JM_HOME}/ThirdParty/nuild_thirdparties/build/${module}
            make clean_install USER_CONFIG=\${JM_HOME}/ThirdParty/build_thirdparties/configurations/${module}/windows/win${bit} BUILD_DIR=\${JENKINS_BUILD_DIR} BLAS_INSTALL_DIR=${INSTALL_PATH_UNIX}/${module}_install${bit}
            """);
            if (stash || archive) {
                dir("${INSTALL_PATH}") {
                    if (stash) {
                        stash includes: "${module}_install${bit}/**", name: "${module}_install${bit}"
                    }
                    if (archive) {
                        archiveArtifacts artifacts: "${module}_install${bit}/**", fingerprint: false
                    }
                }
            }
        }
    }
}