#!/bin/bash
#
# NGinX Section
#

# Install nginx
apt install -y epel-release
apt install -y nginx
apt install -y unzip
apt install -y firewalld

# Create the /var/www directory if it doesn't exist
mkdir -p /var/www
mkdir -p /var/www/App

systemctl restart nginx

# Open HTTP port 80 in the firewall
systemctl stop firewalld
firewall-offline-cmd --zone=public --add-service=http
firewall-offline-cmd --zone=public --add-service=https
firewall-offline-cmd --zone=public --add-port=5000/tcp 
# firewall-cmd --reload
systemctl start firewalld

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
apt install -y python3-oci-cli
# Download the application from your bucket
oci os object get -bn install-files --name App.zip --file ./App.zip --auth instance_principal
unzip ./App.zip -d /var/www/App

# Create Kestral service for the asp.net application
echo '
[Unit]
Description=Example .NET Web API App running on Linux

[Service]
WorkingDirectory=/var/www/App/
ExecStart=/.dotnet/dotnet /var/www/App/ociTestASPNET.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-example
User=ubuntu
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_NOLOGO=true

[Install]
WantedBy=multi-user.target' | tee /etc/systemd/system/aspnetTestApp.service

systemctl enable aspnetTestApp.service
systemctl start aspnetTestApp.service

# Configure nginx to serve /var/www directory
mkdir -p /etc/nginx/sites-available

echo '
server {
    listen       80;
    server_name  _;
    location / {
        proxy_pass         http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF' | tee /etc/nginx/sites-available/default

systemctl restart nginx





