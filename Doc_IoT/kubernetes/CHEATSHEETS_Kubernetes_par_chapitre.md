# 📋 CHEAT SHEETS — KUBERNETES LE LIVRE COMPLET
## Une fiche de référence rapide par chapitre

---

# FICHE CH.1 — POURQUOI KUBERNETES

```
┌─────────────────────────────────────────────────────────────┐
│ Docker = UN conteneur sur UNE machine                       │
│ Kubernetes = MILLIERS de conteneurs sur CENTAINES de machines│
└─────────────────────────────────────────────────────────────┘
```

**Les 7 superpouvoirs K8s :**
| Pouvoir | Ce que ça fait |
|---|---|
| Auto-healing | Pod mort → recréé auto |
| Auto-scaling | Charge ↑ → réplicas ↑ (HPA) |
| Rolling updates | MAJ sans coupure |
| Service discovery | Les pods se trouvent via DNS |
| Load balancing | Trafic réparti entre réplicas |
| Config management | ConfigMap/Secret injectés |
| Bin packing | Placement optimal des pods |

**Les distributions :**
| Outil | Quoi | Usage |
|---|---|---|
| kubeadm | K8s standard, multi-binaires, etcd | Prod enterprise |
| K3s | K8s allégé CNCF, 1 binaire, SQLite | Edge, IoT, apprentissage |
| K3d | K3s DANS Docker (nodes = conteneurs) | Dev local, CI |
| Minikube | Cluster local dans VM/conteneur | Apprentissage |
| Kind | K8s standard dans Docker | CI/CD, tests |

**Piège classique :** Docker Compose ≠ orchestrateur multi-machines. Compose = dev local mono-machine, K8s = prod distribuée.

---

# FICHE CH.2 — ARCHITECTURE GLOBALE

```
CLUSTER = CONTROL PLANE (cerveau) + WORKER NODES (muscles)

Control Plane : API Server, etcd, Scheduler, Controller Manager
Worker Node   : Kubelet, Container Runtime, Kube-proxy, tes Pods
```

**Règles d'or :**
1. **TOUT passe par l'API Server** (aucune communication directe entre composants)
2. **Modèle DÉCLARATIF** : tu décris l'état final, K8s trouve comment y arriver
3. **Boucle de réconciliation** : comparer désiré vs réel, corriger, répéter — en permanence
4. **Watch, pas polling** : connexions HTTP/2 longue durée, événements pushés

**Structure universelle de tout objet :**
```yaml
apiVersion: <groupe>/<version>  # quelle API
kind: <Type>                    # quel objet
metadata: {...}                 # qui je suis
spec: {...}                     # ce que JE veux (j'écris)
status: {...}                   # ce qui EST (K8s écrit)
```

**Labels = colle du système :**
```yaml
# Pod porte :          # Service sélectionne :
labels:                selector:
  app: web        ←──    app: web
```

---

# FICHE CH.3 — CONTROL PLANE

| Composant | Rôle | Port | Si DOWN |
|---|---|---|---|
| **API Server** | Guichet unique : auth → RBAC → admission → validation → etcd | 6443 | Plus de gestion, pods existants survivent |
| **etcd** | Base clé-valeur, source de vérité, algo Raft | 2379/2380 | Cluster paralysé (gestion), pods survivent |
| **Scheduler** | Choisit le node (filtre + score), écrit `spec.nodeName` | — | Nouveaux pods restent Pending |
| **Controller Mgr** | ~30 boucles de réconciliation (Deployment, RS, Node...) | — | Plus d'auto-healing ni scaling |
| **CoreDNS** | DNS interne : `svc.ns.svc.cluster.local` | 53 | Résolution de noms cassée |

**Pipeline API Server (ordre exact) :**
```
Authentification → Autorisation (RBAC) → Admission (mutating puis validating)
→ Validation schéma → Écriture etcd → Notification watchers
```

**Quorum etcd :** N instances → tolère (N-1)/2 pannes. Toujours **impair** : 3 (tolère 1), 5 (tolère 2).

**Piège :** le Scheduler ne LANCE PAS les pods, il écrit juste `nodeName` dans etcd. C'est le Kubelet qui lance.

---

# FICHE CH.4 — WORKER NODES

| Composant | Rôle |
|---|---|
| **Kubelet** | Agent local : watch ses pods, ordonne au CRI, exécute les probes, rapporte status. Port 10250 |
| **containerd/CRI-O** | Runtime : pull images, crée namespaces/cgroups, lance via runc |
| **Kube-proxy** | Écrit les règles iptables/IPVS des Services (le trafic ne passe PAS par lui) |
| **CNI** (Flannel/Calico/Cilium) | Donne une IP à chaque pod, réseau inter-nodes |

