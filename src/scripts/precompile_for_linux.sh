artifact_name="${PACKAGE_NAME}_linux"
# dependencies that shouldn't be installed here, because they should already be present on the target system
unwanted_deps=(alsa-lib openssl)
# install homebrew dependencies
apt-get update
apt-get install -y curl gcc git make g++ bzip2
# create directories for artifacts
mkdir -p ~/project/workspace/$artifact_name/include
mkdir -p ~/project/workspace/$artifact_name/lib
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
# remove unnecessary casks, since sometimes they can break things
caskroom=$(brew --caskroom)
rm -rf "${caskroom:?}"/*
# get the latest version of the package and check if it matches the version provided in the tag
real_version="v$(brew info $PACKAGE_NAME | tail -n +1 | head -1 | cut -d ' ' -f 4)"
if [[ ! $EXPECTED_VERSION =~ ^($real_version|"no check")$ ]]; then
  echo "Version passed via tag: $EXPECTED_VERSION not matching installed version: $real_version"
  exit 1
fi
# uninstall all packages that are already installed, since only the installed package
# and it's dependencies are needed
for pkg in $(brew list); do
  brew uninstall --ignore-dependencies --force $pkg
done
# install package
brew install $PACKAGE_NAME
# uninstall unwanted deps
for pkg in "${unwanted_deps[@]}"; do
  if brew list | grep -E "^${pkg}($|@)"; then
    brew uninstall --ignore-dependencies --force $pkg
  fi
done
# copy the artifacts
cp -Lr "$(brew --prefix)"/include/* ~/project/workspace/$artifact_name/include
cd "$(brew --prefix)"/lib || exit 1
for f in "$(brew --prefix)"/Cellar/*/*/lib/lib*.so*; do
  cp -a $f ~/project/workspace/$artifact_name/lib
done

