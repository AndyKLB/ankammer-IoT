# KUBERNETES — LE LIVRE COMPLET
## Du débutant à l'expert, de la théorie à l'internale

---

> **Comment utiliser ce livre**
> Chaque notion est présentée dans cet ordre invariable :
> 1. L'image mentale (comprendre avant de savoir)
> 2. Le problème résolu (pourquoi ça existe)
> 3. Le fonctionnement interne (comment ça marche vraiment)
> 4. La syntaxe et les détails techniques
> 5. Les erreurs fréquentes
> 6. Les exercices

---

# TABLE DES MATIÈRES

- **Chapitre 1** — Pourquoi Kubernetes existe
- **Chapitre 2** — Architecture globale de Kubernetes
- **Chapitre 3** — Les composants du Control Plane
- **Chapitre 4** — Les composants des Worker Nodes
- **Chapitre 5** — Le cycle de vie complet d'un YAML
- **Chapitre 6** — YAML : syntaxe complète
- **Chapitre 7** — Les champs universels Kubernetes
- **Chapitre 8** — Pod
- **Chapitre 9** — Deployment
- **Chapitre 10** — ReplicaSet
- **Chapitre 11** — StatefulSet
- **Chapitre 12** — DaemonSet
- **Chapitre 13** — Job et CronJob
- **Chapitre 14** — Service
- **Chapitre 15** — Ingress
- **Chapitre 16** — Namespace
- **Chapitre 17** — ConfigMap et Secret
- **Chapitre 18** — Volumes, PV, PVC, StorageClass
- **Chapitre 19** — RBAC : ServiceAccount, Role, ClusterRole
- **Chapitre 20** — NetworkPolicy
- **Chapitre 21** — HPA, LimitRange, ResourceQuota
- **Chapitre 22** — Le réseau Kubernetes en profondeur
- **Chapitre 23** — K3s
- **Chapitre 24** — K3d
- **Chapitre 25** — ArgoCD et GitOps
- **Chapitre 26** — kubectl : toutes les commandes
- **Annexes**

---
---

# CHAPITRE 1 — POURQUOI KUBERNETES EXISTE

## 1.1 L'image mentale de départ

**Imagine un restaurant.**

Au début, le restaurant est petit. Un seul cuisinier prépare tous les plats. Quand il y a beaucoup de clients, le cuisinier travaille plus vite. S'il tombe malade, le restaurant ferme. Si la demande double du jour au lendemain, impossible de s'adapter.

Maintenant imagine que ce restaurant devient une chaîne mondiale : 10 000 cuisines, des millions de clients, des plats différents selon les régions, des pics de demande imprédictibles, des cuisiniers qui tombent malades, des équipements qui tombent en panne.

Comment gères-tu ça ?

Tu as besoin d'un **système de coordination automatique** qui :
- Sait combien de cuisiniers sont disponibles
- Distribue le travail automatiquement
- Remplace les cuisiniers absents
- S'adapte à la demande en temps réel
- Garde une trace de tout ce qui se passe

**Kubernetes est ce système de coordination.** Mais pour des applications informatiques plutôt que des cuisiniers.

---

## 1.2 L'histoire : comment on en est arrivé là

### L'ère des serveurs physiques (avant 2000)

```
┌──────────────────────────────────────────────────────┐
│                   SERVEUR PHYSIQUE                    │
│                                                      │
│   Application A    Application B    Application C    │
│       (en cours)       (en cours)       (en cours)   │
│                                                      │
│           Système d'exploitation Linux               │
│                                                      │
│               Matériel physique                      │
└──────────────────────────────────────────────────────┘
```

**Problèmes :**
- Gaspillage : si l'application A utilise 10% du CPU, les 90% restants sont perdus
- Conflits : deux applications peuvent avoir besoin de versions différentes de Python
- Isolation nulle : une application peut crasher et affecter les autres
- Déploiement lent : acheter un serveur physique prend des semaines

### L'ère des machines virtuelles (2000-2013)

```
┌──────────────────────────────────────────────────────────┐
│                   SERVEUR PHYSIQUE                        │
│                                                          │
│    ┌─────────────┐   ┌─────────────┐   ┌─────────────┐  │
│    │     VM 1    │   │     VM 2    │   │     VM 3    │  │
│    │  App A      │   │  App B      │   │  App C      │  │
│    │  OS Linux   │   │  OS Windows │   │  OS Linux   │  │
│    └─────────────┘   └─────────────┘   └─────────────┘  │
│                                                          │
│              Hyperviseur (VMware, VirtualBox)            │
│                                                          │
│                   Matériel physique                      │
└──────────────────────────────────────────────────────────┘
```

**Améliorations :**
- Isolation : chaque VM est indépendante
- Meilleure utilisation des ressources

**Nouveaux problèmes :**
- Chaque VM contient un OS complet = lourd (plusieurs Go)
- Démarrage lent (minutes)
- Toujours du gaspillage

### L'ère des conteneurs (2013 — Docker)

```
┌──────────────────────────────────────────────────────────┐
│                   SERVEUR PHYSIQUE                        │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │Conteneur │  │Conteneur │  │Conteneur │  │Conteneur │ │
│  │  App A   │  │  App B   │  │  App C   │  │  App D   │ │
│  │ (Python) │  │ (Node.js)│  │ (Java)   │  │ (Go)     │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │
│                                                          │
│              Docker Engine (runtime)                     │
│                                                          │
│              Système d'exploitation Linux                │
│                                                          │
│                   Matériel physique                      │
└──────────────────────────────────────────────────────────┘
```

**Révolution :**
- Un conteneur ne contient que l'application et ses dépendances directes
- Démarrage en secondes (parfois millisecondes)
- Léger : quelques Mo au lieu de plusieurs Go
- Portable : "ça marche sur ma machine" devient enfin vrai partout

**Mais voici le nouveau problème** : et si tu as 1000 conteneurs répartis sur 50 serveurs ?

---

## 1.3 Le problème de la coordination à grande échelle

Imagine maintenant que tu gères un service comme Netflix :

```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ Serveur 1│  │ Serveur 2│  │ Serveur 3│  │ Serveur 4│
│          │  │          │  │          │  │          │
│ API: 3   │  │ API: 2   │  │ DB: 1    │  │ Cache: 5 │
│ Cache: 2 │  │ Worker: 4│  │ Worker: 2│  │ API: 1   │
│ Worker: 1│  │          │  │          │  │          │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

Questions qui surgissent immédiatement :

1. **Serveur 2 tombe** : qui relance les conteneurs ailleurs ?
2. **Trafic × 10 ce soir** : comment rajouter des conteneurs d'API automatiquement ?
3. **Nouvelle version** : comment la déployer sans interruption de service ?
4. **Conteneur malade** (fuite mémoire) : qui le détecte et le redémarre ?
5. **Quel serveur a encore de la place** pour ce nouveau conteneur ?
6. **Comment les conteneurs se trouvent** sur le réseau interne ?
7. **Logs, métriques** : comment collecter tout ça ?

Docker seul ne répond à aucune de ces questions. Docker lance des conteneurs sur UNE machine. Il ne sait pas ce qui se passe sur les autres machines.

C'est exactement le problème que Kubernetes résout.

---

## 1.4 Ce que Kubernetes fait concrètement

**Kubernetes est un système d'orchestration de conteneurs.**

Le mot "orchestration" vient de l'orchestre musical. Un chef d'orchestre ne joue pas lui-même, mais coordonne des dizaines de musiciens pour qu'ils jouent ensemble au bon moment.

Kubernetes est ce chef d'orchestre pour tes conteneurs.

### Les 7 superpouvoirs de Kubernetes

**1. Auto-healing (auto-guérison)**
```
Conteneur mort → Kubernetes le redémarre automatiquement
Node mort → Kubernetes migre ses conteneurs sur d'autres nodes
Application ne répond plus → Kubernetes arrête d'envoyer du trafic vers elle
```

**2. Auto-scaling (mise à l'échelle automatique)**
```
CPU > 80% pendant 5 minutes → Kubernetes ajoute des instances
Trafic redescend → Kubernetes supprime les instances inutiles
```

**3. Rolling updates (mises à jour sans interruption)**
```
Version 1 tourne → tu déploies la version 2
Kubernetes remplace progressivement : 1 ancien → 1 nouveau → 1 ancien → 1 nouveau...
Si version 2 plante → rollback automatique vers version 1
```

**4. Service discovery et load balancing**
```
10 instances de ton API tournent
Le client appelle "mon-api" → Kubernetes distribue la requête sur les 10 instances
Une instance disparaît → automatiquement retirée de la rotation
```

**5. Gestion de la configuration**
```
Mot de passe de base de données → stocké dans un Secret Kubernetes
Variables d'environnement → injectées automatiquement dans chaque conteneur
```

**6. Gestion du stockage**
```
"J'ai besoin de 50 Go de disque persistant"
Kubernetes provisionne automatiquement le volume, l'attache au bon conteneur
```

**7. Bin packing (optimisation des ressources)**
```
Serveur A : 30% CPU libre, 40% RAM libre
Serveur B : 60% CPU libre, 10% RAM libre
Nouveau conteneur : besoin de 20% CPU et 30% RAM
→ Kubernetes choisit automatiquement Serveur A
```

---

## 1.5 Docker vs Kubernetes : la confusion fréquente

C'est l'une des questions les plus posées. La réponse courte : **ils ne sont pas concurrents, ils sont complémentaires.**

```
┌────────────────────────────────────────────────────────────────────┐
│                    ANALOGIE : LA CONSTRUCTION                       │
│                                                                    │
│  Docker = Les briques (crée et emballe les conteneurs)             │
│                                                                    │
│  Kubernetes = L'architecte + le chef de chantier                   │
│  (décide où mettre les briques, gère les ouvriers, surveille tout) │
└────────────────────────────────────────────────────────────────────┘
```

| Aspect | Docker seul | Kubernetes |
|--------|-------------|------------|
| Périmètre | Une seule machine | N machines (cluster) |
| Si un conteneur plante | Il reste mort (sauf restart policy) | Redémarre automatiquement |
| Si un serveur tombe | Les conteneurs sont perdus | Migre sur d'autres serveurs |
| Mise à l'échelle | Manuelle | Automatique (HPA) |
| Mise à jour | Interruption de service | Rolling update sans interruption |
| Réseau multi-machines | Complexe à configurer | Natif |
| Découverte de services | Manuelle | Automatique via DNS |

**Note importante :** Kubernetes peut utiliser Docker comme runtime de conteneurs, mais depuis Kubernetes 1.24, Docker n'est plus supporté directement — Kubernetes utilise containerd ou CRI-O. (Mais les images Docker fonctionnent toujours, c'est juste le runtime d'exécution qui change.)

---

## 1.6 Docker Compose vs Kubernetes

Docker Compose est parfait pour le développement local. Kubernetes est fait pour la production à grande échelle.

```yaml
# docker-compose.yml
version: '3'
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
  api:
    image: myapi:latest
    environment:
      DB_HOST: db
  db:
    image: postgres:14
```

```yaml
# L'équivalent Kubernetes (très simplifié)
# → 3 Deployments + 3 Services + 1 Secret + ...
# → beaucoup plus verbeux mais infiniment plus puissant
```

| Aspect | Docker Compose | Kubernetes |
|--------|----------------|------------|
| Cible | Dev local | Production |
| Multi-machines | Non | Oui |
| Auto-healing | Non | Oui |
| Auto-scaling | Non | Oui |
| Verbosité | Faible | Élevée |
| Courbe d'apprentissage | Faible | Élevée |
| Configuration réseau | Automatique et simple | Complexe mais puissante |

---

## 1.7 Les variantes de Kubernetes : K3s, K3d, Minikube, Kind, kubeadm

Kubernetes "standard" est lourd. Plusieurs projets offrent des alternatives selon le contexte.

### Kubernetes standard (kubeadm)

```
┌─────────────────────────────────────────────────────────┐
│                KUBERNETES STANDARD                       │
│                                                         │
│  etcd cluster (3+ nodes) + API Server + Scheduler +    │
│  Controller Manager + Kubelet + CNI + CSI + ...        │
│                                                         │
│  Ressources : plusieurs Go RAM, plusieurs CPU           │
│  Usage : production enterprise                          │
│  Complexité : très élevée                               │
└─────────────────────────────────────────────────────────┘
```

`kubeadm` est l'outil officiel pour installer un cluster Kubernetes standard sur des serveurs. C'est lui qui "monte" le cluster : initialise le Control Plane, configure les certificats TLS, joint les Worker Nodes.

### K3s

```
┌─────────────────────────────────────────────────────────┐
│                       K3s                               │
│                                                         │
│  Kubernetes complet mais allégé :                       │
│  - Un seul binaire (< 100 Mo)                          │
│  - SQLite au lieu d'etcd (par défaut)                  │
│  - Traefik intégré                                     │
│  - Composants cloud inutiles retirés                   │
│                                                         │
│  Ressources : 512 Mo RAM suffisent                      │
│  Usage : IoT, edge, Raspberry Pi, apprentissage        │
│  Complexité : faible                                    │
└─────────────────────────────────────────────────────────┘
```

K3s est créé par Rancher (maintenant SUSE). Il est certifié CNCF — c'est du vrai Kubernetes, pas une émulation. La différence : des composants non essentiels ont été retirés et le tout est empaqueté en un seul binaire.

**Pourquoi "K3s" ?** K8s a 8 lettres entre K et s. K3s voulait être environ la moitié de K8s en taille, donc 3 lettres entre K et s.

### K3d

```
┌─────────────────────────────────────────────────────────┐
│                       K3d                               │
│                                                         │
│  K3s DANS Docker                                        │
│                                                         │
│  Machine hôte                                           │
│    └── Docker Engine                                    │
│          ├── Conteneur : k3s-server (Control Plane)    │
│          ├── Conteneur : k3s-agent (Worker Node)       │
│          └── Conteneur : k3d-loadbalancer (LB)        │
│                                                         │
│  Usage : développement, tests, CI/CD                   │
│  Avantage : cluster Kubernetes en 30 secondes          │
└─────────────────────────────────────────────────────────┘
```

K3d n'est pas Kubernetes dans des VMs — c'est Kubernetes dans des **conteneurs Docker**. Chaque "node" est un conteneur. C'est extrêmement léger et rapide pour tester.

### Minikube

```
┌─────────────────────────────────────────────────────────┐
│                     Minikube                            │
│                                                         │
│  Kubernetes en local pour le développement              │
│                                                         │
│  Crée une VM (ou conteneur) sur ta machine              │
│  avec un cluster single-node complet                   │
│                                                         │
│  Drivers : Docker, VirtualBox, HyperKit, qemu...       │
│  Usage : apprentissage, développement local             │
│  Avantage : très bien documenté, addons faciles        │
└─────────────────────────────────────────────────────────┘
```

Minikube est l'outil officiel Kubernetes pour le développement local. Il gère automatiquement la création d'une VM locale avec un cluster single-node.

### Kind (Kubernetes IN Docker)

```
┌─────────────────────────────────────────────────────────┐
│                       Kind                              │
│                                                         │
│  Kubernetes IN Docker — similaire à K3d mais avec      │
│  Kubernetes standard (pas K3s)                         │
│                                                         │
│  Usage principal : tests des CI/CD pipelines           │
│  Avantage : comportement identique au prod standard    │
└─────────────────────────────────────────────────────────┘
```

### Tableau comparatif

| Outil | Kubernetes | Dans Docker | Ressources | Usage |
|-------|-----------|-------------|------------|-------|
| kubeadm | Standard | Non (VMs/bare metal) | Élevées | Production |
| K3s | Allégé (CNCF) | Non (bare metal) | Faibles | Edge, IoT, prod légère |
| K3d | K3s | Oui | Très faibles | Dev, CI/CD |
| Minikube | Standard | Optionnel | Moyennes | Apprentissage, dev |
| Kind | Standard | Oui | Faibles | CI/CD, tests |

---

## 1.8 Kubernetes dans l'écosystème cloud

Les grands cloud providers proposent Kubernetes "managé" : tu n'as pas à gérer le Control Plane, ils s'en occupent.

```
┌────────────────────────────────────────────────────────────────┐
│                  KUBERNETES MANAGÉ                              │
│                                                                │
│  AWS    → EKS (Elastic Kubernetes Service)                     │
│  GCP    → GKE (Google Kubernetes Engine)                       │
│  Azure  → AKS (Azure Kubernetes Service)                       │
│  OVH    → OVHcloud Managed Kubernetes                          │
│                                                                │
│  Tu fournis : les Worker Nodes et tes applications             │
│  Ils fournissent : le Control Plane (etcd, API Server...)      │
└────────────────────────────────────────────────────────────────┘
```

---

## 1.9 Résumé du chapitre

```
┌────────────────────────────────────────────────────────────────┐
│                     RETENIR DU CHAPITRE 1                      │
│                                                                │
│  1. Docker = faire tourner UN conteneur sur UNE machine        │
│  2. Kubernetes = orchestrer des MILLIERS de conteneurs         │
│     sur des CENTAINES de machines                              │
│                                                                │
│  3. Kubernetes résout :                                        │
│     - Auto-healing (redémarrage automatique)                   │
│     - Auto-scaling (ajustement automatique)                    │
│     - Rolling updates (MAJ sans coupure)                       │
│     - Service discovery (trouver ses voisins)                  │
│     - Load balancing (répartition de charge)                   │
│     - Gestion config/secrets                                   │
│     - Gestion stockage persistant                              │
│                                                                │
│  4. K3s = Kubernetes allégé pour edge/IoT                      │
│     K3d = K3s dans Docker pour le dev local                    │
│     kubeadm = Kubernetes standard pour la prod                 │
└────────────────────────────────────────────────────────────────┘
```

---

## 1.10 QCM et exercices

### QCM

**Q1.** Qu'est-ce que Kubernetes fait que Docker seul ne peut pas faire ?
A) Créer des images de conteneurs
B) Gérer des conteneurs sur plusieurs machines simultanément ✓
C) Écrire des Dockerfiles
D) Construire des réseaux locaux

**Q2.** K3s est :
A) Une version de Docker pour Raspberry Pi
B) Une implémentation Kubernetes complète mais allégée, certifiée CNCF ✓
C) Un outil pour créer des images Docker
D) Un orchestrateur concurrent de Kubernetes

**Q3.** La différence principale entre K3d et K3s est :
A) K3d est plus léger que K3s
B) K3d fait tourner K3s à l'intérieur de conteneurs Docker ✓
C) K3d utilise etcd, pas SQLite
D) K3d ne supporte pas les Deployments

**Q4.** Docker Compose est préférable à Kubernetes quand :
A) Tu as 500 serveurs en production
B) Tu as besoin d'auto-scaling automatique
C) Tu développes localement sur une seule machine ✓
D) Tu veux de l'auto-healing

**Q5.** "kubeadm" sert à :
A) Gérer des images Docker
B) Installer et initialiser un cluster Kubernetes standard ✓
C) Remplacer kubectl
D) Créer des Namespaces

### Exercice pratique

Si tu as Docker installé, lance :
```bash
# Installer K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Créer un cluster
k3d cluster create moncluster

# Vérifier qu'il tourne
kubectl get nodes
```

Tu devrais voir un nœud avec le statut `Ready`. C'est un cluster Kubernetes complet tournant dans des conteneurs Docker sur ta machine.

---
# CHAPITRE 2 — ARCHITECTURE GLOBALE DE KUBERNETES

## 2.1 La vue d'ensemble : le cluster

**Image mentale : une ville intelligente**

Un cluster Kubernetes est comme une ville intelligente :
- La **mairie** (Control Plane) prend les décisions, gère les ressources, planifie
- Les **quartiers** (Worker Nodes) abritent les habitants (conteneurs)
- Le **registre municipal** (etcd) garde une trace de tout
- Le **chef d'urbanisme** (Scheduler) décide où construire quoi
- Les **contrôleurs** vérifient que la réalité correspond aux plans
- Les **services publics** (DNS, réseau) font communiquer tout le monde

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLUSTER KUBERNETES                           │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                       CONTROL PLANE                           │  │
│  │                                                               │  │
│  │  ┌──────────────┐  ┌──────────┐  ┌──────────────────────┐   │  │
│  │  │  API Server  │  │  etcd    │  │  Controller Manager  │   │  │
│  │  │  (le portail)│  │(la mémoire)│ │  (les gardiens)     │   │  │
│  │  └──────────────┘  └──────────┘  └──────────────────────┘   │  │
│  │                                                               │  │
│  │  ┌──────────────┐  ┌─────────────────────────────────────┐  │  │
│  │  │  Scheduler   │  │     Cloud Controller Manager        │  │  │
│  │  │  (le placeur)│  │     (si cloud provider)             │  │  │
│  │  └──────────────┘  └─────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────┐  ┌──────────────────────┐               │
│  │    WORKER NODE 1     │  │    WORKER NODE 2     │  ...           │
│  │                      │  │                      │               │
│  │  ┌────┐  ┌────────┐  │  │  ┌────┐  ┌────────┐ │               │
│  │  │Pod │  │  Pod   │  │  │  │Pod │  │  Pod   │ │               │
│  │  └────┘  └────────┘  │  │  └────┘  └────────┘ │               │
│  │                      │  │                      │               │
│  │  Kubelet             │  │  Kubelet             │               │
│  │  Kube-proxy          │  │  Kube-proxy          │               │
│  │  Container Runtime   │  │  Container Runtime   │               │
│  └──────────────────────┘  └──────────────────────┘               │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2.2 Les deux grandes parties d'un cluster

### Control Plane (Plan de contrôle)

C'est le "cerveau" de Kubernetes. Il prend toutes les décisions mais **n'exécute généralement pas** les applications utilisateur (sauf dans les petits clusters K3s mono-nœud).

**Ce qui s'y trouve :**
- **API Server** : le seul point d'entrée pour tout
- **etcd** : base de données distribuée, source de vérité
- **Scheduler** : décide sur quel node placer chaque pod
- **Controller Manager** : surveille l'état et corrige les écarts
- **Cloud Controller Manager** : interface avec AWS/GCP/Azure (optionnel)

### Worker Nodes (Nœuds de travail)

Ce sont les "muscles" de Kubernetes. Ils exécutent réellement les conteneurs de tes applications.

**Ce qui s'y trouve :**
- **Kubelet** : agent local qui reçoit les ordres du Control Plane
- **Container Runtime** : ce qui lance vraiment les conteneurs (containerd, CRI-O)
- **Kube-proxy** : gère les règles réseau pour les Services
- **Tes Pods** : les conteneurs de tes applications

---

## 2.3 Le principe fondamental : l'état désiré vs l'état réel

C'est LE concept central de Kubernetes. Tout le reste en découle.

**Philosophie déclarative, pas impérative :**

```
╔══════════════════════════════════════════════════════════════╗
║  APPROCHE IMPÉRATIVE (ce que tu faisais avant)              ║
║                                                              ║
║  "Lance 3 copies de mon app"                                ║
║  "Si une crash, relance-la"                                  ║
║  "Si une nouvelle version est disponible, mets à jour"       ║
║                                                              ║
║  → Tu décris COMMENT faire                                   ║
╚══════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════╗
║  APPROCHE DÉCLARATIVE (Kubernetes)                           ║
║                                                              ║
║  "Je veux 3 copies de mon app en permanence"                 ║
║  "Je veux la version 2.0 de l'image"                         ║
║  "Je veux que le port 80 soit accessible"                    ║
║                                                              ║
║  → Tu décris l'ÉTAT FINAL souhaité                           ║
║  → Kubernetes trouve lui-même COMMENT y arriver              ║
╚══════════════════════════════════════════════════════════════╝
```

**Comment ça marche en pratique :**

```
Tu écris :  "Je veux 3 pods"      → stored dans etcd
                 ↓
Controller lit : "État désiré = 3 pods, État réel = 0 pods"
                 ↓
Controller agit : "Je vais créer 3 pods"
                 ↓
Pods créés, état réel = 3 pods
                 ↓
Un pod crash → état réel = 2 pods
                 ↓
Controller détecte l'écart (désiré=3, réel=2)
                 ↓
Controller crée un nouveau pod → état réel = 3 pods
```

Cette boucle s'appelle la **boucle de réconciliation** (reconciliation loop). Elle tourne en permanence pour chaque type de ressource Kubernetes.

---

## 2.4 Communication dans le cluster

**Règle absolue : tout passe par l'API Server.**

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   kubectl              controllers        kubelet               │
│     │                      │                │                   │
│     │                      │                │                   │
│     ▼                      ▼                ▼                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    API SERVER                            │   │
│  │                 (le hub central)                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│     │                      │                │                   │
│     ▼                      ▼                ▼                   │
│   etcd              scheduler          autres composants        │
│                                                                 │
│  JAMAIS de communication directe entre composants.              │
│  Tout transite par l'API Server.                                │
└─────────────────────────────────────────────────────────────────┘
```

Pourquoi cette règle ? Parce que l'API Server est :
1. **Le seul à écrire dans etcd** (les autres ne parlent pas directement à etcd)
2. **Le point d'authentification/autorisation** (tout est vérifié ici)
3. **Le point d'audit** (tout est loggé ici)
4. **Le seul source de vérité** pour l'état actuel

---

## 2.5 Le système de watch (observation)

Les composants de Kubernetes ne *demandent* pas périodiquement l'état — ils *observent* en temps réel. C'est le mécanisme de **watch**.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  POLLING (inefficace, pas ce que fait Kubernetes) :             │
│                                                                 │
│  Scheduler → "Nouveaux pods non schedulés ?" → API Server      │
│  (toutes les N secondes)                                        │
│                                                                 │
│  WATCH (ce que Kubernetes fait vraiment) :                      │
│                                                                 │
│  Scheduler → "Je surveille les pods non schedulés"              │
│  API Server → [connexion HTTP/2 longue durée maintenue]         │
│  API Server → "Nouveau pod non schedulé !" → Scheduler (push)  │
│  API Server → "Encore un !" → Scheduler (push)                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Techniquement :** les composants établissent une connexion HTTP/2 longue durée (Server-Sent Events ou WebSocket) avec l'API Server et reçoivent les changements en temps quasi-réel. C'est bien plus efficace que du polling.

---

## 2.6 Les objets Kubernetes : une taxonomie

Tout dans Kubernetes est un **objet**. Un objet est une entité persistante dans le système qui représente l'état désiré du cluster.

```
┌────────────────────────────────────────────────────────────────┐
│                   TAXONOMIE DES OBJETS                         │
│                                                                │
│  WORKLOADS (ce qui tourne)                                     │
│  ├── Pod                    (unité de base)                    │
│  ├── Deployment             (pods stateless répliqués)         │
│  ├── ReplicaSet             (nombre de réplicas)               │
│  ├── StatefulSet            (pods avec état persistant)        │
│  ├── DaemonSet              (un pod par node)                  │
│  ├── Job                    (tâche ponctuelle)                 │
│  └── CronJob                (tâche planifiée)                  │
│                                                                │
│  RÉSEAU (comment on accède)                                    │
│  ├── Service                (point d'accès stable)             │
│  ├── Ingress                (routage HTTP/HTTPS)               │
│  ├── NetworkPolicy          (règles firewall réseau)           │
│  └── EndpointSlice          (IPs des pods d'un Service)        │
│                                                                │
│  CONFIG (paramétrage)                                          │
│  ├── ConfigMap              (configuration non sensible)       │
│  └── Secret                 (configuration sensible)           │
│                                                                │
│  STOCKAGE (persistance)                                        │
│  ├── PersistentVolume       (volume existant)                  │
│  ├── PersistentVolumeClaim  (demande de volume)                │
│  └── StorageClass           (type de stockage)                 │
│                                                                │
│  ORGANISATION                                                  │
│  ├── Namespace              (isolation logique)                │
│  ├── ResourceQuota          (limites par namespace)            │
│  └── LimitRange             (limites par conteneur)            │
│                                                                │
│  SÉCURITÉ                                                      │
│  ├── ServiceAccount         (identité d'un pod)                │
│  ├── Role / ClusterRole     (permissions)                      │
│  └── RoleBinding / ClusterRoleBinding  (attribution)           │
│                                                                │
│  AUTOSCALING                                                   │
│  └── HorizontalPodAutoscaler (HPA)                             │
└────────────────────────────────────────────────────────────────┘
```

---

## 2.7 La structure universelle d'un objet Kubernetes

Tous les objets Kubernetes ont exactement la même structure de base :

```yaml
apiVersion: apps/v1        # Quelle API Kubernetes utiliser
kind: Deployment           # Quel type d'objet
metadata:                  # Métadonnées (qui je suis)
  name: mon-app
  namespace: default
  labels:
    app: mon-app
spec:                      # État DÉSIRÉ (ce que je veux)
  replicas: 3
  # ... détails selon le type d'objet
status:                    # État RÉEL (ce qui existe vraiment)
  availableReplicas: 3     # ← rempli par Kubernetes, pas par toi
  # ... rempli automatiquement
```

