artifact_name="${PACKAGE_NAME}_macos_${ARCHITECTURE}"
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install $PACKAGE_NAME
real_version="v$(brew list --versions | grep -w $PACKAGE_NAME | cut -d ' ' -f 2)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"not a tag") ]]; then
    echo "Version passed via tag not matching installed version"
    exit 1
fi    
cp -r /usr/local/include/* ~/project/workspace/$artifact_name/include
cd /usr/local/lib || exit 1
for f in *.dylib; do
    install_name_tool -id "@rpath/$f" $f
    cp -a "$(readlink $f)" ~/project/workspace/$artifact_name/lib
done
