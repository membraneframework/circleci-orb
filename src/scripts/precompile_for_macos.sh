artifact_name="${PACKAGE_NAME}_macos_${ARCHITECTURE}"
case $ARCHITECTURE in 
    arm) brew_prefix="/opt/homebrew" ;;
    intel) brew_prefix="/usr/local" ;;
esac    
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
[[ "$(brew list)" == "" ]] || brew remove --force "$(brew list)" --ignore-dependencies
brew install $PACKAGE_NAME
real_version="v$(brew list --versions | grep -w $PACKAGE_NAME | cut -d ' ' -f 2)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"no check")$ ]]
then
    echo "Version passed via tag: $EXPECTED_VERSION not matching installed version: $real_version"
    exit 1
fi  
cp -r ${brew_prefix}/include/* ~/project/workspace/$artifact_name/include
cd "${brew_prefix}"/lib || exit 1
for l in *.dylib
do
    cp -a "$(readlink $l)" ~/project/workspace/$artifact_name/lib
    f=~/project/workspace/$artifact_name/lib/$l
    if [ ! -L $f ]
    then
        # Problem: libraries installed by brew have load commands in them that use absolute paths. 
        # This renders them unusable in any other location other than the one they were installed in.
        # Solution: 

        # update the LC_ID_DYLIB command of current library so that it's name is a relative path, 
        # not absolute, so that it can be located during linking
        install_name_tool -id "@rpath/$(basename $f)" $f
        # update LC_LOAD_DYLIB commands that refer to dependencies of current library that have been 
        # installed by brew so that their names are also relative paths, so that the dependencies can be located during linking
        otool -L $f | tail -n +3 | awk -F" " '{print $1}' | ( grep "^${brew_prefix}" || [ "$?" == "1" ] ) | while read -r line; do install_name_tool -change $line "@rpath/$(basename $line)" $f; done
        # if compiled on arm architecture then the libraries will be codesigned on `brew install`
        # and need to be resigned, because the previous changes invalidated the signature
        [[ $ARCHITECTURE == arm ]] && codesign --sign - --force --preserve-metadata=entitlements,requirements,flags,runtime $f
    fi
done
