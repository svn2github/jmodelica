def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, bitness=["32", "64"], stash=false, archive=true) {
    buildThirdPartyFromMake(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, "lapack", bitness=["32", "64"], stash, archive)
}