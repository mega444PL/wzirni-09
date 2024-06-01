#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install apache2 php libapache2-mod-php mysql-server postfix openssh-server openvpn fail2ban -y

# Apache2

sudo mkdir -p /var/www/site1 /var/www/site2 /var/www/site3

echo "<html><body><h1>Site 1</h1></body></html>" | sudo tee /var/www/site1/index.html
echo "<html><body><h1>Site 2</h1></body></html>" | sudo tee /var/www/site2/index.html
echo "<html><body><h1>Site 3</h1></body></html>" | sudo tee /var/www/site3/index.html

for i in 1 2 3; do
    sudo bash -c "cat > /etc/apache2/sites-available/site${i}.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@site${i}.com
    ServerName site${i}.com
    ServerAlias www.site${i}.com
    DocumentRoot /var/www/site${i}
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"
    sudo a2ensite site${i}.conf
done

sudo systemctl reload apache2

# Restart
sudo systemctl restart apache2
sudo systemctl restart mysql
sudo systemctl restart postfix
sudo systemctl restart ssh
sudo systemctl restart openvpn

# Sprawdzenie statusu
sudo systemctl status apache2
sudo systemctl status mysql
sudo systemctl status postfix
sudo systemctl status ssh
sudo systemctl status openvpn