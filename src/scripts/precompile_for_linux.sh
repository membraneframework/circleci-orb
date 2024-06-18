artifact_name="${PACKAGE_NAME}_linux"
unwanted_deps=(alsa-lib openssl)
apt-get update
apt-get install -y curl gcc git make g++ bzip2
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
real_version="v$(brew info $PACKAGE_NAME | tail -n +1 | head -1 | cut -d ' ' -f 4)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"no check")$ ]]
then
    echo "Version passed via tag: $EXPECTED_VERSION not matching installed version: $real_version"
    exit 1
fi  
PATH="$(brew --prefix)/bin:$PATH"
export PATH
caskroom=$(brew --caskroom)
rm -f "${caskroom:?}"/*
for pkg in $(brew list)
do
    brew uninstall --ignore-dependencies --force $pkg
done
brew install $PACKAGE_NAME
for pkg in "${unwanted_deps[@]}"
do
    if brew list | grep -E "^${pkg}($|@)"
    then
        brew uninstall --ignore-dependencies --force $pkg
    fi
done
cp -Lr "$(brew --prefix)"/include/* ~/project/workspace/$artifact_name/include
cd "$(brew --prefix)"/lib || exit 1
for f in "$(brew --prefix)"/Cellar/*/*/lib/*.so*
do
    cp -a $f ~/project/workspace/$artifact_name/lib
done