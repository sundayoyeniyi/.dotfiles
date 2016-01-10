# Opening VS Code from command line with code .
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}