artifact_name="${PACKAGE_NAME}_macos_${ARCHITECTURE}"
case $ARCHITECTURE in 
    arm) brew_prefix="/opt/homebrew" ;;
    intel) brew_prefix="/usr/local" ;;
esac    
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install $PACKAGE_NAME
real_version="v$(brew list --versions | grep -w $PACKAGE_NAME | cut -d ' ' -f 2)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"no check")$ ]]
then
    echo "Version passed via tag: $EXPECTED_VERSION not matching installed version: $real_version"
    exit 1
fi  
cp -r ${brew_prefix}/include/* ~/project/workspace/$artifact_name/include
cd "${brew_prefix}"/lib || exit 1
for f in *.dylib
do
    install_name_tool -id "@rpath/$f" $f
    otool -L $f | tail -n +3 | cut -d ' ' -f 1 | ( grep "^${brew_prefix}" || [ "$?" == "1" ] ) | while read -r line; do install_name_tool -change $line "@rpath/$(basename $line)" $f; done
    [[ $ARCHITECTURE == arm ]] && codesign --sign - --force --preserve-metadata=entitlements,requirements,flags,runtime $f
    cp -a "$(readlink $f)" ~/project/workspace/$artifact_name/lib
done
