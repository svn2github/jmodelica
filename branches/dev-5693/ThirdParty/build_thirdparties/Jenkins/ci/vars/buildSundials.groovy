def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, bitness=["32", "64"], stash=false, archive=true) {
    buildThirdPartyFromMake(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, "sundials", bitness=["32", "64"], stash, archive)
}