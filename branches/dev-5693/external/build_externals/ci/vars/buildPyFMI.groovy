def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, TARGET, bitness=["32", "64"], FMIL_HOME_BASE, stash=false, archive=true) {
    if (JM_CHECKOUT_PATH != null) {
        checkoutJM(${JM_BRANCH})
    }
    if (FMIL_HOME_BASE != null) {
        FMIL_HOME_BASE="${INSTALL_PATH}/fmil_install"
    }
    for (bit in bitness) {
        runMSYSWithEnv("""\
        export JM_HOME="\$(pwd)/JModelica/"
        JENKINS_BUILD_DIR="\$(pwd)/build
        cd \${SRC_HOME}/external/build_externals/build/pyfmi
        make ${TARGET} USER_CONFIG=${SRC_HOME}/external/build_externals/configurations/PyFMI/windows/win${bit} BUILD_DIR=${JENKINS_BUILD_DIR} FMIL_HOME=${FMIL_HOME_BASE}${bit} INSTALL_DIR_FOLDER=${INSTALL_PATH}/${TARGET}/Python_${bit}
        """);
        if (stash || archive) {
            dir("${INSTALL_PATH}/${TARGET}") {
                if (stash) {
                    stash includes: "Python_${bit}/**", name: "Python_${bit}_pyfmi_${TARGET}"
                }
                if (archive) {
                    archiveArtifact: "Python_${bit}/**"
                }
            }
        }
    }
}
