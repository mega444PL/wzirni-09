#!/bin/bash

# Wyłączenie źródła CD-ROM w pliku sources.list
sudo sed -i '/^deb cdrom:/s/^/#/' /etc/apt/sources.list

# Dodanie repozytoriów sieciowych (przykładowe dla Debian 12, Bookworm)
sudo tee /etc/apt/sources.list.d/bookworm.list <<EOF
deb http://deb.debian.org/debian/ bookworm main contrib non-free
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

# Aktualizacja listy pakietów
sudo apt update

# Instalacja wymaganych usług
sudo apt install apache2 php libapache2-mod-php mariadb-server postfix openssh-server openvpn fail2ban -y

# Konfiguracja Apache z trzema wirtualnymi hostami
sudo mkdir -p /var/www/site1 /var/www/site2 /var/www/site3

# Utworzenie plików index.html dla każdej witryny
echo "<html><body><h1>Site 1</h1></body></html>" | sudo tee /var/www/site1/index.html
echo "<html><body><h1>Site 2</h1></body></html>" | sudo tee /var/www/site2/index.html
echo "<html><body><h1>Site 3</h1></body></html>" | sudo tee /var/www/site3/index.html

# Konfiguracja wirtualnych hostów
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

# Przeładowanie Apache
sudo systemctl reload apache2

# Restart usług dla pewności
sudo systemctl restart apache2
sudo systemctl restart mysql
sudo systemctl restart postfix
sudo systemctl restart ssh
sudo systemctl restart openvpn

# Sprawdzenie statusu usług
sudo systemctl status apache2
sudo systemctl status mysql
sudo systemctl status postfix
sudo systemctl status ssh
sudo systemctl status openvpn
