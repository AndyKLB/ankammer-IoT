# 🗺️ SCHÉMA RÉSEAU COMPLET — INCEPTION OF THINGS
## Du curl jusqu'au pod, chaque couture numérotée

> **Comment lire ce document.** Chaque lien entre deux objets est une **couture**, numérotée
> ①②③… pour le flux Nord-Sud et ⒶⒷⒸ… pour le flux Est-Ouest. Quand le même numéro
> apparaît sur deux objets différents, c'est que ces deux champs DOIVENT être égaux :
> c'est là que ça se coud — et là que ça craque en cas de faute de frappe.

---

## 0. LÉGENDE — les deux familles de trafic et les quatre réseaux

```
NORD-SUD  = trafic qui ENTRE dans le cluster depuis l'extérieur
            (toi → app, toi → GitLab, toi → ArgoCD)
            chemin : /etc/hosts → Docker → serverlb → Traefik → pod

EST-OUEST = trafic ENTRE les pods, à l'intérieur du cluster
            (ArgoCD → GitLab, GitLab → PostgreSQL/Redis/MinIO)
            chemin : CoreDNS → ClusterIP → iptables → pod
            → ne touche JAMAIS Traefik ni le serverlb !
```

| Réseau traversé      | Plage (défauts K3s) | Géré par                                  |
|----------------------|---------------------|-------------------------------------------|
| Loopback hôte        | `127.0.0.1`         | le kernel de TA machine                    |
| Réseau Docker k3d    | `172.18.0.0/16`     | Docker (bridge `k3d-mycluster`)            |
| Pod CIDR             | `10.42.0.0/16`      | le CNI Flannel                             |
| Service CIDR         | `10.43.0.0/16`      | kube-proxy — **IPs VIRTUELLES** (iptables) |

Rappel clé : les `10.43.x.x` n'existent sur **aucune** carte réseau. Elles ne vivent que
dans des règles iptables. On le voit en action plus bas.

---

## 1. FLUX NORD-SUD — la chaîne verticale complète

Requête : `curl http://local.ankammer.com:8080/`

```
TA MACHINE (hôte)
│
│   curl http://local.ankammer.com:8080/
│
├─① /etc/hosts ──────── local.ankammer.com → 127.0.0.1
│                       (curl CONSERVE le nom : il partira
│                        dans le header "Host:" → couture ⑤)
▼
127.0.0.1:8080
│
├─② DNAT Docker ─────── règle iptables posée à la création du cluster
│                       par  --port "8080:80@loadbalancer"
│                       → destination réécrite : 172.18.0.5:80
▼
┌─────────────────────────────────────────────────────┐
│  CONTENEUR k3d-mycluster-serverlb  (172.18.0.5)     │
│  nginx en mode STREAM = proxy TCP AVEUGLE           │
│  → ne lit RIEN du HTTP, recopie les octets          │
│    vers le port 80 du (des) node(s) server          │
└─────────────────────────────────────────────────────┘
▼
┌─────────────────────────────────────────────────────┐
│  CONTENEUR k3d-mycluster-server-0  (172.18.0.4)     │
│  = LE NODE (tout un Kubernetes à l'intérieur)       │
│                                                     │
│  ServiceLB de K3s (Klipper) tient le :80 du node    │
│  → kube-proxy : DNAT ClusterIP du svc traefik       │
│    vers le pod Traefik réel                         │
└─────────────────────────────────────────────────────┘
▼
┌─────────────────────────────────────────────────────┐
│  POD TRAEFIK  (10.42.0.7)                           │
│  TERMINAISON HTTP — première lecture de la requête  │
│                                                     │
│  ⑤ lit  Host: local.ankammer.com                    │
│  ④ ne considère que les Ingress de SA classe        │
│  ⑧ règle matchée → backend.service.name             │
│  ⑨ backend.service.port.number = 8888               │
│  ⑥ consulte les ENDPOINTS du Service                │
│     (PAS la ClusterIP !) → [10.42.0.12:80, …]       │
└─────────────────────────────────────────────────────┘
│
├─⑦ connexion DIRECTE au PodIP:targetPort
│   trajet : veth Traefik → bridge cni0 → veth app
│   (un seul node → pas de VXLAN, pont Linux pur)
▼
┌─────────────────────────────────────────────────────┐
│  POD ankammer-playground  (10.42.0.12)              │
│  le PROCESSUS nginx écoute sur 80 (= targetPort)    │
│  → répond {"status":"ok","message":"v2"}            │
└─────────────────────────────────────────────────────┘
│
▼  RETOUR : conntrack a mémorisé chaque traduction
   → dé-NAT automatique à chaque étape, en sens inverse
```

