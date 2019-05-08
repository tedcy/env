set -x
set -e

cd /root
wget https://studygolang.com/dl/golang/go1.12.5.linux-amd64.tar.gz
tar xvf go1.12.5.linux-amd64.tar.gz
mkdir gopath
echo "export GOROOT=/root/go
export GOPATH=/root/gopath
export PATH=\$PATH:\$GOPATH/bin:\$GOROOT/bin" >> ~/.bashrc
rm -rf go1.12.5.linux-amd64.tar.gz
cd -
