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
yum install -y epel-release
yum install -y nginx

# Create the /var/www directory if it doesn't exist
mkdir -p /var/www
mkdir -p /var/www/app
unzip ./App.zip -d /var/www/App


# Configure nginx to serve /var/www directory
bash -c 'cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /var/www;
        index  index.html;
    }

    # Additional configuration can go here
}
EOF'

# Start nginx service
systemctl start nginx
systemctl enable nginx

# Open HTTP port 80 in the firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Print status messages
echo "nginx has been installed and configured."
echo "You can access the server at http://<YOUR_SERVER_IP>/"




