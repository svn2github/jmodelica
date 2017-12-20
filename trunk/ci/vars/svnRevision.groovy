import java.util.regex.Pattern;

def call(path, sdk_home="C:\\JModelica.org-SDK-1.13\\") {
    print "Getting svn revision for path ${path}";
    def infoStr = bat returnStdout: true, script: """\
@echo off
set SDK_HOME="${sdk_home}"
%SDK_HOME%\\Subversion\\bin\\svn.exe info --xml "${path}"
""";
    def revPattern = new Pattern(/^\s+revision="([0-9]+)">$/, Pattern.MULTILINE);
    def m = revPattern.matcher(infoStr);
    m.find(); // Fail fast :D
    try {
        return Integer.parseInt(m.group(1));
    } catch (e) {
        print "Failed to get revision, output:"
        print infoStr;
        throw e;
    }
}