---

## 2. LES YAML CÔTE À CÔTE — où vivent les coutures

> Même numéro des deux côtés = les deux champs doivent être **identiques**.

### 2.1 — Ingress ↔ Service (coutures ③ ④ ⑤ ⑧ ⑨)

```
INGRESS  (namespace: dev)                     SERVICE  (namespace: dev)
──────────────────────────────────────        ──────────────────────────────────
apiVersion: networking.k8s.io/v1              apiVersion: v1
kind: Ingress                                 kind: Service
metadata:                                     metadata:
  name: ankammer-playground                     name: ankammer-playground   ⑧
  namespace: dev                     ③          namespace: dev              ③
spec:                                         spec:
  ingressClassName: traefik          ④          selector:
  rules:                                          app: ankammer-playground  ⑥
  - host: local.ankammer.com         ⑤          ports:
    http:                                       - port: 8888                ⑨
      paths:                                      targetPort: 80            ⑦
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ankammer-playground ⑧
            port:
              number: 8888            ⑨
```

- **③** : un Ingress ne peut référencer qu'un Service de **son propre namespace**
  (contrainte stricte de l'API — pas de cross-namespace).
- **⑧/⑨** : référence par **nom** + par **port du Service** (jamais le targetPort ici).

### 2.2 — Service ↔ Pod (coutures ⑥ ⑦)

```
SERVICE  (dev)                                POD  (template du Deployment, dev)
──────────────────────────────────────        ──────────────────────────────────
spec:                                         metadata:
  selector:                                     labels:
    app: ankammer-playground         ⑥            app: ankammer-playground  ⑥
  ports:                                      spec:
  - port: 8888                                  containers:
      ("prise murale" côté cluster,             - name: app
       jamais sur le fil pour Traefik)            ports:
    targetPort: 80                   ⑦            - containerPort: 80
                                                    (DOCUMENTATION seulement)
                                                ⑦ = le port d'ÉCOUTE réel du
                                                    PROCESSUS (config nginx),
                                                    que targetPort doit refléter
```

- **⑥** : le selector attrape les pods par **labels** → l'Endpoint Controller
  fabrique la liste `PodIP:targetPort` des pods **Ready**.
- **⑦** : `containerPort` ne fait rien ; la vérité est le `listen` du processus.
  Mismatch targetPort ↔ listen = `connection refused`.

### 2.3 — Tableau des 9 coutures Nord-Sud

| #  | Le lien (égalité exigée)                                | Lu par                | Si mismatch                       |
|----|---------------------------------------------------------|-----------------------|-----------------------------------|
| ①  | nom tapé ↔ entrée `/etc/hosts` → 127.0.0.1              | l'OS (avant tout DNS) | « Server not found »              |
| ②  | `8080:80@loadbalancer` → règle DNAT Docker              | kernel hôte           | connexion refusée sur :8080       |
| ③  | namespace Ingress ↔ namespace Service                   | l'API (contrainte)    | référence impossible              |
| ④  | `ingressClassName` ↔ classe de Traefik                  | Traefik               | règle ignorée → **404**           |
| ⑤  | nom tapé = header `Host:` = `rules.host`                | Traefik (routage L7)  | mauvaise règle → **404**/autre app|
| ⑥  | `service.selector` ↔ `pod.labels`                       | Endpoint Controller   | Endpoints vides → **503**         |
| ⑦  | `targetPort` ↔ port d'écoute du **processus**           | Traefik via Endpoints | **connection refused** → 503      |
| ⑧  | `backend.service.name` ↔ `service.metadata.name`        | Traefik               | **503** service not found         |
| ⑨  | `backend.service.port.number` ∈ `service.ports[].port`  | Traefik (clé vers ⑦)  | **503**                           |

---

## 3. FLUX EST-OUEST — ArgoCD → GitLab (coutures Ⓐ-Ⓖ)

### 3.1 — L'URL décomposée : chaque segment est une couture

```
repoURL de l'Application ArgoCD (namespace argocd) :

http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/ankammer-iot.git
       └──────────Ⓐ───────────┘└─Ⓑ──┘└───────Ⓒ────────┘└─Ⓔ─┘└────────Ⓕ────────┘

Ⓐ  = metadata.name du SERVICE           → résolu par CoreDNS
Ⓑ  = namespace du Service               → obligatoire : ArgoCD vit dans
                                           "argocd", pas dans "gitlab"
Ⓒ  = suffixe DNS standard du cluster    → "ceci est un Service"
Ⓔ  = PORT du Service (8181 = Workhorse, → traduit par iptables (DNAT)
     le frontal HTTP de GitLab)
Ⓕ  = chemin côté GITLAB (plus du K8s !) → "root" = utilisateur GitLab
                                           (PAS root Linux), projet ankammer-iot
```

### 3.2 — URL ↔ Service ↔ Pod côte à côte (Ⓐ Ⓑ Ⓓ Ⓔ Ⓖ)

```
SERVICE  (namespace: gitlab)                  POD webservice  (gitlab)
──────────────────────────────────────        ──────────────────────────────────
apiVersion: v1                                metadata:
kind: Service                                   labels:
metadata:                                         app: webservice           Ⓓ
  name: gitlab-webservice-default    Ⓐ        spec:
  namespace: gitlab                  Ⓑ          containers:
spec:                                           - name: webservice
  selector:                                       (Workhorse écoute 8181
    app: webservice                  Ⓓ             par sa configuration)
  ports:
  - port: 8181                       Ⓔ
    targetPort: 8181                 Ⓖ
```

### 3.3 — Le rituel en 4 temps (identique pour TOUTES les flèches internes)

```
TEMPS 1 — QUESTION DNS
  Le pod (repo-server) veut joindre  gitlab-webservice-default.gitlab.svc.cluster.local
  Son /etc/resolv.conf (injecté par le kubelet) pointe vers CoreDNS (10.43.0.10)

TEMPS 2 — RÉPONSE
  CoreDNS (qui watch les Services) répond : 10.43.55.10  ← une ClusterIP FANTÔME

TEMPS 3 — LA MAGIE IPTABLES (kube-proxy)                                  Ⓔ
  Connexion TCP vers 10.43.55.10:8181 → interceptée par les chaînes :
    KUBE-SERVICES  : "dest 10.43.55.10:8181 ? → saute vers KUBE-SVC-GLXX"
    KUBE-SVC-GLXX  : tirage probabiliste entre les Endpoints              Ⓓ
    KUBE-SEP-YYYY  : DNAT → 10.42.0.30:8181 (le VRAI pod)                 Ⓖ

TEMPS 4 — DERNIER SAUT
  10.42.0.20 → 10.42.0.30 : veth → cni0 → veth. Livré.
  (conntrack mémorise ; le retour se dé-NAT tout seul)
```

Remplace `8181` par `5432` (PostgreSQL), `6379` (Redis) ou `9000` (MinIO) :
**c'est mot pour mot le même film** pour chaque dépendance du bonus.

### 3.4 — Tableau des coutures Est-Ouest

| #  | Le lien                                        | Mécanisme                              |
|----|------------------------------------------------|----------------------------------------|
| Ⓐ  | segment 1 de l'URL = `metadata.name` du Service| CoreDNS (watch les Services)           |
| Ⓑ  | segment 2 = `namespace` du Service             | CoreDNS (qualification cross-namespace)|
| Ⓒ  | `.svc.cluster.local`                           | suffixe standard → réponse = ClusterIP |
| Ⓓ  | `selector` ↔ labels des pods webservice        | Endpoint Controller → liste PodIP:port |
| Ⓔ  | `:8181` de l'URL = `port` du Service           | kube-proxy : DNAT iptables             |
| Ⓕ  | `/root/ankammer-iot.git`                       | **hors K8s** : Rails (user + projet)   |
| Ⓖ  | `targetPort` = port d'écoute de Workhorse      | dernier saut veth → cni0 → veth        |

---

## 4. LES DEUX CHEMINS VERS LE MÊME GITLAB — la convergence

```
          TOI (git push / navigateur)      ARGOCD (git fetch)
          ─────────────────────────────    ─────────────────────────────────
URL       http://local.gitlab.com:8080     http://gitlab-webservice-default
                 /root/ankammer-iot.git       .gitlab.svc.cluster.local:8181
                                              /root/ankammer-iot.git
                  │                                   │
RÉSOLUTION        │ /etc/hosts (machine HÔTE)         │ CoreDNS (DNS du CLUSTER)
                  │ → 127.0.0.1                       │ → ClusterIP 10.43.55.10
                  ▼                                   ▼
ENTRÉE            :8080 → DNAT Docker                 :8181 → chaînes KUBE-*
                  → serverlb → node                     (DNAT kube-proxy)
                  ▼                                   │
ROUTAGE L7        Traefik lit Host:                   │  (pas de L7 ici :
                  → Ingress gitlab-webservice…        │   DNS + iptables, point)
                  ▼                                   ▼
                  └────────►  SERVICE gitlab-webservice-default : 8181  ◄────┘
                                         │  selector Ⓓ → Endpoints
                                         ▼
                              POD webservice — Workhorse :8181  (Ⓖ)
                                         │
                              Rails décode /root/ankammer-iot.git  (Ⓕ)
                                         ▼
                                  Gitaly (le dépôt physique)
```

**Le point de soutenance :** deux résolutions de nom radicalement différentes
(/etc/hosts vs CoreDNS), deux portes (Traefik vs iptables direct), **un seul
Service, un seul port, un seul dépôt**. Le chemin `/root/ankammer-iot.git` est
identique dans les deux URLs — normal : c'est GitLab qui l'interprète, et c'est
le même GitLab au bout des deux chemins.

---

## 5. LA RÈGLE QUI UNIFIE TOUT — les 4 types de liens

Chaque flèche de ce document est l'un de ces quatre types. Il n'en existe pas d'autre :

```
1. PAR FICHIER LOCAL   /etc/hosts, /etc/resolv.conf          → coutures ①, Ⓒ
2. PAR NOM             backend.service.name, segments DNS     → ⑧, Ⓐ, Ⓑ
3. PAR LABELS          selector ↔ labels                      → ⑥, Ⓓ
4. PAR PORT            mapping → port → targetPort → listen   → ② ⑨ ⑦, Ⓔ Ⓖ
```

### Grille de debug : symptôme → couture

| Symptôme                       | Coutures à vérifier | Vérification                                  |
|--------------------------------|---------------------|-----------------------------------------------|
| « Server not found »           | ①                   | `getent hosts local.ankammer.com`             |
| Connexion refusée sur :8080    | ②                   | `sudo iptables -t nat -S DOCKER \| grep 8080` |
| **404** partout                | ④                   | ingressClassName / controller présent          |
| **404** sur une règle          | ⑤                   | typo dans le host / ordre des règles          |
| **503** no available server    | ⑥ ⑧ ⑨              | `kubectl get endpoints` (vide ?) / nom / port |
| **connection refused**         | ⑦ Ⓖ                | targetPort ≠ port d'écoute du processus       |
| ArgoCD ComparisonError         | Ⓐ Ⓑ Ⓔ Ⓕ           | l'URL interne, segment par segment            |

---

## 6. VOIR CHAQUE COUCHE DE TES PROPRES YEUX

```bash
# ① la résolution hôte
getent hosts local.ankammer.com

# ② la règle DNAT posée par Docker/k3d
sudo iptables -t nat -S DOCKER | grep 8080

# ③-⑨ les objets et leurs coutures
kubectl get ingress -A
kubectl get svc -A | grep -E 'traefik|ankammer|gitlab-webservice'
kubectl get endpoints -n dev ankammer-playground

# Les ClusterIP fantômes : introuvables sur les interfaces…
docker exec k3d-mycluster-server-0 ip addr | grep 10.43        # → rien !
# …mais bien vivantes dans iptables
docker exec k3d-mycluster-server-0 iptables -t nat -L KUBE-SERVICES -n | head

# TEMPS 1-2 : la vision DNS d'un pod
kubectl run t --rm -it --image=busybox -n gitlab -- sh -c \
  "cat /etc/resolv.conf && nslookup gitlab-webservice-default"

# Le test qui reproduit EXACTEMENT ce que fait ArgoCD
kubectl run t --rm -it --image=alpine/git -n argocd -- \
  git ls-remote http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/ankammer-iot.git
```

---

## 7. LA PHRASE DE SOUTENANCE (le condensé)

> « Le trafic externe traverse quatre traductions — /etc/hosts, le DNAT Docker, le
> ServiceLB de K3s, puis Traefik, seul à lire le header Host, qui route directement
> vers les PodIPs via les Endpoints. Le trafic interne n'utilise que deux mécanismes :
> CoreDNS qui traduit les noms de Services en ClusterIPs virtuelles, et les règles
> iptables de kube-proxy qui traduisent ces IPs fantômes en vraies IPs de pods.
> Ingress pour le Nord-Sud, DNS + iptables pour l'Est-Ouest. »
