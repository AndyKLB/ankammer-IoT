#!/bin/bash

set -euo pipefail

# ── Couleurs pour l'affichage ─────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'  # No Color (reset)

# ── Fonctions d'affichage ─────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}    $1"; }
success() { echo -e "${GREEN}[OK]${NC}      $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC}   $1"; }
error()   { echo -e "${RED}[ERREUR]${NC} $1"; exit 1; }
step()    { echo -e "\n${BOLD}══ $1 ══${NC}"; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Installation IoT — Partie 3                ║${NC}"
echo -e "${BOLD}║   K3d + Argo CD + GitOps                     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

step "Étape 1/5 : Docker"
if command -v docker &>/dev/null; then
    success "Docker already installed"
else
    info "Installation of docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    success "Docker successfully installed!"
    warning "Refresh terminal or use cmd: newgrp docker"
fi

if ! docker info &>/dev/null; then
    echo "launching docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi
success "Docker is working!"

step "Étape 2/5 : kubectl"
if command -v kubectl &>/dev/null; then
    success "kubectl already installed: $(kubectl version --client 2>/dev/null)"
else
    info "Downloading kubectl..."
    KUBECTL_VER=$(curl -sL https://dl.k8s.io/release/stable.txt)
    info "Version: $KUBECTL_VER"
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VER/bin/linux/amd64/kubectl"
    sudo chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    success "Kubectl successfully installed: $(kubectl version --client 2>/dev/null)"
fi

step "Étape 3/5 : K3d"
if command -v k3d &>/dev/null; then
    success "k3d already installed"
else
    info "Installation of k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    success "k3d successfully installed"
fi

step "Etape 4/5: Cluster K3d"
CLUSTER_NAME="myCluster"
if k3d cluster list 2>/dev/null | grep -q "^${CLUSTER_NAME}"; then
    warning "Cluster: '$CLUSTER_NAME' already created"
    info "Checking status of '$CLUSTER_NAME'"
    k3d cluster start "$CLUSTER_NAME" 2>/dev/null || true
else
    info "Creation of k3d cluster: '$CLUSTER_NAME'..."
    k3d cluster create "$CLUSTER_NAME" \
        --port "8080:80@loadbalancer" \
        --port "8443:443@loadbalancer" \
        --wait
    success "Cluster: ${CLUSTER_NAME} created!"
fi

info "Waiting for all nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
echo ""
kubectl get nodes
echo ""

step "Etape 5/5: Namespaces + ArgoCD"
info "Namespaces creation..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
success "Created namespaces: "
kubectl get namespaces | grep -E "argocd|dev"
info "ArgoCD installation..."
kubectl apply --server-side -n argocd \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
info "Waiting for Argo CD to be ready"
kubectl wait --for=condition=Available \
    deployment/argocd-server \
    -n argocd \
    --timeout=300s
info "Configuring Argo CD for HTTP access behind the ingress..."
kubectl patch configmap argocd-cmd-params-cm \
    -n argocd \
    --type merge \
    -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment/argocd-server -n argocd
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
success "Argo CD is ready!"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFS_DIR="${SCRIPT_DIR}/../confs"
ARGOCD_DIR="${SCRIPT_DIR}/../confs/argocd"
ARGOCD_CONF="${ARGOCD_DIR}/argocd-app.yaml"
ARGOCD_INGRESS="${ARGOCD_DIR}/argocd-ingress.yaml"
if [ -f "${ARGOCD_INGRESS}" ]; then
    info "Exposing Argo CD via ingress..."
    kubectl apply -f "${ARGOCD_INGRESS}"
    success "Argo CD exposed on http://local.argo.com:8080"
fi
if [ -f "${ARGOCD_CONF}" ]; then
    info "Applying argo cd config..."
    kubectl apply -f "${ARGOCD_CONF}"
    success "Argo CD successfully configured!"
else
    warning "Argo cd config file not found in : ${ARGOCD_DIR}"
    warning "Update repo's URL then apply it: kubectl apply -f p3/argocd/argocd-app.yaml"
fi

ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "password not available")

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                   INSTALLATION TERMINÉE !                    ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓${NC} Cluster K3d : ${CLUSTER_NAME}"
echo -e "${GREEN}✓${NC} Namespaces  : argocd, dev"
echo -e "${GREEN}✓${NC} Argo CD     : opérationnel"
echo ""
echo -e "${BOLD}─── Accès à l'interface Argo CD ───────────────────────────────${NC}"
echo "  URL      : http://local.argo.com:8080  (A rensigner dans /etc/hosts : 127.0.0.1 local.argo.com)"
echo "  User     : admin"
echo "  Password : ${ARGOCD_PASS}"
echo ""
echo -e "${BOLD}─── Accès à l'application ─────────────────────────────────────${NC}"
echo "  Test     : curl http://local.ankammer.com:8080/ (A renseigner dans /etc/hosts : 127.0.0.1 local.ankammer.com)"
echo "  Attendu  : {\"status\":\"ok\",\"message\":\"v1\"}"
echo ""
echo -e "${BOLD}─── Démonstration de la mise à jour automatique ───────────────${NC}"
echo "  1. Modifier p3/confs/deployment.yaml : v1 → v2"
echo "  2. git add . && git commit -m 'v2' && git push"
echo "  3. Attendre ~3 minutes (ou forcer dans l'UI Argo CD)"
echo "  4. curl http://local.ankammer.com:8080/ → {\"message\": \"v2\"}"
echo ""
