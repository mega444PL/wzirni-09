#!/bin/bash

# Aktualizacja systemu
sudo apt update && sudo apt upgrade -y

# Instalacja Lynis
sudo apt install lynis -y

# Przeprowadzenie wstępnego skanowania Lynis
sudo lynis audit system --report-file /var/log/lynis-pre-hardening.log

# Konfiguracja retencji danych i logów (CIS 4.1.1)
sudo bash -c "cat > /etc/logrotate.d/syslog <<EOF
/var/log/syslog
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        reload rsyslog >/dev/null 2>&1 || true
    endscript
}
EOF"

# Konfiguracja Firewall dla IPv4 (CIS 3.5.1)
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Wyłączenie nieużywanych systemów plików (CIS 1.1.1)
sudo bash -c "cat > /etc/modprobe.d/CIS.conf <<EOF
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
EOF"

# Ustawienia użytkowników i grup (CIS 6.2)
sudo useradd -D -f 30
sudo passwd -l root

# Parametry sieciowe (host i router) (CIS 3.2)
sudo bash -c "cat > /etc/sysctl.d/99-sysctl.conf <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
EOF"
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf

# Konfiguracja serwera SSH (CIS 5.2)
sudo bash -c "cat >> /etc/ssh/sshd_config <<EOF
Protocol 2
LogLevel INFO
PermitRootLogin no
MaxAuthTries 4
IgnoreRhosts yes
HostbasedAuthentication no
PermitEmptyPasswords no
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
AllowUsers your_user
EOF"
sudo systemctl reload sshd

# Konfiguracja Firewall dla IPv6 (CIS 3.5.2)
sudo bash -c "cat > /etc/ufw/ipv6.conf <<EOF
DEFAULT_INPUT_POLICY="DROP"
DEFAULT_OUTPUT_POLICY="ACCEPT"
DEFAULT_FORWARD_POLICY="DROP"
EOF"
sudo ufw enable

# Konfiguracja SELinuxa (CIS 1.6.1)
sudo apt install selinux-basics selinux-policy-default auditd -y
sudo selinux-activate
sudo reboot

# Po restarcie: Ustawienie SELinux w trybie enforcing (tę komendę należy ręcznie wykonać po restarcie)
# sudo setenforce 1