**Les quatre sections :**
1. **apiVersion** : quelle version de l'API Kubernetes pour cet objet
2. **kind** : le type d'objet
3. **metadata** : les informations d'identification
4. **spec** : ce que tu veux (tu l'écris)
5. **status** : ce qui existe réellement (Kubernetes l'écrit, jamais toi)

---

## 2.8 Les namespaces : isolation logique

Un namespace est une partition logique du cluster. Pense-y comme des dossiers dans un système de fichiers.

```
cluster-kubernetes/
├── namespace: default          ← tes apps si tu ne spécifies rien
├── namespace: kube-system      ← composants système (CoreDNS, etc.)
├── namespace: kube-public      ← ressources publiques
├── namespace: kube-node-lease  ← heartbeats des nodes
├── namespace: production       ← ton app en prod
├── namespace: staging          ← ton app en staging
└── namespace: monitoring       ← Prometheus, Grafana
```

**Ce que les namespaces isolent :**
- Les noms (deux Deployments peuvent avoir le même nom dans des namespaces différents)
- Les quotas de ressources
- Les politiques réseau
- Les permissions RBAC

**Ce que les namespaces n'isolent PAS :**
- Les Nodes (partagés par tout le cluster)
- Les PersistentVolumes (ressource cluster-wide)
- Les ClusterRoles (ressource cluster-wide)

---

## 2.9 Les labels et sélecteurs : le système de liaison

Les labels sont des paires clé/valeur attachées à n'importe quel objet. Ils sont la colle qui relie les objets entre eux.

```
┌────────────────────────────────────────────────────────────────┐
│                   LE SYSTÈME DE LABELS                         │
│                                                                │
│  Pod (avec labels)            Service (avec selector)          │
│  ┌──────────────────┐         ┌──────────────────────────┐    │
│  │ app: frontend    │ ←──────→│ selector:                │    │
│  │ version: v2      │         │   app: frontend          │    │
│  │ tier: web        │         │   tier: web              │    │
│  └──────────────────┘         └──────────────────────────┘    │
│                                                                │
│  Pod (avec labels)                                             │
│  ┌──────────────────┐         Le Service envoie du trafic     │
│  │ app: frontend    │ ←───┐   vers tous les pods dont les     │
│  │ version: v2      │     │   labels correspondent au         │
│  │ tier: web        │     └── selector du Service             │
│  └──────────────────┘                                         │
│                                                                │
│  Pod (labels différents — EXCLU)                               │
│  ┌──────────────────┐                                         │
│  │ app: backend     │   ← Ce pod n'est pas sélectionné        │
│  │ tier: api        │     car app: backend ≠ app: frontend    │
│  └──────────────────┘                                         │
└────────────────────────────────────────────────────────────────┘
```

**Les sélecteurs :**
- `selector: matchLabels: app: frontend` → sélection exacte
- `selector: matchExpressions:` → sélection avec opérateurs (In, NotIn, Exists...)

---

## 2.10 Résumé du chapitre

```
┌────────────────────────────────────────────────────────────────┐
│                    RETENIR DU CHAPITRE 2                       │
│                                                                │
│  1. Cluster = Control Plane + Worker Nodes                     │
│                                                                │
│  2. Control Plane = cerveau (API Server, etcd,                 │
│     Scheduler, Controller Manager)                             │
│                                                                │
│  3. Worker Node = muscles (Kubelet, Container Runtime,         │
│     Kube-proxy, tes Pods)                                      │
│                                                                │
│  4. TOUT passe par l'API Server                                │
│                                                                │
│  5. Kubernetes est DÉCLARATIF : tu décris l'état final,        │
│     Kubernetes trouve comment y arriver                        │
│                                                                │
│  6. La boucle de réconciliation compare état désiré et         │
│     état réel en permanence                                    │
│                                                                │
│  7. Les labels/selectors relient les objets entre eux          │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 3 — LES COMPOSANTS DU CONTROL PLANE

## 3.1 L'API Server : le portail unique

### Image mentale

L'API Server est comme le **guichet unique d'une mairie**. Peu importe ce que tu veux faire (créer un pod, modifier un service, supprimer un deployment) : tu passes par ce guichet. Pas de back door. Le guichet vérifie ton identité, vérifie que tu as le droit de faire ce que tu demandes, enregistre ta demande, et la transmet au bon département.

### Ce que fait l'API Server

```
┌─────────────────────────────────────────────────────────────────┐
│                       API SERVER                                │
│                                                                 │
│  ENTRÉE : Requêtes HTTP/HTTPS REST                              │
│                                                                 │
│  1. AUTHENTIFICATION                                            │
│     "Qui est-tu ?"                                              │
│     → Certificat TLS, token Bearer, Basic auth                 │
│                                                                 │
│  2. AUTORISATION (RBAC)                                         │
│     "As-tu le droit de faire ça ?"                              │
│     → Vérifie les Roles, ClusterRoles, Bindings                │
│                                                                 │
│  3. ADMISSION CONTROL                                           │
│     "Est-ce que cette requête est valide/acceptable ?"          │
│     → Mutating webhooks (modifie la requête)                    │
│     → Validating webhooks (valide la requête)                   │
│                                                                 │
│  4. VALIDATION                                                  │
│     "Est-ce que le YAML est bien formé ?"                       │
│     → Schema validation                                         │
│                                                                 │
│  5. PERSISTENCE                                                 │
│     "Enregistre dans etcd"                                      │
│                                                                 │
│  6. NOTIFICATION                                                │
│     "Notifie les watchers"                                      │
│                                                                 │
│  SORTIE : Réponse HTTP + événements aux watchers                │
└─────────────────────────────────────────────────────────────────┘
```

### Communication

```
Qui parle AVEC l'API Server :

   kubectl          → création/lecture/modification/suppression d'objets
   Scheduler        → lit les pods non schedulés, écrit les décisions
   Controller Mgr   → lit l'état, crée/modifie/supprime des objets
   Kubelet          → lit ses pods assignés, écrit les statuts
   Kube-proxy       → lit les Services et Endpoints
   Metrics Server   → lit les métriques des nodes
   Webhooks         → appelés par l'API Server pour admission control
```

### Ports utilisés

| Port | Protocole | Usage |
|------|-----------|-------|
| 6443 | HTTPS | Port principal (kubectl, composants) |
| 8080 | HTTP | Ancienne interface locale non sécurisée (désactivée en prod) |

### Ce qui se passe si l'API Server tombe

```
┌────────────────────────────────────────────────────────────────┐
│  API Server DOWN : conséquences                                │
│                                                                │
│  ✗ kubectl ne peut plus rien faire                             │
│  ✗ Plus de nouveaux déploiements possibles                     │
│  ✗ Plus de scaling automatique                                 │
│  ✗ Plus de réparation automatique                              │
│                                                                │
│  ✓ Les pods DÉJÀ lancés continuent de tourner                  │
│  ✓ Kube-proxy continue d'appliquer ses règles existantes       │
│  ✓ Les Services existants continuent de fonctionner            │
│                                                                │
│  En résumé : le cluster "survit" à court terme mais           │
│  ne peut plus s'adapter ni se réparer.                         │
└────────────────────────────────────────────────────────────────┘
```

### Haute disponibilité de l'API Server

En production, on déploie généralement 3 instances de l'API Server derrière un load balancer :

```
Client (kubectl)
      │
      ▼
┌───────────────┐
│ Load Balancer │
└───────────────┘
   │     │     │
   ▼     ▼     ▼
┌─────┐┌─────┐┌─────┐
│ API ││ API ││ API │
│ Srv ││ Srv ││ Srv │
│  1  ││  2  ││  3  │
└─────┘└─────┘└─────┘
```

---

## 3.2 etcd : la mémoire du cluster

### Image mentale

etcd est comme le **registre d'état civil de ta ville**. Chaque naissance (création de pod), mariage (liaison service-pod), décès (suppression) est enregistré. Si tu veux savoir l'état exact du cluster à n'importe quel instant, etcd le sait. Si etcd perd ses données, le cluster perd sa mémoire.

### Ce qu'est etcd

etcd est une base de données clé-valeur distribuée, hautement disponible, cohérente. Elle utilise l'algorithme **Raft** pour maintenir la cohérence entre plusieurs instances.

```
┌─────────────────────────────────────────────────────────────────┐
│                     ETCD                                        │
│                                                                 │
│  Stockage : clés-valeurs                                        │
│                                                                 │
│  Exemples de clés :                                             │
│  /registry/pods/default/mon-pod              → état du pod      │
│  /registry/deployments/default/mon-deploy   → état du deploy   │
│  /registry/services/default/mon-service     → état du service  │
│  /registry/namespaces/production            → namespace        │
│                                                                 │
│  Les valeurs sont des objets sérialisés en protobuf            │
│  (pas en JSON/YAML directement — c'est l'API Server qui        │
│   fait la conversion)                                           │
│                                                                 │
│  Caractéristiques :                                             │
│  - Fort cohérence (strong consistency)                          │
│  - Haute disponibilité (cluster de 3 ou 5 instances)           │
│  - SEUL l'API Server peut lire/écrire dans etcd                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### L'algorithme Raft et le quorum

Pour maintenir la cohérence, etcd utilise un consensus majoritaire. Avec N instances, il faut (N/2 + 1) instances disponibles pour fonctionner :

| Instances | Quorum requis | Pannes tolérées |
|-----------|---------------|-----------------|
| 1 | 1 | 0 |
| 3 | 2 | 1 |
| 5 | 3 | 2 |
| 7 | 4 | 3 |

C'est pourquoi on déploie toujours un nombre **impair** d'instances etcd.

### Ports utilisés

| Port | Usage |
|------|-------|
| 2379 | Communication client (API Server → etcd) |
| 2380 | Communication inter-instances etcd (peer) |

### Ce qui se passe si etcd tombe

```
┌────────────────────────────────────────────────────────────────┐
│  etcd DOWN : conséquences                                      │
│                                                                │
│  ✗ L'API Server ne peut plus ni lire ni écrire                 │
│  ✗ Toutes les opérations kubectl échouent                      │
│  ✗ Le Scheduler ne peut pas scheduler de nouveaux pods         │
│  ✗ Les Controllers ne peuvent pas lire l'état                  │
│                                                                │
│  ✓ Les pods déjà lancés continuent de tourner                  │
│  ✓ Kube-proxy continue avec ses règles en mémoire              │
│                                                                │
│  C'est LA ressource critique à sauvegarder régulièrement !     │
│  Commande de backup :                                           │
│  ETCDCTL_API=3 etcdctl snapshot save backup.db                 │
└────────────────────────────────────────────────────────────────┘
```

---

## 3.3 Le Scheduler : l'organisateur de places

### Image mentale

Le Scheduler est comme un **maître d'hôtel dans un restaurant** qui doit placer ses clients :
- Il regarde les tables disponibles (les nodes)
- Il connaît les préférences de chaque client (affinités, tolerations)
- Il vérifie les contraintes (régime alimentaire = ressources requises)
- Il attribue la meilleure table selon tous ces critères

### Ce que fait le Scheduler

```
┌─────────────────────────────────────────────────────────────────┐
│                      SCHEDULER                                  │
│                                                                 │
│  ENTRÉE : Pod créé dans etcd sans node assigné (spec.nodeName   │
│           est vide)                                             │
│                                                                 │
│  PROCESSUS EN DEUX PHASES :                                     │
│                                                                 │
│  Phase 1 : FILTRAGE                                             │
│  "Quels nodes sont ÉLIGIBLES pour ce pod ?"                     │
│  Critères d'exclusion :                                         │
│  ├── Node a assez de CPU ? (requests.cpu)                       │
│  ├── Node a assez de RAM ? (requests.memory)                    │
│  ├── Node a le bon label ? (nodeSelector)                       │
│  ├── Node accepte les taints du pod ? (tolerations)             │
│  ├── Le pod respecte les affinités/anti-affinités ?             │
│  └── Les ports demandés sont libres ? (hostPort)                │
│                                                                 │
│  Phase 2 : SCORING                                              │
│  "Parmi les nodes éligibles, lequel est LE MEILLEUR ?"          │
│  Critères de score (0-100) :                                    │
│  ├── Node avec le plus de ressources libres (LeastRequestedPriority)│
│  ├── Node préféré par le pod (preferred affinity)               │
│  ├── Équilibrage des pods identiques (inter-pod anti-affinity)  │
│  └── ... et d'autres                                            │
│                                                                 │
│  SORTIE : Écrit spec.nodeName dans le Pod dans etcd             │
└─────────────────────────────────────────────────────────────────┘
```

### Le Scheduler ne lance pas les pods !

Point crucial souvent mal compris. Le Scheduler **décide** où les pods vont, mais **ne les lance pas**. Il écrit juste `spec.nodeName: node-3` dans l'objet Pod dans etcd. C'est le Kubelet du node-3 qui verra ce changement et lancera réellement le pod.

```
Avant scheduling :
Pod {
  name: mon-pod
  spec.nodeName: ""     ← vide, pod "pending"
}

Après scheduling :
Pod {
  name: mon-pod
  spec.nodeName: "worker-node-3"     ← Scheduler a écrit ici
}
```

### Ce qui se passe si le Scheduler tombe

```
┌────────────────────────────────────────────────────────────────┐
│  Scheduler DOWN : conséquences                                 │
│                                                                │
│  ✗ Les NOUVEAUX pods restent en état "Pending" indéfiniment    │
│  ✗ L'auto-scaling ne peut pas créer de nouveaux pods          │
│                                                                │
│  ✓ Les pods DÉJÀ schedulés continuent de tourner              │
│  ✓ Le cluster est "stable" mais ne peut pas évoluer            │
│                                                                │
│  Impact : moins critique que l'API Server ou etcd              │
└────────────────────────────────────────────────────────────────┘
```

---

## 3.4 Le Controller Manager : les gardiens de l'état

### Image mentale

Le Controller Manager est comme un **bâtiment rempli de gardiens**, chacun responsable d'un aspect spécifique du cluster. Chaque gardien surveille en boucle son domaine et corrige les écarts. Il y a le gardien des Deployments, le gardien des ReplicaSets, le gardien des Nodes, etc.

### Ce qu'est le Controller Manager

Le Controller Manager est en réalité **un seul processus** qui héberge une multitude de contrôleurs indépendants. Chaque contrôleur implémente une boucle de réconciliation pour un type d'objet spécifique.

```
┌─────────────────────────────────────────────────────────────────┐
│                   CONTROLLER MANAGER                            │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Deployment Controller                                    │   │
│  │ "État désiré: 3 replicas. État réel: 2. → crée 1 pod"  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ReplicaSet Controller                                    │   │
│  │ "Mon ReplicaSet veut 5 pods. J'en ai 4. → crée 1 pod"  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Node Controller                                          │   │
│  │ "Ce node n'a pas répondu depuis 40s. → NotReady."       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Service Account Controller                               │   │
│  │ "Nouveau namespace. → crée le ServiceAccount 'default'" │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Endpoint Controller                                      │   │
│  │ "Nouveau pod avec label app:web → ajoute son IP         │   │
│  │  aux Endpoints du Service 'web-svc'"                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ... et 30+ autres contrôleurs                                  │
└─────────────────────────────────────────────────────────────────┘
```

### La boucle de réconciliation expliquée en détail

Chaque contrôleur suit exactement ce pattern :

```
┌──────────────────────────────────────────────────────────────────┐
│              BOUCLE DE RÉCONCILIATION                            │
│                                                                  │
│  1. OBSERVE                                                      │
│     "Watch" sur l'API Server pour mon type d'objet               │
│     Je reçois les créations/modifications/suppressions en temps  │
│     réel (pas de polling)                                        │
│                                                                  │
│  2. ANALYSE                                                      │
│     Pour chaque événement :                                      │
│     état_désiré = spec de l'objet dans etcd                     │
│     état_réel = ressources réelles existantes                    │
│                                                                  │
│  3. ACT                                                          │
│     Si état_réel != état_désiré :                                │
│       → Faire les appels API nécessaires pour corriger           │
│         (créer pods, modifier services, etc.)                    │
│                                                                  │
│  4. Retour à 1 (en permanence)                                   │
└──────────────────────────────────────────────────────────────────┘
```

### Les contrôleurs importants et leur rôle

| Contrôleur | Surveille | Action |
|------------|-----------|--------|
| Deployment Controller | Deployments | Crée/modifie ReplicaSets |
| ReplicaSet Controller | ReplicaSets | Crée/supprime Pods |
| StatefulSet Controller | StatefulSets | Crée/supprime Pods ordonnés |
| DaemonSet Controller | DaemonSets | Assure 1 Pod par Node |
| Job Controller | Jobs | Crée Pods, marque Job terminé |
| Node Controller | Nodes | Détecte nodes morts, evicts pods |
| Endpoint Controller | Services, Pods | Maintient les Endpoints |
| Namespace Controller | Namespaces | Nettoie à la suppression |
| PersistentVolume Controller | PVs, PVCs | Binding PV↔PVC |

### Ce qui se passe si le Controller Manager tombe

```
┌────────────────────────────────────────────────────────────────┐
│  Controller Manager DOWN : conséquences                        │
│                                                                │
│  ✗ Plus d'auto-healing (pod crash → pas de remplacement)       │
│  ✗ Plus de scaling automatique                                 │
│  ✗ Les rolling updates s'arrêtent en plein milieu              │
│  ✗ Les nodes morts ne sont pas détectés et remplacés           │
│                                                                │
│  ✓ Tout ce qui tourne continue de tourner                      │
│  ✓ Les règles réseau existantes restent en place               │
└────────────────────────────────────────────────────────────────┘
```

---

## 3.5 Cloud Controller Manager (optionnel)

Le Cloud Controller Manager fait l'interface entre Kubernetes et l'infrastructure cloud sous-jacente (AWS, GCP, Azure...).

```
┌─────────────────────────────────────────────────────────────────┐
│                CLOUD CONTROLLER MANAGER                         │
│                                                                 │
│  Node Controller         → Enregistre les nouvelles VMs comme  │
│                            Nodes Kubernetes                     │
│                                                                 │
│  Route Controller        → Configure les routes réseau dans    │
│                            le VPC cloud                         │
│                                                                 │
│  Service Controller      → Crée des Load Balancers cloud        │
│                            quand tu crées un Service LoadBalancer│
│                                                                 │
│  Volume Controller       → Provisionne des disques EBS/GCE PD  │
│                            quand tu crées un PVC                │
└─────────────────────────────────────────────────────────────────┘
```

En K3s local (ton projet IoT), ce composant n'existe pas. Les Services LoadBalancer ne fonctionnent pas sans cloud provider (sauf avec Traefik/MetalLB).

---

## 3.6 CoreDNS : le DNS interne du cluster

CoreDNS n'est pas un composant du Control Plane stricto sensu, mais il est indispensable et tourne dans le namespace `kube-system`.

### Ce que fait CoreDNS

```
┌─────────────────────────────────────────────────────────────────┐
│                       COREDNS                                   │
│                                                                 │
│  Résolution DNS interne au cluster                              │
│                                                                 │
│  Service "mon-service" dans namespace "production" :            │
│  → mon-service.production.svc.cluster.local                     │
│                                                                 │
│  Pod avec IP 10.42.1.5 dans namespace "default" :               │
│  → 10-42-1-5.default.pod.cluster.local                          │
│                                                                 │
│  Format des noms de Services :                                  │
│  <service>.<namespace>.svc.<cluster-domain>                     │
│                                                                 │
│  Raccourcis possibles depuis un pod dans le même namespace :    │
│  "mon-service" seul suffit                                      │
│  (CoreDNS ajoute automatiquement .default.svc.cluster.local)   │
└─────────────────────────────────────────────────────────────────┘
```

### Exemples de résolution DNS

```
Depuis un pod dans namespace "dev" :

curl http://api-service
  → résout : api-service.dev.svc.cluster.local
  → IP : 10.96.45.23 (ClusterIP du Service)

curl http://api-service.production
  → résout : api-service.production.svc.cluster.local
  → IP : 10.96.45.78 (Service dans namespace "production")

curl http://api-service.production.svc.cluster.local
  → résolution complète, même résultat
```

---

## 3.7 Architecture Control Plane en haute disponibilité

En production, le Control Plane est répliqué pour la haute disponibilité :

```
┌─────────────────────────────────────────────────────────────────┐
│              CONTROL PLANE HAUTE DISPONIBILITÉ                  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   MASTER NODE 1                          │   │
│  │  API Server (actif)                                      │   │
│  │  Controller Manager (actif)                              │   │
│  │  Scheduler (actif)                                       │   │
│  │  etcd (membre du cluster)                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   MASTER NODE 2                          │   │
│  │  API Server (actif)                                      │   │
│  │  Controller Manager (standby — leader election)          │   │
│  │  Scheduler (standby — leader election)                   │   │
│  │  etcd (membre du cluster)                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   MASTER NODE 3                          │   │
│  │  API Server (actif)                                      │   │
│  │  Controller Manager (standby)                            │   │
│  │  Scheduler (standby)                                     │   │
│  │  etcd (membre du cluster)                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Notes :                                                        │
│  - Les 3 API Servers sont TOUS actifs (derrière un LB)         │
│  - Controller Manager et Scheduler utilisent le leader          │
│    election : un seul actif, les autres en attente             │
│  - etcd : cluster à 3 membres avec quorum = 2                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.8 Résumé : qui fait quoi dans le Control Plane

```
┌────────────────────────────────────────────────────────────────┐
│              RÉSUMÉ DU CONTROL PLANE                           │
│                                                                │
│  API Server     : Point d'entrée unique. Authentification,     │
│                   autorisation, validation, persistence etcd.  │
│                   Port : 6443                                  │
│                                                                │
│  etcd           : Source de vérité. Base de données de tout   │
│                   l'état du cluster. Jamais accédée           │
│                   directement (seulement par l'API Server).   │
│                   Ports : 2379 (client), 2380 (peer)          │
│                                                                │
│  Scheduler      : Décide sur quel node placer chaque pod.     │
│                   Écrit spec.nodeName dans etcd.               │
│                   NE LANCE PAS les pods.                       │
│                                                                │
│  Controller Mgr : Boucles de réconciliation pour tous les     │
│                   types d'objets. Corrige les écarts entre    │
│                   état désiré et état réel.                   │
│                                                                │
│  CoreDNS        : DNS interne du cluster. Résout les noms     │
│                   de Services en IPs.                         │
└────────────────────────────────────────────────────────────────┘
```

---

## 3.9 QCM et exercices

### QCM

**Q1.** Quel composant du Control Plane écrit dans etcd ?
A) Le Scheduler directement
B) Le Controller Manager directement
C) Uniquement l'API Server ✓
D) Le Kubelet

**Q2.** Que fait le Scheduler quand il choisit un node pour un pod ?
A) Il lance directement le pod sur ce node
B) Il écrit spec.nodeName dans l'objet Pod dans etcd ✓
C) Il contacte directement le Kubelet du node
D) Il crée un nouvel objet "SchedulingDecision"

**Q3.** Combien d'instances etcd faut-il pour tolérer 2 pannes simultanées ?
A) 3
B) 4
C) 5 ✓
D) 6

**Q4.** Le Controller Manager est :
A) Un seul contrôleur spécialisé pour les Deployments
B) Un processus hébergeant de nombreux contrôleurs différents ✓
C) Le composant qui stocke l'état du cluster
D) L'interface avec le cloud provider

**Q5.** Si l'API Server tombe, que se passe-t-il ?
A) Tous les pods s'arrêtent immédiatement
B) Les pods existants continuent mais aucune opération de gestion n'est possible ✓
C) Rien, etcd prend le relais
D) Le Scheduler continue de fonctionner normalement

### Exercice de réflexion

Trace le chemin complet de cette commande :
```bash
kubectl scale deployment mon-app --replicas=5
```

Depuis l'appel jusqu'au moment où le 5ème pod tourne. Note chaque composant impliqué et ce qu'il fait.

**Réponse :**
1. `kubectl` → requête HTTP PATCH vers l'API Server (port 6443)
2. API Server → authentifie + autorise + valide la requête
3. API Server → met à jour `replicas: 5` dans etcd
4. API Server → notifie les watchers (Deployment Controller)
5. Deployment Controller → lit : désiré=5, réel=3 → crée ReplicaSet mis à jour
6. ReplicaSet Controller → lit : désiré=5, réel=3 → crée 2 Pods dans etcd (sans nodeName)
7. Scheduler → détecte 2 pods sans nodeName → filtre + score les nodes
8. Scheduler → écrit spec.nodeName dans les 2 pods
9. Kubelet du node choisi → détecte les pods lui étant assignés
10. Kubelet → demande au Container Runtime de lancer les conteneurs
11. Conteneurs démarrent → Kubelet met à jour le status des pods dans etcd

---
# CHAPITRE 4 — LES COMPOSANTS DES WORKER NODES

## 4.1 Vue d'ensemble d'un Worker Node

```
┌─────────────────────────────────────────────────────────────────┐
│                      WORKER NODE                                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     KUBELET                              │  │
│  │  Agent local — reçoit les ordres, surveille les pods     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  CONTAINER RUNTIME                       │  │
│  │  containerd / CRI-O — lance vraiment les conteneurs      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   KUBE-PROXY                             │  │
│  │  Gère les règles iptables/IPVS pour les Services         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  PLUGIN CNI                              │  │
│  │  Flannel / Calico / Cilium — gère le réseau des pods     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐                       │
│  │ Pod  │  │ Pod  │  │ Pod  │  │ Pod  │  ← tes applications   │
│  └──────┘  └──────┘  └──────┘  └──────┘                       │
│                                                                 │
│  OS Linux + Kernel                                              │
│  Matériel physique (CPU, RAM, disque)                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4.2 Le Kubelet : l'agent local

### Image mentale

Le Kubelet est comme un **chef de brigade dans une cuisine**. Le Control Plane (la direction) lui dit "voici la liste des plats à préparer ce soir". Le Kubelet s'assure que les plats sont préparés, surveille la qualité, et remonte les informations à la direction.

Il ne reçoit pas ses ordres de la direction de façon push — il les va chercher lui-même régulièrement (mais il est aussi notifié via le mécanisme de watch).

### Ce que fait le Kubelet

```
┌─────────────────────────────────────────────────────────────────┐
│                        KUBELET                                  │
│                                                                 │
│  ENREGISTREMENT (au démarrage) :                                │
│  "Bonjour API Server, je suis le node worker-1,                 │
│   j'ai 8 CPU et 16 Go de RAM, voici mes labels..."              │
│                                                                 │
│  SURVEILLANCE PERMANENTE :                                      │
│  - Watch sur l'API Server : "Donne-moi les pods assignés à     │
│    worker-1 (spec.nodeName == worker-1)"                        │
│  - Reçoit la spec de chaque pod à lancer                        │
│                                                                 │
│  LANCEMENT DES PODS :                                           │
│  1. Reçoit la PodSpec d'un nouveau pod                          │
│  2. Demande au CRI (containerd) de pull l'image si besoin      │
│  3. Demande au CNI de créer le réseau du pod                   │
│  4. Demande au CSI de monter les volumes si besoin             │
│  5. Demande au CRI de créer et démarrer les conteneurs         │
│                                                                 │
│  HEALTH MONITORING :                                            │
│  - Exécute livenessProbe → si échoue → redémarre le conteneur  │
│  - Exécute readinessProbe → si échoue → retire du Service      │
│  - Exécute startupProbe → vérifie que l'app a démarré          │
│                                                                 │
│  REPORTING :                                                    │
│  - Envoie le statut des pods à l'API Server                    │
│  - Envoie des "heartbeats" toutes les X secondes               │
│  - Rapporte les métriques (CPU, RAM des pods)                  │
│                                                                 │
│  GARBAGE COLLECTION :                                           │
│  - Supprime les images non utilisées                            │
│  - Supprime les conteneurs arrêtés                              │
└─────────────────────────────────────────────────────────────────┘
```

### Ports utilisés par le Kubelet

| Port | Usage |
|------|-------|
| 10250 | HTTPS : API du Kubelet (kubectl logs, exec, port-forward) |
| 10255 | HTTP : métriques en lecture seule (deprecated) |
| 10256 | HTTP : healthz endpoint |

### Le Kubelet n'obéit qu'à l'API Server

Contrairement à ce qu'on pourrait croire, le Kubelet ne reçoit pas d'ordres du Scheduler directement. Le Scheduler écrit dans etcd → l'API Server notifie le Kubelet via le watch. Le Kubelet parle **uniquement** avec l'API Server.

### Les Static Pods : une exception

Il existe un cas où le Kubelet lance des pods **sans** l'API Server : les **static pods**. Ce sont des manifestes YAML placés directement sur le node dans `/etc/kubernetes/manifests/`. Le Kubelet les lit directement et les lance.

```
/etc/kubernetes/manifests/
├── kube-apiserver.yaml       ← l'API Server lui-même !
├── kube-controller-manager.yaml
├── kube-scheduler.yaml
└── etcd.yaml
```

C'est ainsi que les composants du Control Plane démarrent sur un cluster kubeadm : ce sont des static pods lancés par le Kubelet du master node, **avant** même que l'API Server soit disponible. Le serpent qui se mord la queue est résolu grâce à ce mécanisme.

---

## 4.3 Container Runtime Interface (CRI) : comment les conteneurs sont lancés

### Image mentale

Le CRI est comme l'**interface standard d'une prise électrique**. Peu importe la marque de ton appareil (Docker, containerd, CRI-O), si elle respecte la norme de la prise, elle s'y branche. Kubernetes définit une interface standard (CRI) et le Kubelet parle à n'importe quel runtime qui l'implémente.

### L'évolution du runtime Kubernetes

```
Avant Kubernetes 1.20 :
  Kubelet → Docker → containerd → runc → conteneur
  (Docker comme intermédiaire = overhead inutile)

Après Kubernetes 1.24 (deprecation de Dockershim) :
  Kubelet → containerd → runc → conteneur   (plus léger)
  Kubelet → CRI-O → runc → conteneur        (alternatif)
```

### La stack complète de lancement d'un conteneur

```
┌─────────────────────────────────────────────────────────────────┐
│               LANCEMENT D'UN CONTENEUR                          │
│                                                                 │
│  Kubelet                                                        │
│    │                                                            │
│    │  gRPC (CRI protocol)                                       │
│    ▼                                                            │
│  containerd (High-level Runtime)                                │
│    │  - Pull l'image si absente                                 │
│    │  - Gère le stockage des layers (overlay filesystem)        │
│    │  - Configure les namespaces Linux                          │
│    │                                                            │
│    │  OCI (Open Container Initiative)                           │
│    ▼                                                            │
│  runc (Low-level Runtime)                                       │
│    │  - Crée les namespaces Linux (pid, net, mnt, uts...)       │
│    │  - Configure les cgroups (limites CPU/RAM)                 │
│    │  - Lance le processus du conteneur                         │
│    ▼                                                            │
│  PROCESSUS (le vrai conteneur, c'est juste un processus Linux)  │
└─────────────────────────────────────────────────────────────────┘
```

### Qu'est-ce qu'un conteneur vraiment ?

Un conteneur n'est pas une VM. C'est un processus Linux normal avec :
- Des **namespaces** pour l'isolation (il voit ses propres processus, son propre réseau, son propre filesystem)
- Des **cgroups** pour la limitation des ressources (max 200m CPU, max 256Mi RAM)

```
┌──────────────────────────────────────────────────────────────┐
│                  CE QU'EST UN CONTENEUR                       │
│                                                              │
│  Namespaces Linux (isolation) :                              │
│  ├── pid namespace    → voit seulement ses processus         │
│  ├── net namespace    → son propre réseau (eth0, IP, etc.)   │
│  ├── mnt namespace    → son propre filesystem                │
│  ├── uts namespace    → son propre hostname                  │
│  ├── user namespace   → mapping UID/GID                      │
│  └── ipc namespace    → IPC isolé                            │
│                                                              │
│  Cgroups (limitation des ressources) :                       │
│  ├── cpu.max          → limite CPU                           │
│  ├── memory.max       → limite RAM                           │
│  └── blkio            → limite I/O disque                    │
│                                                              │
│  Résultat : un processus qui "croit" être seul sur           │
│  son serveur mais partage réellement le kernel               │
└──────────────────────────────────────────────────────────────┘
```

---

## 4.4 Kube-proxy : les règles réseau des Services

### Image mentale

Kube-proxy est comme un **central téléphonique** de bureau. Quand tu appelles le standard "Service web-app", il redirige ton appel vers l'un des vrais téléphones disponibles (les pods). Si un téléphone est déconnecté, il l'enlève automatiquement de la rotation.

### Ce que fait Kube-proxy

```
┌─────────────────────────────────────────────────────────────────┐
│                      KUBE-PROXY                                 │
│                                                                 │
│  Surveille les Services et Endpoints dans l'API Server          │
│                                                                 │
│  Pour chaque Service ClusterIP créé :                           │
│  Exemple: Service "web" → ClusterIP 10.96.0.100 : port 80      │
│  Pods: 10.42.1.5:8080, 10.42.2.3:8080, 10.42.3.7:8080         │
│                                                                 │
│  Kube-proxy crée des règles :                                   │
│  "Toute connexion vers 10.96.0.100:80                           │
│   → redirige vers 10.42.1.5:8080 OU 10.42.2.3:8080            │
│      OU 10.42.3.7:8080 (round-robin)"                          │
│                                                                 │
│  Ces règles peuvent être implémentées de 3 façons :             │
│  1. iptables (défaut) — règles iptables DNAT                   │
│  2. IPVS — plus performant pour de nombreux Services            │
│  3. userspace (ancien, déprecié)                               │
└─────────────────────────────────────────────────────────────────┘
```

### Mode iptables (défaut)

```bash
# Exemple simplifié de règles iptables créées par kube-proxy :

# Paquet vers ClusterIP 10.96.0.100:80
-A KUBE-SERVICES -d 10.96.0.100/32 -p tcp --dport 80 \
  -j KUBE-SVC-ABCDEF

# Round-robin entre 3 pods (statistique)
-A KUBE-SVC-ABCDEF -m statistic --mode random --probability 0.33 \
  -j KUBE-SEP-POD1
-A KUBE-SVC-ABCDEF -m statistic --mode random --probability 0.5 \
  -j KUBE-SEP-POD2
-A KUBE-SVC-ABCDEF \
  -j KUBE-SEP-POD3

# DNAT vers les IPs réelles des pods
-A KUBE-SEP-POD1 -p tcp -j DNAT --to-destination 10.42.1.5:8080
-A KUBE-SEP-POD2 -p tcp -j DNAT --to-destination 10.42.2.3:8080
-A KUBE-SEP-POD3 -p tcp -j DNAT --to-destination 10.42.3.7:8080
```

**Point important :** kube-proxy ne fait PAS de proxy réseau au sens traditionnel. Le trafic ne passe pas *à travers* kube-proxy — kube-proxy crée des règles dans le kernel Linux (iptables/IPVS) et le trafic est redirigé directement au niveau kernel, sans passer par un processus proxy.

---

## 4.5 CNI : Container Network Interface

### Image mentale

Le CNI est comme un **service de plomberie** pour les pods. Quand un pod est créé, quelqu'un doit lui "brancher un tuyau réseau" (lui donner une IP, configurer les routes). Le CNI est le standard qui définit comment ce branchement se fait. Flannel, Calico, Cilium sont des plombiers qui suivent ce standard.

### Ce que fait le CNI

```
┌─────────────────────────────────────────────────────────────────┐
│                        CNI                                      │
│                                                                 │
│  Quand un pod est créé :                                        │
│  1. Le Kubelet appelle le plugin CNI installé                   │
│  2. Le CNI :                                                    │
│     - Crée une interface réseau virtuelle (veth pair)           │
│     - Attribue une IP au pod (depuis le CIDR pod)               │
│     - Configure les routes pour que le pod joigne les autres    │
│     - Configure les règles pour que les pods de différents      │
│       nodes se joignent (overlay network ou BGP)                │
│                                                                 │
│  Résultat : chaque pod a sa propre IP unique dans le cluster    │
│  et peut communiquer avec n'importe quel autre pod              │
│  (même sur un autre node) sans NAT                              │
└─────────────────────────────────────────────────────────────────┘
```

### Les principaux CNI

| CNI | Approche | Points forts | Usage typique |
|-----|----------|-------------|---------------|
| Flannel | VXLAN overlay | Simple, léger | Dev, K3s default |
| Calico | BGP + policy | NetworkPolicies puissantes | Production |
| Cilium | eBPF | Très performant, observabilité | Production moderne |
| Weave | Mesh overlay | Simple, chiffrement intégré | Dev/Test |

### L'overlay network (VXLAN) expliqué

```
Node 1 (10.0.0.1)             Node 2 (10.0.0.2)
├── Pod A (10.42.0.1)          ├── Pod C (10.42.1.1)
└── Pod B (10.42.0.2)          └── Pod D (10.42.1.2)

Pod A veut parler à Pod C (10.42.1.1) :

1. Pod A envoie un paquet : src=10.42.0.1, dst=10.42.1.1
2. Flannel intercepte ce paquet sur Node 1
3. Flannel encapsule dans un paquet VXLAN :
   Outer: src=10.0.0.1, dst=10.0.0.2 (IPs des nodes)
   Inner: src=10.42.0.1, dst=10.42.1.1 (IPs des pods)
4. Le paquet traverse le réseau physique de 10.0.0.1 à 10.0.0.2
5. Flannel sur Node 2 décapsule
6. Pod C reçoit le paquet original : src=10.42.0.1, dst=10.42.1.1
```

---

## 4.6 Ce qu'est réellement un Pod

### Image mentale

Un pod est comme une **cabine téléphonique partagée**. Plusieurs téléphones (conteneurs) peuvent être dans la même cabine. Ils partagent la même ligne téléphonique (interface réseau, adresse IP) et peuvent se parler en interne via localhost. Mais chaque téléphone a sa propre logique.

### La structure interne d'un Pod

```
┌─────────────────────────────────────────────────────────────────┐
│                          POD                                    │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PAUSE CONTAINER (infrastructure container)  │  │
│  │  - Le tout premier conteneur créé dans le pod            │  │
│  │  - "Tient" le namespace réseau et IPC                    │  │
│  │  - Ne fait rien sauf dormir (pause)                      │  │
│  │  - Tous les autres conteneurs rejoignent son namespace   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────┐   ┌──────────────────────────────────┐   │
│  │  INIT CONTAINER  │   │        INIT CONTAINER 2          │   │
│  │  (s'exécute      │   │  (s'exécute après init 1)        │   │
│  │  avant tout)     │   │                                  │   │
│  └──────────────────┘   └──────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────┐   ┌──────────────────────────────────┐   │
│  │  CONTENEUR APP   │   │     CONTENEUR SIDECAR            │   │
│  │  (ton appli)     │   │  (log collector, proxy, etc.)    │   │
│  └──────────────────┘   └──────────────────────────────────┘   │
│                                                                 │
│  IP du pod : 10.42.0.45 (unique dans le cluster)               │
│  Partagée par TOUS les conteneurs du pod                        │
│                                                                 │
│  Volume partagé entre conteneurs :                              │
│  /shared-data accessible dans tous les conteneurs              │
└─────────────────────────────────────────────────────────────────┘
```

### Le pause container

Le pause container est un détail d'implémentation essentiel. Il est créé en premier et maintient le namespace réseau du pod. Quand un conteneur applicatif redémarre, le namespace réseau n'est pas recréé — il appartient au pause container qui lui survit.

```bash
# Sur un node Kubernetes, tu verras :
docker ps | grep pause
# ou
crictl ps | grep pause
# → un conteneur "pause" pour chaque pod
```

### Pourquoi les pods sont éphémères

Un pod est conçu pour être **jetable**. Il ne se migre jamais — il est supprimé et recréé. Son IP change à chaque recréation. C'est pourquoi tu ne dois jamais utiliser l'IP d'un pod directement dans ton code : utilise un Service à la place.

---

## 4.7 Le cycle de vie complet du lancement d'un pod

Voici la séquence complète depuis la commande jusqu'au conteneur en cours d'exécution :

```
┌──────────────────────────────────────────────────────────────────┐
│         CYCLE DE VIE COMPLET DU LANCEMENT D'UN POD               │
│                                                                  │
│  1. kubectl apply -f pod.yaml                                    │
│     └── HTTP POST /api/v1/namespaces/default/pods                │
│                                                                  │
│  2. API Server reçoit la requête                                 │
│     └── Authentification (certificat TLS)                        │
│     └── Autorisation (RBAC : peut-il créer des pods ?)           │
│     └── Admission Control (webhooks de validation)               │
│     └── Validation du schéma YAML                                │
│     └── Écrit le Pod dans etcd (status.phase = Pending)          │
│     └── Notifie les watchers                                     │
│                                                                  │
│  3. Scheduler (watcher sur les pods Pending sans nodeName)       │
│     └── Filtre les nodes : qui peut accueillir ce pod ?          │
│     └── Score les nodes éligibles                                │
│     └── Choisit le meilleur node                                 │
│     └── Écrit spec.nodeName = "worker-2" dans etcd              │
│                                                                  │
│  4. Kubelet de worker-2 (watcher sur ses pods)                   │
│     └── Détecte le nouveau pod assigné à lui                     │
│     └── Contacte le Container Runtime (containerd)               │
│                                                                  │
│  5. containerd                                                   │
│     └── Vérifie si l'image est en cache local                    │
│     └── Si non : pull l'image depuis le registry                 │
│     └── Crée le network namespace (via CNI plugin)               │
│     └── Configure les cgroups (limites CPU/RAM)                  │
│     └── Lance le pause container                                 │
│     └── Exécute les init containers (séquentiellement)           │
│     └── Lance les conteneurs applicatifs                         │
│                                                                  │
│  6. CNI Plugin                                                   │
│     └── Crée une paire veth (virtual ethernet)                   │
│     └── Connecte un bout au pod, l'autre au node                 │
│     └── Attribue une IP du CIDR pod au pod                       │
│     └── Configure les routes                                     │
│                                                                  │
│  7. Kubelet (monitoring)                                         │
│     └── Démarre les probes (liveness, readiness, startup)        │
│     └── Rapporte status.phase = Running à l'API Server          │
│                                                                  │
│  8. Endpoint Controller (watcher sur Pods et Services)           │
│     └── Si le pod a des labels matchant un Service :             │
│         Ajoute l'IP du pod aux Endpoints du Service             │
│                                                                  │
│  9. Kube-proxy (watcher sur Endpoints)                           │
│     └── Met à jour les règles iptables pour inclure le nouveau pod│
│                                                                  │
│  Le pod est maintenant opérationnel et accessible !              │
└──────────────────────────────────────────────────────────────────┘
```

---

## 4.8 Résumé du chapitre

```
┌────────────────────────────────────────────────────────────────┐
│              RETENIR DU CHAPITRE 4                             │
│                                                                │
│  Kubelet     : Agent local sur chaque node. Reçoit les specs  │
│                des pods, demande au CRI de les lancer,        │
│                surveille leur santé, rapporte à l'API Server. │
│                Port 10250.                                     │
│                                                                │
│  CRI/Runtime : containerd ou CRI-O. Lance vraiment les        │
│                conteneurs via runc. Implémente l'interface CRI.│
│                                                                │
│  Kube-proxy  : Maintient les règles iptables/IPVS pour que   │
│                les Services redirigent vers les bons pods.    │
│                Le trafic ne passe PAS par kube-proxy.         │
│                                                                │
│  CNI         : Donne une IP à chaque pod, configure le        │
│                réseau inter-pods (même cross-node).           │
│                                                                │
│  Pod         : Groupe de 1+ conteneurs partageant une IP      │
│                et des volumes. Unité de base Kubernetes.      │
│                Éphémère par nature.                            │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 5 — LE CYCLE DE VIE COMPLET D'UN YAML

## 5.1 Image mentale : le voyage d'un YAML

Imagine une **lettre administrative**. Tu l'écris (ton YAML), tu l'envoies à la mairie (l'API Server), la mairie la valide, la classe dans ses archives (etcd), et déclenche les bons services (controllers, kubelet) pour exécuter ce qui est demandé.

Suivons ce voyage étape par étape avec un exemple concret.

---

## 5.2 Le YAML de départ

```yaml
# mon-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
  labels:
    app: web
    version: "2.0"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```

---

## 5.3 Étape 1 : kubectl transforme le YAML en requête HTTP

```
╔══════════════════════════════════════════════════════════════╗
║  kubectl apply -f mon-deployment.yaml                        ║
╚══════════════════════════════════════════════════════════════╝

kubectl fait plusieurs choses :

1. Lit le fichier YAML
2. Sérialise en JSON (l'API Kubernetes parle JSON, pas YAML)
3. Détermine l'URL de l'API à appeler :
   - apiVersion: apps/v1       → /apis/apps/v1
   - kind: Deployment          → /deployments
   - namespace: production     → /namespaces/production/
   
   URL complète :
   POST https://api-server:6443/apis/apps/v1/namespaces/production/deployments

4. Ajoute les headers :
   - Authorization: Bearer <token>
   - Content-Type: application/json
   - Accept: application/json

5. Envoie la requête HTTP

Note : kubectl apply est intelligent.
  - Si l'objet n'existe pas → HTTP POST (création)
  - Si l'objet existe déjà  → HTTP PATCH (mise à jour)
    (il compare avec l'annotation kubectl.kubernetes.io/last-applied-configuration)
```

---

## 5.4 Étape 2 : L'API Server traite la requête

```
╔══════════════════════════════════════════════════════════════╗
║  API SERVER : PIPELINE DE TRAITEMENT                         ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────┐
│  AUTHENTIFICATION                                        │
│                                                          │
│  "Qui es-tu ?"                                           │
│                                                          │
│  Méthodes supportées (essayées dans l'ordre) :           │
│  1. Client certificate TLS (le plus courant en prod)    │
│  2. Bearer token (utilisé par les ServiceAccounts)      │
│  3. HTTP Basic Auth (à éviter)                          │
│  4. Anonymous (si activé, très rare)                    │
│                                                          │
│  Résultat : identité = "user:andy" ou                   │
│             "serviceaccount:default:my-sa"              │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  AUTORISATION (RBAC)                                     │
│                                                          │
│  "As-tu le droit ?"                                      │
│                                                          │
│  Vérifie : l'identité authentifiée peut-elle             │
│  faire "create" sur "deployments" dans                   │
│  "namespace production" ?                                │
│                                                          │
│  Cherche un RoleBinding ou ClusterRoleBinding qui        │
│  lie l'identité à un Role ayant cette permission.       │
│                                                          │
│  Si non → HTTP 403 Forbidden                            │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  ADMISSION CONTROL                                       │
│                                                          │
│  "Est-ce acceptable selon nos politiques ?"              │
│                                                          │
│  Phase 1 - Mutating Webhooks (modifient la requête) :   │
│  - Injection de sidecars (Istio, etc.)                  │
│  - Ajout de labels/annotations automatiques             │
│  - Définition de valeurs par défaut                     │
│                                                          │
│  Phase 2 - Validating Webhooks (valident sans modifier):│
│  - Vérification des politiques de sécurité              │
│  - Vérification des quotas                              │
│  - Vérification des noms d'images approuvées            │
│                                                          │
│  Admission controllers intégrés (exemples) :            │
│  - LimitRanger : ajoute des limits si manquantes        │
│  - ResourceQuota : vérifie que le quota n'est pas dépassé│
│  - NamespaceLifecycle : refuse si namespace supprimé    │
│  - PodSecurity : vérifie la politique de sécurité       │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  VALIDATION DU SCHÉMA                                    │
│                                                          │
│  "Le YAML est-il bien formé ?"                           │
│                                                          │
│  - Tous les champs obligatoires sont présents ?         │
│  - Les types sont corrects ? (int là où int attendu)    │
│  - Les valeurs sont dans les intervalles valides ?      │
│                                                          │
│  Si non → HTTP 422 Unprocessable Entity                 │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  PERSISTENCE DANS ETCD                                   │
│                                                          │
│  L'API Server sérialise l'objet en protobuf             │
│  et l'écrit dans etcd à la clé :                        │
│  /registry/deployments/production/web-app               │
│                                                          │
│  L'API Server ajoute des champs automatiquement :       │
│  - metadata.uid           → identifiant unique          │
│  - metadata.resourceVersion → version de l'objet        │
│  - metadata.creationTimestamp                           │
│  - metadata.generation                                  │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  NOTIFICATION DES WATCHERS                               │
│                                                          │
│  L'API Server envoie un événement ADDED sur toutes      │
│  les connexions de watch qui observent les              │
│  Deployments dans le namespace production.              │
│                                                          │
│  Destinataires : Deployment Controller, et tout         │
│  autre composant qui surveille les Deployments.         │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  RÉPONSE À KUBECTL                                       │
│                                                          │
│  HTTP 201 Created                                        │
│  Body : l'objet Deployment complet (avec les champs     │
│         ajoutés automatiquement par l'API Server)       │
│                                                          │
│  kubectl affiche :                                       │
│  deployment.apps/web-app created                        │
└─────────────────────────────────────────────────────────┘
```

---

## 5.5 Étape 3 : Le Deployment Controller réagit

```
╔══════════════════════════════════════════════════════════════╗
║  DEPLOYMENT CONTROLLER                                       ║
╚══════════════════════════════════════════════════════════════╝

1. Reçoit l'événement ADDED (nouveau Deployment)

2. Lit le Deployment : replicas=3, selector=app:web

3. Cherche les ReplicaSets existants appartenant à ce Deployment
   (via ownerReferences)
   → Aucun trouvé (c'est un nouveau Deployment)

4. Crée un ReplicaSet :
   apiVersion: apps/v1
   kind: ReplicaSet
   metadata:
     name: web-app-7d9f8c6b4
     ownerReferences:
     - apiVersion: apps/v1
       kind: Deployment
       name: web-app
       uid: abc-123...
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: web
         pod-template-hash: 7d9f8c6b4   ← hash du template
     template:
       # ... copie du template du Deployment

5. Envoie la création du ReplicaSet à l'API Server
   → API Server écrit dans etcd
   → Notifie le ReplicaSet Controller
```

---

## 5.6 Étape 4 : Le ReplicaSet Controller crée les Pods

```
╔══════════════════════════════════════════════════════════════╗
║  REPLICASET CONTROLLER                                       ║
╚══════════════════════════════════════════════════════════════╝

1. Reçoit l'événement ADDED (nouveau ReplicaSet)

2. Lit le ReplicaSet : replicas=3

3. Compte les pods existants avec les labels
   app:web + pod-template-hash:7d9f8c6b4
   → 0 pods trouvés

4. Écart = 3 - 0 = 3 → doit créer 3 pods

5. Crée 3 objets Pod dans etcd :
   - web-app-7d9f8c6b4-xk2p1  (nom = replicaset + suffixe aléatoire)
   - web-app-7d9f8c6b4-mn4q9
   - web-app-7d9f8c6b4-rt7wz

   Chaque Pod :
   - spec.nodeName est VIDE → pod en état Pending
   - ownerReferences pointe vers le ReplicaSet
   - Contient la spec complète des conteneurs

6. Les 3 pods sont maintenant dans etcd avec status.phase=Pending
```

---

## 5.7 Étape 5 : Le Scheduler assigne les pods aux nodes

```
╔══════════════════════════════════════════════════════════════╗
║  SCHEDULER                                                   ║
╚══════════════════════════════════════════════════════════════╝

Pour chaque pod Pending (sans nodeName) :

Pod: web-app-7d9f8c6b4-xk2p1
  requests: cpu=100m, memory=128Mi

Filtrage des nodes :
  worker-1: 3 CPU libres, 4Gi RAM libre → ÉLIGIBLE
  worker-2: 0.5 CPU libre, 512Mi RAM libre → ÉLIGIBLE
  worker-3: 0.2 CPU libre, 100Mi RAM libre → ÉLIMINÉ (RAM insuffisante)

Scoring :
  worker-1: score=85 (beaucoup de ressources libres)
  worker-2: score=52 (ressources limitées)

Décision : worker-1

Action : PATCH /api/v1/namespaces/production/pods/web-app-...-xk2p1
  spec.nodeName = "worker-1"

L'API Server met à jour etcd.
Le Kubelet de worker-1 est notifié.

(Répété pour les 2 autres pods)
```

---

## 5.8 Étape 6 : Le Kubelet lance les conteneurs

```
╔══════════════════════════════════════════════════════════════╗
║  KUBELET (worker-1)                                          ║
╚══════════════════════════════════════════════════════════════╝

1. Reçoit l'événement : nouveau pod assigné à worker-1

2. Lit la PodSpec :
   - image: nginx:1.25
   - requests: cpu=100m, memory=128Mi
   - limits: cpu=200m, memory=256Mi
   - containerPort: 80

3. Vérifie si l'image est en cache local
   → Non → demande à containerd de puller nginx:1.25

4. containerd pull nginx:1.25 depuis Docker Hub
   Layers téléchargées et stockées dans /var/lib/containerd/

5. Kubelet demande au CNI de créer le réseau :
   → CNI crée une veth pair
   → Attribue IP 10.42.1.23 au pod
   → Configure les routes

6. Kubelet demande à containerd de créer le pod :
   a. Lance le pause container (tient le namespace réseau)
   b. Crée le namespace cgroup avec les limites
   c. Lance le conteneur nginx avec :
      - namespace réseau du pause container
      - cgroups configurés (max 200m CPU, max 256Mi RAM)
      - Variables d'environnement injectées
      - Volumes montés si applicable

7. Kubelet démarre les probes (si définies)

8. Kubelet met à jour le statut dans l'API Server :
   status.phase = Running
   status.podIP = 10.42.1.23
   status.containerStatuses[0].ready = true
   status.containerStatuses[0].state.running.startedAt = "..."
```

---

## 5.9 Étape 7 : Le pod devient accessible

```
╔══════════════════════════════════════════════════════════════╗
║  ENDPOINT CONTROLLER + KUBE-PROXY                           ║
╚══════════════════════════════════════════════════════════════╝

Si un Service avec selector app:web existe :

Endpoint Controller :
1. Détecte le nouveau pod Ready avec labels app:web
2. Ajoute 10.42.1.23:80 aux Endpoints du Service web-svc
3. Écrit dans etcd

Kube-proxy (sur CHAQUE node) :
1. Reçoit l'événement : Endpoints de web-svc mis à jour
2. Met à jour les règles iptables/IPVS :
   ClusterIP → [10.42.1.23:80, 10.42.2.15:80, 10.42.3.8:80]

Le pod est maintenant accessible via le Service !
```

---

## 5.10 Récapitulatif visuel complet

```
kubectl apply -f deployment.yaml
         │
         ▼
┌──────────────┐
│  API Server  │ ← Authentifie, Autorise, Valide, Stocke dans etcd
└──────────────┘
         │ notifie watchers
         ▼
┌──────────────────────┐
│ Deployment Controller│ ← Crée ReplicaSet
└──────────────────────┘
         │ ReplicaSet créé dans etcd
         ▼
┌──────────────────────┐
│ ReplicaSet Controller│ ← Crée 3 Pods (sans nodeName)
└──────────────────────┘
         │ Pods créés dans etcd (Pending)
         ▼
┌──────────────────────┐
│     Scheduler        │ ← Assigne chaque pod à un node
└──────────────────────┘
         │ spec.nodeName écrit dans etcd
         ▼
┌──────────────────────┐
│  Kubelet (node X)    │ ← Lance les conteneurs
└──────────────────────┘
         │ utilise
    ┌────┴────┐
    ▼         ▼
containerd   CNI Plugin
(conteneurs) (réseau IP)
         │
         ▼
┌──────────────────────┐
│  Pod Running         │ ← Accessible !
│  IP: 10.42.1.23      │
└──────────────────────┘
         │
         ▼
┌──────────────────────┐
│ Endpoint Controller  │ ← Ajoute l'IP au Service
└──────────────────────┘
         │
         ▼
┌──────────────────────┐
│    Kube-proxy        │ ← Met à jour iptables
└──────────────────────┘
         │
         ▼
  Trafic routé vers le pod !
```

---

---

# CHAPITRE 6 — YAML : SYNTAXE COMPLÈTE

## 6.1 Qu'est-ce que YAML ?

**YAML** = "YAML Ain't Markup Language" (acronyme récursif).

C'est un format de sérialisation de données **lisible par les humains**. Kubernetes l'utilise pour décrire toutes ses ressources. Comprendre YAML parfaitement est essentiel — la majorité des bugs Kubernetes viennent d'erreurs YAML.

**Image mentale :** YAML est comme un **plan de maison en langage naturel**. Plutôt que des plans d'architecte complexes (XML, JSON avec toutes leurs accolades), YAML ressemble à une description textuelle structurée par l'indentation.

---

## 6.2 La règle n°1 : l'indentation

**YAML utilise des ESPACES, jamais des tabulations.**

C'est la source d'erreur numéro une. Si tu utilises une tabulation à la place d'espaces, le parser YAML rejettera le fichier.

```yaml
# CORRECT : espaces (2 espaces par niveau recommandé)
parent:
  enfant:
    petit-enfant: valeur

# INCORRECT : tabulations (NE PAS FAIRE)
parent:
	enfant:       ← TABULATION = ERREUR
		petit-enfant: valeur
```

**Combien d'espaces ?** Kubernetes utilise conventionnellement **2 espaces** par niveau. D'autres projets utilisent 4. L'important c'est la **cohérence** : tous les enfants du même parent doivent avoir le même niveau d'indentation.

```yaml
# Les deux sont valides YAML, mais 2 espaces est la convention Kubernetes
spec:           # niveau 0
  containers:   # niveau 1 (2 espaces)
    - name: web # niveau 2 (4 espaces au total)
```

---

## 6.3 Les types de données scalaires

### Chaînes de caractères (strings)

```yaml
# Sans guillemets (le plus courant)
name: mon-pod
image: nginx:1.25
message: Bonjour le monde

# Avec guillemets doubles (nécessaire si la valeur contient des caractères spéciaux)
version: "1.25"          # guillemets car on veut une string, pas un float
label: "app: web"        # guillemets car contient ":"
message: "C'est bon"     # guillemets pour l'apostrophe

# Avec guillemets simples (la valeur est littérale, pas d'interprétation)
path: '\n'               # le \n est littéral, pas un saut de ligne
message: 'He said "hello"'  # les guillemets doubles dans la valeur

# Différence guillemets simples vs doubles :
a: "ligne1\nligne2"     # \n est interprété comme saut de ligne
b: 'ligne1\nligne2'     # \n est littéral (backslash + n)
```

### Quand faut-il des guillemets ?

```yaml
# Cas où les guillemets sont OBLIGATOIRES :

# 1. La valeur ressemble à un autre type
version: "1.25"     # sans guillemets → float 1.25
active: "true"      # sans guillemets → booléen true
count: "123"        # sans guillemets → entier 123
nothing: "null"     # sans guillemets → null

# 2. La valeur contient des caractères spéciaux YAML
label: "app: frontend"   # contient ":"
path: "a/b"              # OK sans guillemets, mais les guillemets clarifient
value: "[1, 2, 3]"       # sans guillemets → liste YAML

# 3. La valeur commence par un caractère spécial
value: ":quelquechose"   # commence par ":"
value: "*glob*"          # commence par "*"
value: "!important"      # commence par "!"
value: "#commentaire"    # commence par "#"

# Cas où les guillemets NE SONT PAS nécessaires (mais OK) :
name: mon-pod        # tirets OK
image: nginx:1.25    # le ":" au milieu d'une string est OK sans guillemets
                     # SAUF si la string est une clé (clé:valeur)
```

### Entiers et flottants

```yaml
replicas: 3           # entier
port: 8080            # entier
weight: 0.5           # float
scientific: 1.5e10    # notation scientifique

# ATTENTION : les ports et replicas sont des entiers
# Ne PAS écrire :
replicas: "3"         # ERREUR : c'est une string, Kubernetes attend un int
```

### Booléens

```yaml
# Valeurs booléennes reconnues par YAML :
enabled: true         # ← recommandé
enabled: True         # également valide
enabled: TRUE         # également valide
disabled: false       # ← recommandé
disabled: False       # également valide
disabled: FALSE       # également valide

# YAML 1.1 (ancien) reconnaissait aussi :
# yes, no, on, off → booléens
# YAML 1.2 (actuel) NE les reconnaît plus comme booléens
# Mais soyez prudents : certains parsers YAML sont encore en 1.1

# Recommandation Kubernetes : utiliser true/false en minuscules
```

### Null

```yaml
# Valeurs null :
valeur: null       # ← recommandé
valeur: ~          # équivalent null
valeur:            # clé sans valeur = null

# Différence importante :
clé: null          # clé présente, valeur null
                   # vs
# (clé absente)    # clé absente du tout

# Pour Kubernetes, ces deux cas peuvent avoir des effets différents
```

---

## 6.4 Les structures de données

### Dictionnaire (mapping)

```yaml
# Syntaxe en bloc (la plus courante)
personne:
  nom: Dupont
  prénom: Jean
  âge: 30

# Syntaxe en ligne (flow style)
personne: {nom: Dupont, prénom: Jean, âge: 30}

# Imbrication profonde
spec:
  template:
    spec:
      containers:
        - name: web
          image: nginx
```

### Liste (sequence)

```yaml
# Syntaxe en bloc avec tirets (la plus courante)
fruits:
  - pomme
  - poire
  - banane

# Syntaxe en ligne (flow style)
fruits: [pomme, poire, banane]

# Liste d'objets (la plus fréquente dans Kubernetes)
containers:
  - name: web
    image: nginx
    ports:
      - containerPort: 80
  - name: sidecar
    image: fluentd

# ATTENTION au positionnement du tiret
# Le tiret EST le premier élément de l'objet de la liste
containers:
  - name: web       ← le tiret marque le début du 1er objet
    image: nginx    ← même niveau que "name" (fait partie du même objet)
  - name: sidecar   ← nouveau tiret = nouvel objet de la liste
    image: fluentd
```

---

## 6.5 Les caractères spéciaux YAML

### Le deux-points `:`

```yaml
# Le ":" est le séparateur clé:valeur
clé: valeur

# RÈGLE : un espace après le ":" est OBLIGATOIRE
# Sauf en fin de ligne (valeur nulle)

# CORRECT :
name: mon-pod
value:          ← valeur nulle, pas d'espace nécessaire

# INCORRECT :
name:mon-pod    ← pas d'espace → ERREUR YAML

# Dans une valeur, ":" ne nécessite PAS de guillemets si au milieu d'un mot
image: nginx:1.25    ← OK, le ":" est dans la valeur
host: localhost:8080 ← OK

# Mais si la valeur COMMENCE par ":", des guillemets sont nécessaires
value: ":8080"    ← guillemets obligatoires
```

### Le tiret `-`

```yaml
# Tiret = élément de liste
items:
  - premier
  - deuxième

# RÈGLE : un espace après le tiret est OBLIGATOIRE
items:
  - premier    ← CORRECT
  -premier     ← INCORRECT (pas d'espace)

# Tiret dans un nom de clé : OK sans guillemets
ma-clé: valeur
```

### Le dièse `#`

```yaml
# Commentaire jusqu'à la fin de la ligne
name: mon-pod  # ceci est un commentaire
# toute cette ligne est un commentaire

# YAML ne supporte PAS les commentaires en bloc (/* ... */)
# Chaque ligne doit avoir son propre #
```

### Les caractères `|` et `>`

```yaml
# | (Literal Block Scalar) : préserve les sauts de ligne
description: |
  Première ligne.
  Deuxième ligne.
  Troisième ligne.

# Résultat : "Première ligne.\nDeuxième ligne.\nTroisième ligne.\n"

# > (Folded Block Scalar) : replie les sauts de ligne en espaces
description: >
  Ceci est une longue
  description qui continue
  sur plusieurs lignes.

# Résultat : "Ceci est une longue description qui continue sur plusieurs lignes.\n"

# Les deux sont très utilisés dans Kubernetes pour :
# - Les scripts inline dans les ConfigMaps
# - Les commandes shell longues
# - Les certificats TLS (qui font plusieurs lignes)
```

### Modificateurs de bloc `|` et `>`

```yaml
# | seul : conserve le saut de ligne final
valeur: |
  ligne1
  ligne2

# |- : supprime le saut de ligne final (chomp)
valeur: |-
  ligne1
  ligne2

# |+ : conserve TOUS les sauts de ligne finaux
valeur: |+
  ligne1
  ligne2


# Nombre d'espaces d'indentation (optionnel)
# |2 signifie que le contenu commence à 2 espaces d'indentation du marqueur
valeur: |2
  ligne1
  ligne2
```

### Les accolades `{}` et crochets `[]`

```yaml
# {} : dictionnaire inline (flow mapping)
metadata: {name: mon-pod, namespace: default}

# [] : liste inline (flow sequence)
ports: [80, 443, 8080]

# Mélange bloc et inline
spec:
  selector:
    matchLabels: {app: web}   ← dictionnaire inline
  ports: [{port: 80, targetPort: 8080}]  ← liste inline d'objets
```

---

## 6.6 Les ancres et alias (réutilisation)

```yaml
# Ancre (&) : définit une valeur réutilisable
defaults: &defaults
  image: nginx:1.25
  pullPolicy: IfNotPresent

# Alias (*) : réutilise une ancre
production:
  <<: *defaults              # merge de l'ancre
  replicas: 10

staging:
  <<: *defaults              # même ancre réutilisée
  replicas: 2

# Résultat équivalent à :
production:
  image: nginx:1.25
  pullPolicy: IfNotPresent
  replicas: 10

staging:
  image: nginx:1.25
  pullPolicy: IfNotPresent
  replicas: 2

# ATTENTION : Kubernetes lui-même ne supporte pas toujours les ancres YAML
# selon l'outil utilisé. kubectl les supporte.
# Les Helm templates n'utilisent pas les ancres YAML (ils ont leur propre système)
```

---

## 6.7 Documents multiples

```yaml
# Le séparateur --- permet plusieurs documents dans un seul fichier
# Très utilisé dans Kubernetes pour grouper des ressources liées

apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
  - port: 80

---    ← séparateur de document

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  # ...

# kubectl apply -f fichier.yaml appliquera LES DEUX ressources
```

---

## 6.8 Les questions fréquentes sur la syntaxe YAML Kubernetes

### Pourquoi `containers:` est une liste mais `spec:` est un dictionnaire ?

```yaml
spec:              # dictionnaire : une seule spec par pod
  containers:      # liste : un pod peut avoir PLUSIEURS conteneurs
    - name: web    # premier conteneur
    - name: proxy  # deuxième conteneur
```

La règle : si un objet Kubernetes peut exister en **plusieurs exemplaires** au même niveau → c'est une liste avec `-`. Si c'est un objet **unique** → c'est un dictionnaire.

### Pourquoi parfois `key:` sans valeur sur la même ligne ?

```yaml
# Ces trois formes sont équivalentes en YAML :

# Forme 1 : valeur sur la même ligne
containers: []     # liste vide

# Forme 2 : valeur sur la ligne suivante
containers:
  - name: web

# Forme 3 : clé suivie d'une sous-structure (implicitement dictionnaire)
spec:
  containers:    ← "containers" est une clé dont la valeur est la liste qui suit
    - name: web
```

### Pourquoi `name:` apparaît si souvent ?

```yaml
# Dans Kubernetes, PRESQUE TOUT s'appelle "name" à un niveau ou un autre :

metadata:
  name: mon-pod          ← nom de l'objet Kubernetes

spec:
  containers:
  - name: mon-conteneur  ← nom du conteneur (dans la liste)
    env:
    - name: MA_VAR       ← nom de la variable d'environnement (dans la liste)
      value: "hello"
    volumeMounts:
    - name: mon-volume   ← nom du volume (référence)
      mountPath: /data
  volumes:
  - name: mon-volume     ← nom du volume (définition)
    emptyDir: {}
```

Les objets **liste** dans Kubernetes contiennent souvent des sous-objets avec un champ `name` pour les identifier.

### Pourquoi `- name:` et non `name:` dans `containers` ?

```yaml
containers:
  - name: web      ← le tiret est OBLIGATOIRE car containers est une LISTE
    image: nginx   ← name et image appartiennent au MÊME objet de la liste

# Sans tiret, YAML ne saurait pas où commence le prochain objet de la liste
```

---

## 6.9 Erreurs YAML fréquentes

### Erreur 1 : indentation incorrecte

```yaml
# INCORRECT
spec:
  containers:
  - name: web       ← mal aligné (devrait être indenté)
    image: nginx

# CORRECT
spec:
  containers:
    - name: web
      image: nginx
```

### Erreur 2 : tabulation au lieu d'espaces

```yaml
# INCORRECT (tabulation invisible mais elle est là)
spec:
	containers:    ← TABULATION = ERREUR FATALE
	  - name: web
```

### Erreur 3 : guillemets manquants autour d'un entier pour un champ string

```yaml
# Kubernetes attend une string pour les labels
labels:
  version: 1.0    ← PROBLÈME : 1.0 est un float, pas une string

# CORRECT
labels:
  version: "1.0"   ← string explicite
```

### Erreur 4 : mauvais niveau d'indentation dans les listes d'objets

```yaml
# INCORRECT : image n'est pas au même niveau que name
containers:
  - name: web
  image: nginx    ← ERREUR : image est au niveau containers, pas de l'objet

# CORRECT
containers:
  - name: web
    image: nginx  ← image est indenté par rapport au tiret
```

### Erreur 5 : oublier le tiret pour une liste

```yaml
# INCORRECT
containers:
  name: web     ← manque le tiret → containers est un dict, pas une liste

# CORRECT
containers:
  - name: web
```

---

## 6.10 Valider son YAML avant d'appliquer

```bash
# Vérifier la syntaxe YAML (sans appliquer)
kubectl apply -f mon-fichier.yaml --dry-run=client

# Valider contre le schéma Kubernetes (sans appliquer sur le cluster)
kubectl apply -f mon-fichier.yaml --dry-run=server

# Expliquer un champ pour voir son type et sa description
kubectl explain deployment.spec.replicas
kubectl explain pod.spec.containers.image
kubectl explain pod.spec.containers --recursive

# Outil externe : kubeval (valide les manifestes offline)
kubeval mon-fichier.yaml

# Outil externe : kube-score (analyse les bonnes pratiques)
kube-score score mon-fichier.yaml
```

---

## 6.11 Résumé YAML Kubernetes

```
┌────────────────────────────────────────────────────────────────┐
│                    CHEAT SHEET YAML                            │
│                                                                │
│  Espaces, jamais tabulations                                   │
│  2 espaces par niveau (convention Kubernetes)                  │
│                                                                │
│  clé: valeur             → dictionnaire                        │
│  - élément               → liste                               │
│  {}                      → dictionnaire vide ou inline         │
│  []                      → liste vide ou inline                │
│                                                                │
│  "valeur"                → string (guillemets doubles)         │
│  'valeur'                → string littérale (guillemets simples)│
│  true / false            → booléen                             │
│  42 / 3.14               → nombre                              │
│  null ou ~               → null                                │
│                                                                │
│  |  → bloc littéral (préserve les \n)                         │
│  >  → bloc replié (replie les \n en espaces)                  │
│  #  → commentaire                                              │
│  ---→ séparateur de documents                                  │
│                                                                │
│  &ancre / *alias / <<: *merge → réutilisation                  │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 7 — LES CHAMPS UNIVERSELS KUBERNETES

## 7.1 La structure commune à tous les objets

Chaque objet Kubernetes, quel que soit son type, partage la même ossature :

```yaml
apiVersion: <groupe>/<version>   # Quelle API
kind: <Type>                     # Quel type d'objet
metadata:                        # Qui suis-je
  name: ...
  namespace: ...
  labels: ...
  annotations: ...
spec:                            # Ce que je veux (état désiré)
  ...
status:                          # Ce qui existe (état réel, écrit par K8s)
  ...
```

Comprendre ces champs universels une fois, c'est les comprendre pour TOUS les objets.

---

## 7.2 apiVersion

### Rôle

Indique quelle version de l'API Kubernetes utiliser pour cet objet. Kubernetes évolue, et les objets peuvent changer de structure entre versions.

### Structure

```yaml
apiVersion: <group>/<version>
```

### Les groupes d'API

```
┌─────────────────────────────────────────────────────────────────┐
│                    GROUPES D'API                                │
│                                                                 │
│  "" (core, pas de groupe) → apiVersion: v1                      │
│     Pod, Service, ConfigMap, Secret, Namespace, Node,          │
│     PersistentVolume, PersistentVolumeClaim, ServiceAccount    │
│                                                                 │
│  apps → apiVersion: apps/v1                                     │
│     Deployment, ReplicaSet, StatefulSet, DaemonSet             │
│                                                                 │
│  batch → apiVersion: batch/v1                                   │
│     Job, CronJob                                               │
│                                                                 │
│  networking.k8s.io → apiVersion: networking.k8s.io/v1         │
│     Ingress, NetworkPolicy, IngressClass                       │
│                                                                 │
│  rbac.authorization.k8s.io → rbac.authorization.k8s.io/v1     │
│     Role, ClusterRole, RoleBinding, ClusterRoleBinding        │
│                                                                 │
│  storage.k8s.io → apiVersion: storage.k8s.io/v1               │
│     StorageClass, VolumeAttachment                            │
│                                                                 │
│  autoscaling → apiVersion: autoscaling/v2                      │
│     HorizontalPodAutoscaler                                    │
│                                                                 │
│  argoproj.io → apiVersion: argoproj.io/v1alpha1               │
│     Application (ArgoCD — CRD)                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Les niveaux de stabilité

```yaml
apiVersion: apps/v1            # Stable (GA - Generally Available)
apiVersion: batch/v1beta1     # Beta (activé par défaut, peut changer)
apiVersion: example.com/v1alpha1  # Alpha (instable, désactivé par défaut)
```

| Niveau | Signification | Utilisation prod |
|--------|---------------|------------------|
| v1 (GA) | Stable, garanti | Oui |
| v1beta1 | Bien testé, peut évoluer | Avec prudence |
| v1alpha1 | Expérimental | Non recommandé |

### Comment trouver la bonne apiVersion

```bash
# Liste toutes les ressources et leur apiVersion
kubectl api-resources

# Liste toutes les versions d'API disponibles
kubectl api-versions

# Détail d'un type d'objet
kubectl explain deployment
# → montre "VERSION: apps/v1"
```

### Erreurs fréquentes

```yaml
# ERREUR : mauvaise apiVersion
apiVersion: v1
kind: Deployment    ← Deployment n'est PAS dans le groupe core !
# → erreur : no matches for kind "Deployment" in version "v1"

# CORRECT
apiVersion: apps/v1
kind: Deployment
```

---

## 7.3 kind

### Rôle

Le type d'objet Kubernetes. C'est ce qui détermine la structure attendue du reste du YAML.

```yaml
kind: Pod
kind: Deployment
kind: Service
kind: Ingress
# ... etc
```

**Règle de nommage :** toujours en PascalCase (première lettre de chaque mot en majuscule).

```yaml
kind: Deployment          # CORRECT
kind: deployment          # INCORRECT (minuscule)
kind: DEPLOYMENT          # INCORRECT (tout majuscule)
```

---

## 7.4 metadata

### Vue d'ensemble

```yaml
metadata:
  name: mon-objet                    # obligatoire (ou generateName)
  namespace: production              # optionnel (default si absent)
  labels:                            # optionnel
    app: web
    env: prod
  annotations:                       # optionnel
    description: "Mon application web"
  # --- champs gérés par Kubernetes (tu ne les écris pas) ---
  uid: 7d9f8c6b-...                  # géré par K8s
  resourceVersion: "12345"           # géré par K8s
  generation: 2                      # géré par K8s
  creationTimestamp: "2026-01-15..." # géré par K8s
  ownerReferences: [...]             # géré par K8s (parfois manuel)
  finalizers: [...]                  # parfois manuel
  managedFields: [...]               # géré par K8s
```

### metadata.name

```yaml
metadata:
  name: mon-app
```

- **Rôle** : identifiant unique de l'objet dans son namespace
- **Type** : string
- **Obligatoire** : oui (sauf si generateName est utilisé)
- **Contraintes** : DNS-1123 subdomain
  - Minuscules uniquement
  - Chiffres, tirets `-`, points `.`
  - Commence et finit par un caractère alphanumérique
  - Max 253 caractères

```yaml
# CORRECT
name: mon-app
name: web-frontend-v2
name: app.production

# INCORRECT
name: Mon-App          # majuscules interdites
name: mon_app          # underscore interdit
name: -mon-app         # ne peut pas commencer par un tiret
```

### metadata.generateName

```yaml
metadata:
  generateName: mon-app-    # Kubernetes ajoute un suffixe aléatoire
```

- **Rôle** : génère un nom unique automatiquement
- **Résultat** : `mon-app-x7k2p`
- **Usage** : quand tu veux créer plusieurs objets sans collision de noms
- **Note** : ne peut pas être utilisé avec `kubectl apply` (seulement `kubectl create`)

### metadata.namespace

```yaml
metadata:
  namespace: production
```

- **Rôle** : dans quel namespace l'objet vit
- **Défaut** : `default` si non spécifié
- **Note** : certains objets sont cluster-scoped (Node, PersistentVolume, Namespace, ClusterRole) et n'ont pas de namespace

### metadata.labels

```yaml
metadata:
  labels:
    app: web
    tier: frontend
    version: "2.0"
    environment: production
```

- **Rôle** : paires clé/valeur pour identifier et grouper les objets
- **Usage** : sélection par les Services, Deployments, requêtes kubectl
- **Contraintes des clés** : max 63 caractères, préfixe optionnel (ex: `app.kubernetes.io/name`)
- **Contraintes des valeurs** : max 63 caractères, alphanumériques + `-` `_` `.`

```bash
# Utilisation des labels dans kubectl
kubectl get pods -l app=web                    # pods avec label app=web
kubectl get pods -l 'environment in (prod,staging)'  # opérateur In
kubectl get pods -l app=web,tier=frontend      # ET logique
kubectl get pods --show-labels                 # affiche tous les labels
```

### Les labels recommandés par Kubernetes

```yaml
metadata:
  labels:
    app.kubernetes.io/name: mon-app
    app.kubernetes.io/instance: mon-app-prod
    app.kubernetes.io/version: "2.0.1"
    app.kubernetes.io/component: frontend
    app.kubernetes.io/part-of: ma-plateforme
    app.kubernetes.io/managed-by: helm
```

### metadata.annotations

```yaml
metadata:
  annotations:
    description: "Application web principale"
    contact: "team-web@example.com"
    kubernetes.io/ingress.class: "traefik"
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
```

- **Rôle** : métadonnées non identifiantes (info additionnelle)
- **Différence avec labels** :
  - Labels : pour IDENTIFIER et SÉLECTIONNER (les selectors les utilisent)
  - Annotations : pour ATTACHER de l'information (jamais utilisées pour la sélection)
- **Pas de limite de taille** (contrairement aux labels : 63 chars)
- **Usage typique** : configuration d'outils (Ingress class, Prometheus, cert-manager...)

```
┌────────────────────────────────────────────────────────────────┐
│              LABELS vs ANNOTATIONS                            │
│                                                                │
│  LABELS                        ANNOTATIONS                    │
│  ├── Pour sélectionner         ├── Pour informer              │
│  ├── Max 63 caractères         ├── Pas de limite pratique     │
│  ├── Utilisés par selectors    ├── Jamais par selectors       │
│  ├── Indexés (recherche rapide)├── Non indexés                │
│  └── app: web                  └── description: "..."         │
└────────────────────────────────────────────────────────────────┘
```

---

## 7.5 Les champs metadata gérés par Kubernetes

Tu ne les écris jamais, mais tu dois les comprendre.

### metadata.uid

```yaml
metadata:
  uid: 7d9f8c6b-4a2e-11ef-b8c3-0242ac120002
```

- **Rôle** : identifiant unique universel de l'objet
- **Écrit par** : l'API Server à la création
- **Immuable** : ne change jamais
- **Différence avec name** : le name peut être réutilisé après suppression (nouvel uid), l'uid est unique à travers le temps

### metadata.resourceVersion

```yaml
metadata:
  resourceVersion: "12345678"
```

- **Rôle** : version de l'objet, incrémentée à chaque modification
- **Usage** : contrôle de concurrence optimiste (optimistic locking)
- **Fonctionnement** : si tu modifies un objet avec une resourceVersion périmée, l'API Server rejette la modification (quelqu'un a modifié entre-temps)

```
┌────────────────────────────────────────────────────────────────┐
│         OPTIMISTIC LOCKING (contrôle de concurrence)          │
│                                                                │
│  Client A lit l'objet (resourceVersion: 100)                  │
│  Client B lit l'objet (resourceVersion: 100)                  │
│                                                                │
│  Client A modifie et envoie (resourceVersion: 100)            │
│  → API Server accepte, nouvelle version: 101                  │
│                                                                │
│  Client B modifie et envoie (resourceVersion: 100)            │
│  → API Server REJETTE (409 Conflict)                          │
│    "L'objet a changé depuis votre lecture"                    │
│  → Client B doit relire (version 101) et réessayer            │
└────────────────────────────────────────────────────────────────┘
```

### metadata.generation

```yaml
metadata:
  generation: 3
```

- **Rôle** : compteur incrémenté à chaque changement de la **spec** (pas du status)
- **Usage** : savoir si la spec a changé
- **Différence avec resourceVersion** : generation ne change que si spec change, resourceVersion change à chaque modification (même du status)

### metadata.creationTimestamp

```yaml
metadata:
  creationTimestamp: "2026-01-15T10:30:00Z"
```

- **Rôle** : date de création de l'objet (format RFC 3339, UTC)
- **Écrit par** : l'API Server

### metadata.ownerReferences

```yaml
metadata:
  ownerReferences:
  - apiVersion: apps/v1
    kind: ReplicaSet
    name: web-app-7d9f8c6b4
    uid: abc-123-...
    controller: true
    blockOwnerDeletion: true
```

- **Rôle** : indique quel objet "possède" celui-ci
- **Usage crucial** : le garbage collection en cascade
- **Exemple** : un Pod créé par un ReplicaSet a une ownerReference vers ce ReplicaSet

```
┌────────────────────────────────────────────────────────────────┐
│            CHAÎNE D'OWNERSHIP ET GARBAGE COLLECTION           │
│                                                                │
│  Deployment "web-app"                                         │
│      │ owns (ownerReference)                                  │
│      ▼                                                        │
│  ReplicaSet "web-app-7d9f8c6b4"                              │
│      │ owns                                                   │
│      ▼                                                        │
│  Pods "web-app-7d9f8c6b4-xxx"                                │
│                                                                │
│  Si tu supprimes le Deployment :                             │
│  → Kubernetes supprime automatiquement le ReplicaSet         │
│  → qui supprime automatiquement les Pods                     │
│                                                                │
│  C'est le GARBAGE COLLECTION EN CASCADE                       │
│  (grâce aux ownerReferences)                                 │
└────────────────────────────────────────────────────────────────┘
```

### metadata.finalizers

```yaml
metadata:
  finalizers:
  - kubernetes.io/pv-protection
  - example.com/cleanup-external-resources
```

- **Rôle** : empêche la suppression immédiate d'un objet jusqu'à ce qu'une tâche de nettoyage soit effectuée
- **Fonctionnement** :
  1. Tu demandes la suppression d'un objet
  2. Si l'objet a des finalizers, il n'est PAS supprimé immédiatement
  3. Il passe en état "Terminating" (deletionTimestamp est défini)
  4. Un contrôleur effectue le nettoyage puis retire son finalizer
  5. Quand tous les finalizers sont retirés → suppression réelle

```
┌────────────────────────────────────────────────────────────────┐
│                  LES FINALIZERS                               │
│                                                                │
│  Problème résolu : "Ne supprime pas ce volume tant que        │
│  je n'ai pas sauvegardé ses données ailleurs"                 │
│                                                                │
│  kubectl delete pvc mon-volume                                │
│      │                                                        │
│      ▼                                                        │
│  L'objet a un finalizer → il passe en "Terminating"           │
│  (deletionTimestamp défini, mais objet toujours là)           │
│      │                                                        │
│      ▼                                                        │
│  Un contrôleur détecte le Terminating                         │
│  → effectue le nettoyage (backup, libération ressource)       │
│  → retire son finalizer                                       │
│      │                                                        │
│      ▼                                                        │
│  Plus de finalizers → suppression RÉELLE                      │
│                                                                │
│  DANGER : un objet "coincé" en Terminating a souvent un       │
│  finalizer dont le contrôleur ne répond plus.                 │
│  Solution d'urgence : retirer manuellement le finalizer       │
│  kubectl patch pvc mon-volume -p                              │
│    '{"metadata":{"finalizers":null}}' --type=merge           │
└────────────────────────────────────────────────────────────────┘
```

### metadata.managedFields

```yaml
metadata:
  managedFields:
  - manager: kubectl
    operation: Apply
    apiVersion: apps/v1
    fieldsType: FieldsV1
    fieldsV1:
      # ... quel outil gère quels champs
```

- **Rôle** : traçabilité de quel outil/utilisateur gère quels champs (Server-Side Apply)
- **Usage** : permet à plusieurs outils de gérer le même objet sans conflit
- **Note** : verbeux, généralement caché. `kubectl get -o yaml` le montre, mais tu peux l'ignorer.

---

## 7.6 spec

### Rôle

Le champ `spec` décrit l'**état désiré** — ce que TU veux. Son contenu dépend entièrement du `kind` de l'objet.

```yaml
# spec d'un Deployment
spec:
  replicas: 3
  selector: {...}
  template: {...}
  strategy: {...}

# spec d'un Service (totalement différent)
spec:
  selector: {...}
  ports: [...]
  type: ClusterIP

# spec d'un Pod (encore différent)
spec:
  containers: [...]
  volumes: [...]
  nodeSelector: {...}
```

Chaque type d'objet a sa propre structure de spec, détaillée dans les chapitres dédiés.

**Point clé :** `spec` est TOUJOURS écrit par toi. C'est ta déclaration d'intention.

---

## 7.7 status

### Rôle

Le champ `status` décrit l'**état réel** — ce qui existe vraiment. Il est **écrit par Kubernetes**, jamais par toi.

```yaml
# status d'un Deployment (écrit par le Deployment Controller)
status:
  observedGeneration: 3
  replicas: 3
  updatedReplicas: 3
  readyReplicas: 3
  availableReplicas: 3
  conditions:
  - type: Available
    status: "True"
    reason: MinimumReplicasAvailable
  - type: Progressing
    status: "True"
    reason: NewReplicaSetAvailable
```

```yaml
# status d'un Pod (écrit par le Kubelet)
status:
  phase: Running
  podIP: 10.42.1.23
  hostIP: 10.0.0.5
  startTime: "2026-01-15T10:30:00Z"
  conditions:
  - type: Ready
    status: "True"
  containerStatuses:
  - name: web
    ready: true
    restartCount: 0
    image: nginx:1.25
    state:
      running:
        startedAt: "2026-01-15T10:30:05Z"
```

### La boucle spec → status

```
┌────────────────────────────────────────────────────────────────┐
│                  SPEC vs STATUS                               │
│                                                                │
│  spec (état désiré)          status (état réel)              │
│  ┌──────────────────┐        ┌──────────────────┐            │
│  │ replicas: 3      │        │ readyReplicas: 2 │            │
│  │ (ce que je veux) │        │ (ce qui existe)  │            │
│  └──────────────────┘        └──────────────────┘            │
│          │                            ▲                       │
│          │                            │                       │
│          ▼                            │                       │
│  ┌─────────────────────────────────────────┐                 │
│  │         CONTROLLER (boucle)              │                 │
│  │  "spec dit 3, status dit 2               │                 │
│  │   → je crée 1 pod de plus"               │                 │
│  └─────────────────────────────────────────┘                 │
│                                                                │
│  Le controller travaille SANS CESSE pour faire                │
│  converger status vers spec.                                  │
└────────────────────────────────────────────────────────────────┘
```

### Les conditions

Le champ `status.conditions` est un pattern récurrent. Chaque condition a :

```yaml
conditions:
- type: Ready                    # le type de condition
  status: "True"                 # "True", "False", ou "Unknown"
  reason: PodCompleted           # raison machine-readable
  message: "All containers ready" # message human-readable
  lastTransitionTime: "..."      # quand la condition a changé
```

Types de conditions courants :
- **Pod** : `Ready`, `Initialized`, `ContainersReady`, `PodScheduled`
- **Deployment** : `Available`, `Progressing`
- **Node** : `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`

---

## 7.8 Résumé du chapitre

```
┌────────────────────────────────────────────────────────────────┐
│              RETENIR DU CHAPITRE 7                             │
│                                                                │
│  apiVersion : quel groupe/version d'API (v1, apps/v1...)      │
│  kind       : quel type d'objet (Pod, Deployment...)          │
│                                                                │
│  metadata :                                                    │
│    name          : identifiant (que tu écris)                 │
│    namespace     : partition logique                          │
│    labels        : pour SÉLECTIONNER                          │
│    annotations   : pour INFORMER                              │
│    uid           : ID unique universel (K8s écrit)            │
│    resourceVersion : version pour concurrence (K8s écrit)     │
│    generation    : compteur de changements de spec            │
│    ownerReferences : chaîne d'ownership (garbage collection)  │
│    finalizers    : empêche suppression avant nettoyage        │
│                                                                │
│  spec   : état DÉSIRÉ (tu l'écris)                            │
│  status : état RÉEL (K8s l'écrit)                            │
│                                                                │
│  Le controller fait converger status vers spec en boucle.     │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 8 — POD

## 8.1 Pourquoi le Pod existe

### Le problème

Docker lance des conteneurs isolés. Mais certaines applications ont besoin de conteneurs **étroitement couplés** qui doivent :
- Partager le même réseau (se parler via localhost)
- Partager des fichiers (volumes communs)
- Vivre et mourir ensemble
- Être toujours sur le même node

Exemple : une application web + un conteneur qui collecte ses logs + un proxy. Ces trois doivent être ensemble.

### La solution : le Pod

Le Pod est l'**unité de déploiement atomique** de Kubernetes. C'est un groupe de un ou plusieurs conteneurs qui partagent :
- Une adresse IP unique
- Un espace de stockage (volumes)
- Un cycle de vie

**Image mentale :** un Pod est comme un **appartement partagé**. Les colocataires (conteneurs) ont chacun leur chambre (leur processus) mais partagent l'adresse postale (IP), la cuisine et le salon (volumes), et emménagent/déménagent ensemble.

---

## 8.2 Le Pod minimal

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mon-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.25
```

C'est le Pod le plus simple possible. Un seul conteneur, aucune configuration avancée.

```bash
kubectl apply -f pod.yaml
kubectl get pod mon-pod
kubectl describe pod mon-pod
kubectl logs mon-pod
kubectl exec -it mon-pod -- /bin/sh
kubectl delete pod mon-pod
```

---

## 8.3 Le cycle de vie d'un Pod

### Les phases (status.phase)

```
┌────────────────────────────────────────────────────────────────┐
│                  PHASES D'UN POD                              │
│                                                                │
│  Pending    → Le pod est accepté mais pas encore lancé         │
│               (téléchargement image, scheduling, init...)      │
│                                                                │
│  Running    → Le pod est lié à un node, au moins un            │
│               conteneur tourne                                 │
│                                                                │
│  Succeeded  → Tous les conteneurs se sont terminés avec        │
│               succès (exit 0), ne redémarreront pas            │
│                                                                │
│  Failed     → Tous les conteneurs se sont terminés, au moins   │
│               un en erreur (exit != 0)                         │
│                                                                │
│  Unknown    → L'état du pod ne peut pas être déterminé         │
│               (souvent : node injoignable)                     │
└────────────────────────────────────────────────────────────────┘
```

### Le diagramme de cycle de vie complet

```
   kubectl apply
        │
        ▼
   ┌─────────┐
   │ Pending │  ← Scheduling en cours, image en téléchargement,
   └─────────┘    init containers en exécution
        │
        │ conteneurs démarrent
        ▼
   ┌─────────┐
   │ Running │  ← Au moins un conteneur tourne
   └─────────┘
        │
        ├──────────────┬──────────────┐
        ▼              ▼              ▼
  ┌──────────┐   ┌─────────┐   (continue de
  │Succeeded │   │ Failed  │    tourner)
  └──────────┘   └─────────┘
  exit 0 partout  exit != 0
```

### Les états des conteneurs (différent des phases du pod)

```yaml
status:
  containerStatuses:
  - name: web
    state:
      # UN de ces trois états :
      waiting:        # en attente (pull image, crash loop...)
        reason: ContainerCreating
      running:        # en cours d'exécution
        startedAt: "..."
      terminated:     # terminé
        exitCode: 0
        reason: Completed
```

```
┌────────────────────────────────────────────────────────────────┐
│              ÉTATS D'UN CONTENEUR                             │
│                                                                │
│  Waiting     → Pas encore en cours (téléchargement,           │
│                attente de dépendances, CrashLoopBackOff)      │
│                                                                │
│  Running     → En cours d'exécution normale                   │
│                                                                │
│  Terminated  → A fini de s'exécuter (avec succès ou échec)    │
└────────────────────────────────────────────────────────────────┘
```

---

## 8.4 Les conteneurs multiples (multi-container pods)

### Les patterns de sidecar

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-avec-sidecar
spec:
  containers:
  # Conteneur principal
  - name: app
    image: mon-app:1.0
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
  # Conteneur sidecar (collecte les logs)
  - name: log-collector
    image: fluentd:latest
    volumeMounts:
    - name: logs
      mountPath: /var/log/app    # même volume, partagé
  volumes:
  - name: logs
    emptyDir: {}
```

### Les 3 patterns classiques de sidecar

```
┌────────────────────────────────────────────────────────────────┐
│              PATTERNS MULTI-CONTENEURS                        │
│                                                                │
│  1. SIDECAR (assistant)                                        │
│     App principale + assistant qui l'aide                     │
│     Ex: app web + collecteur de logs                          │
│                                                                │
│  2. AMBASSADOR (proxy sortant)                                 │
│     App + proxy qui gère les connexions externes             │
│     Ex: app + proxy vers la base de données                  │
│                                                                │
│  3. ADAPTER (transformateur)                                   │
│     App + adaptateur qui transforme les sorties              │
│     Ex: app + adaptateur qui formate les métriques           │
│        pour Prometheus                                        │
└────────────────────────────────────────────────────────────────┘
```

### Communication entre conteneurs d'un même pod

```yaml
# Les conteneurs d'un même pod partagent localhost
spec:
  containers:
  - name: app
    image: mon-app
    # app écoute sur le port 8080
  - name: proxy
    image: nginx
    # proxy peut joindre l'app via localhost:8080 !
    # car ils partagent le même network namespace
```

---

## 8.5 Les init containers

### Le problème résolu

Parfois, il faut préparer quelque chose AVANT que l'application démarre :
- Attendre qu'une base de données soit prête
- Télécharger un fichier de configuration
- Créer un répertoire, définir des permissions
- Effectuer une migration de base de données

### La solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-avec-init
spec:
  initContainers:
  # S'exécute EN PREMIER, doit réussir avant de continuer
  - name: wait-for-db
    image: busybox:1.36
    command: ['sh', '-c', 'until nc -z db-service 5432; do echo waiting; sleep 2; done']
  # S'exécute APRÈS le premier init container
  - name: fetch-config
    image: busybox:1.36
    command: ['sh', '-c', 'wget -O /config/app.conf http://config-server/app.conf']
    volumeMounts:
    - name: config
      mountPath: /config
  # Conteneurs principaux (après TOUS les init containers)
  containers:
  - name: app
    image: mon-app:1.0
    volumeMounts:
    - name: config
      mountPath: /etc/app
  volumes:
  - name: config
    emptyDir: {}
```

### Ordre d'exécution

```
┌────────────────────────────────────────────────────────────────┐
│              ORDRE D'EXÉCUTION DES CONTENEURS                 │
│                                                                │
│  1. initContainer 1  (wait-for-db)                            │
│     ↓ doit se terminer avec succès (exit 0)                   │
│  2. initContainer 2  (fetch-config)                           │
│     ↓ doit se terminer avec succès (exit 0)                   │
│  3. Tous les containers principaux DÉMARRENT en parallèle     │
│     - app                                                      │
│     - sidecars éventuels                                       │
│                                                                │
│  Si un initContainer échoue :                                 │
│  → Kubernetes le redémarre (selon restartPolicy)              │
│  → Les conteneurs principaux ne démarrent JAMAIS avant que    │
│    tous les init containers aient réussi                      │
└────────────────────────────────────────────────────────────────┘
```

---

## 8.6 Anatomie complète d'un conteneur

Voici tous les champs possibles d'un conteneur avec explications.

```yaml
spec:
  containers:
  - name: mon-conteneur          # OBLIGATOIRE : nom unique dans le pod
    image: nginx:1.25            # OBLIGATOIRE : image à utiliser
    imagePullPolicy: IfNotPresent # Always, IfNotPresent, Never

    # --- COMMANDE ---
    command: ["/bin/sh"]         # override l'ENTRYPOINT de l'image
    args: ["-c", "echo hello"]   # override le CMD de l'image
    workingDir: /app             # répertoire de travail

    # --- PORTS ---
    ports:
    - name: http                 # nom optionnel du port
      containerPort: 80          # port exposé par le conteneur
      protocol: TCP              # TCP (défaut) ou UDP

    # --- VARIABLES D'ENVIRONNEMENT ---
    env:
    - name: DB_HOST
      value: "database"          # valeur directe
    - name: SECRET_KEY
      valueFrom:                 # valeur depuis une source
        secretKeyRef:
          name: mon-secret
          key: api-key
    - name: POD_IP
      valueFrom:
        fieldRef:                # valeur depuis un champ du pod
          fieldPath: status.podIP

    envFrom:                     # importe TOUTES les clés d'un ConfigMap/Secret
    - configMapRef:
        name: app-config
    - secretRef:
        name: app-secrets

    # --- RESSOURCES ---
    resources:
      requests:                  # ce dont le conteneur a BESOIN (pour scheduling)
        cpu: "100m"              # 100 millicores = 0.1 CPU
        memory: "128Mi"          # 128 mébioctets
      limits:                    # maximum autorisé
        cpu: "200m"
        memory: "256Mi"

    # --- PROBES (sondes de santé) ---
    livenessProbe:               # le conteneur est-il vivant ?
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
    readinessProbe:              # le conteneur est-il prêt à recevoir du trafic ?
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
    startupProbe:                # le conteneur a-t-il fini de démarrer ?
      httpGet:
        path: /startup
        port: 80
      failureThreshold: 30
      periodSeconds: 10

    # --- VOLUMES ---
    volumeMounts:
    - name: data
      mountPath: /var/data       # où monter dans le conteneur
      readOnly: false

    # --- LIFECYCLE HOOKS ---
    lifecycle:
      postStart:                 # après le démarrage du conteneur
        exec:
          command: ["/bin/sh", "-c", "echo started"]
      preStop:                   # avant l'arrêt du conteneur
        exec:
          command: ["/bin/sh", "-c", "nginx -s quit"]

    # --- SÉCURITÉ ---
    securityContext:
      runAsUser: 1000            # UID de l'utilisateur
      runAsNonRoot: true         # interdit de tourner en root
      readOnlyRootFilesystem: true  # filesystem racine en lecture seule
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE

    # --- COMPORTEMENT ---
    stdin: false                 # garde stdin ouvert
    tty: false                   # alloue un TTY
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File  # File ou FallbackToLogsOnError
```

---

## 8.7 command et args : comprendre l'override

C'est une source fréquente de confusion. Comment `command` et `args` interagissent avec l'image Docker.

```
┌────────────────────────────────────────────────────────────────┐
│         COMMAND / ARGS vs ENTRYPOINT / CMD                    │
│                                                                │
│  Dans le Dockerfile :          Dans le YAML Kubernetes :      │
│  ENTRYPOINT  ←──── override par ────  command                 │
│  CMD         ←──── override par ────  args                    │
│                                                                │
│  Cas 1 : rien dans le YAML                                    │
│  → utilise ENTRYPOINT + CMD de l'image                        │
│                                                                │
│  Cas 2 : seulement args dans le YAML                          │
│  → utilise ENTRYPOINT de l'image + args du YAML               │
│                                                                │
│  Cas 3 : seulement command dans le YAML                       │
│  → utilise command du YAML (ignore ENTRYPOINT ET CMD)         │
│                                                                │
│  Cas 4 : command ET args dans le YAML                         │
│  → utilise command + args du YAML (ignore tout de l'image)    │
└────────────────────────────────────────────────────────────────┘
```

Exemples concrets :

```yaml
# Image nginx avec ENTRYPOINT ["nginx"] et CMD ["-g", "daemon off;"]

# Cas 1 : lance "nginx -g daemon off;"
containers:
- name: web
  image: nginx

# Cas 2 : lance "nginx -g daemon on;" (args override CMD)
containers:
- name: web
  image: nginx
  args: ["-g", "daemon on;"]

# Cas 3 : lance "/bin/sh" (command override ENTRYPOINT et CMD)
containers:
- name: web
  image: nginx
  command: ["/bin/sh"]

# Cas 4 : lance "/bin/sh -c 'echo hello'"
containers:
- name: web
  image: nginx
  command: ["/bin/sh"]
  args: ["-c", "echo hello"]
```

---

## 8.8 Les probes en profondeur

### Les 3 types de probes

```
┌────────────────────────────────────────────────────────────────┐
│                     LES 3 PROBES                             │
│                                                                │
│  startupProbe    → "L'application a-t-elle FINI de démarrer ?" │
│  Utilité : applications lentes à démarrer                     │
│  Tant qu'elle échoue, les autres probes sont désactivées      │
│  Quand elle réussit → liveness et readiness prennent le relais│
│                                                                │
│  livenessProbe   → "L'application est-elle VIVANTE ?"          │
│  Si échoue → Kubernetes REDÉMARRE le conteneur                │
│  Utilité : détecter les deadlocks, les blocages              │
│                                                                │
│  readinessProbe  → "L'application est-elle PRÊTE à servir ?"   │
│  Si échoue → le pod est RETIRÉ des Endpoints du Service       │
│  (pas de redémarrage, juste plus de trafic)                  │
│  Utilité : pauses temporaires (chargement de cache, etc.)     │
└────────────────────────────────────────────────────────────────┘
```

### Les 3 méthodes de vérification

```yaml
# Méthode 1 : HTTP GET
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
    httpHeaders:
    - name: Custom-Header
      value: healthcheck
# Succès si code HTTP 200-399

# Méthode 2 : TCP Socket
livenessProbe:
  tcpSocket:
    port: 8080
# Succès si la connexion TCP s'établit

# Méthode 3 : Exec (commande)
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
# Succès si la commande retourne exit 0
```

### Les paramètres de timing

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15   # attendre 15s après démarrage avant la 1ère sonde
  periodSeconds: 10         # sonder toutes les 10s
  timeoutSeconds: 1         # timeout de chaque sonde
  successThreshold: 1       # nb de succès consécutifs pour être "sain"
  failureThreshold: 3       # nb d'échecs consécutifs pour être "malade"
```

```
┌────────────────────────────────────────────────────────────────┐
│           EXEMPLE DE TIMELINE D'UNE LIVENESS PROBE           │
│                                                                │
│  t=0s   : conteneur démarre                                   │
│  t=15s  : initialDelaySeconds écoulé, 1ère sonde              │
│  t=15s  : sonde OK                                            │
│  t=25s  : sonde OK                                            │
│  t=35s  : sonde ÉCHOUE (1/3)                                  │
│  t=45s  : sonde ÉCHOUE (2/3)                                  │
│  t=55s  : sonde ÉCHOUE (3/3) → failureThreshold atteint       │
│  t=55s  : Kubernetes REDÉMARRE le conteneur                   │
└────────────────────────────────────────────────────────────────┘
```

---

## 8.9 Le champ restartPolicy

```yaml
spec:
  restartPolicy: Always    # Always (défaut), OnFailure, Never
```

```
┌────────────────────────────────────────────────────────────────┐
│                  RESTART POLICY                              │
│                                                                │
│  Always     → Redémarre toujours (défaut pour Deployments)    │
│               Usage : applications qui doivent toujours tourner│
│                                                                │
│  OnFailure  → Redémarre seulement si exit != 0                │
│               Usage : Jobs qui doivent réussir                │
│                                                                │
│  Never      → Ne redémarre jamais                             │
│               Usage : tâches ponctuelles, débogage           │
└────────────────────────────────────────────────────────────────┘
```

### Le CrashLoopBackOff

```
┌────────────────────────────────────────────────────────────────┐
│                  CRASHLOOPBACKOFF                            │
│                                                                │
│  Un conteneur crash → Kubernetes le redémarre                 │
│  Il recrash → redémarre → recrash → redémarre...              │
│                                                                │
│  Kubernetes applique un DÉLAI EXPONENTIEL entre chaque         │
│  tentative pour éviter de surcharger le système :             │
│                                                                │
│  1er crash  → attente 10s                                     │
│  2e crash   → attente 20s                                     │
│  3e crash   → attente 40s                                     │
│  4e crash   → attente 80s                                     │
│  ...jusqu'à un maximum de 5 minutes                           │
│                                                                │
│  L'état "CrashLoopBackOff" = le pod est dans cette boucle     │
│                                                                │
│  Débogage :                                                    │
│  kubectl logs mon-pod --previous  (logs du crash précédent)   │
│  kubectl describe pod mon-pod     (voir les events)           │
└────────────────────────────────────────────────────────────────┘
```

---

## 8.10 Erreurs fréquentes avec les Pods

```
┌────────────────────────────────────────────────────────────────┐
│                  ERREURS COURANTES                          │
│                                                                │
│  ImagePullBackOff                                             │
│  → L'image n'existe pas ou registry inaccessible              │
│  → Vérifier : nom d'image, tag, credentials du registry       │
│                                                                │
│  CrashLoopBackOff                                             │
│  → L'application crash au démarrage en boucle                 │
│  → kubectl logs --previous pour voir pourquoi                 │
│                                                                │
│  Pending (bloqué)                                             │
│  → Pas de node avec assez de ressources                       │
│  → Ou pas de node matchant nodeSelector/affinity              │
│  → kubectl describe pod pour voir les events du scheduler     │
│                                                                │
│  OOMKilled                                                    │
│  → Le conteneur a dépassé sa limite mémoire                   │
│  → Augmenter resources.limits.memory                          │
│                                                                │
│  CreateContainerConfigError                                   │
│  → ConfigMap ou Secret référencé n'existe pas                 │
└────────────────────────────────────────────────────────────────┘
```

---

## 8.11 Exercices

### QCM

**Q1.** Que partagent les conteneurs d'un même Pod ?
A) Rien, ils sont isolés
B) L'adresse IP et les volumes ✓
C) Uniquement le CPU
D) Le même processus

**Q2.** Un initContainer qui échoue :
A) Est ignoré, les conteneurs principaux démarrent quand même
B) Empêche les conteneurs principaux de démarrer et est redémarré ✓
C) Fait passer le pod en Succeeded
D) N'a aucun effet

**Q3.** Si une livenessProbe échoue, Kubernetes :
A) Retire le pod du Service
B) Redémarre le conteneur ✓
C) Supprime le pod définitivement
D) Ne fait rien

**Q4.** Si une readinessProbe échoue, Kubernetes :
A) Redémarre le conteneur
B) Retire le pod des Endpoints du Service (plus de trafic) ✓
C) Supprime le pod
D) Passe le pod en CrashLoopBackOff

**Q5.** Dans un YAML, si tu spécifies `command` mais pas `args` :
A) L'ENTRYPOINT et le CMD de l'image sont utilisés
B) Le command du YAML remplace ENTRYPOINT, et CMD est ignoré ✓
C) Erreur de validation
D) Le CMD de l'image est conservé

### Exercice pratique

Crée un Pod avec :
- Un init container qui attend 5 secondes
- Un conteneur principal nginx
- Une liveness probe HTTP sur le port 80
- Une limite mémoire de 128Mi

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: exercice-pod
spec:
  initContainers:
  - name: wait
    image: busybox:1.36
    command: ['sh', '-c', 'sleep 5']
  containers:
  - name: web
    image: nginx:1.25
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    resources:
      limits:
        memory: "128Mi"
```

---
# CHAPITRE 9 — DEPLOYMENT

## 9.1 Pourquoi le Deployment existe

### Le problème avec les Pods seuls

Un Pod seul est fragile :
- S'il crash, personne ne le recrée
- Si le node meurt, le pod est perdu à jamais
- Pas de mise à l'échelle (impossible d'avoir "3 copies")
- Pas de mise à jour progressive

### Le problème avec les ReplicaSets seuls

Le ReplicaSet gère plusieurs copies d'un pod, mais :
- Pas de gestion des mises à jour de version
- Pas de rollback
- Pas d'historique

### La solution : le Deployment

Le Deployment est l'objet le plus utilisé de Kubernetes. Il gère :
- Le nombre de réplicas (via un ReplicaSet)
- Les mises à jour progressives (rolling updates)
- Les rollbacks (retour à une version antérieure)
- L'historique des révisions

**Image mentale :** le Deployment est un **chef de projet**. Tu lui dis "je veux 3 exemplaires de la version 2.0 de cette app". Il gère les équipes (ReplicaSets), remplace les travailleurs absents (pods), et gère les transitions de version sans interruption.

---

## 9.2 La hiérarchie Deployment → ReplicaSet → Pod

```
┌────────────────────────────────────────────────────────────────┐
│              HIÉRARCHIE DE DÉLÉGATION                        │
│                                                                │
│  Deployment "web-app"                                         │
│  │  "Je veux 3 réplicas de la version 2.0"                    │
│  │                                                            │
│  │  crée et gère                                              │
│  ▼                                                            │
│  ReplicaSet "web-app-7d9f8c6b4" (version 2.0)               │
│  │  "Je m'assure qu'il y a toujours 3 pods"                  │
│  │                                                            │
│  │  crée et gère                                              │
│  ▼                                                            │
│  Pod "web-app-7d9f8c6b4-xk2p1"                              │
│  Pod "web-app-7d9f8c6b4-mn4q9"                              │
│  Pod "web-app-7d9f8c6b4-rt7wz"                              │
│                                                                │
│  Le Deployment ne gère PAS directement les pods.             │
│  Il gère des ReplicaSets, qui gèrent les pods.               │
└────────────────────────────────────────────────────────────────┘
```

### Pourquoi cette indirection ?

Le ReplicaSet intermédiaire est crucial pour les **rolling updates**. Lors d'une mise à jour, le Deployment crée un NOUVEAU ReplicaSet et fait décroître l'ancien progressivement :

```
Pendant une mise à jour v1 → v2 :

Deployment "web-app"
│
├── ReplicaSet v1 (ancien) : 3 → 2 → 1 → 0 pods
│
└── ReplicaSet v2 (nouveau) : 0 → 1 → 2 → 3 pods

Les deux ReplicaSets coexistent temporairement.
```

---

## 9.3 Le Deployment complet expliqué

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
  labels:
    app: web
spec:
  # --- NOMBRE DE RÉPLICAS ---
  replicas: 3

  # --- SÉLECTEUR (quels pods ce Deployment gère) ---
  selector:
    matchLabels:
      app: web
  # IMPORTANT : selector.matchLabels DOIT correspondre à
  # template.metadata.labels

  # --- HISTORIQUE ---
  revisionHistoryLimit: 10   # nb d'anciens ReplicaSets à garder

  # --- DÉLAIS ---
  minReadySeconds: 0         # temps pendant lequel un pod doit être
                             # Ready avant d'être considéré disponible
  progressDeadlineSeconds: 600  # timeout avant de considérer le
                                # déploiement en échec

  # --- STRATÉGIE DE MISE À JOUR ---
  strategy:
    type: RollingUpdate      # RollingUpdate (défaut) ou Recreate
    rollingUpdate:
      maxSurge: 1            # nb de pods EN PLUS autorisés pendant MAJ
      maxUnavailable: 0      # nb de pods indisponibles autorisés

  # --- TEMPLATE DU POD ---
  template:
    metadata:
      labels:
        app: web             # DOIT matcher selector.matchLabels
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```

---

## 9.4 Les stratégies de mise à jour

### RollingUpdate (défaut)

Remplace progressivement les anciens pods par les nouveaux, sans interruption.

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1          # 1 pod supplémentaire max pendant la transition
    maxUnavailable: 0    # 0 pod indisponible (zéro interruption)
```

```
┌────────────────────────────────────────────────────────────────┐
│      ROLLING UPDATE (maxSurge=1, maxUnavailable=0)          │
│                                                                │
│  État initial : 3 pods v1                                     │
│  [v1] [v1] [v1]                                              │
│                                                                │
│  Étape 1 : crée 1 pod v2 (surge)                             │
│  [v1] [v1] [v1] [v2-creating]                               │
│                                                                │
│  Étape 2 : v2 prêt, supprime 1 v1                            │
│  [v1] [v1] [v2]                                              │
│                                                                │
│  Étape 3 : crée 1 pod v2                                     │
│  [v1] [v1] [v2] [v2-creating]                               │
│                                                                │
│  Étape 4 : v2 prêt, supprime 1 v1                            │
│  [v1] [v2] [v2]                                              │
│                                                                │
│  Étape 5 : crée 1 pod v2                                     │
│  [v1] [v2] [v2] [v2-creating]                               │
│                                                                │
│  Étape 6 : v2 prêt, supprime dernier v1                      │
│  [v2] [v2] [v2]                                              │
│                                                                │
│  Résultat : 3 pods v2, JAMAIS moins de 3 pods dispos         │
└────────────────────────────────────────────────────────────────┘
```

### Recreate

Supprime TOUS les anciens pods, PUIS crée les nouveaux. Interruption de service.

```yaml
strategy:
  type: Recreate
```

```
┌────────────────────────────────────────────────────────────────┐
│                     RECREATE                                │
│                                                                │
│  État initial : 3 pods v1                                     │
│  [v1] [v1] [v1]                                              │
│                                                                │
│  Étape 1 : supprime TOUS les v1                              │
│  (aucun pod — INTERRUPTION DE SERVICE)                        │
│                                                                │
│  Étape 2 : crée tous les v2                                  │
│  [v2] [v2] [v2]                                              │
│                                                                │
│  Usage : quand v1 et v2 ne peuvent pas coexister             │
│  (ex: migration de schéma de base de données incompatible)   │
└────────────────────────────────────────────────────────────────┘
```

### maxSurge et maxUnavailable en détail

```
┌────────────────────────────────────────────────────────────────┐
│         COMBINAISONS maxSurge / maxUnavailable              │
│                                                                │
│  maxSurge=1, maxUnavailable=0 (le plus prudent)              │
│  → Toujours ≥ replicas pods dispos, +1 temporaire            │
│  → Zéro interruption, mais plus lent                         │
│                                                                │
│  maxSurge=0, maxUnavailable=1                                │
│  → Jamais plus de replicas pods, -1 temporaire               │
│  → Économe en ressources, mais capacité réduite pendant MAJ  │
│                                                                │
│  maxSurge=25%, maxUnavailable=25% (défaut)                   │
│  → Équilibre entre vitesse et disponibilité                  │
│                                                                │
│  Les valeurs peuvent être des nombres ou des pourcentages    │
└────────────────────────────────────────────────────────────────┘
```

---

## 9.5 Les commandes de gestion des Deployments

```bash
# Créer/mettre à jour
kubectl apply -f deployment.yaml

# Voir l'état
kubectl get deployment web-app
kubectl get deployment web-app -o wide
kubectl describe deployment web-app

# Mettre à jour l'image (déclenche un rolling update)
kubectl set image deployment/web-app web=nginx:1.26

# Scaler
kubectl scale deployment web-app --replicas=5

# Suivre le rollout
kubectl rollout status deployment/web-app

# Historique des révisions
kubectl rollout history deployment/web-app

# Rollback à la révision précédente
kubectl rollout undo deployment/web-app

# Rollback à une révision spécifique
kubectl rollout undo deployment/web-app --to-revision=2

# Mettre en pause / reprendre (pour grouper plusieurs changements)
kubectl rollout pause deployment/web-app
kubectl rollout resume deployment/web-app

# Redémarrer (recrée tous les pods sans changer la config)
kubectl rollout restart deployment/web-app
```

---

## 9.6 Le rollback expliqué

```
┌────────────────────────────────────────────────────────────────┐
│                     ROLLBACK                                │
│                                                                │
│  Kubernetes garde un historique des ReplicaSets               │
│  (limité par revisionHistoryLimit)                            │
│                                                                │
│  Révision 1 : ReplicaSet v1.0 (0 pods, conservé)             │
│  Révision 2 : ReplicaSet v2.0 (0 pods, conservé)             │
│  Révision 3 : ReplicaSet v3.0 (3 pods, ACTIF)               │
│                                                                │
│  kubectl rollout undo deployment/web-app                      │
│  → Réactive le ReplicaSet v2.0                               │
│  → Scale v3.0 à 0, scale v2.0 à 3                            │
│                                                                │
│  Révision 2 : ReplicaSet v2.0 (3 pods, ACTIF de nouveau)    │
│  Révision 4 : (l'ancien v3.0 devient révision 4)            │
│                                                                │
│  Le rollback est lui-même un rolling update !                 │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 10 — REPLICASET

## 10.1 Rôle du ReplicaSet

Le ReplicaSet garantit qu'un nombre spécifié de pods identiques tournent en permanence. C'est le moteur derrière les Deployments.

**Tu ne crées presque jamais de ReplicaSet directement** — le Deployment le fait pour toi. Mais comprendre le ReplicaSet est essentiel.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25
```

## 10.2 La boucle du ReplicaSet Controller

```
┌────────────────────────────────────────────────────────────────┐
│              BOUCLE DU REPLICASET CONTROLLER                 │
│                                                                │
│  Toutes les X millisecondes (ou sur événement) :              │
│                                                                │
│  1. Compte les pods matchant le selector (app: web)           │
│     et appartenant à ce ReplicaSet (ownerReference)          │
│                                                                │
│  2. Compare avec replicas désiré :                            │
│     - réel < désiré → crée (désiré - réel) pods              │
│     - réel > désiré → supprime (réel - désiré) pods          │
│     - réel = désiré → ne fait rien                           │
│                                                                │
│  Ce cycle tourne EN PERMANENCE.                               │
│  Supprime un pod à la main → il est recréé en secondes.      │
└────────────────────────────────────────────────────────────────┘
```

## 10.3 Le selector et les pods "adoptés"

Un ReplicaSet adopte TOUS les pods matchant son selector, même ceux qu'il n'a pas créés. C'est pourquoi le selector doit être précis.

```
┌────────────────────────────────────────────────────────────────┐
│                  ADOPTION DE PODS                           │
│                                                                │
│  Danger : si tu crées un pod manuel avec label app:web        │
│  et qu'un ReplicaSet a selector app:web...                    │
│                                                                │
│  → Le ReplicaSet "adopte" ce pod (le compte dans ses replicas)│
│  → Si ça dépasse le nombre désiré, le ReplicaSet supprime     │
│    un pod (peut-être le tien !)                              │
│                                                                │
│  C'est pourquoi les Deployments ajoutent un label unique      │
│  pod-template-hash au selector pour éviter les collisions.    │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 11 — STATEFULSET

## 11.1 Pourquoi le StatefulSet existe

Les Deployments sont parfaits pour les applications **stateless** (sans état) : n'importe quel pod peut traiter n'importe quelle requête, l'ordre n'a pas d'importance, les pods sont interchangeables.

Mais certaines applications ont besoin d'**identité stable** :
- Bases de données (PostgreSQL, MySQL, MongoDB)
- Systèmes distribués (Kafka, Elasticsearch, Cassandra)
- Applications nécessitant un stockage persistant lié à chaque instance

### Ce que le StatefulSet garantit

```
┌────────────────────────────────────────────────────────────────┐
│              GARANTIES DU STATEFULSET                        │
│                                                                │
│  1. IDENTITÉ RÉSEAU STABLE                                    │
│     Les pods ont des noms prévisibles et stables :            │
│     mysql-0, mysql-1, mysql-2                                 │
│     (pas de suffixe aléatoire comme les Deployments)         │
│                                                                │
│  2. STOCKAGE STABLE                                           │
│     Chaque pod a son propre PersistentVolume qui le suit      │
│     mysql-0 → volume-mysql-0 (toujours le même)              │
│                                                                │
│  3. DÉPLOIEMENT/SCALING ORDONNÉ                               │
│     Création : mysql-0, PUIS mysql-1, PUIS mysql-2           │
│     Suppression : mysql-2, PUIS mysql-1, PUIS mysql-0        │
│     (ordre inverse)                                          │
│                                                                │
│  4. DNS STABLE PAR POD                                        │
│     mysql-0.mysql-service.namespace.svc.cluster.local        │
└────────────────────────────────────────────────────────────────┘
```

## 11.2 Le StatefulSet complet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql       # nom du Service headless associé (OBLIGATOIRE)
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  # --- TEMPLATE DE VOLUME (unique au StatefulSet) ---
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

Le `volumeClaimTemplates` crée automatiquement un PVC unique par pod :
- `data-mysql-0`
- `data-mysql-1`
- `data-mysql-2`

## 11.3 Le Service headless

Un StatefulSet nécessite un Service "headless" (sans ClusterIP) pour donner une identité DNS à chaque pod :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  clusterIP: None          # headless = pas de ClusterIP
  selector:
    app: mysql
  ports:
  - port: 3306
```

Résultat : chaque pod est joignable via son DNS individuel :
```
mysql-0.mysql.default.svc.cluster.local → IP du pod mysql-0
mysql-1.mysql.default.svc.cluster.local → IP du pod mysql-1
```

---

# CHAPITRE 12 — DAEMONSET

## 12.1 Pourquoi le DaemonSet existe

Certaines tâches doivent tourner sur **CHAQUE node** du cluster :
- Collecte de logs (Fluentd, Filebeat)
- Monitoring des nodes (Node Exporter, Datadog agent)
- Réseau (kube-proxy est un DaemonSet, les plugins CNI aussi)
- Stockage (agents CSI)

### Ce que le DaemonSet garantit

```
┌────────────────────────────────────────────────────────────────┐
│                  DAEMONSET                                   │
│                                                                │
│  "Un pod par node, automatiquement"                           │
│                                                                │
│  Node 1 → 1 pod du DaemonSet                                  │
│  Node 2 → 1 pod du DaemonSet                                  │
│  Node 3 → 1 pod du DaemonSet                                  │
│                                                                │
│  Nouveau node ajouté au cluster → un pod y est créé auto      │
│  Node retiré → son pod est supprimé auto                     │
│                                                                │
│  Pas de "replicas" — le nombre = nombre de nodes             │
└────────────────────────────────────────────────────────────────┘
```

## 12.2 Le DaemonSet complet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      # Souvent, on veut tourner même sur les master nodes
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluentd:latest
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log      # accède aux logs du node hôte
```

---

# CHAPITRE 13 — JOB ET CRONJOB

## 13.1 Pourquoi le Job existe

Les Deployments sont faits pour des applications qui tournent **en permanence**. Mais certaines tâches doivent s'exécuter **une fois** puis s'arrêter :
- Migrations de base de données
- Traitements batch
- Calculs ponctuels
- Envoi d'emails en masse

### Le Job garantit l'exécution jusqu'au succès

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: migration
spec:
  completions: 1           # nb d'exécutions réussies souhaitées
  parallelism: 1           # nb d'exécutions en parallèle
  backoffLimit: 4          # nb de tentatives avant abandon
  activeDeadlineSeconds: 600  # timeout global
  template:
    spec:
      restartPolicy: OnFailure   # OnFailure ou Never (jamais Always)
      containers:
      - name: migration
        image: mon-app:1.0
        command: ["python", "migrate.py"]
```

## 13.2 Les patterns de Job

```
┌────────────────────────────────────────────────────────────────┐
│                  PATTERNS DE JOB                            │
│                                                                │
│  1. Job unique (completions=1, parallelism=1)                 │
│     Une tâche, une exécution                                  │
│                                                                │
│  2. Job à complétions fixes (completions=5, parallelism=1)    │
│     5 exécutions séquentielles réussies                       │
│                                                                │
│  3. Job parallèle (completions=5, parallelism=2)              │
│     5 exécutions réussies, 2 en parallèle max                 │
│                                                                │
│  4. Work queue (parallelism=3, pas de completions)            │
│     Plusieurs workers traitent une file jusqu'à épuisement   │
└────────────────────────────────────────────────────────────────┘
```

## 13.3 Le CronJob

Le CronJob crée des Jobs selon une planification (comme cron sous Linux).

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 2 * * *"    # tous les jours à 2h du matin
  concurrencyPolicy: Forbid   # Allow, Forbid, Replace
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  startingDeadlineSeconds: 300
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: backup-tool:1.0
            command: ["./backup.sh"]
```

### La syntaxe cron

```
┌────────────────────────────────────────────────────────────────┐
│                  SYNTAXE CRON                               │
│                                                                │
│   ┌───────────── minute (0-59)                                │
│   │ ┌───────────── heure (0-23)                               │
│   │ │ ┌───────────── jour du mois (1-31)                      │
│   │ │ │ ┌───────────── mois (1-12)                            │
│   │ │ │ │ ┌───────────── jour de la semaine (0-6, 0=dimanche) │
│   │ │ │ │ │                                                   │
│   * * * * *                                                   │
│                                                                │
│  Exemples :                                                    │
│  "0 2 * * *"      → tous les jours à 2h00                     │
│  "*/15 * * * *"   → toutes les 15 minutes                     │
│  "0 0 * * 0"      → tous les dimanches à minuit              │
│  "0 9 * * 1-5"    → à 9h du lundi au vendredi                │
│  "0 0 1 * *"      → le 1er de chaque mois à minuit           │
└────────────────────────────────────────────────────────────────┘
```

### concurrencyPolicy

```
┌────────────────────────────────────────────────────────────────┐
│              CONCURRENCY POLICY                              │
│                                                                │
│  Allow (défaut) → autorise plusieurs Jobs en parallèle        │
│                   si le précédent n'est pas fini              │
│                                                                │
│  Forbid → saute la nouvelle exécution si la précédente        │
│           tourne encore                                       │
│                                                                │
│  Replace → annule la précédente et lance la nouvelle          │
└────────────────────────────────────────────────────────────────┘
```

---

## Résumé des workloads

```
┌────────────────────────────────────────────────────────────────┐
│              QUAND UTILISER QUOI                             │
│                                                                │
│  Pod         → jamais directement en prod (test/debug)        │
│  Deployment  → applications stateless (web, API)              │
│  ReplicaSet  → jamais directement (utilisé par Deployment)    │
│  StatefulSet → applications avec état (bases de données)      │
│  DaemonSet   → un pod par node (logs, monitoring, réseau)     │
│  Job         → tâche ponctuelle qui doit réussir              │
│  CronJob     → tâche planifiée récurrente                     │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 14 — SERVICE

## 14.1 Pourquoi le Service existe

### Le problème fondamental

Les pods sont éphémères. Leur IP change à chaque recréation :

```
Pod web-app-xk2p1 : IP 10.42.1.5    (crash)
Pod web-app-mn4q9 : IP 10.42.2.8    (recréé, nouvelle IP)
```

Si ton frontend appelle directement `10.42.1.5`, il casse dès que le pod est recréé. De plus, avec 3 réplicas, vers quelle IP envoyer la requête ?

### La solution : le Service

Le Service fournit une **adresse stable** et un **load balancing** vers un groupe de pods.

**Image mentale :** le Service est comme un **numéro de standard téléphonique d'entreprise**. Tu appelles toujours le même numéro (l'IP du Service). Le standard te redirige vers un employé disponible (un pod). Si un employé part, le standard redirige vers un autre, sans que tu changes de numéro.

```
┌────────────────────────────────────────────────────────────────┐
│                     LE SERVICE                              │
│                                                                │
│  Client → Service (ClusterIP: 10.96.0.100:80) [STABLE]       │
│                    │                                          │
│                    │ load balancing                          │
│         ┌──────────┼──────────┐                              │
│         ▼          ▼          ▼                              │
│      Pod 1      Pod 2      Pod 3                             │
│   10.42.1.5   10.42.2.8   10.42.3.2  [ÉPHÉMÈRES]           │
│                                                                │
│  L'IP du Service ne change JAMAIS.                            │
│  Les IPs des pods changent, mais le Service suit             │
│  automatiquement grâce aux labels.                           │
└────────────────────────────────────────────────────────────────┘
```

---

## 14.2 Les types de Services

```
┌────────────────────────────────────────────────────────────────┐
│                  TYPES DE SERVICES                          │
│                                                                │
│  ClusterIP (défaut)                                          │
│  → IP interne au cluster uniquement                          │
│  → Accessible seulement depuis l'intérieur du cluster        │
│                                                                │
│  NodePort                                                    │
│  → Expose sur un port de CHAQUE node (30000-32767)           │
│  → Accessible depuis l'extérieur via <IP-node>:<nodePort>    │
│                                                                │
│  LoadBalancer                                                │
│  → Crée un load balancer externe (cloud provider)            │
│  → IP publique dédiée                                        │
│                                                                │
│  ExternalName                                                │
│  → Alias DNS vers un service externe                         │
│  → Pas de proxy, juste un CNAME DNS                          │
│                                                                │
│  Headless (clusterIP: None)                                 │
│  → Pas d'IP virtuelle, DNS retourne les IPs des pods         │
│  → Pour StatefulSets, découverte directe des pods            │
└────────────────────────────────────────────────────────────────┘
```

## 14.3 ClusterIP en détail

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: ClusterIP           # défaut, peut être omis
  selector:
    app: web                # sélectionne les pods avec ce label
  ports:
  - name: http
    port: 80                # port du Service
    targetPort: 8080        # port du conteneur
    protocol: TCP
```

### port vs targetPort

```
┌────────────────────────────────────────────────────────────────┐
│                port vs targetPort                            │
│                                                                │
│  Client → Service:80 → Pod:8080                              │
│           (port)       (targetPort)                          │
│                                                                │
│  port       : le port sur lequel le Service écoute           │
│  targetPort : le port sur lequel le conteneur écoute         │
│                                                                │
│  Le client se connecte au "port".                            │
│  Le Service redirige vers le "targetPort" des pods.          │
│                                                                │
│  targetPort peut être un nom (si le port du conteneur        │
│  est nommé) :                                                 │
│  targetPort: http  → cible le port nommé "http" du conteneur │
└────────────────────────────────────────────────────────────────┘
```

## 14.4 NodePort en détail

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80              # port du ClusterIP (interne)
    targetPort: 8080      # port du conteneur
    nodePort: 30080       # port externe sur chaque node (30000-32767)
```

```
┌────────────────────────────────────────────────────────────────┐
│                     NODEPORT                                │
│                                                                │
│  Client externe                                              │
│      │                                                        │
│      │ http://<IP-de-n-importe-quel-node>:30080              │
│      ▼                                                        │
│  ┌──────────────────────────────────────────────┐           │
│  │  Node 1 (:30080)  Node 2 (:30080)  Node 3     │           │
│  │       │                │             │        │           │
│  │       └────────────────┼─────────────┘        │           │
│  │                        ▼                       │           │
│  │             ClusterIP interne :80              │           │
│  │                        │                       │           │
│  │              ┌─────────┼─────────┐             │           │
│  │              ▼         ▼         ▼             │           │
│  │           Pod:8080  Pod:8080  Pod:8080         │           │
│  └──────────────────────────────────────────────┘           │
│                                                                │
│  Le port 30080 est ouvert sur TOUS les nodes,                │
│  même ceux qui n'hébergent pas de pod du Service.            │
└────────────────────────────────────────────────────────────────┘
```

## 14.5 LoadBalancer en détail

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

```
┌────────────────────────────────────────────────────────────────┐
│                   LOADBALANCER                              │
│                                                                │
│  Internet                                                    │
│      │                                                        │
│      ▼                                                        │
│  Load Balancer Cloud (AWS ELB, GCP LB...)                    │
│  IP publique : 34.120.45.67                                  │
│      │                                                        │
│      ▼                                                        │
│  NodePort (créé automatiquement)                             │
│      │                                                        │
│      ▼                                                        │
│  ClusterIP                                                   │
│      │                                                        │
│      ▼                                                        │
│  Pods                                                        │
│                                                                │
│  Note : nécessite un cloud provider.                         │
│  En local (K3s/K3d), reste "Pending" sauf avec              │
│  MetalLB ou le ServiceLB de K3s (Klipper).                  │
└────────────────────────────────────────────────────────────────┘
```

## 14.6 Le rôle des Endpoints

Quand tu crées un Service, Kubernetes crée automatiquement un objet `Endpoints` (ou `EndpointSlice`) qui liste les IPs des pods correspondants.

```
┌────────────────────────────────────────────────────────────────┐
│                    ENDPOINTS                                │
│                                                                │
│  Service "web" (selector: app=web)                           │
│      │                                                        │
│      │ Endpoint Controller surveille les pods                │
│      ▼                                                        │
│  Endpoints "web" :                                           │
│    10.42.1.5:8080   ← pod 1 (Ready)                         │
│    10.42.2.8:8080   ← pod 2 (Ready)                         │
│    10.42.3.2:8080   ← pod 3 (Ready)                         │
│                                                                │
│  Quand un pod devient NotReady :                             │
│  → retiré des Endpoints → plus de trafic vers lui            │
│                                                                │
│  Vérifier :                                                   │
│  kubectl get endpoints web                                   │
│  kubectl get endpointslices                                  │
└────────────────────────────────────────────────────────────────┘
```

## 14.7 La résolution DNS des Services

```
┌────────────────────────────────────────────────────────────────┐
│                DNS DES SERVICES                             │
│                                                                │
│  Format complet :                                            │
│  <service>.<namespace>.svc.cluster.local                     │
│                                                                │
│  Exemples depuis un pod :                                    │
│                                                                │
│  Même namespace :                                            │
│  curl http://web-service                                     │
│  curl http://web-service:80                                  │
│                                                                │
│  Autre namespace :                                           │
│  curl http://web-service.production                          │
│  curl http://web-service.production.svc.cluster.local        │
│                                                                │
│  Le port peut être nommé via SRV records mais c'est rare.    │
└────────────────────────────────────────────────────────────────┘
```

## 14.8 sessionAffinity et externalTrafficPolicy

```yaml
spec:
  # Colle un client au même pod (basé sur l'IP source)
  sessionAffinity: ClientIP    # None (défaut) ou ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800

  # Préserve l'IP source du client (NodePort/LoadBalancer)
  externalTrafficPolicy: Local  # Cluster (défaut) ou Local
```

```
┌────────────────────────────────────────────────────────────────┐
│              externalTrafficPolicy                          │
│                                                                │
│  Cluster (défaut)                                            │
│  → Le trafic peut être routé vers un pod sur un autre node   │
│  → L'IP source du client est masquée (SNAT)                  │
│  → Meilleure distribution de charge                          │
│                                                                │
│  Local                                                       │
│  → Le trafic reste sur le node qui l'a reçu                  │
│  → L'IP source du client est préservée                       │
│  → Si pas de pod sur ce node → connexion refusée             │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 15 — INGRESS

## 15.1 Pourquoi l'Ingress existe

### Le problème

Avec les Services :
- NodePort : ports bizarres (30000+), un port par service, pas pratique
- LoadBalancer : une IP publique (et un coût) PAR service

Si tu as 20 microservices à exposer, tu aurais besoin de 20 LoadBalancers (20 IPs publiques, 20 fois le coût). Absurde.

### La solution : l'Ingress

L'Ingress permet d'exposer PLUSIEURS services derrière UNE SEULE IP, en routant selon :
- Le nom de domaine (host)
- Le chemin URL (path)

**Image mentale :** l'Ingress est comme la **réception d'un immeuble de bureaux**. Une seule entrée (une IP publique). La réception lit ta destination ("Service comptabilité" = app1.com, "Service RH" = app2.com) et te dirige vers le bon étage (le bon Service).

```
┌────────────────────────────────────────────────────────────────┐
│                     INGRESS                                 │
│                                                                │
│  Internet (une seule IP publique)                            │
│      │                                                        │
│      ▼                                                        │
│  ┌──────────────────────────────────────────┐               │
│  │         INGRESS CONTROLLER               │               │
│  │         (Traefik, Nginx...)              │               │
│  │                                          │               │
│  │  Lit le Host header et le path :         │               │
│  │  app1.com      → Service app-one         │               │
│  │  app2.com      → Service app-two         │               │
│  │  app3.com/api  → Service api             │               │
│  └──────────────────────────────────────────┘               │
│      │              │              │                         │
│      ▼              ▼              ▼                         │
│  Service app-one  Service app-two  Service api               │
│      │              │              │                         │
│      ▼              ▼              ▼                         │
│  Pods            Pods            Pods                        │
└────────────────────────────────────────────────────────────────┘
```

## 15.2 Ingress Controller vs Ingress Resource

Point crucial souvent mal compris :

```
┌────────────────────────────────────────────────────────────────┐
│         INGRESS RESOURCE vs INGRESS CONTROLLER              │
│                                                                │
│  INGRESS RESOURCE (l'objet YAML)                             │
│  → Juste des RÈGLES déclaratives                             │
│  → "app1.com doit aller vers le Service app-one"            │
│  → Ne fait RIEN tout seul                                   │
│                                                                │
│  INGRESS CONTROLLER (le programme qui tourne)                │
│  → Lit les Ingress Resources                                │
│  → Configure un vrai reverse proxy (Nginx, Traefik)         │
│  → Route effectivement le trafic                            │
│                                                                │
│  Sans Ingress Controller, tes Ingress Resources sont         │
│  des bouts de papier que personne ne lit !                   │
│                                                                │
│  K3s inclut Traefik par défaut.                              │
│  Kubernetes standard n'inclut RIEN → il faut l'installer.    │
└────────────────────────────────────────────────────────────────┘
```

## 15.3 L'Ingress complet

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mon-ingress
  annotations:
    # Spécifie quel Ingress Controller utiliser
    kubernetes.io/ingress.class: "traefik"
spec:
  # Optionnel : classe d'Ingress (méthode moderne)
  ingressClassName: traefik

  # --- RÈGLES DE ROUTAGE ---
  rules:
  # Règle basée sur le host
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-one
            port:
              number: 80

  - host: app2.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-two
            port:
              number: 80

  # Règle basée sur le path
  - host: api.example.com
    http:
      paths:
      - path: /users
        pathType: Prefix
        backend:
          service:
            name: users-service
            port:
              number: 80
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: products-service
            port:
              number: 80

  # Règle par défaut (sans host) - DOIT être en dernier
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: default-app
            port:
              number: 80

  # --- TLS (HTTPS) ---
  tls:
  - hosts:
    - app1.com
    - app2.com
    secretName: mon-certificat-tls
```

## 15.4 pathType en détail

```
┌────────────────────────────────────────────────────────────────┐
│                    pathType                                 │
│                                                                │
│  Prefix                                                      │
│  → Matche tout ce qui COMMENCE par le path                   │
│  → path: /api matche /api, /api/, /api/users, /api/v1/x     │
│                                                                │
│  Exact                                                       │
│  → Matche EXACTEMENT le path                                 │
│  → path: /api matche SEULEMENT /api                          │
│  → /api/users ne matche PAS                                  │
│                                                                │
│  ImplementationSpecific                                      │
│  → Dépend de l'Ingress Controller                            │
│  → Comportement variable, éviter                             │
└────────────────────────────────────────────────────────────────┘
```

## 15.5 L'ordre des règles compte

```
┌────────────────────────────────────────────────────────────────┐
│              ORDRE DES RÈGLES INGRESS                        │
│                                                                │
│  La règle par défaut (sans host) doit être en DERNIER.       │
│                                                                │
│  INCORRECT (défaut en premier) :                             │
│  - http:                    ← capture TOUT                   │
│      paths:                                                   │
│      - path: /              → default-app                    │
│  - host: app1.com           ← jamais atteinte !             │
│      ...                                                      │
│                                                                │
│  CORRECT (défaut en dernier) :                               │
│  - host: app1.com           ← règle spécifique d'abord      │
│      ...                                                      │
│  - http:                    ← fallback en dernier           │
│      paths:                                                   │
│      - path: /              → default-app                    │
└────────────────────────────────────────────────────────────────┘
```

## 15.6 Comment tester un Ingress sans DNS

Comme vu dans le projet IoT, tu peux tester sans configurer de vrai DNS :

```bash
# Méthode 1 : header Host avec curl
curl -H "Host: app1.com" http://192.168.56.110

# Méthode 2 : modifier /etc/hosts
echo "192.168.56.110 app1.com app2.com app3.com" | sudo tee -a /etc/hosts
# puis dans le navigateur : http://app1.com

# Méthode 3 : option --resolve de curl
curl --resolve app1.com:80:192.168.56.110 http://app1.com
```

## 15.7 Le flux complet d'une requête via Ingress

```
┌────────────────────────────────────────────────────────────────┐
│         FLUX COMPLET D'UNE REQUÊTE INGRESS                  │
│                                                                │
│  1. curl -H "Host: app1.com" http://192.168.56.110          │
│                                                                │
│  2. La requête arrive sur le node (port 80)                  │
│                                                                │
│  3. Traefik (Ingress Controller) écoute le port 80           │
│     Il reçoit la requête                                      │
│                                                                │
│  4. Traefik lit le header "Host: app1.com"                   │
│                                                                │
│  5. Traefik consulte ses règles (issues des Ingress) :       │
│     app1.com → Service app-one:80                            │
│                                                                │
│  6. Traefik route vers le ClusterIP du Service app-one       │
│                                                                │
│  7. Le Service app-one load-balance vers un de ses pods      │
│     (via les Endpoints et iptables/kube-proxy)              │
│                                                                │
│  8. Le pod traite la requête et répond                       │
│                                                                │
│  9. La réponse remonte le chemin inverse                     │
└────────────────────────────────────────────────────────────────┘
```

## 15.8 Erreurs fréquentes avec l'Ingress

```
┌────────────────────────────────────────────────────────────────┐
│              ERREURS INGRESS COURANTES                      │
│                                                                │
│  404 sur toutes les requêtes                                 │
│  → Ingress Controller pas installé                           │
│  → ou ingressClassName incorrect                             │
│  → ou le Service référencé n'existe pas                      │
│                                                                │
│  404 sur une règle spécifique seulement                      │
│  → faute de frappe dans le host ou le nom du Service         │
│  → ordre des règles (défaut avant spécifique)                │
│                                                                │
│  502 Bad Gateway                                             │
│  → Le Service existe mais pas de pods Ready derrière         │
│  → Vérifier kubectl get endpoints <service>                  │
│                                                                │
│  Annotation ignorée                                          │
│  → Utiliser une annotation Nginx sur Traefik (ou l'inverse)  │
│  → Chaque controller a ses propres annotations               │
│                                                                │
│  ADDRESS vide dans kubectl get ingress                       │
│  → Normal en K3s local sans LoadBalancer cloud               │
│  → Le trafic passe par l'IP du node directement             │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 16 — NAMESPACE

## 16.1 Pourquoi les Namespaces existent

Un cluster Kubernetes peut héberger des centaines d'applications, plusieurs équipes, plusieurs environnements. Sans organisation, ce serait le chaos : collisions de noms, aucune isolation, impossible de gérer les permissions.

**Image mentale :** les namespaces sont comme les **appartements dans un immeuble**. Chaque appartement (namespace) a ses propres occupants (ressources), sa propre organisation, et on peut avoir un "Jean Dupont" dans l'appartement 1 et un autre "Jean Dupont" dans l'appartement 2 sans conflit.

## 16.2 Le Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: prod
```

## 16.3 Ce que les Namespaces isolent (et n'isolent pas)

```
┌────────────────────────────────────────────────────────────────┐
│              PORTÉE DES NAMESPACES                           │
│                                                                │
│  ISOLÉ par namespace (namespaced resources) :                │
│  - Pods, Deployments, ReplicaSets, StatefulSets              │
│  - Services, Ingress                                         │
│  - ConfigMaps, Secrets                                       │
│  - PersistentVolumeClaims                                    │
│  - Roles, RoleBindings                                       │
│  - ServiceAccounts                                           │
│                                                                │
│  NON isolé (cluster-scoped resources) :                      │
│  - Nodes                                                     │
│  - PersistentVolumes                                         │
│  - StorageClasses                                            │
│  - ClusterRoles, ClusterRoleBindings                        │
│  - Namespaces eux-mêmes                                      │
│  - IngressClasses                                            │
└────────────────────────────────────────────────────────────────┘
```

## 16.4 Les namespaces système

```
┌────────────────────────────────────────────────────────────────┐
│              NAMESPACES PAR DÉFAUT                           │
│                                                                │
│  default          → où vont tes ressources sans namespace    │
│  kube-system      → composants Kubernetes (CoreDNS, proxy)   │
│  kube-public      → ressources publiques (lisibles par tous) │
│  kube-node-lease  → heartbeats des nodes (leases)            │
└────────────────────────────────────────────────────────────────┘
```

## 16.5 Commandes namespaces

```bash
kubectl get namespaces
kubectl create namespace dev
kubectl get pods -n dev              # pods du namespace dev
kubectl get pods --all-namespaces    # ou -A
kubectl config set-context --current --namespace=dev  # namespace par défaut
kubectl delete namespace dev         # SUPPRIME TOUT dedans !
```

---

# CHAPITRE 17 — CONFIGMAP ET SECRET

## 17.1 Pourquoi ils existent

Le principe fondamental : **séparer la configuration du code**. Ton image Docker doit être identique en dev, staging et prod. Seule la configuration change. Il ne faut JAMAIS hardcoder :
- Les URLs de bases de données
- Les mots de passe, clés API
- Les paramètres d'environnement

**Image mentale :** ConfigMap et Secret sont comme les **réglages d'un appareil**. Le même téléviseur (image Docker) peut être configuré différemment (langue, luminosité) selon l'utilisateur, sans changer le téléviseur lui-même.

## 17.2 ConfigMap : configuration non sensible

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  # Paires clé-valeur simples
  DATABASE_HOST: "postgres.production.svc.cluster.local"
  DATABASE_PORT: "5432"
  LOG_LEVEL: "info"

  # Un fichier de configuration complet
  app.properties: |
    server.port=8080
    server.timeout=30
    cache.enabled=true

  nginx.conf: |
    server {
      listen 80;
      location / {
        proxy_pass http://backend;
      }
    }
```

## 17.3 Secret : configuration sensible

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  # Les valeurs DOIVENT être encodées en base64
  db-password: cGFzc3dvcmQxMjM=       # "password123" en base64
  api-key: YWJjZGVmZ2hpams=           # "abcdefghijk" en base64
stringData:
  # stringData accepte le texte en clair (encodé automatiquement)
  db-user: "admin"
```

```
┌────────────────────────────────────────────────────────────────┐
│              SECRET : BASE64 N'EST PAS DU CHIFFREMENT        │
│                                                                │
│  ATTENTION : base64 est un ENCODAGE, pas un CHIFFREMENT.      │
│  N'importe qui peut décoder :                                │
│  echo "cGFzc3dvcmQxMjM=" | base64 -d  → password123          │
│                                                                │
│  Les Secrets sont stockés en base64 dans etcd.               │
│  Pour une vraie sécurité :                                    │
│  - Activer le chiffrement etcd at-rest                       │
│  - Utiliser des solutions externes (Vault, Sealed Secrets)   │
│  - Restreindre l'accès RBAC aux Secrets                      │
└────────────────────────────────────────────────────────────────┘
```

### Créer un Secret en ligne de commande

```bash
# Depuis des valeurs littérales
kubectl create secret generic app-secrets \
  --from-literal=db-password=password123 \
  --from-literal=api-key=abcdefghijk

# Depuis des fichiers
kubectl create secret generic tls-secret \
  --from-file=tls.crt=./cert.pem \
  --from-file=tls.key=./key.pem

# Secret pour un registry Docker privé
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass
```

## 17.4 Les types de Secrets

```
┌────────────────────────────────────────────────────────────────┐
│                  TYPES DE SECRETS                           │
│                                                                │
│  Opaque (défaut)                                            │
│  → données arbitraires clé-valeur                           │
│                                                                │
│  kubernetes.io/tls                                          │
│  → certificats TLS (tls.crt et tls.key)                     │
│                                                                │
│  kubernetes.io/dockerconfigjson                            │
│  → credentials de registry Docker privé                     │
│                                                                │
│  kubernetes.io/service-account-token                       │
│  → token de ServiceAccount                                  │
│                                                                │
│  kubernetes.io/basic-auth                                  │
│  → username/password                                        │
│                                                                │
│  kubernetes.io/ssh-auth                                    │
│  → clé SSH privée                                           │
└────────────────────────────────────────────────────────────────┘
```

## 17.5 Consommer ConfigMap et Secret dans un Pod

### Méthode 1 : variables d'environnement individuelles

```yaml
spec:
  containers:
  - name: app
    image: mon-app
    env:
    # Depuis un ConfigMap
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: DATABASE_HOST
    # Depuis un Secret
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: db-password
```

### Méthode 2 : toutes les clés d'un coup

```yaml
spec:
  containers:
  - name: app
    image: mon-app
    envFrom:
    - configMapRef:
        name: app-config      # toutes les clés deviennent des variables
    - secretRef:
        name: app-secrets     # idem pour le secret
```

### Méthode 3 : monter comme fichiers (volume)

```yaml
spec:
  containers:
  - name: app
    image: mon-app
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: app-config       # chaque clé devient un fichier
  - name: secret-volume
    secret:
      secretName: app-secrets
```

```
┌────────────────────────────────────────────────────────────────┐
│         CONFIGMAP MONTÉ COMME VOLUME                        │
│                                                                │
│  ConfigMap app-config :                                      │
│    DATABASE_HOST: "postgres"                                 │
│    app.properties: "server.port=8080"                        │
│                                                                │
│  Monté dans /etc/config/ devient :                           │
│    /etc/config/DATABASE_HOST     (contient "postgres")       │
│    /etc/config/app.properties    (contient "server.port...")│
│                                                                │
│  Chaque CLÉ devient un FICHIER.                              │
└────────────────────────────────────────────────────────────────┘
```

## 17.6 Mise à jour dynamique

```
┌────────────────────────────────────────────────────────────────┐
│         MISE À JOUR DES CONFIGMAP/SECRET                    │
│                                                                │
│  Variables d'environnement (env/envFrom) :                   │
│  → NE se mettent PAS à jour automatiquement                  │
│  → Il faut redémarrer le pod                                 │
│  → kubectl rollout restart deployment/mon-app                │
│                                                                │
│  Volumes montés :                                            │
│  → SE mettent à jour automatiquement (délai ~1 minute)      │
│  → Mais l'application doit relire le fichier                 │
│  → (beaucoup d'apps ne le font pas sans redémarrage)        │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 18 — VOLUMES, PV, PVC, STORAGECLASS

## 18.1 Le problème du stockage

Les conteneurs sont éphémères. Quand un conteneur redémarre, son système de fichiers est réinitialisé. Toute donnée écrite est perdue.

Pour les applications avec état (bases de données), c'est inacceptable. Il faut un stockage **persistant** qui survit aux redémarrages et recréations de pods.

**Image mentale :** un volume est comme un **disque dur externe**. Le conteneur (ordinateur) peut redémarrer, être remplacé, mais le disque externe (volume) garde les données et peut être rebranché sur le nouveau conteneur.

## 18.2 Les types de volumes

```
┌────────────────────────────────────────────────────────────────┐
│                  TYPES DE VOLUMES                           │
│                                                                │
│  ÉPHÉMÈRES (durée de vie du pod)                            │
│  ├── emptyDir     → dossier vide, partagé entre conteneurs   │
│  │                  du pod, effacé à la mort du pod          │
│  └── configMap/secret → monte config comme fichiers          │
│                                                                │
│  PERSISTANTS (survivent au pod)                             │
│  ├── hostPath     → dossier du node hôte (dev uniquement)   │
│  ├── nfs          → montage NFS réseau                      │
│  ├── PVC          → demande de stockage abstraite (RECOMMANDÉ)│
│  └── CSI          → stockage via driver externe (cloud)     │
└────────────────────────────────────────────────────────────────┘
```

## 18.3 emptyDir

```yaml
spec:
  containers:
  - name: app
    volumeMounts:
    - name: cache
      mountPath: /cache
  - name: sidecar
    volumeMounts:
    - name: cache
      mountPath: /shared    # même volume, partagé entre les 2 conteneurs
  volumes:
  - name: cache
    emptyDir:
      sizeLimit: 1Gi
      # medium: Memory  ← pour un tmpfs (RAM au lieu de disque)
```

Usage : cache temporaire, partage de fichiers entre conteneurs d'un même pod. Effacé quand le pod meurt.

## 18.4 hostPath

```yaml
spec:
  containers:
  - name: app
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    hostPath:
      path: /var/log/mon-app
      type: DirectoryOrCreate
```

```
┌────────────────────────────────────────────────────────────────┐
│                  DANGER hostPath                            │
│                                                                │
│  hostPath monte un dossier du NODE dans le pod.              │
│                                                                │
│  Problèmes :                                                  │
│  - Si le pod est reschedulé sur un autre node, les données   │
│    ne suivent PAS (elles étaient sur l'ancien node)         │
│  - Risque de sécurité (accès au filesystem du node)         │
│                                                                │
│  Usage acceptable :                                          │
│  - DaemonSets qui accèdent aux logs/métriques du node       │
│  - Développement local (Minikube, K3d)                      │
│                                                                │
│  À ÉVITER en production pour des données applicatives.       │
└────────────────────────────────────────────────────────────────┘
```

## 18.5 Le modèle PV / PVC / StorageClass

C'est le système de stockage persistant recommandé de Kubernetes. Il sépare la **demande** (PVC) de la **ressource** (PV).

```
┌────────────────────────────────────────────────────────────────┐
│              LE MODÈLE PV / PVC / STORAGECLASS              │
│                                                                │
│  StorageClass (le "type" de stockage)                        │
│  → "SSD rapide", "HDD économique", "NFS partagé"            │
│  → Définit COMMENT provisionner le stockage                 │
│      │                                                        │
│      │ provisionne dynamiquement                             │
│      ▼                                                        │
│  PersistentVolume (PV) - la ressource réelle                 │
│  → Un vrai morceau de stockage (10Gi sur un disque SSD)     │
│  → Existe indépendamment des pods                           │
│      │                                                        │
│      │ lié à (bound)                                         │
│      ▼                                                        │
│  PersistentVolumeClaim (PVC) - la demande                    │
│  → "J'ai besoin de 10Gi en lecture-écriture"               │
│  → Ce que l'application demande                             │
│      │                                                        │
│      │ monté dans                                           │
│      ▼                                                        │
│  Pod                                                        │
│  → Utilise le PVC comme un volume                          │
└────────────────────────────────────────────────────────────────┘
```

### Pourquoi cette séparation ?

Elle sépare les rôles :
- L'**administrateur** gère les StorageClass et parfois les PV (l'infrastructure)
- Le **développeur** crée juste un PVC (la demande) sans savoir comment le stockage est provisionné

### PersistentVolumeClaim (ce que tu écris le plus souvent)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
  - ReadWriteOnce         # voir modes ci-dessous
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
```

### PersistentVolume (souvent auto-créé par la StorageClass)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  persistentVolumeReclaimPolicy: Retain  # Retain, Delete, Recycle
  nfs:
    server: 192.168.1.100
    path: /exports/data
```

### StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs   # le driver de provisioning
parameters:
  type: gp3
  iopsPerGB: "10"
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

## 18.6 Les access modes

```
┌────────────────────────────────────────────────────────────────┐
│                  ACCESS MODES                               │
│                                                                │
│  ReadWriteOnce (RWO)                                        │
│  → Monté en lecture-écriture par UN SEUL node               │
│  → Le plus courant (disques block : EBS, GCE PD)           │
│                                                                │
│  ReadOnlyMany (ROX)                                        │
│  → Monté en lecture seule par PLUSIEURS nodes               │
│                                                                │
│  ReadWriteMany (RWX)                                       │
│  → Monté en lecture-écriture par PLUSIEURS nodes            │
│  → Nécessite un stockage réseau (NFS, CephFS)              │
│  → Les disques block NE le supportent PAS                   │
│                                                                │
│  ReadWriteOncePod (RWOP)                                   │
│  → Monté par UN SEUL pod (plus strict que RWO)             │
└────────────────────────────────────────────────────────────────┘
```

## 18.7 Utiliser un PVC dans un Pod

```yaml
spec:
  containers:
  - name: postgres
    image: postgres:14
    volumeMounts:
    - name: data
      mountPath: /var/lib/postgresql/data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc     # référence le PVC créé plus tôt
```

## 18.8 Le cycle de vie du binding

```
┌────────────────────────────────────────────────────────────────┐
│              CYCLE DE VIE PV/PVC                            │
│                                                                │
│  1. Tu crées un PVC (demande de 10Gi)                        │
│     État : Pending                                           │
│                                                                │
│  2a. Provisioning STATIQUE :                                 │
│      Un PV correspondant existe déjà → binding immédiat      │
│                                                                │
│  2b. Provisioning DYNAMIQUE :                                │
│      La StorageClass crée automatiquement un PV              │
│      → PV créé → binding                                     │
│                                                                │
│  3. PVC lié (Bound) au PV                                    │
│     État : Bound                                             │
│                                                                │
│  4. Un pod utilise le PVC → stockage monté                  │
│                                                                │
│  5. Suppression du PVC :                                     │
│     reclaimPolicy détermine le sort du PV :                  │
│     - Retain : le PV et les données sont conservés          │
│     - Delete : le PV et les données sont supprimés          │
└────────────────────────────────────────────────────────────────┘
```

## 18.9 CSI : Container Storage Interface

Le CSI est le standard qui permet à des fournisseurs de stockage tiers de s'intégrer à Kubernetes sans modifier le code de Kubernetes.

```
┌────────────────────────────────────────────────────────────────┐
│                  CSI                                        │
│                                                                │
│  Comme le CRI (runtime) et le CNI (réseau),                  │
│  le CSI est une interface standard pour le STOCKAGE.        │
│                                                                │
│  Kubernetes → CSI Driver → Système de stockage réel          │
│                                                                │
│  Exemples de drivers CSI :                                    │
│  - AWS EBS CSI driver                                        │
│  - GCE PD CSI driver                                         │
│  - Ceph CSI                                                  │
│  - Longhorn (stockage distribué pour K3s)                   │
│                                                                │
│  Le driver CSI gère : create, attach, mount, unmount,        │
│  detach, delete des volumes.                                │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 19 — RBAC : SERVICEACCOUNT, ROLE, CLUSTERROLE

## 19.1 Pourquoi RBAC existe

RBAC (Role-Based Access Control) contrôle **qui peut faire quoi** dans le cluster. Sans lui, n'importe qui pourrait tout supprimer.

**Image mentale :** RBAC est le **système de badges d'accès d'une entreprise**. Chaque personne (utilisateur ou application) a un badge (ServiceAccount) qui lui donne accès à certaines zones (Roles) selon son travail.

## 19.2 Les 4 concepts de RBAC

```
┌────────────────────────────────────────────────────────────────┐
│                  LES 4 PIÈCES DE RBAC                       │
│                                                                │
│  QUI (les identités)                                        │
│  ├── User          → humain (géré hors Kubernetes)          │
│  ├── Group         → groupe d'utilisateurs                  │
│  └── ServiceAccount → identité d'une application/pod         │
│                                                                │
│  QUOI (les permissions)                                     │
│  ├── Role          → permissions dans UN namespace          │
│  └── ClusterRole   → permissions dans TOUT le cluster       │
│                                                                │
│  LIAISON (attribution)                                      │
│  ├── RoleBinding        → lie identité ↔ Role (namespace)   │
│  └── ClusterRoleBinding → lie identité ↔ ClusterRole (cluster)│
└────────────────────────────────────────────────────────────────┘
```

## 19.3 ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mon-app-sa
  namespace: production
```

Chaque pod tourne avec un ServiceAccount (le `default` s'il n'est pas spécifié). Ce SA détermine ce que le pod peut faire via l'API Kubernetes.

```yaml
spec:
  serviceAccountName: mon-app-sa   # le pod utilise ce SA
  containers:
  - name: app
    image: mon-app
```

## 19.4 Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: production
rules:
- apiGroups: [""]              # "" = core API group
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
```

### Les verbs (actions)

```
┌────────────────────────────────────────────────────────────────┐
│                  VERBS RBAC                                 │
│                                                                │
│  get      → lire un objet spécifique                        │
│  list     → lister les objets                               │
│  watch    → surveiller les changements                      │
│  create   → créer                                           │
│  update   → modifier (remplacer)                            │
│  patch    → modifier (partiellement)                        │
│  delete   → supprimer                                       │
│  deletecollection → supprimer plusieurs                     │
│                                                                │
│  "*"      → tous les verbs                                  │
└────────────────────────────────────────────────────────────────┘
```

## 19.5 ClusterRole

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader          # pas de namespace (cluster-scoped)
rules:
- apiGroups: [""]
  resources: ["nodes"]       # Nodes sont cluster-scoped
  verbs: ["get", "list", "watch"]
```

## 19.6 RoleBinding et ClusterRoleBinding

```yaml
# Lie un ServiceAccount à un Role
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: production
subjects:
- kind: ServiceAccount
  name: mon-app-sa
  namespace: production
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```
┌────────────────────────────────────────────────────────────────┐
│              COMBINAISONS RBAC                              │
│                                                                │
│  Role + RoleBinding                                         │
│  → permissions dans un seul namespace                       │
│                                                                │
│  ClusterRole + ClusterRoleBinding                          │
│  → permissions dans tout le cluster                         │
│                                                                │
│  ClusterRole + RoleBinding (combinaison utile !)            │
│  → un ClusterRole réutilisable, appliqué à un namespace     │
│  → ex: le ClusterRole "admin" appliqué au namespace "dev"   │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 20 — NETWORKPOLICY

## 20.1 Pourquoi NetworkPolicy existe

Par défaut dans Kubernetes, **tous les pods peuvent communiquer avec tous les pods**. C'est un risque de sécurité : si un pod est compromis, il peut atteindre toute la base de données.

NetworkPolicy est un **firewall au niveau des pods**.

**Image mentale :** sans NetworkPolicy, tous les bureaux d'un immeuble ont des portes ouvertes entre eux. NetworkPolicy installe des serrures : seuls les bureaux autorisés peuvent communiquer.

## 20.2 NetworkPolicy complète

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: production
spec:
  # À quels pods cette policy s'applique
  podSelector:
    matchLabels:
      app: database

  policyTypes:
  - Ingress
  - Egress

  # Trafic ENTRANT autorisé
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend        # seuls les pods "backend" peuvent entrer
    ports:
    - protocol: TCP
      port: 5432

  # Trafic SORTANT autorisé
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: logging
    ports:
    - protocol: TCP
      port: 514
```

## 20.3 Le point crucial : deny par défaut

```
┌────────────────────────────────────────────────────────────────┐
│              LOGIQUE NETWORKPOLICY                          │
│                                                                │
│  Règle 1 : sans AUCUNE NetworkPolicy                         │
│  → tout est autorisé (allow all)                            │
│                                                                │
│  Règle 2 : dès qu'UNE NetworkPolicy sélectionne un pod       │
│  → tout ce qui n'est PAS explicitement autorisé est REFUSÉ  │
│  → (deny by default pour ce pod)                           │
│                                                                │
│  Exemple deny-all (isole totalement) :                       │
│  spec:                                                       │
│    podSelector: {}          ← tous les pods                 │
│    policyTypes:                                             │
│    - Ingress                ← bloque tout l'entrant         │
│                                                                │
│  IMPORTANT : NetworkPolicy nécessite un CNI qui la supporte  │
│  (Calico, Cilium). Flannel seul ne l'implémente PAS !        │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 21 — HPA, LIMITRANGE, RESOURCEQUOTA

## 21.1 HorizontalPodAutoscaler (HPA)

Le HPA ajuste automatiquement le nombre de réplicas selon la charge.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70    # cible : 70% CPU moyen
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

```
┌────────────────────────────────────────────────────────────────┐
│                  FONCTIONNEMENT HPA                         │
│                                                                │
│  Toutes les 15s, le HPA :                                    │
│  1. Lit les métriques (via Metrics Server)                   │
│  2. Calcule : réplicas désirés =                            │
│     ceil(réplicas actuels × métrique actuelle / cible)      │
│                                                                │
│  Exemple :                                                    │
│  - 3 pods, CPU moyen à 90%, cible 70%                        │
│  - désirés = ceil(3 × 90 / 70) = ceil(3.86) = 4            │
│  → scale à 4 pods                                            │
│                                                                │
│  Nécessite : Metrics Server installé                         │
│  Nécessite : resources.requests définies sur les pods       │
└────────────────────────────────────────────────────────────────┘
```

## 21.2 ResourceQuota

Limite les ressources totales d'un namespace.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: production
spec:
  hard:
    requests.cpu: "10"           # total des requests CPU
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "50"                   # max 50 pods
    services: "10"
    persistentvolumeclaims: "20"
```

## 21.3 LimitRange

Définit des valeurs par défaut et des limites par conteneur/pod dans un namespace.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
  - type: Container
    default:                     # limits par défaut si non spécifiées
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:              # requests par défaut
      cpu: "100m"
      memory: "128Mi"
    max:                         # maximum autorisé
      cpu: "2"
      memory: "2Gi"
    min:                         # minimum requis
      cpu: "50m"
      memory: "64Mi"
```

---

# CHAPITRE 22 — LE RÉSEAU KUBERNETES EN PROFONDEUR

## 22.1 Les 4 problèmes réseau de Kubernetes

```
┌────────────────────────────────────────────────────────────────┐
│              LES 4 PROBLÈMES RÉSEAU                         │
│                                                                │
│  1. Conteneur ↔ Conteneur (même pod)                         │
│     → via localhost (namespace réseau partagé)              │
│                                                                │
│  2. Pod ↔ Pod (même node ou nodes différents)                │
│     → via le CNI (chaque pod a une IP unique)               │
│                                                                │
│  3. Pod ↔ Service                                           │
│     → via kube-proxy (iptables/IPVS) et ClusterIP           │
│                                                                │
│  4. Externe ↔ Service                                       │
│     → via NodePort, LoadBalancer, ou Ingress                │
└────────────────────────────────────────────────────────────────┘
```

## 22.2 Le modèle réseau de Kubernetes

Kubernetes impose 3 règles fondamentales :

```
┌────────────────────────────────────────────────────────────────┐
│              RÈGLES DU MODÈLE RÉSEAU                        │
│                                                                │
│  1. Chaque pod a sa propre IP unique dans le cluster         │
│                                                                │
│  2. Tous les pods peuvent communiquer entre eux SANS NAT     │
│     (peu importe le node)                                    │
│                                                                │
│  3. L'IP qu'un pod voit de lui-même = l'IP que les autres    │
│     voient de lui                                            │
│                                                                │
│  Ces règles sont implémentées par le CNI (Flannel, Calico). │
└────────────────────────────────────────────────────────────────┘
```

## 22.3 Les plages d'IP dans un cluster

```
┌────────────────────────────────────────────────────────────────┐
│              LES 3 PLAGES D'IP                             │
│                                                                │
│  Node CIDR (IPs des nodes)                                  │
│  → ex: 192.168.1.0/24                                       │
│  → IPs réelles des machines                                 │
│                                                                │
│  Pod CIDR (IPs des pods)                                    │
│  → ex: 10.42.0.0/16                                         │
│  → attribuées par le CNI                                    │
│  → chaque node reçoit un sous-réseau (10.42.1.0/24...)     │
│                                                                │
│  Service CIDR (ClusterIPs des services)                     │
│  → ex: 10.96.0.0/12                                         │
│  → IPs VIRTUELLES (n'existent nulle part physiquement)     │
│  → gérées par kube-proxy via iptables                      │
└────────────────────────────────────────────────────────────────┘
```

## 22.4 Comment une ClusterIP fonctionne (la magie de kube-proxy)

Une ClusterIP est une IP **virtuelle** qui n'existe sur aucune interface réseau. Comment ça marche ?

```
┌────────────────────────────────────────────────────────────────┐
│         LA MAGIE DE LA CLUSTERIP                            │
│                                                                │
│  Service "web" : ClusterIP 10.96.0.50:80                    │
│  Pods : 10.42.1.5:8080, 10.42.2.8:8080                     │
│                                                                │
│  Un pod fait : curl http://10.96.0.50:80                    │
│                                                                │
│  1. Le paquet part vers 10.96.0.50                          │
│                                                                │
│  2. Les règles iptables (créées par kube-proxy) interceptent│
│     tout paquet vers 10.96.0.50:80                          │
│                                                                │
│  3. iptables fait du DNAT (Destination NAT) :               │
│     réécrit la destination vers un pod réel                 │
│     10.96.0.50:80 → 10.42.1.5:8080 (choix aléatoire)      │
│                                                                │
│  4. Le paquet part vers le vrai pod                         │
│                                                                │
│  La ClusterIP n'existe QUE dans les règles iptables.        │
│  C'est pour ça qu'on ne peut pas la "pinger" comme une      │
│  vraie IP dans certains cas.                                │
└────────────────────────────────────────────────────────────────┘
```

## 22.5 iptables vs IPVS

```
┌────────────────────────────────────────────────────────────────┐
│              MODES DE KUBE-PROXY                           │
│                                                                │
│  iptables (défaut)                                          │
│  → Utilise les règles iptables du kernel Linux              │
│  → Simple, robuste                                          │
│  → Performance dégradée avec BEAUCOUP de services           │
│    (parcours linéaire des règles)                          │
│                                                                │
│  IPVS (IP Virtual Server)                                   │
│  → Utilise le module IPVS du kernel                         │
│  → Table de hachage (O(1) au lieu de O(n))                 │
│  → Meilleur pour les gros clusters (1000+ services)         │
│  → Plus d'algorithmes de load balancing (rr, lc, sh...)    │
└────────────────────────────────────────────────────────────────┘
```

## 22.6 Les CNI comparés

```
┌────────────────────────────────────────────────────────────────┐
│                  CNI EN DÉTAIL                             │
│                                                                │
│  FLANNEL                                                    │
│  → Overlay réseau simple via VXLAN                          │
│  → Encapsule les paquets pod dans des paquets UDP           │
│  → PAS de NetworkPolicy                                     │
│  → Défaut de K3s                                           │
│                                                                │
│  CALICO                                                     │
│  → Utilise BGP (routage natif, pas d'overlay par défaut)   │
│  → Performant (pas d'encapsulation si BGP)                  │
│  → NetworkPolicies avancées                                 │
│  → Populaire en production                                  │
│                                                                │
│  CILIUM                                                     │
│  → Basé sur eBPF (dans le kernel, très performant)         │
│  → Observabilité poussée (Hubble)                          │
│  → NetworkPolicies L7 (HTTP-aware)                         │
│  → Moderne, en forte croissance                            │
└────────────────────────────────────────────────────────────────┘
```

## 22.7 Le VXLAN de Flannel expliqué en détail

```
┌────────────────────────────────────────────────────────────────┐
│              ENCAPSULATION VXLAN                            │
│                                                                │
│  Pod A (10.42.1.5 sur Node1 192.168.1.10)                  │
│  veut parler à                                              │
│  Pod B (10.42.2.8 sur Node2 192.168.1.20)                  │
│                                                                │
│  1. Pod A émet : [src:10.42.1.5 | dst:10.42.2.8 | data]    │
│                                                                │
│  2. Flannel sur Node1 intercepte, encapsule dans VXLAN :    │
│     ┌─────────────────────────────────────────────────┐    │
│     │ Outer IP: src:192.168.1.10 dst:192.168.1.20     │    │
│     │ UDP (port 8472)                                 │    │
│     │ VXLAN header (VNI)                              │    │
│     │  ┌───────────────────────────────────────────┐ │    │
│     │  │ Inner: src:10.42.1.5 dst:10.42.2.8 | data│ │    │
│     │  └───────────────────────────────────────────┘ │    │
│     └─────────────────────────────────────────────────┘    │
│                                                                │
│  3. Ce paquet voyage sur le réseau physique                 │
│     (192.168.1.10 → 192.168.1.20)                          │
│                                                                │
│  4. Flannel sur Node2 décapsule                             │
│                                                                │
│  5. Pod B reçoit : [src:10.42.1.5 | dst:10.42.2.8 | data]  │
│                                                                │
│  Le réseau overlay "10.42.x.x" est virtuel, construit       │
│  par-dessus le réseau physique "192.168.1.x".              │
└────────────────────────────────────────────────────────────────┘
```

---
# CHAPITRE 23 — K3S

## 23.1 Ce qu'est K3s exactement

K3s est une distribution Kubernetes **certifiée conforme** (CNCF), c'est-à-dire du vrai Kubernetes, mais optimisée pour :
- Les environnements à ressources limitées (IoT, edge, Raspberry Pi)
- La simplicité d'installation (un seul binaire)
- Le développement et l'apprentissage

**Image mentale :** si Kubernetes standard est un **camion de déménagement** (puissant mais lourd et complexe), K3s est une **camionnette** : moins imposant, plus facile à conduire, suffisant pour la plupart des besoins.

## 23.2 Ce que K3s change par rapport à Kubernetes standard

```
┌────────────────────────────────────────────────────────────────┐
│              K3s vs KUBERNETES STANDARD                     │
│                                                                │
│  STOCKAGE                                                    │
│  Standard : etcd (cluster distribué complexe)               │
│  K3s      : SQLite par défaut (fichier unique simple)       │
│             (etcd optionnel pour la HA)                     │
│                                                                │
│  BINAIRE                                                     │
│  Standard : plusieurs binaires séparés                      │
│  K3s      : UN seul binaire (< 100 Mo) contenant tout      │
│                                                                │
│  COMPOSANTS INTÉGRÉS                                        │
│  K3s inclut par défaut :                                    │
│  - Traefik (Ingress Controller)                            │
│  - ServiceLB / Klipper (LoadBalancer)                      │
│  - Local Path Provisioner (stockage)                       │
│  - CoreDNS, Metrics Server                                  │
│  - Flannel (CNI)                                           │
│                                                                │
│  RETIRÉ                                                      │
│  - Cloud provider code (in-tree)                           │
│  - Storage drivers legacy                                  │
│  - Fonctionnalités alpha peu utilisées                     │
│                                                                │
│  RUNTIME                                                     │
│  K3s : containerd intégré (pas besoin d'installer Docker)   │
└────────────────────────────────────────────────────────────────┘
```

## 23.3 L'architecture K3s

```
┌────────────────────────────────────────────────────────────────┐
│              ARCHITECTURE K3s                              │
│                                                                │
│  K3s SERVER (Control Plane + peut exécuter des pods)         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Un seul processus k3s qui contient :                │   │
│  │  - API Server                                        │   │
│  │  - Scheduler                                         │   │
│  │  - Controller Manager                                │   │
│  │  - SQLite (ou etcd)                                  │   │
│  │  - Kubelet (car il peut aussi faire tourner des pods)│   │
│  │  - containerd                                        │   │
│  │  - Flannel                                           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                │
│  K3s AGENT (Worker uniquement)                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Un seul processus k3s agent qui contient :          │   │
│  │  - Kubelet                                           │   │
│  │  - containerd                                        │   │
│  │  - Flannel                                           │   │
│  │  - kube-proxy                                        │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────┘
```

## 23.4 Installation de K3s

```bash
# Installation du serveur (Control Plane)
curl -sfL https://get.k3s.io | sh -

# Avec des options
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
  --write-kubeconfig-mode=644 \
  --node-ip=192.168.56.110 \
  --disable=traefik" sh -

# Récupérer le token pour joindre des agents
sudo cat /var/lib/rancher/k3s/server/node-token

# Sur un agent (worker), joindre le cluster
curl -sfL https://get.k3s.io | \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN=<le-token> \
  sh -
```

## 23.5 Les variables d'environnement K3s

```
┌────────────────────────────────────────────────────────────────┐
│              VARIABLES K3s                                 │
│                                                                │
│  INSTALL_K3S_EXEC                                          │
│  → arguments passés au binaire k3s                         │
│  → ex: "--disable=traefik --node-ip=..."                  │
│                                                                │
│  INSTALL_K3S_VERSION                                       │
│  → version précise à installer                             │
│  → ex: "v1.28.5+k3s1"                                     │
│                                                                │
│  INSTALL_K3S_CHANNEL                                       │
│  → canal (stable, latest, testing)                        │
│                                                                │
│  K3S_URL                                                   │
│  → URL du serveur à rejoindre (pour un agent)             │
│  → sa présence fait de l'installation un AGENT             │
│                                                                │
│  K3S_TOKEN                                                 │
│  → token d'authentification pour rejoindre le cluster      │
│                                                                │
│  K3S_KUBECONFIG_MODE                                       │
│  → permissions du fichier kubeconfig                       │
└────────────────────────────────────────────────────────────────┘
```

## 23.6 Le node-token expliqué

```
┌────────────────────────────────────────────────────────────────┐
│              LE NODE-TOKEN                                 │
│                                                                │
│  Emplacement :                                              │
│  /var/lib/rancher/k3s/server/node-token                     │
│                                                                │
│  Format :                                                   │
│  K10<hash-du-CA>::server:<secret>                          │
│                                                                │
│  Rôle :                                                     │
│  - Authentifie un agent qui veut rejoindre le cluster       │
│  - Contient de quoi vérifier le certificat du serveur       │
│                                                                │
│  Sécurité :                                                 │
│  - Quiconque a ce token + l'URL peut joindre le cluster     │
│  - À protéger en production                                 │
│                                                                │
│  Pour joindre un agent, il faut DEUX choses :               │
│  1. K3S_URL   (où est le serveur)                          │
│  2. K3S_TOKEN (preuve d'autorisation)                      │
│  L'un sans l'autre ne suffit pas.                          │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 24 — K3D

## 24.1 Ce qu'est K3d

K3d = **K3s in Docker**. Il fait tourner un cluster K3s complet où chaque "node" est un **conteneur Docker** au lieu d'une machine ou VM.

**Image mentale :** au lieu de construire des maisons séparées (VMs) pour chaque node, K3d construit des chambres (conteneurs) dans une même maison (ton Docker). Beaucoup plus rapide et léger, parfait pour tester.

## 24.2 Ce que K3d crée réellement

```
┌────────────────────────────────────────────────────────────────┐
│         CE QUE K3d CRÉE DANS DOCKER                        │
│                                                                │
│  k3d cluster create mycluster --servers 1 --agents 2         │
│                                                                │
│  Crée ces conteneurs Docker :                                │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ k3d-mycluster-server-0                                │   │
│  │ → conteneur avec k3s server (Control Plane)          │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ k3d-mycluster-agent-0                                 │   │
│  │ → conteneur avec k3s agent (Worker)                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ k3d-mycluster-agent-1                                 │   │
│  │ → conteneur avec k3s agent (Worker)                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ k3d-mycluster-serverlb                                │   │
│  │ → conteneur load balancer (reverse proxy)            │   │
│  │ → point d'entrée unique vers le cluster              │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                │
│  + un réseau Docker dédié pour que ces conteneurs           │
│    communiquent entre eux                                    │
└────────────────────────────────────────────────────────────────┘
```

## 24.3 Pourquoi un LoadBalancer Docker est créé

```
┌────────────────────────────────────────────────────────────────┐
│         LE LOADBALANCER K3d (serverlb)                     │
│                                                                │
│  Problème : dans Docker, les conteneurs ont des IPs           │
│  internes qui changent. Comment accéder au cluster de         │
│  façon stable depuis ta machine hôte ?                        │
│                                                                │
│  Solution : le conteneur serverlb                            │
│  → C'est un reverse proxy (basé sur nginx)                   │
│  → Il a un point d'entrée stable                            │
│  → Il redirige vers les serveurs K3s                        │
│                                                                │
│  C'est aussi lui qui gère le mapping des ports :             │
│  --port "8080:80@loadbalancer"                              │
│  → port 8080 de ta machine → port 80 du loadbalancer        │
│  → puis vers le Traefik interne du cluster                  │
└────────────────────────────────────────────────────────────────┘
```

## 24.4 La syntaxe des ports décodée

```
┌────────────────────────────────────────────────────────────────┐
│         DÉCODAGE : --port "8080:80@loadbalancer"           │
│                                                                │
│  8080          → port sur ta MACHINE HÔTE                    │
│  :             → séparateur                                  │
│  80            → port DANS le conteneur cible               │
│  @loadbalancer → QUEL conteneur reçoit ce mapping           │
│                                                                │
│  Chemin complet d'une requête :                              │
│                                                                │
│  Ta machine (localhost:8080)                                 │
│        │                                                      │
│        ▼                                                      │
│  Conteneur serverlb (port 80)                                │
│        │                                                      │
│        ▼                                                      │
│  Traefik dans le cluster K3s (port 80)                       │
│        │                                                      │
│        ▼                                                      │
│  Ton Service → tes Pods                                       │
│                                                                │
│  Autres cibles possibles :                                   │
│  @server:0   → le serveur 0 directement                     │
│  @agent:1    → l'agent 1 directement                        │
│  @all        → tous les nodes                               │
└────────────────────────────────────────────────────────────────┘
```

## 24.5 Pourquoi @loadbalancer et pas directement un node

```
┌────────────────────────────────────────────────────────────────┐
│         POURQUOI PASSER PAR LE LOADBALANCER                │
│                                                                │
│  Si tu mappais directement vers @server:0 :                  │
│  → Le port ne fonctionnerait que si ce serveur précis        │
│    est vivant                                                │
│  → Pas de répartition entre plusieurs serveurs               │
│                                                                │
│  Avec @loadbalancer :                                        │
│  → Point d'entrée stable indépendant des nodes               │
│  → Répartition automatique                                   │
│  → Résilience si un node tombe                              │
│                                                                │
│  C'est le même principe qu'un vrai LoadBalancer cloud,       │
│  mais simulé dans un conteneur Docker.                       │
└────────────────────────────────────────────────────────────────┘
```

## 24.6 Commandes K3d

```bash
# Créer un cluster
k3d cluster create mycluster \
  --servers 1 \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer"

# Lister les clusters
k3d cluster list

# Démarrer/arrêter
k3d cluster start mycluster
k3d cluster stop mycluster

# Supprimer
k3d cluster delete mycluster

# Charger une image locale dans le cluster (utile en dev !)
k3d image import mon-image:latest -c mycluster

# Récupérer le kubeconfig
k3d kubeconfig get mycluster
```

## 24.7 Comment K3d configure kubectl

```
┌────────────────────────────────────────────────────────────────┐
│         K3d ET KUBECONFIG                                  │
│                                                                │
│  À la création, K3d :                                        │
│  1. Génère le kubeconfig du cluster                          │
│  2. Le fusionne dans ~/.kube/config                          │
│  3. Change le contexte courant vers le nouveau cluster       │
│                                                                │
│  Le kubeconfig pointe vers le loadbalancer (serverlb) :      │
│  server: https://0.0.0.0:<port-aléatoire>                   │
│                                                                │
│  Ainsi kubectl parle au serverlb, qui relaie vers l'API      │
│  Server réel dans le conteneur k3s-server.                  │
└────────────────────────────────────────────────────────────────┘
```

---

# CHAPITRE 25 — ARGOCD ET GITOPS

## 25.1 Qu'est-ce que le GitOps

Le GitOps est une méthode de déploiement où **Git est la source unique de vérité**. L'état désiré du cluster est décrit dans un dépôt Git, et un outil (ArgoCD) synchronise automatiquement le cluster avec ce dépôt.

**Image mentale :** le GitOps est comme un **thermostat connecté à un plan écrit**. Tu écris sur le plan "je veux 21°C" (tu commits dans Git). Le thermostat (ArgoCD) lit ce plan en permanence et ajuste le chauffage (le cluster) pour correspondre. Si quelqu'un baisse manuellement le chauffage, le thermostat le remet à 21°C (self-heal).

## 25.2 Le principe fondamental

```
┌────────────────────────────────────────────────────────────────┐
│              GITOPS : LE PRINCIPE                          │
│                                                                │
│  APPROCHE TRADITIONNELLE (push) :                            │
│  Développeur → kubectl apply → Cluster                       │
│  (l'humain pousse les changements vers le cluster)          │
│  Problèmes : qui a fait quoi ? état réel = état voulu ?      │
│                                                                │
│  APPROCHE GITOPS (pull) :                                    │
│  Développeur → git push → Dépôt Git                          │
│                              │                               │
│                              │ ArgoCD surveille              │
│                              ▼                               │
│                          ArgoCD → applique au Cluster        │
│  (ArgoCD tire les changements depuis Git)                   │
│                                                                │
│  Avantages :                                                 │
│  - Git = historique complet + audit + rollback              │
│  - État déclaratif et versionné                             │
│  - Self-healing (correction des dérives)                    │
│  - Pas de credentials cluster distribués aux devs           │
└────────────────────────────────────────────────────────────────┘
```

## 25.3 Les 4 principes du GitOps

```
┌────────────────────────────────────────────────────────────────┐
│              LES 4 PRINCIPES GITOPS                        │
│                                                                │
│  1. DÉCLARATIF                                              │
│     Tout l'état du système est décrit de façon déclarative  │
│                                                                │
│  2. VERSIONNÉ ET IMMUABLE                                   │
│     L'état est stocké dans Git (historique, versions)       │
│                                                                │
│  3. TIRÉ AUTOMATIQUEMENT (pulled)                           │
│     Les agents tirent l'état désiré depuis Git              │
│                                                                │
│  4. RÉCONCILIÉ EN CONTINU                                   │
│     Des agents vérifient et corrigent les dérives           │
└────────────────────────────────────────────────────────────────┘
```

## 25.4 L'architecture d'ArgoCD

```
┌────────────────────────────────────────────────────────────────┐
│              COMPOSANTS D'ARGOCD                           │
│                                                                │
│  argocd-server                                             │
│  → API + interface web + gRPC                              │
│  → point d'interaction utilisateur                        │
│                                                                │
│  argocd-repo-server                                        │
│  → clone les dépôts Git                                    │
│  → génère les manifestes (Helm, Kustomize, YAML)          │
│                                                                │
│  argocd-application-controller                             │
│  → le cœur : compare l'état Git avec l'état cluster        │
│  → détecte les différences (OutOfSync)                    │
│  → applique les changements (sync)                        │
│                                                                │
│  argocd-dex-server                                         │
│  → authentification SSO (optionnel)                       │
│                                                                │
│  redis                                                     │
│  → cache                                                   │
└────────────────────────────────────────────────────────────────┘
```

## 25.5 L'objet Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mon-app
  namespace: argocd          # les Applications vivent dans argocd
spec:
  project: default

  # --- SOURCE : d'où vient l'état désiré ---
  source:
    repoURL: https://github.com/user/mon-repo.git
    targetRevision: main     # branche, tag, ou commit
    path: manifests          # dossier dans le repo

  # --- DESTINATION : où appliquer ---
  destination:
    server: https://kubernetes.default.svc   # cluster local
    namespace: dev           # namespace cible

  # --- POLITIQUE DE SYNCHRONISATION ---
  syncPolicy:
    automated:
      prune: true            # supprime ce qui n'est plus dans Git
      selfHeal: true         # corrige les dérives manuelles
    syncOptions:
    - CreateNamespace=true    # crée le namespace si absent
```

## 25.6 Les concepts clés d'ArgoCD

```
┌────────────────────────────────────────────────────────────────┐
│              CONCEPTS ARGOCD                              │
│                                                                │
│  SYNC STATUS                                                │
│  - Synced     : cluster = Git                              │
│  - OutOfSync  : cluster ≠ Git (dérive détectée)           │
│                                                                │
│  HEALTH STATUS                                              │
│  - Healthy    : ressources fonctionnelles                  │
│  - Progressing: en cours de déploiement                    │
│  - Degraded   : problème                                   │
│  - Missing    : ressource absente                          │
│                                                                │
│  SYNC (l'action de synchroniser)                           │
│  - Manuel : tu cliques "Sync" ou argocd app sync           │
│  - Automated : ArgoCD sync automatiquement                 │
│                                                                │
│  PRUNE                                                      │
│  - Si true : supprime du cluster ce qui a été retiré de Git │
│  - Si false : garde les ressources orphelines              │
│                                                                │
│  SELF-HEAL                                                 │
│  - Si true : annule les modifs manuelles (kubectl edit)    │
│    pour revenir à l'état Git                               │
│                                                                │
│  REVISION                                                  │
│  - Le commit Git précis déployé                           │
└────────────────────────────────────────────────────────────────┘
```

## 25.7 prune et selfHeal en détail

```
┌────────────────────────────────────────────────────────────────┐
│              PRUNE vs SELF-HEAL                            │
│                                                                │
│  PRUNE (nettoyage)                                         │
│  Scénario : tu supprimes deployment.yaml de Git             │
│  - prune: true  → ArgoCD supprime le Deployment du cluster  │
│  - prune: false → le Deployment reste (orphelin)           │
│                                                                │
│  SELF-HEAL (auto-correction)                               │
│  Scénario : quelqu'un fait kubectl scale deploy --replicas=10│
│             mais Git dit replicas=3                         │
│  - selfHeal: true  → ArgoCD remet à 3 (état Git)          │
│  - selfHeal: false → ArgoCD détecte OutOfSync mais         │
│                       n'agit pas sans sync manuel          │
│                                                                │
│  DANGER de prune: true :                                    │
│  Une suppression accidentelle dans Git → suppression        │
│  automatique en production. À manier avec précaution.       │
└────────────────────────────────────────────────────────────────┘
```

## 25.8 Le cycle GitOps complet

```
┌────────────────────────────────────────────────────────────────┐
│         CYCLE COMPLET GITOPS AVEC ARGOCD                   │
│                                                                │
│  1. Développeur modifie deployment.yaml (image v1 → v2)     │
│                                                                │
│  2. git commit + git push vers le dépôt                     │
│                                                                │
│  3. argocd-repo-server (poll toutes les ~3 min ou webhook)  │
│     détecte le nouveau commit                               │
│                                                                │
│  4. argocd-application-controller compare :                 │
│     - État Git : image v2                                   │
│     - État cluster : image v1                               │
│     → Status : OutOfSync                                    │
│                                                                │
│  5. Si automated sync : ArgoCD applique automatiquement     │
│     Si manuel : attend le clic "Sync"                       │
│                                                                │
│  6. ArgoCD fait kubectl apply en interne                    │
│     → Le Deployment est mis à jour (image v2)              │
│     → Kubernetes fait un rolling update                    │
│                                                                │
│  7. ArgoCD surveille la santé                               │
│     → Status : Synced + Healthy                            │
│                                                                │
│  8. Si quelqu'un modifie manuellement le cluster :          │
│     → selfHeal ramène à l'état Git                         │
└────────────────────────────────────────────────────────────────┘
```

## 25.9 Installation et accès ArgoCD

```bash
# Installer ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Récupérer le mot de passe admin initial
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Accéder à l'interface
kubectl port-forward svc/argocd-server -n argocd 8443:443
# → https://localhost:8443 (user: admin)

# CLI ArgoCD
argocd login localhost:8443
argocd app list
argocd app sync mon-app
argocd app get mon-app
```

---
# CHAPITRE 26 — KUBECTL : TOUTES LES COMMANDES

## 26.1 Comment kubectl fonctionne

```
┌────────────────────────────────────────────────────────────────┐
│              KUBECTL EN INTERNE                            │
│                                                                │
│  kubectl est un CLIENT HTTP qui parle à l'API Server.        │
│                                                                │
│  1. Lit ~/.kube/config (kubeconfig) pour savoir :           │
│     - l'adresse de l'API Server                             │
│     - les credentials (certificat, token)                  │
│     - le contexte courant (cluster + namespace)            │
│                                                                │
│  2. Transforme ta commande en requête HTTP REST             │
│     kubectl get pods → GET /api/v1/namespaces/default/pods  │
│                                                                │
│  3. Envoie la requête, reçoit du JSON                        │
│                                                                │
│  4. Formate le résultat pour l'affichage                    │
└────────────────────────────────────────────────────────────────┘
```

## 26.2 Les commandes de lecture

```bash
# GET : lister/afficher
kubectl get pods                          # pods du namespace courant
kubectl get pods -A                        # tous les namespaces
kubectl get pods -n production             # namespace spécifique
kubectl get pods -o wide                   # + IPs et nodes
kubectl get pods -o yaml                   # sortie YAML complète
kubectl get pods -o json                   # sortie JSON
kubectl get pods --show-labels             # affiche les labels
kubectl get pods -l app=web                # filtre par label
kubectl get pods --watch                   # surveille en temps réel
kubectl get pods --field-selector status.phase=Running
kubectl get all                            # tous les objets courants

# DESCRIBE : détails complets d'un objet (+ events)
kubectl describe pod mon-pod
kubectl describe deployment mon-app
kubectl describe node worker-1

# EXPLAIN : documentation d'un champ
kubectl explain pod.spec.containers
kubectl explain deployment.spec --recursive

# LOGS
kubectl logs mon-pod                       # logs d'un pod
kubectl logs mon-pod -c mon-conteneur      # conteneur spécifique
kubectl logs mon-pod --previous            # logs du crash précédent
kubectl logs mon-pod -f                     # suivre en temps réel
kubectl logs -l app=web --all-containers   # par label
kubectl logs mon-pod --tail=100            # 100 dernières lignes
kubectl logs mon-pod --since=1h            # dernière heure
```

## 26.3 Les commandes de création/modification

```bash
# APPLY : créer ou mettre à jour (déclaratif, RECOMMANDÉ)
kubectl apply -f fichier.yaml
kubectl apply -f dossier/                  # tous les YAML du dossier
kubectl apply -f https://url/fichier.yaml  # depuis une URL
kubectl apply -k dossier/                   # avec Kustomize

# CREATE : créer (impératif, échoue si existe déjà)
kubectl create deployment web --image=nginx
kubectl create namespace dev
kubectl create secret generic mon-secret --from-literal=key=value
kubectl create configmap mon-config --from-file=config.txt

# Générer du YAML sans créer (très utile !)
kubectl create deployment web --image=nginx \
  --dry-run=client -o yaml > deployment.yaml

# EDIT : éditer en direct
kubectl edit deployment web                # ouvre l'éditeur

# PATCH : modifier partiellement
kubectl patch deployment web \
  -p '{"spec":{"replicas":5}}'

# REPLACE : remplacer entièrement
kubectl replace -f fichier.yaml

# SET : modifier un attribut spécifique
kubectl set image deployment/web web=nginx:1.26
kubectl set env deployment/web LOG_LEVEL=debug
kubectl set resources deployment/web --limits=cpu=200m,memory=512Mi
```

## 26.4 Les commandes de gestion

```bash
# SCALE : ajuster le nombre de réplicas
kubectl scale deployment web --replicas=5
kubectl scale deployment web --replicas=0   # arrêter sans supprimer

# ROLLOUT : gérer les déploiements
kubectl rollout status deployment/web       # état du déploiement
kubectl rollout history deployment/web      # historique
kubectl rollout undo deployment/web         # rollback
kubectl rollout undo deployment/web --to-revision=2
kubectl rollout restart deployment/web      # redémarrer les pods
kubectl rollout pause deployment/web
kubectl rollout resume deployment/web

# DELETE : supprimer
kubectl delete pod mon-pod
kubectl delete -f fichier.yaml
kubectl delete deployment web
kubectl delete pods --all                   # tous les pods du namespace
kubectl delete namespace dev                # ATTENTION : supprime tout dedans
```

## 26.5 Les commandes de débogage

```bash
# EXEC : exécuter une commande dans un conteneur
kubectl exec mon-pod -- ls /app
kubectl exec -it mon-pod -- /bin/sh         # shell interactif
kubectl exec -it mon-pod -c conteneur -- /bin/bash

# PORT-FORWARD : rediriger un port local vers un pod/service
kubectl port-forward pod/mon-pod 8080:80
kubectl port-forward svc/mon-service 8080:80
kubectl port-forward deployment/web 8080:80

# CP : copier des fichiers
kubectl cp mon-pod:/app/log.txt ./log.txt   # depuis le pod
kubectl cp ./config.txt mon-pod:/app/        # vers le pod

# TOP : métriques de ressources (nécessite Metrics Server)
kubectl top nodes
kubectl top pods
kubectl top pods -A --sort-by=cpu

# DEBUG : conteneur de débogage éphémère
kubectl debug mon-pod -it --image=busybox

# EVENTS : voir les événements du cluster
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n production
```

## 26.6 Les commandes sur les nodes

```bash
# CORDON : marquer un node comme non-schedulable
kubectl cordon worker-1                     # plus de nouveaux pods

# UNCORDON : réautoriser le scheduling
kubectl uncordon worker-1

# DRAIN : vider un node (pour maintenance)
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data

# TAINT : ajouter/retirer un taint
kubectl taint nodes worker-1 key=value:NoSchedule
kubectl taint nodes worker-1 key=value:NoSchedule-   # retirer
```

## 26.7 Les commandes de métadonnées

```bash
# LABEL : gérer les labels
kubectl label pod mon-pod env=prod
kubectl label pod mon-pod env-                # retirer le label
kubectl label nodes worker-1 disktype=ssd

# ANNOTATE : gérer les annotations
kubectl annotate pod mon-pod description="mon app"

# Configuration et contexte
kubectl config view                          # voir le kubeconfig
kubectl config get-contexts                  # lister les contextes
kubectl config use-context mon-cluster       # changer de cluster
kubectl config set-context --current --namespace=dev

# API discovery
kubectl api-resources                        # tous les types d'objets
kubectl api-versions                         # toutes les versions d'API
kubectl version                              # version client + serveur
kubectl cluster-info                         # infos du cluster
```

## 26.8 Les astuces kubectl

```bash
# Alias recommandé
alias k=kubectl

# Autocomplétion (bash)
source <(kubectl completion bash)

# Sortie personnalisée avec JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'

# Sortie en colonnes personnalisées
kubectl get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP

# Trier
kubectl get pods --sort-by=.metadata.creationTimestamp

# Attendre une condition
kubectl wait --for=condition=Ready pod/mon-pod --timeout=60s
kubectl wait --for=condition=Available deployment/web --timeout=120s

# Dry-run pour valider
kubectl apply -f fichier.yaml --dry-run=client
kubectl apply -f fichier.yaml --dry-run=server

# Diff avant d'appliquer
kubectl diff -f fichier.yaml
```

---

# ANNEXES

## Annexe A — Glossaire

```
┌────────────────────────────────────────────────────────────────┐
│                    GLOSSAIRE                               │
│                                                                │
│  Cluster       : ensemble de machines gérées par Kubernetes  │
│  Node          : une machine (physique ou virtuelle)         │
│  Control Plane : le cerveau du cluster                        │
│  Worker Node   : machine qui exécute les applications         │
│  Pod           : plus petite unité déployable (1+ conteneurs) │
│  Deployment    : gère des pods stateless répliqués            │
│  ReplicaSet    : garantit N réplicas d'un pod                 │
│  StatefulSet   : pods avec identité stable                    │
│  DaemonSet     : un pod par node                              │
│  Job           : tâche ponctuelle                             │
│  CronJob       : tâche planifiée                              │
│  Service       : point d'accès stable vers des pods           │
│  Ingress       : routage HTTP/HTTPS externe                   │
│  ConfigMap     : configuration non sensible                   │
│  Secret        : configuration sensible                       │
│  Namespace     : partition logique du cluster                 │
│  Label         : métadonnée clé-valeur pour sélection         │
│  Selector      : critère de sélection par labels              │
│  PV            : volume de stockage réel                       │
│  PVC           : demande de stockage                          │
│  StorageClass  : type de stockage provisionnable              │
│  CNI           : interface réseau des conteneurs              │
│  CRI           : interface runtime des conteneurs             │
│  CSI           : interface stockage des conteneurs            │
│  etcd          : base de données du cluster                   │
│  kubelet       : agent sur chaque node                        │
│  kube-proxy    : gère les règles réseau des Services          │
│  Reconciliation: boucle qui aligne état réel sur état désiré  │
│  ClusterIP     : IP virtuelle interne d'un Service            │
│  RBAC          : contrôle d'accès basé sur les rôles          │
│  GitOps        : Git comme source de vérité du déploiement    │
└────────────────────────────────────────────────────────────────┘
```

## Annexe B — Ports importants

```
┌────────────────────────────────────────────────────────────────┐
│                    PORTS KUBERNETES                       │
│                                                                │
│  6443   → API Server (HTTPS)                                 │
│  2379   → etcd (client)                                      │
│  2380   → etcd (peer)                                        │
│  10250  → Kubelet API                                        │
│  10256  → kube-proxy health                                  │
│  30000-32767 → plage NodePort                                │
│  8472   → Flannel VXLAN (UDP)                                │
│  53     → CoreDNS (DNS)                                      │
└────────────────────────────────────────────────────────────────┘
```

## Annexe C — Cheat sheet de débogage

```
┌────────────────────────────────────────────────────────────────┐
│              WORKFLOW DE DÉBOGAGE                          │
│                                                                │
│  Pod ne démarre pas :                                        │
│  1. kubectl get pods            (quel état ?)                │
│  2. kubectl describe pod X       (events en bas)             │
│  3. kubectl logs X               (logs applicatifs)          │
│  4. kubectl logs X --previous    (si crash loop)             │
│                                                                │
│  Service inaccessible :                                      │
│  1. kubectl get endpoints X      (des pods derrière ?)       │
│  2. kubectl get pods -l <selector> (pods Ready ?)           │
│  3. Vérifier port vs targetPort                             │
│  4. kubectl exec depuis un autre pod pour tester            │
│                                                                │
│  Ingress 404 :                                              │
│  1. Ingress Controller installé ?                           │
│  2. kubectl get ingress                                     │
│  3. Ordre des règles, ingressClassName                      │
│  4. Service référencé existe ?                              │
│                                                                │
│  Node NotReady :                                            │
│  1. kubectl describe node X      (conditions)               │
│  2. Vérifier kubelet sur le node                           │
│  3. Vérifier le CNI                                         │
└────────────────────────────────────────────────────────────────┘
```

## Annexe D — Les états courants et leur signification

```
┌────────────────────────────────────────────────────────────────┐
│              ÉTATS ET SIGNIFICATIONS                      │
│                                                                │
│  Running            → tout va bien                          │
│  Pending            → en attente (ressources ? scheduling ?) │
│  ContainerCreating  → création en cours (pull image ?)      │
│  CrashLoopBackOff   → crash répété (voir logs --previous)   │
│  ImagePullBackOff   → image introuvable/inaccessible        │
│  ErrImagePull       → échec du pull d'image                 │
│  OOMKilled          → dépassement mémoire (augmenter limits) │
│  Completed          → terminé avec succès (normal pour Job)  │
│  Error              → terminé en erreur                     │
│  Terminating        → en cours de suppression               │
│  Evicted            → expulsé (manque de ressources node)   │
│  Init:0/1           → init container en cours               │
└────────────────────────────────────────────────────────────────┘
```

## Annexe E — Mémotechniques

```
┌────────────────────────────────────────────────────────────────┐
│                  MÉMOTECHNIQUES                          │
│                                                                │
│  Ordre du lancement d'un pod :                              │
│  "A-E-S-K-C" = API server, Etcd, Scheduler, Kubelet, CRI    │
│                                                                │
│  Les 3 interfaces standard :                                │
│  "CRI-CNI-CSI" = Runtime, Network, Storage                  │
│                                                                │
│  livenessProbe vs readinessProbe :                          │
│  Liveness  = "es-tu VIVANT ?" (échec → REDÉMARRE)          │
│  Readiness = "es-tu PRÊT ?" (échec → RETIRE du service)    │
│                                                                │
│  Labels vs Annotations :                                    │
│  Labels = pour SÉLECTIONNER (courts, indexés)              │
│  Annotations = pour INFORMER (longs, non-indexés)          │
│                                                                │
│  spec vs status :                                           │
│  spec = ce que JE veux (j'écris)                           │
│  status = ce qui EST (Kubernetes écrit)                    │
└────────────────────────────────────────────────────────────────┘
```

## Annexe F — Ressources pour aller plus loin

```
┌────────────────────────────────────────────────────────────────┐
│              POUR APPROFONDIR                             │
│                                                                │
│  Documentation officielle : kubernetes.io/docs              │
│  API Reference : kubernetes.io/docs/reference               │
│  kubectl explain <objet> : documentation intégrée           │
│                                                                │
│  Pratique :                                                  │
│  - killercoda.com (labs interactifs gratuits)               │
│  - kodekloud.com (cours pratiques)                          │
│                                                                │
│  Certifications :                                            │
│  - CKA (Certified Kubernetes Administrator)                 │
│  - CKAD (Certified Kubernetes Application Developer)        │
│  - CKS (Certified Kubernetes Security Specialist)           │
└────────────────────────────────────────────────────────────────┘
```

---

# CONCLUSION

Ce livre a couvert Kubernetes depuis les fondations conceptuelles jusqu'aux détails internes de son fonctionnement. Tu as maintenant :

- La compréhension du **pourquoi** (les problèmes que Kubernetes résout)
- L'**architecture** complète (Control Plane, Worker Nodes, et leurs composants)
- Le **cycle de vie** détaillé d'un YAML jusqu'au conteneur en exécution
- La maîtrise du **YAML** et de tous les champs Kubernetes
- Chaque **objet** Kubernetes en profondeur
- Le **réseau**, le **stockage**, la **sécurité**
- **K3s**, **K3d**, **ArgoCD** et le **GitOps**
- Toutes les commandes **kubectl**

La clé pour devenir expert : **pratiquer**. Monte un cluster K3d, déploie des applications, casse-les volontairement, répare-les. La compréhension théorique de ce livre combinée à la pratique fera de toi un expert Kubernetes.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│   "Kubernetes n'est pas compliqué une fois qu'on comprend     │
│    qu'il ne fait qu'une seule chose, en boucle, pour tout :   │
│    comparer ce qui EST à ce qui DEVRAIT ÊTRE,                 │
│    et corriger la différence."                                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

*Fin du livre.*
