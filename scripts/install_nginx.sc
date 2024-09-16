#!/bin/bash

# Update system packages
sudo yum update -y

# Install nginx
sudo yum install -y epel-release
sudo yum install -y nginx

# Create the /var/www directory if it doesn't exist
sudo mkdir -p /var/www

# Create the Hello World HTML file
echo '<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
</head>
<body>
    <h1>Hello World!</h1>
</body>
</html>' | sudo tee /var/www/index.html

# Configure nginx to serve /var/www directory
sudo bash -c 'cat > /etc/nginx/conf.d/default.conf <<EOF
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
sudo systemctl start nginx
sudo systemctl enable nginx

# Open HTTP port 80 in the firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Print status messages
echo "nginx has been installed and configured."
echo "You can access the server at http://<YOUR_SERVER_IP>/"
