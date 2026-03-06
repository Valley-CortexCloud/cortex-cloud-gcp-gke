version=1.6.41
fileName="signalbench-$version-linux-musl-x86_64"

wget https://github.com/gocortexio/signalbench/releases/download/v$version/$fileName
sudo chmod +x $fileName
sudo mv $fileName /usr/local/bin/signalbench

categories=$(signalbench list | grep "CATEGORY" | cut -d ' ' -f 2- | xargs)

signalbench category $categories