#!/bin/bash

# Demande du nom d'utilisateur
read -p "Entrez le nom du nouvel utilisateur: " NEW_USER

# Mise à jour du système
echo "Mise à jour du système..."
apt update && apt upgrade -y

# Création du nouvel utilisateur
adduser --gecos "" $NEW_USER
usermod -aG sudo $NEW_USER

echo "Utilisateur $NEW_USER créé et ajouté au groupe sudo."

# Copie de la clé SSH
mkdir -p /home/$NEW_USER/.ssh
cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/ 2>/dev/null
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh
chmod 600 /home/$NEW_USER/.ssh/authorized_keys

echo "Configuration SSH pour $NEW_USER terminée."

# Sécurisation de SSH
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#Port 22/Port 55/' /etc/ssh/sshd_config

echo "SSH sécurisé."

# Activation de UFW avec port 55 ouvert
ufw allow 55/tcp
ufw --force enable

echo "Pare-feu activé avec SSH sur le port 55."

# Redémarrage des services et du VPS
systemctl restart sshd

echo "Redémarrage du VPS dans 10 secondes..."
sleep 10
reboot
