artifact_name="${PACKAGE_NAME}_macos_intel"
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install $PACKAGE_NAME
cp -r /usr/local/include/* ~/project/workspace/$artifact_name/include
for f in /usr/local/lib/*.dylib
do
    install_name_tool -id "@rpath/$(basename $f)" $f
    cp -a $(readlink $f) ~/project/workspace/$artifact_name/lib
done
