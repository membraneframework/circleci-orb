package_name=$1
artifact_name="${package_name}_macos_intel"
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install portaudio
cp -r /usr/local/include/* ~/project/workspace/$artifact_name/include
cp -r /usr/local/lib/*.dylib ~/project/workspace/$artifact_name/lib
cd ~/project/workspace/$artifact_name/lib
for f in *.dylib;
do
    install_name_tool -id "@rpath/$f" $f
done