**Stack de lancement :**
```
Kubelet → (gRPC/CRI) → containerd → (OCI) → runc → PROCESSUS Linux
```

**Un conteneur = un processus Linux avec :**
- **namespaces** (pid, net, mnt, uts, ipc) = isolation
- **cgroups** (cpu.max, memory.max) = limites

**Le pause container :** premier conteneur du pod, "tient" le namespace réseau. Les autres le rejoignent. Survit aux redémarrages des conteneurs applicatifs.

**Static pods :** manifestes dans `/etc/kubernetes/manifests/` lus directement par le Kubelet sans API Server — c'est ainsi que le Control Plane lui-même démarre (kubeadm).

---

# FICHE CH.5 — CYCLE DE VIE D'UN YAML

```
kubectl apply -f deploy.yaml
   │  (YAML→JSON, POST https://api:6443/apis/apps/v1/.../deployments)
   ▼
API Server (auth→RBAC→admission→validation→etcd→notif)
   ▼
Deployment Controller  → crée le ReplicaSet
   ▼
ReplicaSet Controller  → crée N Pods (nodeName VIDE = Pending)
   ▼
Scheduler              → filtre + score les nodes → écrit spec.nodeName
   ▼
Kubelet (du node élu)  → pull image, CNI (IP), CRI (conteneurs), probes
   ▼
Pod Running (status remonté à l'API Server)
   ▼
Endpoint Controller    → ajoute l'IP du pod aux Endpoints du Service
   ▼
Kube-proxy (chaque node) → met à jour iptables → trafic routé !
```

**À retenir par cœur (ordre) :** kubectl → API Server → etcd → Controllers → Scheduler → Kubelet → CRI/CNI → Running → Endpoints → iptables.

