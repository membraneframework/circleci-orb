package_name=$1
artifact_name="${package_name}_linux"
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
brew install $package_name
cp -Lr /home/linuxbrew/.linuxbrew/include/* ~/project/workspace/$artifact_name/include
cp -Lr /home/linuxbrew/.linuxbrew/lib/*.so.* ~/project/workspace/$artifact_name/lib