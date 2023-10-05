artifact_name="${PACKAGE_NAME}_linux"
apt-get update
apt-get install -y curl gcc git make g++ bzip2
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
brew install $PACKAGE_NAME
real_version="v$(brew list --versions | grep -w $PACKAGE_NAME | cut -d ' ' -f 2)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"no check")$ ]]
then
    echo "Version passed via tag: $(EXPECTED_VERSION) not matching installed version: $($real_version)"
    exit 1
fi    
cp -Lr /home/linuxbrew/.linuxbrew/include/* ~/project/workspace/$artifact_name/include
cd /home/linuxbrew/.linuxbrew/lib || exit 1
for f in *.so*
do
    cp -a "$(readlink $f)" ~/project/workspace/$artifact_name/lib
done