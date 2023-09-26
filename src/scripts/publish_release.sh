apt update
cd /root/
apt install -y wget
wget https://github.com/tcnksm/ghr/releases/download/v0.16.0/ghr_v0.16.0_linux_amd64.tar.gz
tar -xf ghr_v0.16.0_linux_amd64.tar.gz
./ghr_v0.16.0_linux_amd64/ghr -t ${GITHUB_TOKEN} -u ${CIRCLE_PROJECT_USERNAME} -r ${CIRCLE_PROJECT_REPONAME} -c ${CIRCLE_SHA1} -delete ${VERSION} /root/artifacts/ 