**kubectl apply :** objet absent → POST (create) ; présent → PATCH (compare avec l'annotation `last-applied-configuration`).

---

# FICHE CH.6 — SYNTAXE YAML

**Règles absolues :**
- ESPACES uniquement, jamais de tabulations (2 espaces = convention K8s)
- Espace obligatoire après `:` et après `-`
- Cohérence d'indentation entre frères

**Types :**
```yaml
string: hello          # ou "hello" ou 'hello'
version: "1.25"        # guillemets sinon → float !
active: true           # booléen (minuscules)
count: 3               # int (PAS "3" si K8s attend un int)
nothing: null          # ou ~
```

**Guillemets OBLIGATOIRES quand :**
- La valeur ressemble à un autre type : `"true"`, `"123"`, `"1.25"`, `"null"`
- Commence par un char spécial : `":x"`, `"*x"`, `"!x"`, `"#x"`, `"[x]"`
- Simple `'...'` = littéral (`'\n'` = backslash-n) ; double `"..."` = interprété (`"\n"` = saut de ligne)

**Structures :**
```yaml
dict:                    # dictionnaire
  clé: valeur
liste:                   # liste
  - item1
  - item2
inline_dict: {a: 1, b: 2}
inline_list: [1, 2, 3]
```

**Multiligne :**
```yaml
literal: |      # préserve les \n (scripts, certifs)
  ligne1
  ligne2
folded: >       # replie les \n en espaces (texte long)
  une longue
  phrase
# |- supprime le \n final ; |+ garde tout
```

**Divers :** `#` commentaire ; `---` sépare les documents ; `&ancre` / `*alias` / `<<: *merge` = réutilisation.

**Logique K8s :** plusieurs exemplaires possibles → liste avec `-` (containers, env, ports, volumes) ; unique → dict (spec, metadata).

**Top 5 des erreurs :** tabulation, tiret oublié, mauvais alignement dans une liste d'objets, `"3"` au lieu de `3`, `:pas-d-espace`.

---

# FICHE CH.7 — CHAMPS UNIVERSELS

**apiVersion — mapping à connaître :**
| Objets | apiVersion |
|---|---|
| Pod, Service, ConfigMap, Secret, Namespace, PV, PVC, SA | `v1` |
| Deployment, ReplicaSet, StatefulSet, DaemonSet | `apps/v1` |
| Job, CronJob | `batch/v1` |
| Ingress, NetworkPolicy, IngressClass | `networking.k8s.io/v1` |
| Role, ClusterRole, (Cluster)RoleBinding | `rbac.authorization.k8s.io/v1` |
| HPA | `autoscaling/v2` |
| StorageClass | `storage.k8s.io/v1` |
| Application ArgoCD | `argoproj.io/v1alpha1` |

**metadata que TU écris :**
```yaml
metadata:
  name: mon-app          # DNS-1123 : minuscules, chiffres, - .
  namespace: prod        # default si absent
  labels: {app: web}     # pour SÉLECTIONNER (max 63 chars)
  annotations: {...}     # pour INFORMER (pas de limite, jamais sélectionnées)
```

**metadata que K8s écrit :**
| Champ | Rôle |
|---|---|
| `uid` | ID unique universel, immuable |
| `resourceVersion` | version → optimistic locking (conflit 409 si périmée) |
| `generation` | incrémenté à chaque changement de **spec** |
| `creationTimestamp` | date de création |
| `ownerReferences` | qui me possède → garbage collection en cascade |
| `finalizers` | bloque la suppression jusqu'au nettoyage (objet coincé en Terminating = finalizer orphelin) |

**Débloquer un objet coincé :**
```bash
kubectl patch <obj> <nom> -p '{"metadata":{"finalizers":null}}' --type=merge
```

**spec vs status :** spec = désiré (toi) ; status = réel (K8s). Le controller fait converger status → spec.

---

# FICHE CH.8 — POD

**Pod minimal :**
```yaml
apiVersion: v1
kind: Pod
metadata: {name: mon-pod}
spec:
  containers:
  - name: web
    image: nginx:1.25
```

**Phases :** Pending → Running → Succeeded/Failed (+ Unknown).
**États conteneur :** Waiting / Running / Terminated.

**command/args vs Dockerfile :**
| YAML | Override |
|---|---|
| rien | ENTRYPOINT + CMD de l'image |
| args seul | ENTRYPOINT image + args YAML |
| command seul | command YAML (CMD ignoré) |
| command + args | tout YAML |

**Les 3 probes :**
| Probe | Question | Si échec |
|---|---|---|
| startupProbe | A fini de démarrer ? | bloque les 2 autres |
| livenessProbe | Vivant ? | **REDÉMARRE** le conteneur |
| readinessProbe | Prêt ? | **RETIRE** des Endpoints (pas de restart) |

Méthodes : `httpGet` (200-399 = OK), `tcpSocket`, `exec` (exit 0 = OK).
Timing : `initialDelaySeconds`, `periodSeconds`, `timeoutSeconds`, `failureThreshold`, `successThreshold`.

**initContainers :** s'exécutent séquentiellement, chacun doit réussir AVANT les conteneurs principaux.

**restartPolicy :** Always (défaut/Deployments) | OnFailure (Jobs) | Never.

**CrashLoopBackOff :** crash répété, délai exponentiel 10s→20s→40s... (max 5 min).
```bash
kubectl logs pod --previous     # logs du crash PRÉCÉDENT
kubectl describe pod            # events en bas
```

**Erreurs → cause :**
| État | Cause probable |
|---|---|
| ImagePullBackOff | image/tag inexistant, registry privé sans secret |
| CrashLoopBackOff | app crash au boot → logs --previous |
| Pending | pas de node éligible (ressources, selector, taints) |
| OOMKilled | dépasse limits.memory |
| CreateContainerConfigError | ConfigMap/Secret référencé absent |

**Ressources :**
```yaml
resources:
  requests: {cpu: 100m, memory: 128Mi}   # pour le scheduling
  limits:   {cpu: 200m, memory: 256Mi}   # plafond (OOMKill si dépassé)
```

---
# FICHE CH.9 — DEPLOYMENT

**Hiérarchie :** Deployment → ReplicaSet → Pods (jamais de gestion directe des pods).

**Squelette complet :**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: web}
spec:
  replicas: 3
  selector:
    matchLabels: {app: web}      # DOIT = template.metadata.labels
  strategy:
    type: RollingUpdate          # ou Recreate
    rollingUpdate:
      maxSurge: 1                # pods EN PLUS autorisés
      maxUnavailable: 0          # pods manquants autorisés
  revisionHistoryLimit: 10
  template:
    metadata:
      labels: {app: web}         # DOIT = selector
    spec:
      containers:
      - name: web
        image: nginx:1.25
