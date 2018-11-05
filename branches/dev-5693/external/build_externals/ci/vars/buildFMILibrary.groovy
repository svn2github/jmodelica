def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, bitness=["32", "64"], stash=false, archive=true) {
    if (! JM_CHECKOUT_PATH) {
        checkoutJM(${JM_BRANCH})
    }
    for (bit in bitness) {
        runMSYSWithEnv("""\
        export JM_HOME="\$(pwd)/JModelica/"
        JENKINS_BUILD_DIR="\$(pwd)/build
        cd \${SRC_HOME}/external/build_externals/build/fmil
        make install USER_CONFIG=${SRC_HOME}/external/build_externals/configurations/FMILibrary/windows/win${bit} BUILD_DIR=${JENKINS_BUILD_DIR} FMIL_HOME=${INSTALL_PATH}/fmil_install${bit}
        """);
        if (stash || archive) {
            dir("${INSTALL_PATH}") {
                if (stash) {
                    stash includes: "fmil_install${bit}/**", name: "fmil_install${bit}"
                }
                if (archive) {
                    archiveArtifact: "fmil_install${bit}/**"
                }
            }
        }
    }
}