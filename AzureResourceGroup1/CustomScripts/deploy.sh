!/bin/sh

apt-get update
apt-get install git -y

cd /usr/local/

ip=`curl ifconfig.me`
# clone the code
git clone https://vaibhav-eleven:Eleven12345@github.com/eleven01team/e01_deployment-scripts.git
cd e01_deployment-scripts
git clone https://vaibhav-eleven:Eleven12345@github.com/eleven01team/e01_nodemanagement.git

# run bootstrap
./bootstrap.sh

# install tessera
wget -q https://github.com/jpmorganchase/tessera/releases/download/tessera-0.6/tessera-app-0.6-app.jar
sudo cp ./tessera-app-0.6-app.jar ${PWD}/tessera/tessera.jar
echo "export  TESSERA_JAR=${PWD}/tessera/tessera.jar" >> /root/.profile
echo "export TESSERA_JAR=${PWD}/tessera/tessera.jar" >> /root/.bashrc
export TESSERA_JAR=${PWD}"/tessera/tessera.jar"
source /root/.profile
source /root/.bashrc

# install golang
GOREL=go1.9.7.linux-amd64.tar.gz
wget -q https://dl.google.com/go/$GOREL
tar xfz $GOREL
sudo mv go /usr/local/go
rm -f $GOREL
PATH=$PATH:/usr/local/go/bin
echo 'PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc
echo "export GOPATH=${PWD}/testnet/build/_workspace" >> /root/.bashrc
export GOPATH=${PWD}/testnet/build/_workspace
source /root/.profile
source /root/.bashrc

echo "======================================================"
echo $(pwd)
echo `cat /root/.bashrc`
echo "======================================================"
source /root/.bashrc
echo `go version`

# make/install testnet
git clone https://vaibhav-eleven:Eleven12345@github.com/eleven01team/testnet.git
cd testnet
git checkout develop
/usr/local/go/bin/go get github.com/urfave/cli
sed -i 's/ChainId/ChainID/g' build/_workspace/src/genesis/genesis.go
make all
sudo cp build/bin/geth /usr/local/bin
sudo cp build/bin/bootnode /usr/local/bin
sudo cp build/bin/ibftUtils /usr/local/bin
cd ../

# install Porosity
wget -q https://github.com/jpmorganchase/quorum/releases/download/v1.2.0/porosity
sudo mv porosity /usr/local/bin && chmod 0755 /usr/local/bin/porosity
#./bootstrap2.sh
#./install_go.sh
		#./install_pro.sh
		#./install_testnet.sh
./install_mongo.sh
sed -i s/localhost/$ip/g setting.sh

cd e01_nodemanagement
git checkout develop
nohup python app.py &

cd database
nohup python DBServer.py &
cd ../../

cd apicontainer
sed -i s/localhost/$ip/g setting.py
nohup python app.py &
cd ../

./setup.sh --c raft --a y --N 1 --nn TestNet --ip $ip --o 1 --nt n --n node1 --pw password12345 --r 22000 --w 22001 --t 22003 --dt 22004 --raft 22005 --ws 22006

cp errout erroutput
> errout