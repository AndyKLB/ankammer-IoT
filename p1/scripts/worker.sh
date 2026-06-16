#!/bin/sh

NAME="ankammer"
SERVER_IP="192.168.56.110"
WORKER_IP="192.168.56.111"


echo "================================================="
echo "Installation K3s - Worker"
echo "IP: "${WORKER_IP}""
echo "Server: "${SERVER_IP}""
echo "================================================="


echo "Waiting for jonction token at /vagrant/..."
echo "Server has to finish his setting"

LIMIT=300
PASSED=0
TOKEN="/vagrant/node-token"

while [ ! -f "$TOKEN" ]; do
	echo "	Token not available yet... (${PASSED}s/${LIMIT}s)"
	sleep 5
	PASSED=$((PASSED + 5))

	if [ $PASSED -ge $LIMIT ]; then
		echo "Error timeout: Token not available after ${PASSED}s"
		echo "Check server: "
		echo "vagrant ssh "${NAME}"S"
		exit 1
	fi
done

echo ">>> Token found! after ${PASSED}s "

NODE_TOKEN=$(cat "$TOKEN" | tr -d '\n')

if [ -z "$NODE_TOKEN" ]; then
	echo "Error node-token is empty"
	exit 1
fi
echo "Valid node-token"

echo "Connexion test to server: "${SERVER_IP}""

PING=0
for i in 1 2 3; do
	if ping -c 1 -W 2 "$SERVER_IP" >/dev/null 2>&1; then
		PING=1
		break
	fi
	sleep 2
done

if [ $PING -eq 0 ]; then
	echo "Ping failed to "${SERVER_IP}""
	echo "Continue, ping can be blocked by firewall"
fi

echo ">>> waiting for K3s API"
TRIES=0
until curl -sk https://${SERVER_IP}:6443/healthz | grep -qE "ok|Unauthorized"; do
	TRIES=$((TRIES + 1))
	if [ $TRIES -ge 12 ]; then
		echo "Error: K3s API unavalaible!"
		exit 1
	fi
	echo "K3s API not ready yet... (try ${TRIES}/12)"
	sleep 5
done
echo "K3s API avalaible!"

echo "K3s agent mode installation..."
echo "Connexion to server: https://${SERVER_IP}:6443"

curl -sfL https://get.k3s.io | \
	INSTALL_K3S_VERSION="v1.28.15+k3s1" \
	K3S_URL="https://$SERVER_IP:6443" \
	K3S_TOKEN="$NODE_TOKEN" \
	INSTALL_K3S_EXEC="--node-ip=${WORKER_IP}" \
	sh -
if [ $? -ne 0 ]; then
	echo "K3s instalation failed exit..."
	exit 1
fi
echo "k3s successfully installed"
echo "Waiting for cluster registering (30s)..."
sleep 30
rc-service k3s-agent status 2>/dev/null | \
head -15 || \
	echo "Service started (check manually)"

echo ""
echo "================================================="
echo "Worker K3s Successfully installed!"
echo "Hostname : $(hostname)"
echo "IP : "${WORKER_IP}""
echo "Server : https://"${SERVER_IP}":6443"
echo "================================================="
echo "Check command on SERVER: "
echo "kubectl get nodes -o wide"
echo "================================================="