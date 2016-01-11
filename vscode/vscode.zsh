# Opening VS Code from command line with code .
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
# vscode plugins for live linting
# ESLint - for JavaScript linting
# markdownhint - for markdown linting
# HTMLhint - for HTML linting
# Stylelint - Modern CSS/SCSS linting