```

**Stratégies :**
- `RollingUpdate` : remplace progressivement (nouveau RS ↑ pendant que l'ancien ↓). Zéro coupure si maxUnavailable=0.
- `Recreate` : tue tout PUIS recrée. Coupure. Pour versions incompatibles entre elles.

**Commandes clés :**
```bash
kubectl set image deployment/web web=nginx:1.26   # déclenche rolling update
kubectl scale deployment web --replicas=5
kubectl rollout status deployment/web
kubectl rollout history deployment/web
kubectl rollout undo deployment/web [--to-revision=2]
kubectl rollout restart deployment/web            # recrée les pods
kubectl rollout pause|resume deployment/web
```

**Piège :** `selector.matchLabels` ≠ `template.labels` → erreur à la création. Un rollback est lui-même un rolling update (réactive un ancien RS).

---

# FICHE CH.10 — REPLICASET

- Garantit N pods identiques en permanence (boucle : compte réel vs désiré → crée/supprime).
- **Jamais créé à la main** : le Deployment le gère (nécessaire pour rollbacks/rolling updates).
- Adopte TOUT pod matchant son selector → le Deployment ajoute `pod-template-hash` pour éviter les collisions.
- Supprimer un pod à la main = il revient en secondes (c'est le RS qui le recrée).

---

# FICHE CH.11 — STATEFULSET

**Pour :** bases de données, Kafka, Elasticsearch — tout ce qui a besoin d'identité stable.

**4 garanties :**
1. Noms stables : `mysql-0`, `mysql-1`, `mysql-2` (pas de suffixe aléatoire)
2. Stockage stable : 1 PVC par pod qui le suit (`data-mysql-0`)
3. Ordre : création 0→1→2, suppression 2→1→0
4. DNS par pod : `mysql-0.mysql.ns.svc.cluster.local`

**Spécificités YAML :**
```yaml
spec:
  serviceName: mysql          # Service headless OBLIGATOIRE
  volumeClaimTemplates:       # crée un PVC par pod
  - metadata: {name: data}
    spec:
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 10Gi}}
```

**Service headless associé :**
```yaml
spec:
  clusterIP: None      # ← headless : DNS retourne les IPs des pods
  selector: {app: mysql}
```

---

# FICHE CH.12 — DAEMONSET

**"Un pod par node, automatiquement."** Nouveau node → pod créé ; node retiré → pod supprimé. Pas de `replicas`.

**Usages :** logs (Fluentd), monitoring (node-exporter), réseau (kube-proxy EST un DaemonSet), CNI, agents CSI.

**Pour tourner aussi sur les masters :**
```yaml
tolerations:
- key: node-role.kubernetes.io/control-plane
  operator: Exists
  effect: NoSchedule
```

Accès au node hôte : volume `hostPath` (ex: `/var/log`).

---

# FICHE CH.13 — JOB & CRONJOB

**Job = tâche ponctuelle qui doit réussir :**
```yaml
apiVersion: batch/v1
kind: Job
spec:
  completions: 1        # nb de succès requis
  parallelism: 1        # exécutions simultanées
  backoffLimit: 4       # tentatives avant abandon
  activeDeadlineSeconds: 600
  template:
    spec:
      restartPolicy: OnFailure    # JAMAIS Always dans un Job
      containers: [...]
```

**CronJob = Job planifié :**
```yaml
apiVersion: batch/v1
kind: CronJob
spec:
  schedule: "0 2 * * *"           # min heure jour mois jour-semaine
  concurrencyPolicy: Forbid       # Allow | Forbid | Replace
  successfulJobsHistoryLimit: 3
  jobTemplate: {spec: {...}}
```

**Cron rapide :** `*/15 * * * *` = toutes les 15 min ; `0 0 * * 0` = dimanche minuit ; `0 9 * * 1-5` = 9h en semaine.

**concurrencyPolicy :** Allow = chevauchements OK | Forbid = saute si précédent en cours | Replace = tue le précédent.

---

# FICHE CH.14 — SERVICE

**Problème résolu :** IP des pods = éphémères. Le Service = IP stable + load balancing + DNS.

**Types :**
| Type | Accès | Usage |
|---|---|---|
| ClusterIP (défaut) | interne au cluster seulement | communication inter-services |
| NodePort | `<IP-node>:30000-32767` depuis l'extérieur | dev/test, derrière un LB externe |
| LoadBalancer | IP publique (cloud) | prod cloud (Pending en local sans MetalLB/Klipper) |
| ExternalName | alias CNAME DNS | pointer vers un service externe |
| Headless (`clusterIP: None`) | DNS → IPs des pods directement | StatefulSets |

**port vs targetPort vs nodePort :**
```yaml
ports:
- port: 80          # port du SERVICE (ce que les clients appellent)
  targetPort: 8080  # port du CONTENEUR (peut être un nom de port)
  nodePort: 30080   # port sur les NODES (NodePort/LoadBalancer only)
