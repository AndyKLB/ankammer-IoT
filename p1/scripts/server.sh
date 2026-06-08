#!/bin/sh

set -e

SERVER_IP="192.168.56.110"

echo "================================================="
echo "Installation K3s - Server (Control Plane)"
echo "IP: ${SERVER_IP}"
echo "Downloading K3s installation script and K3s binary"
echo "================================================="

# Explication de chaque argument (voir Chapitre 5.2 pour détails) :
# --write-kubeconfig-mode=644 → kubeconfig lisible sans sudo
# --node-ip                   → IP de ce nœud dans le cluster
# --bind-address              → IP d'écoute de l'API Server
# --advertise-address         → IP dans les certificats TLS
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
	--write-kubeconfig-mode=644 \
	--node-ip=${SERVER_IP} \
	--bind-address=${SERVER_IP} \
	--advertise-address=${SERVER_IP} sh -

echo ">>> Waiting for complete launching of K3s..."
sleep 40
echo ">>> Waiting for kubernetes API..."
TRIES=0
until kubectl get nodes > /dev/null 2>&1; do
	TRIES=$((TRIES + 1))
	if [ $TRIES -ge 20 ]; then
		echo "Error K3s not launching after 100 secondes!"
		echo "Cmd check: sudo journalctl -u k3s -n 50"
		exit 1
	fi
	echo "	Waiting for API (tries: ${TRIES}/20)"
	sleep 5
done
echo ">>> kubernetes API available!"

echo ""
echo "Checking cluster nodes: "
kubectl get nodes -o wide
echo ""

echo "Pods system launching: "
kubectl get pods -n kube-system

echo ""
echo "Copying jonction token to /vagrant/..."
TOKEN_FILE="/var/lib/rancher/k3s/server/node-token"
if [ ! -f "$TOKEN_FILE" ]; then
	echo "Error token file does not exist yet"
	echo "K3s may have not be launched yet"
fi

cp "$TOKEN_FILE" /vagrant/node-token
echo "Token file successfully copied!"
echo "Token partial preview (50 first characters)"
head -c 50 /vagrant/node-token
echo "..."

echo ""
echo "================================================="
echo "K3s server successfully installed"
echo "================================================="
echo "Preview		:"
echo "Hostname		: $(hostname)"
echo "				:"
echo "				:"
echo "				:"
echo "				:"
echo "================================================="

