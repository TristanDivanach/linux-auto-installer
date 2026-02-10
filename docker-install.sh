cat << 'EOF' > install_docker.sh
#!/bin/bash

# Créer le dossier logs s'il n'existe pas
mkdir -p logs

# Rediriger la sortie vers le fichier de log ET l'écran
exec > >(tee -a logs/install.log) 2>&1

echo "=========================================="
echo "   Installation de Docker (Force Stable)  "
echo "=========================================="

# 1. Nettoyage et dépendances
apt-get update
apt-get install -y ca-certificates curl gnupg

# 2. Gestion de la clé GPG
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Configuration du dépôt (on force 'noble' si 'plucky' échoue)
# Docker n'a souvent pas de repo pour les versions de test au premier jour
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  noble stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Installation
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Test
if command -v docker &> /dev/null; then
    echo "SUCCESS: Docker $(docker --version) installé."
else
    echo "ERROR: L'installation a échoué."
    exit 1
fi
EOF

chmod +x install_docker.sh
