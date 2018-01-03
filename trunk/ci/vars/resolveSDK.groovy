def call() {
    if (binding.hasVariable('SDK_HOME')) {
        return SDK_HOME
    } else {
        return 'C:\\JModelica.org-SDK-1.13\\'
    }
}