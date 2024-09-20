#!/bin/bash
#
# NGinX Section
#

# Install nginx
sudo apt install -y epel-release
sudo apt install -y nginx

# Create the /var/www directory if it doesn't exist
sudo mkdir -p /var/www
sudo mkdir -p /var/www/App

# Create the Hello World HTML file
echo '<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
</head>
<body>
    <h1>Hello World!</h1>
</body>
</html>' |  sudo tee /var/www/index.html

sudo systemctl restart nginx

# Open HTTP port 80 in the firewall
sudo systemctl stop firewalld
sudo firewall-offline-cmd --zone=public --add-service=http
sudo firewall-offline-cmd --zone=public --add-service=https
sudo firewall-offline-cmd --zone=public --add-port=5000/tcp 
# firewall-cmd --reload
sudo systemctl start firewalld

#
# Dot Net Section
#

# Install the latest version of .NET on the instance
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
sudo chmod +x ./dotnet-install.sh
sudo ./dotnet-install.sh --version latest --install-dir /.dotnet
echo 'export DOTNET_ROOT=/.dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' >> ~/.bashrc

# Install the OCL-CLI
sudo apt yum install -y python3-oci-cli
# Download the application from your bucket
# oci os object get -bn install-files --name App.zip --file ./App.zip --auth instance_principal
unzip ./App.zip -d /var/www/App

# Create Kestral service for the asp.net application
echo '
[Unit]
Description=Example .NET Web API App running on Linux

[Service]
WorkingDirectory=/var/www/App
ExecStart=/.dotnet/dotnet /var/www/App/ociTestASPNET.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-example
User=opc
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_NOLOGO=true

[Install]
WantedBy=multi-user.target'  |  sudo tee /etc/systemd/system/aspnetTestApp.service

systemctl enable aspnetTestApp.service
systemctl start aspnetTestApp.service

# Configure nginx to serve /var/www directory
#bash -c 'cat > /etc/nginx/conf.d/default.conf <<EOF

mkdir -p /etc/nginx/sites-available

#bash -c 'cat > /etc/nginx/sites-available/aspnetTestApp.conf <<EOF
server {
    listen       80;
    server_name  _;
    location / {
        proxy_pass         http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection $connection_upgrade;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF'

ln -s /etc/nginx/sites-available/nginxdotnet /etc/nginx/sites-enabled/nginxdotnet

systemctl restart nginx