```

**Endpoints :** liste des IP:port des pods **Ready** matchant le selector.
```bash
kubectl get endpoints web    # vide ? → labels faux ou pods pas Ready
```

**DNS :** `<service>.<namespace>.svc.cluster.local` ; même namespace → `<service>` suffit ; autre namespace → `<service>.<namespace>`.

**Divers :** `sessionAffinity: ClientIP` (colle un client à un pod) ; `externalTrafficPolicy: Local` (préserve l'IP source, trafic reste sur le node).

**Debug service inaccessible :** 1) endpoints vides ? 2) pods Ready ? 3) targetPort = port réel du conteneur ? 4) tester depuis un pod interne.

---

# FICHE CH.15 — INGRESS

**Problème résolu :** 20 services = 20 LoadBalancers (coût). L'Ingress = 1 IP, routage par host/path.

**RESOURCE (règles) ≠ CONTROLLER (le programme qui route).** Sans controller (Traefik, Nginx), l'Ingress ne fait RIEN. K3s inclut Traefik ; K8s standard n'inclut rien.

**Squelette :**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mon-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: {name: app-one, port: {number: 80}}
  - http:                      # règle par défaut SANS host → EN DERNIER !
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: {name: default-app, port: {number: 80}}
  tls:
  - hosts: [app1.com]
    secretName: tls-cert
```

**pathType :** `Prefix` (/api matche /api/users) | `Exact` (/api seulement) | `ImplementationSpecific` (éviter).

**Tester sans DNS :**
```bash
curl -H "Host: app1.com" http://<IP>
echo "<IP> app1.com" | sudo tee -a /etc/hosts   # puis navigateur
curl --resolve app1.com:80:<IP> http://app1.com
```

**Flux :** requête → Traefik (lit le header Host) → Service → Endpoints → pod.

**Debug :**
| Symptôme | Cause |
|---|---|
| 404 partout | controller absent / ingressClassName faux |
| 404 une règle | typo host/service, ordre (défaut avant spécifique) |
| 502 | service existe mais 0 endpoints Ready |
| ADDRESS vide | normal en local sans LB cloud |

---

# FICHE CH.16 — NAMESPACE

**Isolation logique** : noms, quotas, RBAC, NetworkPolicies. **N'isole PAS** : Nodes, PV, ClusterRoles, StorageClasses.

**Système :** `default`, `kube-system` (CoreDNS, proxy...), `kube-public`, `kube-node-lease`.

```bash
kubectl create namespace dev
kubectl get pods -n dev
kubectl get pods -A
kubectl config set-context --current --namespace=dev
kubectl delete namespace dev    # ⚠️ SUPPRIME TOUT DEDANS
```

**Cross-namespace DNS :** `service.autre-namespace` — un Service ne sélectionne que des pods de SON namespace.

---

# FICHE CH.17 — CONFIGMAP & SECRET

**Principe :** séparer config du code. Même image partout, config différente par environnement.

**ConfigMap (non sensible) :**
```yaml
apiVersion: v1
kind: ConfigMap
metadata: {name: app-config}
data:
  DB_HOST: "postgres"
  app.conf: |
    server.port=8080
```

**Secret (sensible — base64 = ENCODAGE, PAS chiffrement !) :**
```yaml
apiVersion: v1
kind: Secret
metadata: {name: app-secrets}
type: Opaque
data:
  password: cGFzc3dvcmQ=       # base64
stringData:
  user: admin                   # clair, encodé automatiquement
```
```bash
echo -n "password" | base64          # encoder
echo "cGFzc3dvcmQ=" | base64 -d      # décoder
kubectl create secret generic s --from-literal=k=v --from-file=f.txt
```

**Types de Secrets :** Opaque | kubernetes.io/tls | dockerconfigjson | basic-auth | ssh-auth.

**3 façons de consommer :**
```yaml
# 1. Variable unitaire
env:
- name: DB_HOST
  valueFrom: {configMapKeyRef: {name: app-config, key: DB_HOST}}
- name: PASS
  valueFrom: {secretKeyRef: {name: app-secrets, key: password}}
# 2. Tout d'un coup
envFrom:
- configMapRef: {name: app-config}
- secretRef: {name: app-secrets}
# 3. Fichiers montés (1 clé = 1 fichier)
volumeMounts: [{name: cfg, mountPath: /etc/config}]
volumes: [{name: cfg, configMap: {name: app-config}}]
```

**Mise à jour :** env vars → PAS de MAJ auto (il faut `rollout restart`) ; volumes → MAJ auto (~1 min) mais l'app doit relire.

---

# FICHE CH.18 — VOLUMES, PV, PVC, STORAGECLASS

