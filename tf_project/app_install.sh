#! /bin/bash

# Install the latest version of .NET on the instance
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest --install-dir /.dotnet
echo 'export DOTNET_ROOT=/.dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' >> ~/.bashrc

# Install the OCL-CLI
yum install -y python3-oci-cli
# Download the application from your bucket
oci os object get -bn install-files --name App.zip --file ./App.zip
# Install nginx
yum install -y nginx
service nginx start
# Set up the website directory
mkdir /var/www
mkdir /var/www/App
unzip ./App.zip -d /var/www/App

firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --reload

