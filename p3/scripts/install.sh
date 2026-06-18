#!/bin/bash

set -euo

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

if command -v kubectl &>/dev/null; then
    success "kubectl already installed: $(kubectl version --client --short 2>/dev/null)"
else
    info "Downloading kubectl..."
    KUBECTL_VER=$(curl -sL https://dl.k8s.io/release/stable.txt)
    info "Version: $KUBECTL_VER"
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VER/bin/linux/amd64/kubectl"
    sudo chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    success "Kubectl successfully installed: $(kubectl version --client --short 2>/dev/null)"
fi


