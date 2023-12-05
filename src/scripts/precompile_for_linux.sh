artifact_name="${PACKAGE_NAME}_linux"
apt-get update
apt-get install -y curl gcc git make g++ bzip2
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
for pkg in $(brew list)
do
    brew uninstall --force $pkg --ignore-dependencies
done
brew install $PACKAGE_NAME
if [[ $PACKAGE_NAME == "portaudio" ]]
then
    brew uninstall alsa-lib openssl --force --ignore-dependencies
fi
real_version="v$(brew list --versions | grep -w $PACKAGE_NAME | cut -d ' ' -f 2)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"no check")$ ]]
then
    echo "Version passed via tag: $EXPECTED_VERSION not matching installed version: $real_version"
    exit 1
fi    
cp -Lr /home/linuxbrew/.linuxbrew/include/* ~/project/workspace/$artifact_name/include
cd /home/linuxbrew/.linuxbrew/lib || exit 1
for f in /home/linuxbrew/.linuxbrew/Cellar/*/*/lib/*.so*
do
    cp -a $f ~/project/workspace/$artifact_name/lib
done