**Types :**
| Volume | Vie | Usage |
|---|---|---|
| emptyDir | celle du pod | cache, partage entre conteneurs du pod |
| hostPath | celle du node | DaemonSets, dev — ⚠️ pas prod (données liées au node) |
| configMap/secret | — | config en fichiers |
| PVC | indépendante | stockage persistant (LE bon choix) |

**Le modèle en 3 étages :**
```
StorageClass (COMMENT provisionner : "ssd-rapide")
     │ provisionne dynamiquement
     ▼
PV (la ressource réelle : 10Gi quelque part)
     │ binding
     ▼
PVC (la demande : "je veux 10Gi RWO")
     │ monté dans
     ▼
Pod
```
Séparation des rôles : admin gère StorageClass/PV, dev écrit juste le PVC.

**PVC :**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: data-pvc}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-ssd
  resources: {requests: {storage: 10Gi}}
```

**Dans le pod :**
```yaml
volumes:
- name: data
  persistentVolumeClaim: {claimName: data-pvc}
```

**Access modes :** RWO (1 node, disques block) | ROX (N nodes lecture) | RWX (N nodes écriture — NFS/CephFS requis) | RWOP (1 pod).

**reclaimPolicy :** Retain (PV+données conservés après suppression du PVC) | Delete (tout supprimé).

**CSI :** interface standard stockage (comme CRI=runtime, CNI=réseau). Drivers : EBS, GCE PD, Ceph, Longhorn (K3s).

---
# FICHE CH.19 — RBAC

**Les 4 pièces :**
```
QUI : User | Group | ServiceAccount (identité d'un pod)
QUOI : Role (1 namespace) | ClusterRole (tout le cluster)
LIEN : RoleBinding (namespace) | ClusterRoleBinding (cluster)
```

**Role + RoleBinding :**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: pod-reader, namespace: prod}
rules:
- apiGroups: [""]              # "" = core (pods, services...)
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
kind: RoleBinding
metadata: {name: read-pods, namespace: prod}
subjects:
- kind: ServiceAccount
  name: mon-sa
  namespace: prod
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Verbs :** get, list, watch, create, update, patch, delete, deletecollection, `*`.

**Combinaison puissante :** ClusterRole + RoleBinding = rôle réutilisable appliqué namespace par namespace.

**Pod → SA :** `spec.serviceAccountName: mon-sa` (sinon `default`).

```bash
kubectl auth can-i create pods --as=system:serviceaccount:prod:mon-sa
```

---

# FICHE CH.20 — NETWORKPOLICY

**Logique en 2 règles :**
1. Aucune policy sur un pod → tout autorisé
2. Dès qu'UNE policy le sélectionne → **deny by default**, seul l'explicite passe

⚠️ Nécessite un CNI compatible : **Calico/Cilium OUI, Flannel seul NON** (policies ignorées silencieusement).

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: db-policy, namespace: prod}
spec:
  podSelector:
    matchLabels: {app: database}   # à qui ça s'applique
  policyTypes: [Ingress, Egress]
  ingress:
  - from:
    - podSelector: {matchLabels: {app: backend}}
    ports:
    - {protocol: TCP, port: 5432}
  egress:
  - to:
    - podSelector: {matchLabels: {app: logging}}
```

**Deny-all (isolation totale) :**
```yaml
spec:
  podSelector: {}          # tous les pods du namespace
  policyTypes: [Ingress]
```

Sélecteurs possibles dans from/to : `podSelector`, `namespaceSelector`, `ipBlock`.

---

# FICHE CH.21 — HPA, LIMITRANGE, RESOURCEQUOTA

**HPA (autoscaling horizontal) :**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: web}
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target: {type: Utilization, averageUtilization: 70}
```
Formule : `désirés = ceil(actuels × usage / cible)`. **Prérequis : Metrics Server + requests définies.**

**ResourceQuota (plafond par NAMESPACE) :**
```yaml
spec:
  hard:
    requests.cpu: "10"
    limits.memory: 40Gi
    pods: "50"
```

**LimitRange (défauts + bornes par CONTENEUR) :**
```yaml
spec:
  limits:
  - type: Container
    default: {cpu: 500m, memory: 512Mi}         # limits si absentes
    defaultRequest: {cpu: 100m, memory: 128Mi}  # requests si absentes
    max: {cpu: "2", memory: 2Gi}
    min: {cpu: 50m, memory: 64Mi}
