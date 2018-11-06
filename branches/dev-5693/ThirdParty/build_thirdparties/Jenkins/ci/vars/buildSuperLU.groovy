def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, bitness=["32", "64"], stash=false, archive=true) {
    buildThirdPartyFromMake(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, "superlu", bitness=["32", "64"], stash, archive)
}