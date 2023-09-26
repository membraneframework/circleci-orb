artifact_name="${PACKAGE_NAME}_linux"
apt-get update
apt-get install -y curl gcc git make g++ bzip2
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
brew install $PACKAGE_NAME
cp -Lr /home/linuxbrew/.linuxbrew/include/* ~/project/workspace/$artifact_name/include
cp -Lr /home/linuxbrew/.linuxbrew/lib/*.so.* ~/project/workspace/$artifact_name/lib