```

---

# FICHE CH.22 — RÉSEAU KUBERNETES

**Les 4 problèmes et leurs solutions :**
| Communication | Solution |
|---|---|
| Conteneur ↔ conteneur (même pod) | localhost (namespace partagé) |
| Pod ↔ pod (tout node) | CNI (IP unique par pod, sans NAT) |
| Pod ↔ Service | kube-proxy (iptables DNAT) |
| Externe ↔ Service | NodePort / LoadBalancer / Ingress |

**3 plages d'IP distinctes :**
```
Node CIDR    : 192.168.1.0/24  (machines réelles)
Pod CIDR     : 10.42.0.0/16    (CNI, un /24 par node)
Service CIDR : 10.96.0.0/12    (IPs VIRTUELLES, que dans iptables)
```

**La ClusterIP n'existe nulle part physiquement :** kube-proxy écrit des règles iptables qui font du DNAT — `10.96.0.50:80 → 10.42.1.5:8080` (choix aléatoire pondéré parmi les endpoints). C'est pour ça qu'un ping de ClusterIP peut échouer alors que le service marche.

**iptables vs IPVS :** iptables = défaut, O(n) ; IPVS = hash O(1), pour 1000+ services, plus d'algos LB.

**VXLAN (Flannel) :** paquets pod encapsulés dans UDP 8472 entre nodes.
```
[Outer: IP node→node | UDP 8472 | VXLAN | Inner: IP pod→pod | data]
```

**CNI :** Flannel = simple, PAS de NetworkPolicy | Calico = BGP, policies, prod | Cilium = eBPF, L7, observabilité.

---

# FICHE CH.23 — K3S

**= Kubernetes certifié CNCF, allégé :** 1 binaire <100 Mo, SQLite (etcd optionnel), composants cloud retirés.

**Inclus par défaut :** Traefik (Ingress), ServiceLB/Klipper (LoadBalancer), local-path-provisioner (Storage), CoreDNS, Metrics Server, Flannel, containerd (pas besoin de Docker).

**Installation serveur :**
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
  --write-kubeconfig-mode=644 \
  --node-ip=192.168.56.110" sh -
```

**Installation agent (worker) :**
```bash
curl -sfL https://get.k3s.io | \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN=<token> sh -
```

**Variables clés :**
| Var | Rôle |
|---|---|
| INSTALL_K3S_EXEC | flags du binaire (--disable=traefik...) |
| INSTALL_K3S_VERSION | version exacte (reproductibilité !) |
| K3S_URL | présence = mode AGENT |
| K3S_TOKEN | auth pour rejoindre |

**Token :** `/var/lib/rancher/k3s/server/node-token`. URL + TOKEN nécessaires ensemble (où + preuve).
**Kubeconfig :** `/etc/rancher/k3s/k3s.yaml`.
**Services (Alpine/OpenRC) :** `rc-service k3s status`, logs `/var/log/k3s.log`.

---

# FICHE CH.24 — K3D

**= K3s DANS Docker.** Chaque "node" = un conteneur.

**Conteneurs créés par `k3d cluster create mycluster --agents 2` :**
```
k3d-mycluster-server-0   (Control Plane)
k3d-mycluster-agent-0/1  (Workers)
k3d-mycluster-serverlb   (LoadBalancer nginx = point d'entrée stable)
+ un réseau Docker dédié
```

**Décodage `--port "8080:80@loadbalancer"` :**
```
8080 = port machine HÔTE
80   = port dans le conteneur CIBLE
@loadbalancer = quelle cible (ou @server:0, @agent:1, @all)

Chemin : localhost:8080 → serverlb:80 → Traefik du cluster → Service → Pod
```
Pourquoi @loadbalancer et pas un node ? Point d'entrée stable, répartition, survit à la mort d'un node.

**Commandes :**
```bash
k3d cluster create|list|start|stop|delete mycluster
k3d image import mon-image:tag -c mycluster    # image locale → cluster
k3d kubeconfig merge mycluster --kubeconfig-switch-context
```

K3d fusionne automatiquement le kubeconfig et change le contexte à la création.

---

# FICHE CH.25 — ARGOCD & GITOPS

**GitOps = Git est LA source de vérité.** Push vers Git → ArgoCD tire et applique (modèle PULL, pas push kubectl).

**4 principes :** déclaratif | versionné dans Git | tiré automatiquement | réconcilié en continu.

**Composants :** argocd-server (UI/API) | argocd-repo-server (clone Git, rend Helm/Kustomize) | argocd-application-controller (compare + sync) | redis | dex (SSO).

**L'objet Application :**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mon-app
  namespace: argocd              # TOUJOURS dans argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/repo.git
    targetRevision: main         # branche/tag/commit
    path: manifests              # dossier dans le repo
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true                # retiré de Git → supprimé du cluster
      selfHeal: true             # kubectl edit manuel → annulé
    syncOptions: [CreateNamespace=true]
```

**Statuts :**
| Sync | Health |
|---|---|
| Synced = cluster == Git | Healthy / Progressing / Degraded / Missing |
| OutOfSync = dérive détectée | |

**prune vs selfHeal :** prune = nettoie les orphelins Git ; selfHeal = écrase les modifs manuelles. ⚠️ prune:true + suppression accidentelle dans Git = suppression en prod.

**Cycle :** git push → repo-server détecte (poll ~3 min ou webhook) → controller compare → OutOfSync → sync (auto ou manuel) → kubectl apply interne → rolling update → Synced+Healthy.

**Accès :**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward svc/argocd-server -n argocd 8443:443
argocd app sync|get|list mon-app
```
⚠️ Le secret initial est supprimé après le premier changement de mot de passe.

---

# FICHE CH.26 — KUBECTL

**Lecture :**
```bash
kubectl get pods [-A|-n ns] [-o wide|yaml|json] [-l app=web] [--watch] [--show-labels]
kubectl describe pod X            # détails + EVENTS (or du debug)
kubectl logs X [-c cont] [-f] [--previous] [--tail=100] [--since=1h]
kubectl explain deployment.spec [--recursive]
kubectl get events --sort-by='.lastTimestamp'
```

**Écriture :**
```bash
kubectl apply -f f.yaml|dossier/|URL      # déclaratif (LE réflexe)
kubectl create deployment web --image=nginx --dry-run=client -o yaml  # générer du YAML
kubectl edit deployment web
kubectl patch deployment web -p '{"spec":{"replicas":5}}'
kubectl set image deployment/web web=nginx:1.26
kubectl delete -f f.yaml | pod X | namespace dev   # ⚠️ cascade
```

**Gestion :**
```bash
kubectl scale deployment web --replicas=5
kubectl rollout status|history|undo|restart|pause|resume deployment/web
```

**Debug :**
```bash
kubectl exec -it pod -- /bin/sh
kubectl port-forward svc/web 8080:80
kubectl cp pod:/app/log.txt ./log.txt
kubectl top nodes|pods
kubectl debug pod -it --image=busybox
```

**Nodes :** `cordon` (bloque scheduling) | `uncordon` | `drain --ignore-daemonsets` (vide pour maintenance) | `taint`.

**Config/contexte :**
```bash
kubectl config get-contexts | use-context X
kubectl config set-context --current --namespace=dev
kubectl api-resources | api-versions
```

**Puissance :**
```bash
kubectl wait --for=condition=Ready pod/X --timeout=60s
kubectl apply -f f.yaml --dry-run=client|server
kubectl diff -f f.yaml
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP
kubectl get pods --sort-by=.metadata.creationTimestamp
```

---

# 🔥 MÉGA-FICHE FINALE — L'ESSENTIEL DES ESSENTIELS

**L'idée unique de Kubernetes :**
```
Comparer ce qui EST (status) à ce qui DEVRAIT ÊTRE (spec),
corriger la différence, recommencer. Pour tout. En permanence.
```

**Le chemin d'un YAML (à réciter) :**
```
kubectl → API Server → etcd → Controller → Scheduler → Kubelet → CRI/CNI → Pod
```

**Les 3 interfaces standard :** CRI (runtime) | CNI (réseau) | CSI (stockage).

**Ports vitaux :** 6443 (API) | 2379-2380 (etcd) | 10250 (kubelet) | 30000-32767 (NodePort) | 8472/UDP (VXLAN) | 53 (CoreDNS).

**Réflexe debug universel :**
```
1. kubectl get X                 (quel état ?)
2. kubectl describe X            (events ?)
3. kubectl logs X [--previous]   (que dit l'app ?)
4. kubectl get endpoints         (si problème réseau/service)
```

**Qui utiliser quand :**
```
App stateless      → Deployment
App avec état      → StatefulSet
1 pod par node     → DaemonSet
Tâche ponctuelle   → Job
Tâche planifiée    → CronJob
Accès stable       → Service ClusterIP
Exposition HTTP    → Ingress (+ controller !)
Config             → ConfigMap ; sensible → Secret
Stockage persistant→ PVC
Permissions        → SA + Role + RoleBinding
Firewall pods      → NetworkPolicy (CNI compatible !)
Autoscaling        → HPA (+ Metrics Server + requests)
```

---

*Fin des cheat sheets.*
