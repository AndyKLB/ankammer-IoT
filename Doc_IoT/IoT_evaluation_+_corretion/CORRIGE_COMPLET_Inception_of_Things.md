---
---

# 🔑 CORRIGÉ COMPLET

> Chaque réponse est expliquée en détail : pourquoi la bonne réponse est correcte, et pourquoi chaque mauvaise réponse est fausse. C'est cette dernière partie qui distingue la compréhension réelle du par-cœur — un évaluateur 42 demande systématiquement "pourquoi pas cette autre option ?".

---

# CORRIGÉ PARTIE 1 — QCM

## Section 1.A — Vagrant

**R1. Réponse : B**
Lors de la première exécution, Vagrant vérifie si la box est présente en cache local (`~/.vagrant.d/boxes/`). Si absente, il la télécharge depuis Vagrant Cloud (ou l'URL spécifiée), puis crée la VM dans le provider configuré et la démarre.
*Pourquoi pas A* : ce serait le cas pour un `vagrant up` ultérieur sur une VM existante, pas la première fois.
*Pourquoi pas C* : Vagrant ne compile jamais VirtualBox, ce sont deux logiciels totalement indépendants.
*Pourquoi pas D* : seule la première fois (ou en cas de cache absent) une connexion réseau est nécessaire pour télécharger la box ; ensuite Vagrant utilise le cache local, surtout avec `box_check_update = false`.

**R2. Réponse : B**
Le dossier `.vagrant/` contient l'état local de l'environnement Vagrant : ID de la VM dans le provider, le provider utilisé, et la clé privée SSH générée spécifiquement pour cette VM.
*Pourquoi pas A* : la box elle-même est stockée ailleurs (`~/.vagrant.d/boxes/`), pas dans `.vagrant/`.
*Pourquoi pas C* : le Vagrantfile n'est jamais "compilé", il est interprété par Ruby à chaque exécution.
*Pourquoi pas D* : supprimer ce dossier casse le lien entre Vagrant et la VM existante ; Vagrant ne saura plus la retrouver/gérer correctement (bien que la VM continue d'exister dans VirtualBox).

**R3. Réponse : B et C**
`vagrant provision` réexécute les scripts sans toucher au cycle de vie de la VM. `vagrant up --provision` fait de même tout en s'assurant que la VM est démarrée (et la démarre si besoin).
*Pourquoi pas A* : `reload` redémarre la VM, ce qui n'est pas le but recherché ici (juste relancer le provisioning).
*Pourquoi pas D* : cela redémarre complètement la VM, plus lourd que nécessaire.

**R4. Réponse : B**
Sans cette option, Vagrant contacte Vagrant Cloud à chaque `vagrant up` pour vérifier si une version plus récente de la box existe, ce qui ajoute une latence réseau.
*Pourquoi pas A* : la box reste bien installée et utilisée normalement.
*Pourquoi pas C* : cela concerne uniquement la box Vagrant, pas les mises à jour système internes à la VM (gérées séparément par `apk update`).
*Pourquoi pas D* : aucun rapport avec le réseau de la VM elle-même.

**R5. Réponse : B**
`vagrant destroy -f` (force) supprime définitivement la VM et son disque virtuel sans demander de confirmation.
*Pourquoi pas A* : ce n'est pas qu'une suppression de configuration, la VM réelle est supprimée du provider.
*Pourquoi pas C* : `suspend` met en pause, `destroy` supprime définitivement.
*Pourquoi pas D* : la box en cache local n'est pas affectée par `destroy`, elle reste réutilisable pour d'autres VMs.

**R6. Réponse : B**
`"2"` désigne la version de l'API de configuration Vagrant (Vagrant Configuration Version 2), qui définit la syntaxe acceptée dans le bloc.
*Pourquoi pas A, C, D* : aucun rapport avec le nombre de VMs, le CPU ou la version de Ruby.

**R7. Réponse : B**
Vagrant cherche par convention un fichier nommé exactement `Vagrantfile` (sans extension) dans le dossier courant.
*Pourquoi pas A, C, D* : ce sont des noms inventés, pas la convention réelle de Vagrant.

**R8. Réponse : B**
`vagrant ssh-config` affiche les paramètres SSH (HostName, Port, IdentityFile...) utilisables tels quels par un client SSH externe ou un fichier `~/.ssh/config`.
*Pourquoi pas A, C, D* : cette commande n'a aucun effet de configuration, c'est purement informatif/lecture.

**R9. Réponse : B**
`halt` est l'équivalent d'un arrêt propre du système d'exploitation (comme `shutdown -h now`) ; `suspend` sauvegarde l'état RAM complet sur disque pour une reprise quasi-instantanée.
*Pourquoi pas A* : les mécanismes sont clairement différents en interne.
*Pourquoi pas C, D* : aucune suppression n'a lieu dans les deux cas, et aucune box différente n'est requise.

**R10. Réponse : B**
C'est exactement le mécanisme utilisé dans le projet pour définir le serveur et le worker dans un seul Vagrantfile.
*Pourquoi pas A* : un seul Vagrantfile par dossier est lu par Vagrant.
*Pourquoi pas C* : cette commande n'existe pas.
*Pourquoi pas D* : c'est au contraire une fonctionnalité native et courante de Vagrant.

**R11. Réponse : B**
`vagrant-vbguest` compare la version des Guest Additions installées dans la box à la version de VirtualBox sur l'hôte, et peut les mettre à jour automatiquement si un décalage est détecté.
*Pourquoi pas A, C, D* : aucun rapport avec un utilisateur invité, le réseau bridge, ou le chiffrement.

**R12. Réponse : B**
Deux VMs avec la même IP statique sur le même réseau private_network peuvent générer des conflits ARP et des comportements réseau instables (l'une ou l'autre répond de façon imprévisible).
*Pourquoi pas A* : Vagrant ne "fusionne" jamais deux VMs distinctes.
*Pourquoi pas C* : Vagrant ne valide pas ce conflit au niveau syntaxique du Vagrantfile, l'erreur n'apparaît qu'au runtime réseau.
*Pourquoi pas D* : c'est précisément le problème, l'isolation n'empêche pas le conflit d'adressage sur le même segment réseau.

**R13. Réponse : B**
C'est spécifiquement la vérification de mise à jour de la **box** (l'image de base), pas du Vagrantfile, de VirtualBox ou de K3s.

**R14. Réponse : B**
`vagrant global-status` parcourt toutes les VMs Vagrant connues sur la machine (peu importe le répertoire d'origine), contrairement à `vagrant status` limité au dossier courant.
*Pourquoi pas A* : c'est justement la commande `status` (sans "global") qui se limite au dossier courant.
*Pourquoi pas C, D* : ce n'est pas son rôle, c'est un état global des VMs (running/stopped/etc.), pas du détail réseau ou de logs.

**R15. Réponse : B**
Sans `set -e`, une commande qui échoue (par exemple un `curl` qui timeout) n'arrête pas l'exécution du script ; les commandes suivantes s'exécutent quand même, potentiellement sur un état incohérent, masquant le vrai problème.
*Pourquoi pas A, C, D* : `set -e` a un effet réel et documenté, Vagrant ne l'ignore pas magiquement, et il n'arrête pas TOUJOURS systématiquement sans cette option.

**R16. Réponse : B**
`--provider` force explicitement quel hyperviseur/backend utiliser (virtualbox, libvirt, vmware...) en cas d'ambiguïté ou de préférence différente du défaut.
*Pourquoi pas A, C, D* : aucun rapport avec un FAI, un repo Git, ou un mainteneur.

**R17. Réponse : B**
C'est la combinaison exacte des deux effets : redémarrage (`reload`) + réexécution complète des scripts de provisioning (`--provision`).
*Pourquoi pas A, C, D* : ce n'est ni un rechargement réseau seul, ni une destruction/recréation, ni une mise à jour de Vagrant lui-même.

**R18. Réponse : B**
Sauf configuration explicite de parallélisme, Vagrant traite généralement les VMs définies dans l'ordre d'écriture du Vagrantfile.
*Pourquoi pas A* : l'ordre a une influence réelle observable dans les logs (`Bringing machine 'X' up...` apparaît dans l'ordre de définition).
*Pourquoi pas C, D* : aucune contrainte d'ordre alphabétique ou liée aux IPs n'existe.

**R19. Réponse : B**
`not created` est l'état affiché par Vagrant pour une VM jamais initialisée, sans aucune erreur fatale.
*Pourquoi pas A, C, D* : aucune erreur fatale n'est levée, ce n'est pas non plus `running` par défaut, et `vagrant status` accepte parfaitement un argument de nom de VM.

**R20. Réponse : B**
La clé "insecure" est une clé SSH publique connue de tous (distribuée avec Vagrant), donc non sécurisée si utilisée seule durablement ; Vagrant en génère une nouvelle propre à chaque VM dès que possible.
*Pourquoi pas A, C, D* : aucun rapport avec le chiffrement disque, Vagrant Cloud, ou le réseau.

---

## Section 1.B — VirtualBox / Libvirt / KVM / QEMU

**R21. Réponse : C**
VirtualBox tourne comme une application sur un système d'exploitation hôte existant (Windows, macOS, Linux) : c'est un hyperviseur de Type 2.
*Pourquoi pas B* : un hyperviseur de Type 1 (comme VMware ESXi ou Hyper-V en mode natif) s'installe directement sur le matériel sans OS hôte intermédiaire.

**R22. Réponse : B**
KVM est un module intégré au noyau Linux qui transforme ce dernier en hyperviseur capable d'exécuter des VMs avec accélération matérielle.
*Pourquoi pas A* : KVM est justement intégré au noyau, pas un logiciel utilisateur indépendant.
*Pourquoi pas C, D* : aucun rapport avec VirtualBox ou un format de fichier.

**R23. Réponse : B**
QEMU émule le matériel virtuel (disque, carte réseau, BIOS...) tandis que KVM accélère l'exécution des instructions CPU via la virtualisation matérielle. Ensemble (QEMU/KVM), ils forment la solution complète.
*Pourquoi pas A* : QEMU ne remplace pas KVM, ils sont complémentaires.
*Pourquoi pas C, D* : ce n'est pas son seul rôle (réseau) ni un outil de compression.

**R24. Réponse : B**
Libvirt est une couche d'abstraction (API + outils comme `virsh`) permettant de gérer différents hyperviseurs sous-jacents de façon unifiée.
*Pourquoi pas A* : libvirt ne virtualise rien lui-même, il pilote des hyperviseurs existants (KVM, Xen...).
*Pourquoi pas C* : il n'a pas la même API que VirtualBox, c'est un écosystème distinct.
*Pourquoi pas D* : ce n'est pas un protocole réseau.

**R25. Réponse : B**
`virsh list --all` liste toutes les VMs (domaines) connues de libvirt, qu'elles soient actives ou arrêtées.
*Pourquoi pas A, C, D* : aucun rapport avec Vagrant directement, le réseau, ou les paquets système.

**R26. Réponse : B**
VT-x et AMD-V sont des extensions matérielles des processeurs Intel/AMD permettant une virtualisation assistée par le hardware, bien plus performante que la virtualisation logicielle pure.
*Pourquoi pas A, C, D* : ce ne sont pas des logiciels, des protocoles réseau, ni des formats de disque.

**R27. Réponse : B**
Sans VT-x activé, VirtualBox peut refuser de démarrer certaines VMs (particulièrement en mode 64-bit) et afficher des erreurs comme VERR_VMX_NO_VMX.
*Pourquoi pas A, C, D* : ce n'est clairement pas "sans aucune limite", ni un problème uniquement réseau, ni une accélération.

**R28. Réponse : A**
`.vdi` (Virtual Disk Image) est le format de disque virtuel natif de VirtualBox.
*Pourquoi pas B, C, D* : aucun rapport avec la config réseau, les logs Vagrant, ou le format de box (qui est généralement une archive contenant le .vdi/.vmdk + métadonnées).

**R29. Réponse : B**
C'est tout à fait normal : VirtualBox et libvirt sont deux écosystèmes de virtualisation totalement indépendants ; une VM gérée par l'un n'apparaît jamais dans les outils de l'autre.
*Pourquoi pas A, C, D* : ce n'est ni une erreur de config, ni une nécessité de migration, ni un signe de corruption.

**R30. Réponse : B**
Ces deux méthodes (option CLI ou variable d'environnement) permettent de forcer explicitement le provider voulu.
*Pourquoi pas A, C* : ce n'est pas impossible, et il n'est pas nécessaire de désinstaller libvirt.
*Pourquoi pas D* : aucun rapport avec le noyau.

**R31. Réponse : B**
C'est l'emplacement de stockage physique des disques virtuels géré par libvirt, par défaut souvent `/var/lib/libvirt/images/`.
*Pourquoi pas A, C, D* : ce n'est pas un stockage réseau partagé entre VMs, ni un cache CPU, ni un protocole de chiffrement.

**R32. Réponse : B**
`vboxmanage` (ou VBoxManage) est l'outil CLI complet pour administrer VirtualBox, indépendamment de l'interface graphique.
*Pourquoi pas A, C, D* : il n'est pas exclusif au GUI (au contraire, alternative au GUI), ni propre à Vagrant ou libvirt.

**R33. Réponse : B**
Les Guest Additions apportent les dossiers partagés, une meilleure résolution/intégration graphique, la synchronisation d'horloge, et le presse-papier partagé notamment.
*Pourquoi pas A, C, D* : aucun rapport avec le nombre de CPU, le noyau, ou le pare-feu de l'hôte.

**R34. Réponse : B**
C'est exactement l'avertissement mentionné par Vagrant : un décalage de version peut casser le fonctionnement des dossiers partagés, comme observé concrètement dans le débogage du projet.
*Pourquoi pas A, C, D* : la VM démarre généralement quand même (juste un avertissement, pas un blocage), le CPU n'est pas affecté, ni le réseau privé en tant que tel.

**R35. Réponse : B**
`vboxsf` (VirtualBox Shared Folder) est le système de fichiers spécifique utilisé pour implémenter les dossiers partagés entre l'hôte et la VM.
*Pourquoi pas A, C, D* : ce n'est ni un protocole de chiffrement, ni un format d'image, ni le nom du processus principal.

**R36. Réponse : B**
KVM s'appuie nativement sur le noyau Linux et la virtualisation matérielle directement, généralement avec moins de couches d'abstraction que VirtualBox sur Linux, d'où un overhead souvent réduit.
*Pourquoi pas A, C, D* : ce n'est pas une règle absolue ("toujours"), libvirt a bien besoin de CPU, et VirtualBox supporte parfaitement les invités Linux.

**R37. Réponse : B**
VNC est un protocole d'affichage distant couramment utilisé par libvirt/QEMU pour donner accès à l'écran virtuel de la VM.
*Pourquoi pas A, C, D* : aucun rapport avec le réseau de la VM elle-même, le type de disque, ou une erreur critique (c'est un fonctionnement normal).

**R38. Réponse : B**
QEMU peut fonctionner en émulation pure (lent, sans KVM) ou s'appuyer sur KVM pour accélérer l'exécution via le matériel — c'est la combinaison classique QEMU/KVM.
*Pourquoi pas A, C, D* : aucune de ces affirmations absolues n'est correcte, la complémentarité est la clé.

**R39. Réponse : A**
`vboxmanage --version` est la commande standard pour afficher la version installée.
*Pourquoi pas B, C, D* : ces commandes n'existent pas sous cette forme.

**R40. Réponse : B**
Le fichier `.img` dans les chemins libvirt représente bien le disque virtuel de la VM (équivalent fonctionnel du `.vdi` VirtualBox).
*Pourquoi pas A, C, D* : ce n'est ni une capture d'écran, ni un fichier ISO d'installation (qui serait l'image source, distincte du disque de destination), ni un log.

---

## Section 1.C — Réseau

**R41. Réponse : B**
`192.168.x.x` fait partie des plages d'adresses privées définies par la RFC 1918, non routables directement sur Internet.
*Pourquoi pas A, C, D* : ce n'est ni publique, ni loopback (127.0.0.1), ni multicast (224.0.0.0-239.255.255.255).

**R42. Réponse : B**
`/24` = 24 bits à 1 suivis de 8 bits à 0, soit `255.255.255.0`.
*Pourquoi pas A, C, D* : ces masques correspondent respectivement à /16, /8, et /32.

**R43. Réponse : B**
2^8 = 256 adresses totales, moins l'adresse réseau (.0) et l'adresse de broadcast (.255), soit 254 adresses utilisables.
*Pourquoi pas A* : 256 est le total incluant réseau et broadcast, pas les utilisables.
*Pourquoi pas C, D* : ces chiffres correspondent à d'autres préfixes (/25 pour 128, et 512 n'existe pas pour un /24).

**R44. Réponse : B**
C'est exactement la définition du réseau host-only utilisé par `private_network` : communication entre VMs et hôte, isolée d'Internet par défaut.
*Pourquoi pas A* : ce serait le rôle d'un réseau public/bridge, pas private_network.
*Pourquoi pas C* : le réseau n'est pas désactivé, juste isolé d'Internet.
*Pourquoi pas D* : Vagrant configure tout automatiquement, sans nécessiter de DHCP externe pour une IP fixe spécifiée.

**R45. Réponse : A**
Le réseau NAT par défaut de Vagrant donne à la VM un accès sortant vers Internet via l'hôte, en traduisant les adresses.
*Pourquoi pas B* : c'est l'inverse qui est généralement vrai par défaut sans port forwarding explicite — l'hôte n'accède pas directement à la VM via NAT sans configuration spécifique.
*Pourquoi pas C, D* : ce n'est ni une isolation complète, ni le rôle premier de ce réseau pour la communication inter-VM (qui passe par private_network dans ce projet).

**R46. Réponse : B**
C'est la distinction fondamentale : Host-only isole du réseau physique externe, Bridge connecte directement la VM au réseau physique comme un appareil supplémentaire visible des autres machines du réseau local.
*Pourquoi pas A, C, D* : il y a clairement une différence, la vitesse n'est pas le critère distinctif principal, et Host-only ne nécessite pas de carte physique dédiée.

**R47. Réponse : B**
Une gateway route le trafic destiné à des réseaux externes au réseau local courant, typiquement vers Internet.
*Pourquoi pas A, C, D* : ce n'est pas spécifique à UDP, ni un rôle DNS, ni de chiffrement.

**R48. Réponse : B**
TCP établit une connexion et garantit (sauf cas réseau extrêmes) la livraison ordonnée et fiable des données, contrairement à UDP qui est sans connexion et sans garantie.
*Pourquoi pas A, C, D* : c'est l'inverse de A, ce n'est pas "toujours plus rapide" (UDP est plus rapide car plus simple, mais moins fiable), et HTTP utilise bien TCP.

**R49. Réponse : B**
Un port identifie un service/processus précis sur une machine ayant déjà une adresse IP donnée.
*Pourquoi pas A, C, D* : ce n'est pas l'IP elle-même, il ne chiffre rien automatiquement, et il complète l'IP plutôt que de la remplacer.

**R50. Réponse : B**
DHCP attribue dynamiquement IP, masque, gateway, DNS à une machine se connectant à un réseau.
*Pourquoi pas A, C, D* : aucun rapport avec le chiffrement, la résolution de noms (rôle de DNS), ou le routage.

**R51. Réponse : B**
DNS traduit les noms de domaine lisibles en adresses IP exploitables par les protocoles réseau.
*Pourquoi pas A, C, D* : ce n'est pas le rôle de DHCP (IP dynamique), ni du chiffrement, ni du firewall.

**R52. Réponse : B**
L'en-tête Host indique au serveur/Ingress quel virtual host est visé, permettant le routage applicatif sans changer l'IP de destination réelle du paquet.
*Pourquoi pas A* : l'IP de destination réelle du paquet (192.168.56.110) reste inchangée, seul le contenu de la requête HTTP change.
*Pourquoi pas C, D* : aucun rapport direct avec le protocole HTTPS ou le port (sauf si explicitement précisé séparément dans l'en-tête, ce qui n'est pas systématique).

**R53. Réponse : B**
Une socket est définie par la combinaison IP + port (+ protocole), c'est ce triplet qui identifie de façon unique une communication réseau.
*Pourquoi pas A, C, D* : aucun de ces éléments seuls ne suffit à la définir.

**R54. Réponse : B**
192.168.56.x et 192.168.57.x ne sont pas dans le même sous-réseau /24, la communication directe sans routage explicite peut échouer ou nécessiter un routeur intermédiaire.
*Pourquoi pas A, C, D* : ce n'est pas "parfaitement normal" sans configuration supplémentaire, Vagrant ne fusionne rien, et la bande passante n'est pas concernée.

**R55. Réponse : C**
`ping` utilise ICMP (Internet Control Message Protocol), ni TCP ni UDP.
*Pourquoi pas A, B, D* : ce sont des protocoles distincts d'ICMP, HTTP étant en plus une couche applicative bien au-dessus.

**R56. Réponse : B**
Recevoir une réponse HTTP structurée (même une erreur 401) prouve que la couche réseau et le serveur HTTP fonctionnent ; seule l'authentification est refusée, ce qui est un comportement applicatif normal et attendu sans credentials.
*Pourquoi pas A, C, D* : c'est l'inverse d'une preuve d'inaccessibilité, 401 ne signifie jamais "erreur réseau bas niveau", et le port est clairement ouvert pour qu'une réponse HTTP soit reçue.

**R57. Réponse : B**
`127.0.0.1` est l'adresse de loopback standard, désignant la machine locale elle-même.
*Pourquoi pas A, C, D* : ce n'est pas une adresse publique, ni de broadcast, ni réservée à Kubernetes.

**R58. Réponse : B**
CoreDNS résout les noms internes des Services Kubernetes (et Pods) en leurs IPs internes au cluster.
*Pourquoi pas A, C, D* : ce n'est pas son rôle d'allouer des IPs (rôle du CNI), ni de chiffrer le trafic, et il ne remplace pas kube-proxy (rôles complémentaires distincts).

**R59. Réponse : A**
La route par défaut est utilisée pour tout trafic ne correspondant à aucune autre route plus spécifique connue de la table de routage.
*Pourquoi pas B, C, D* : elle n'est pas nécessairement "la seule route possible", n'est pas réservée à DNS, ni à UDP.

**R60. Réponse : B**
Le port 6443 est le port standard de l'API Server Kubernetes/K3s, indispensable pour que le worker rejoigne le cluster et continue de communiquer avec le Control Plane ensuite.
*Pourquoi pas A, C, D* : SSH utilise le port 22, ce n'est pas un rôle DNS, et ce n'est pas lié au NAT en tant que tel.

**R61. Réponse : C**
L'adresse de broadcast d'un `/24` est toujours la dernière adresse de la plage, soit `.255` dans ce cas : `192.168.56.255`.
*Pourquoi pas A, B, D* : `.0` est l'adresse réseau, `.1` est souvent (mais pas systématiquement) la gateway, et `192.168.255.255` correspondrait à un tout autre préfixe bien plus large.

**R62. Réponse : A**
Passer de /24 à /25 divise le nombre d'adresses disponibles par 2 (256 → 128 adresses totales, donc moitié moins).
*Pourquoi pas B, C, D* : ce ne sont pas les bons facteurs de division pour un seul bit de préfixe ajouté.

**R63. Réponse : B**
ICMP (ping) peut être explicitement filtré par un pare-feu sans affecter le trafic TCP sur un port autorisé spécifiquement — ce sont des règles indépendantes.
*Pourquoi pas A, C, D* : le réseau n'est pas "totalement cassé" si TCP fonctionne, ce n'est pas impossible, et le DNS n'est pas en cause ici (la connexion utilise directement une IP).

**R64. Réponse : B**
Un conflit d'adresse IP cause des comportements réseau imprévisibles, des pertes de paquets, et un accès intermittent à l'une ou l'autre machine.
*Pourquoi pas A, C, D* : ce n'est clairement pas "sans conséquence", cela ne répartit aucune charge utilement, et le DNS n'est pas directement concerné.

**R65. Réponse : B**
Le routage est le processus de détermination du chemin réseau pour qu'un paquet atteigne sa destination, potentiellement à travers plusieurs réseaux intermédiaires.
*Pourquoi pas A, C, D* : ce n'est ni du chiffrement, ni de l'attribution IP (DHCP), ni de la résolution de noms (DNS).

---

## Section 1.D — Linux / Alpine / OpenRC

**R66. Réponse : B**
Alpine se distingue par sa taille minimale, l'usage de musl libc (au lieu de glibc) et BusyBox (utilitaires compacts).
*Pourquoi pas A, C, D* : c'est l'inverse de A, Alpine n'est pas basée sur Debian, et elle dispose bien d'un gestionnaire de paquets (apk).

**R67. Réponse : C**
`apk` (Alpine Package Keeper) est le gestionnaire natif d'Alpine.
*Pourquoi pas A, B, D* : `apt` est Debian/Ubuntu, `yum` est RedHat/CentOS historique, `pacman` est Arch Linux.

**R68. Réponse : B**
OpenRC est un système d'init et de gestion des services, alternative légère à systemd, utilisé par défaut sur Alpine.
*Pourquoi pas A, C, D* : ce n'est ni un système de fichiers, ni un langage de script, ni un protocole réseau.

**R69. Réponse : B**
`rc-service NOM status` affiche l'état actuel d'un service géré par OpenRC, équivalent fonctionnel de `systemctl status` sous systemd.
*Pourquoi pas A, C, D* : ce serait `rc-service k3s start` pour démarrer, et ce n'est ni une suppression ni une config réseau.

**R70. Réponse : B**
BusyBox regroupe de nombreux utilitaires Unix essentiels (ls, cp, ping, grep...) en un seul binaire compact, économisant l'espace disque.
*Pourquoi pas A, C, D* : ce n'est ni un noyau, ni un serveur web complet, ni un système de virtualisation.

**R71. Réponse : B**
Sur Alpine/BusyBox, `/bin/sh` correspond généralement à `ash`, une implémentation légère et conforme POSIX.
*Pourquoi pas A, C, D* : bash n'est pas le défaut sur Alpine (doit être installé séparément), ni zsh, ni PowerShell (Windows).

**R72. Réponse : B**
`chmod +x` ajoute le bit d'exécution, permettant de lancer le script directement (`./script.sh`).
*Pourquoi pas A, C, D* : aucun rapport avec suppression, changement de propriétaire (rôle de chown), ou compression.

**R73. Réponse : B**
`chown` change le propriétaire utilisateur et/ou le groupe propriétaire d'un fichier/dossier.
*Pourquoi pas A, C, D* : permissions rwx sont gérées par chmod, l'extension n'a rien à voir, et il ne supprime rien.

**R74. Réponse : B**
`sudo` permet d'exécuter une commande avec les privilèges d'un autre utilisateur (typiquement root), de façon ponctuelle et tracée.
*Pourquoi pas A, C, D* : ce n'est ni un changement de mot de passe permanent, ni une création d'utilisateur automatique, ni un chiffrement.

**R75. Réponse : B**
Le PID identifie de façon unique chaque processus en cours d'exécution sur le système, attribué par le noyau.
*Pourquoi pas A, C, D* : aucun rapport avec un paquet réseau, une partition disque, ou une permission.

**R76. Réponse : B**
`ps aux` liste tous les processus, et `grep k3s` filtre pour ne garder que les lignes contenant "k3s".
*Pourquoi pas A, C, D* : cette commande est purement informative en lecture, elle ne démarre, ne supprime, ni ne vérifie de version directement.

**R77. Réponse : B**
`r`=read (lecture), `w`=write (écriture), `x`=execute (exécution), dans cet ordre précis.
*Pourquoi pas A, C, D* : ces interprétations sont incorrectes par rapport à la convention Unix standard.

**R78. Réponse : B**
755 en octal = rwx (7) pour le propriétaire, r-x (5) pour le groupe, r-x (5) pour les autres.
*Pourquoi pas A, C, D* : ce ne sont pas les bonnes correspondances octales pour ces valeurs.

**R79. Réponse : B**
Un point de montage est le répertoire à travers lequel un système de fichiers externe (disque, partition, dossier partagé) devient accessible dans l'arborescence globale.
*Pourquoi pas A, C, D* : ce n'est ni un accès réseau en tant que tel, ni une zone RAM, ni un type de processus.

**R80. Réponse : B**
Cette commande filtre la liste des montages actifs pour repérer si un système de fichiers vboxsf (lié au dossier partagé) est effectivement monté.
*Pourquoi pas A, C, D* : aucun rapport direct avec le statut du service Vagrant lui-même, sa version, ou les VMs actives.

**R81. Réponse : B**
Activer un dépôt comme edge/community donne accès à des paquets plus récents ou supplémentaires non présents dans le dépôt stable par défaut.
*Pourquoi pas A, C, D* : cela ne désinstalle rien, n'active pas systemd (Alpine reste sur OpenRC), et ne change pas le noyau.

**R82. Réponse : B**
Modifier le système de paquets nécessite des privilèges administrateur (root), d'où l'erreur de permission pour un utilisateur normal sans sudo.
*Pourquoi pas A, C, D* : ce n'est pas un bug, pas besoin de redémarrer, et cela n'a rien à voir avec SSH.

**R83. Réponse : B**
`journalctl -u SERVICE -n 50` affiche les 50 dernières lignes de logs du service spécifié, sur un système utilisant systemd (pas Alpine/OpenRC qui utilise d'autres mécanismes de logs).
*Pourquoi pas A, C, D* : ce n'est pas une commande de démarrage, ni de suppression, ni de configuration de démarrage automatique.

**R84. Réponse : B**
Un groupe Unix permet de donner collectivement des droits/accès à plusieurs utilisateurs sans dupliquer individuellement chaque permission.
*Pourquoi pas A, C, D* : il ne remplace pas les utilisateurs individuels, ne chiffre rien, et ne limite pas le nombre de processus.

**R85. Réponse : B**
`/usr/local/bin/` est l'emplacement conventionnel pour les binaires installés manuellement, distinct des binaires gérés par le gestionnaire de paquets système.
*Pourquoi pas A, C, D* : `/etc/` est pour la configuration, `/var/log/` pour les logs, `/proc/` est un système de fichiers virtuel d'informations sur les processus.

---

## Section 1.E — Shell POSIX

**R86. Réponse : B**
`/bin/sh` sur Alpine pointe vers `ash` (POSIX minimal via BusyBox), tandis que `bash` (s'il est installé) propose des extensions non-POSIX (comme `[[ ]]`, les tableaux, etc.) absentes par défaut en sh.
*Pourquoi pas A, C, D* : il y a clairement une différence, bash existe bien sous Linux, et la vitesse n'est pas le facteur distinctif principal ici.

**R87. Réponse : B**
`set -e` arrête immédiatement l'exécution du script dès qu'une commande retourne un code de sortie non nul (sauf exceptions comme dans certaines conditions de test).
*Pourquoi pas A, C, D* : ce n'est ni un mode debug (`set -x` pour ça), ni un export automatique, ni une suppression des erreurs (c'est l'inverse, il les rend bloquantes).

**R88. Réponse : B**
`[ -z "$VAR" ]` teste si la chaîne est de longueur zéro (vide), syntaxe POSIX standard et portable.
*Pourquoi pas A, C, D* : ces syntaxes sont incorrectes ou non standards en sh POSIX.

**R89. Réponse : B**
En shell, `[` est en réalité une commande externe ou intégrée (pas juste un symbole syntaxique), et `]` doit être son dernier argument séparé par un espace ; sans cet espace, le shell tente d'interpréter `0]` comme un seul token invalide.
*Pourquoi pas A, C, D* : ce n'est pas une règle de "collage", `-ne` existe bel et bien en POSIX, et le point-virgule n'est pas le problème ici.

**R90. Réponse : B**
`$?` après une commande réussie vaut `0`, convention universelle Unix pour "succès".
*Pourquoi pas A, C, D* : ce n'est ni un nom de commande, ni systématiquement 1, ni un PID.

**R91. Réponse : B**
`until` exécute le bloc tant que la condition est FAUSSE, et s'arrête dès qu'elle devient vraie — c'est l'inverse exact de `while`.
*Pourquoi pas A, C, D* : c'est l'opposé de A, ce n'est pas une exécution unique forcée, et la syntaxe est parfaitement valide.

**R92. Réponse : B**
`cat "$TOKEN"` lit le fichier dont le CHEMIN est stocké dans la variable TOKEN ; `cat TOKEN` (sans `$`) cherche littéralement un fichier nommé "TOKEN" dans le dossier courant.
*Pourquoi pas A, C, D* : ce sont deux comportements radicalement différents, et le second n'est jamais recommandé en pratique pour cet usage.

**R93. Réponse : B**
Le pipe connecte la sortie standard (stdout) de la commande de gauche à l'entrée standard (stdin) de la commande de droite.
*Pourquoi pas A, C, D* : ce n'est ni une exécution parallèle déconnectée, ni une redirection d'erreurs uniquement, ni un mécanisme réseau.

**R94. Réponse : B**
`2>&1` redirige le flux d'erreurs (descripteur 2) vers la même destination actuelle que le flux de sortie standard (descripteur 1).
*Pourquoi pas A, C, D* : ce n'est ni stdin vers stdout, ni une redirection vers un fichier littéralement nommé "1", ni une fermeture de descripteur.

**R95. Réponse : B**
Un here-document fournit un bloc de texte multiligne directement dans le script comme entrée standard d'une commande, sans fichier externe.
*Pourquoi pas A, C, D* : aucun rapport avec le téléchargement, la définition de fonction, ou le chiffrement.

**R96. Réponse : B**
Si la commande est coupée mal à propos (avec un retour à la ligne fermant la chaîne `INSTALL_K3S_EXEC="..."` avant `sh -`), `sh -` devient une instruction séparée et indépendante qui ne reçoit jamais le flux du `curl` via pipe, et la variable d'environnement n'est jamais transmise à la bonne commande exécutée.
*Pourquoi pas A, C, D* : c'est précisément le bug réel rencontré et corrigé dans le débogage du projet, ce n'est ni esthétique seulement, ni neutre sur le comportement.

**R97. Réponse : B**
La boucle `for i in 1 2 3` exécute le corps trois fois, avec `i` valant successivement "1", puis "2", puis "3".
*Pourquoi pas A, C, D* : ce n'est ni une exécution unique, ni un parcours caractère par caractère d'une chaîne "123", ni infini.

**R98. Réponse : B**
`$(commande)` capture la sortie standard de la commande exécutée, utilisable comme une chaîne de caractères (substitution de commande).
*Pourquoi pas A, C, D* : ce n'est pas le code de sortie (qui serait `$?` après l'exécution), ni le PID, et cette syntaxe existe bel et bien en POSIX.

**R99. Réponse : B**
Sans guillemets, une variable vide ou contenant des espaces peut faire que `[ ]` reçoive un nombre incorrect d'arguments, provoquant une erreur de syntaxe au runtime (`unary operator expected` par exemple).
*Pourquoi pas A, C, D* : la différence pratique est réelle et documentée, les guillemets ne sont pas absolument obligatoires partout (mais fortement recommandés ici), et cela n'accélère rien.

**R100. Réponse : B**
Une fonction shell regroupe des commandes réutilisables, accepte des arguments positionnels (`$1`, `$2`...), et communique un résultat via son code de sortie (`return`) ou implicitement (code de la dernière commande exécutée).
*Pourquoi pas A, C, D* : aucune de ces contraintes n'est réelle en shell POSIX.

---

## Section 1.F — Kubernetes / K3s

**R101. Réponse : B**
L'API Server est le point d'entrée unique exposé en REST pour toutes les opérations sur l'état du cluster.
*Pourquoi pas A, C, D* : c'est etcd/SQLite qui stocke physiquement, le Scheduler qui décide du placement, et le kubelet/container runtime qui exécute réellement les conteneurs.

**R102. Réponse : B**
etcd est une base de données clé-valeur distribuée, persistante, qui constitue la source de vérité de l'état du cluster.
*Pourquoi pas A, C, D* : ce n'est ni un cache temporaire, ni un composant purement réseau, ni un outil CLI.

**R103. Réponse : B**
SQLite est plus léger, adapté aux contraintes de ressources visées par K3s (edge, IoT, dev) ; etcd reste disponible en option pour des besoins de haute disponibilité multi-master.
*Pourquoi pas A, C, D* : etcd n'est ni obligatoire ni une "légende" (il fonctionne très bien et reste l'option recommandée en HA), et SQLite n'est pas universellement plus rapide qu'etcd sous toute charge.

**R104. Réponse : B**
Le Scheduler décide, en fonction des ressources disponibles et des contraintes, sur quel nœud worker placer chaque nouveau pod.
*Pourquoi pas A, C, D* : ce sont les rôles respectifs d'etcd/SQLite, de l'API Server, et du kubelet/runtime.

**R105. Réponse : B**
Le kubelet est l'agent local qui exécute concrètement les ordres de l'API Server pour lancer et surveiller les pods sur son nœud, qu'il soit worker ou control plane (cas de la Partie 1 avec une seule VM serveur qui fait aussi tourner des pods système).
*Pourquoi pas A, C, D* : il peut tourner aussi sur le control plane, ne remplace pas l'API Server, et n'a pas pour rôle premier le stockage réseau.

**R106. Réponse : B**
kube-proxy maintient les règles réseau (souvent via iptables ou IPVS) qui permettent aux Services Kubernetes de router effectivement le trafic vers les bons pods.
*Pourquoi pas A, C, D* : ce n'est ni le rôle du Scheduler, ni du stockage de config, ni de la gestion des certificats (rôle plutôt du Control Plane/kubelet pour les TLS internes).

**R107. Réponse : B**
Un Pod peut contenir un ou plusieurs conteneurs partageant réseau (IP) et stockage, bien que le cas le plus fréquent soit un seul conteneur.
*Pourquoi pas A, C, D* : ce n'est pas "toujours un seul sans exception", ce n'est pas un type de nœud, et ce n'est pas un synonyme strict de Deployment (le Deployment gère des Pods, il n'EST pas un Pod).

**R108. Réponse : B**
Le Deployment décrit l'état désiré (réplicas, image, stratégie de mise à jour) et le maintient automatiquement face aux pannes ou changements.
*Pourquoi pas A, C, D* : aucun rapport direct avec le réseau du cluster lui-même, il ne remplace pas le besoin de Pods (il en crée via ReplicaSet), et ne gère pas le stockage persistant directement.

**R109. Réponse : B**
ClusterIP fournit une IP virtuelle stable interne au cluster, redirigeant vers les pods correspondant au selector.
*Pourquoi pas A, C, D* : ClusterIP n'expose rien sur Internet directement, ce n'est pas un type de nœud, et il peut tout à fait cibler plusieurs pods simultanément (c'est même son intérêt principal pour le load balancing).

**R110. Réponse : B**
L'Ingress définit des règles de routage HTTP/HTTPS, appliquées concrètement par un Ingress Controller, vers différents Services selon domaine ou chemin.
*Pourquoi pas A, C, D* : il ne remplace pas les Services (il s'appuie sur eux), ne stocke pas de logs, et ne gère pas l'allocation RAM.

**R111. Réponse : B**
Sans Ingress Controller actif, l'objet Ingress n'est qu'une déclaration sans effet, car rien n'implémente concrètement les règles déclarées.
*Pourquoi pas A, C, D* : ce n'est ni un fonctionnement immédiat, ni un blocage total du trafic, ni une suppression automatique des Services.

**R112. Réponse : B**
Un Namespace crée une partition logique pour isoler/organiser des ressources au sein d'un même cluster physique.
*Pourquoi pas A, C, D* : aucune amélioration automatique de performance réseau, il ne remplace pas les Deployments, et ne gère pas le stockage physique des disques.

**R113. Réponse : B**
Un Label attache une métadonnée clé-valeur identifiante, exploitable ensuite pour la sélection/filtrage par d'autres objets (Service, Deployment...).
*Pourquoi pas A, C, D* : ce n'est ni une permission de sécurité, ni un mécanisme de placement forcé automatique, ni une définition de réplicas.

**R114. Réponse : B**
`selector.matchLabels` indique précisément quels labels les pods gérés doivent porter pour être reconnus et administrés par ce Deployment.
*Pourquoi pas A, C, D* : aucun rapport avec le stockage physique, le chiffrement, ou le namespace cible (qui se définit autrement, via le contexte/metadata.namespace).

**R115. Réponse : B**
Sans correspondance exacte, le Deployment ne peut pas reconnaître les pods qu'il a créés comme étant les "siens", ce qui provoque des comportements incohérents (création infinie de nouveaux pods, gestion erronée du nombre de réplicas).
*Pourquoi pas A, C, D* : ce n'est pas qu'une convention esthétique, c'est une exigence technique fonctionnelle, et cela concerne bien les Deployments (pas uniquement les Services).

**R116. Réponse : B**
`-A` (ou `--all-namespaces`) liste les pods de TOUS les namespaces, pas seulement default.
*Pourquoi pas A, C, D* : c'est l'inverse de A, cette commande ne supprime rien, et n'affiche pas QUE les pods en erreur (elle affiche tout, en erreur ou pas).

**R117. Réponse : B**
Le node-token authentifie et autorise un agent souhaitant rejoindre le cluster contrôlé par le serveur qui l'a généré.
*Pourquoi pas A, C, D* : aucun rapport avec le chiffrement disque, l'identification kubectl, ou l'adresse IP du worker (définie séparément via `--node-ip`).

**R118. Réponse : B**
`K3S_URL` indique au futur agent l'adresse complète (incluant le port 6443) du serveur K3s auquel se connecter pour rejoindre le cluster.
*Pourquoi pas A, C, D* : aucun rapport avec un dépôt Git, le DNS du worker, ou l'image Docker.

**R119. Réponse : B**
CrashLoopBackOff signifie que le conteneur démarre, échoue rapidement, et que Kubernetes retente le démarrage en boucle avec un délai croissant (backoff).
*Pourquoi pas A, C, D* : ce n'est pas un pod jamais schedulé (ce serait `Pending`), pas un fonctionnement normal mais lent, et ce n'est généralement pas uniquement réseau (c'est souvent applicatif).

**R120. Réponse : B**
Des Endpoints vides signifient le plus souvent qu'aucun pod actuellement Ready ne correspond au selector du Service (labels incorrects, ou pods non démarrés/non prêts).
*Pourquoi pas A, C, D* : le Service existe toujours (sinon la commande échouerait différemment), ce n'est pas nécessairement tout le cluster hors ligne, et le namespace existe (sinon erreur différente).

---

*Fin du corrigé de la Partie 1 (QCM). Le corrigé de la Partie 2 (questions théoriques) suit.*
# CORRIGÉ PARTIE 2 — QUESTIONS THÉORIQUES OUVERTES

> Pour les questions ouvertes, le corrigé donne une réponse de référence complète. Une réponse partielle n'est pas forcément fausse, mais un évaluateur 42 attend que tous les points clés soient couverts spontanément, sans relance.

## Section 2.A — Virtualisation et hyperviseurs

**R1.** Un hyperviseur de **Type 1** (bare-metal) s'installe directement sur le matériel physique, sans système d'exploitation hôte intermédiaire : c'est lui-même le premier logiciel à démarrer et à contrôler le matériel (exemple : VMware ESXi, Microsoft Hyper-V en mode natif, ou KVM qui transforme le noyau Linux lui-même en hyperviseur). Un hyperviseur de **Type 2** (hosted) tourne comme une application ordinaire au-dessus d'un système d'exploitation hôte déjà installé (exemple : VirtualBox, VMware Workstation). VirtualBox est donc clairement Type 2. KVM est un cas particulier souvent classé Type 1 car il s'intègre au noyau Linux lui-même (le noyau devenant l'hyperviseur), bien que QEMU (souvent associé) s'exécute en espace utilisateur.

**R2.** La virtualisation matérielle (VT-x/AMD-V) permet au processeur d'exécuter directement, sans traduction logicielle coûteuse, la plupart des instructions de la VM. Sans elle, l'hyperviseur doit émuler ou traduire chaque instruction en logiciel (binary translation), ce qui est beaucoup plus lent et complexe. En son absence, VirtualBox peut soit refuser de démarrer certaines VMs (notamment 64-bit), soit retomber sur un mode d'émulation logicielle nettement moins performant si disponible.

**R3.** KVM est le module noyau qui transforme Linux en hyperviseur capable d'exécuter du code natif de VM avec accélération matérielle. QEMU émule les périphériques virtuels (disque, carte réseau, BIOS, carte graphique) et peut s'appuyer sur KVM pour accélérer l'exécution CPU au lieu de tout émuler en logiciel pur. Libvirt est une couche d'abstraction par-dessus, offrant une API et des outils (`virsh`) unifiés pour gérer KVM/QEMU (et d'autres hyperviseurs comme Xen) de façon cohérente, sans avoir à manipuler directement les commandes QEMU complexes. Ces trois composants restent séparés car ils ont des responsabilités distinctes (accélération CPU, émulation matérielle, gestion/orchestration), ce qui permet de les faire évoluer et de les réutiliser indépendamment dans d'autres contextes.

**R4.** Une VM virtualise l'intégralité du matériel et fait tourner un noyau d'OS invité complet et indépendant ; les conteneurs, eux, partagent le même noyau que l'hôte et n'isolent que l'espace utilisateur (processus, système de fichiers, réseau) via des mécanismes du noyau Linux (namespaces, cgroups). Une VM est donc beaucoup plus isolée (deux noyaux distincts) mais plus lourde, tandis qu'un conteneur est plus léger et rapide mais partage une surface d'attaque potentielle au niveau du noyau commun.

**R5.** L'isolation forte d'une VM vient précisément du fait qu'elle a son propre noyau complet, totalement indépendant de l'hôte et des autres VMs : une faille dans le noyau d'une VM ne compromet pas directement les autres VMs ni l'hôte (sauf faille d'hyperviseur lui-même). Ce niveau d'isolation a un coût : chaque VM embarque son propre noyau (consommation RAM/CPU/disque dès le démarrage), contrairement aux conteneurs qui mutualisent le noyau et n'ajoutent que l'overhead de l'application elle-même.

**R6.** Un "Storage pool" dans libvirt désigne un emplacement de stockage logique (souvent un répertoire, mais potentiellement un volume LVM, NFS...) dans lequel libvirt va créer et gérer les disques virtuels des VMs. Par défaut, le storage pool "default" pointe généralement vers `/var/lib/libvirt/images/`, où l'on trouve les fichiers `.img` représentant les disques virtuels des VMs.

**R7.** Les Guest Additions communiquent avec l'hyperviseur VirtualBox via des interfaces internes spécifiques à chaque version. Si la version installée dans la VM (par exemple 7.0.2) ne correspond pas à la version de VirtualBox sur l'hôte (par exemple 7.2), certaines fonctionnalités avancées peuvent être incompatibles ou instables, en particulier les dossiers partagés (vboxsf). Dans le projet, ce décalage a concrètement empêché le montage correct de `/vagrant` sur certaines VMs, provoquant des erreurs "No such file or directory" lors de la copie du node-token.

**R8.** `vboxsf` est le système de fichiers réseau-like spécifique implémenté par les Guest Additions VirtualBox pour exposer, à l'intérieur de la VM, un dossier de la machine hôte comme un point de montage classique. Son rôle exact est de faire le pont entre le système de fichiers de l'hôte et celui de l'invité, via le module noyau `vboxsf` chargé dans la VM, en s'appuyant sur les déclarations de `synced_folder` faites côté Vagrant/VirtualBox.

**R9.** La commande `vagrant status` indique le provider utilisé entre parenthèses (par exemple `running (virtualbox)` ou `running (libvirt)`). On peut confirmer en croisant avec `vboxmanage list vms` (qui ne montrera la VM que si elle est gérée par VirtualBox) et `virsh list --all` (qui ne la montrera que si elle est gérée par libvirt) : une seule de ces deux commandes affichera la VM en question, ce qui confirme sans ambiguïté le provider réellement utilisé.

**R10.** L'allocation de RAM/CPU dans un Vagrantfile (via `vb.memory`, `vb.cpus`) configure des limites/réservations logicielles au niveau de l'hyperviseur, mais le système hôte gère en réalité dynamiquement le partage des ressources physiques entre toutes les VMs et processus actifs. Sauf configuration avancée de réservation stricte, ces valeurs représentent un plafond maximal alloué à la VM, pas un blocage exclusif et permanent de cette quantité de RAM/CPU sur la machine physique tout entière.

**R11.** Un disque virtuel `.vdi` est un fichier sur le système hôte qui simule un disque dur physique pour la VM. En allocation dynamique, le fichier ne consomme initialement que l'espace réellement utilisé par les données écrites, grossissant progressivement jusqu'à la taille maximale définie. En allocation fixe, tout l'espace est réservé immédiatement sur le disque hôte, indépendamment de l'usage réel, ce qui offre généralement de meilleures performances mais consomme plus d'espace dès la création.

**R12.** Chaque VM K3s embarque un système d'exploitation invité complet (Alpine, avec son noyau, ses bibliothèques, ses services), consommant typiquement plusieurs centaines de Mo de RAM minimum juste pour exister, avant même de lancer K3s. Les conteneurs K3d, eux, partagent le noyau Linux de l'hôte et n'ajoutent que le processus K3s lui-même et ses dépendances directes (quelques dizaines à une centaine de Mo), sans dupliquer un noyau complet par instance — d'où une consommation globale nettement inférieure pour un nombre équivalent de "nœuds" simulés.

---

## Section 2.B — Vagrant

**R13.** Le Vagrantfile est un fichier texte (en Ruby) qui décrit de façon déclarative et reproductible la configuration complète d'une ou plusieurs machines virtuelles : box utilisée, ressources allouées, réseau, scripts de provisioning. On parle d'"infrastructure as code" car cette configuration, versionnable dans un système comme Git, permet de recréer exactement le même environnement sur n'importe quelle machine compatible, simplement en exécutant `vagrant up`, sans configuration manuelle répétitive via une interface graphique.

**R14.** Vagrant lit d'abord le Vagrantfile présent dans le dossier courant. Il vérifie ensuite si la box spécifiée est déjà présente en cache local (`~/.vagrant.d/boxes/`) ; si absente, il la télécharge depuis la source indiquée (souvent Vagrant Cloud). Il crée ensuite la VM dans le provider choisi (VirtualBox par défaut généralement) avec les paramètres définis (réseau, RAM, CPU), démarre la VM, attend que SSH soit disponible, remplace la clé SSH insecure par une clé générée propre à cette VM, configure les dossiers partagés et le réseau, puis exécute dans l'ordre tous les scripts de provisioning définis.

**R15.** `vagrant halt` éteint proprement le système d'exploitation invité (équivalent d'un `shutdown`), libérant la RAM et le CPU alloués, mais conservant le disque virtuel intact pour un redémarrage ultérieur. `vagrant suspend` sauvegarde l'état complet de la RAM sur le disque hôte avant d'arrêter la VM, permettant une reprise quasi-instantanée exactement où on s'était arrêté (au prix d'un espace disque supplémentaire pour stocker cet état). `vagrant destroy` supprime définitivement la VM et son disque virtuel : il n'y a plus aucun état à reprendre, tout doit être recréé depuis zéro (box + provisioning) au prochain `vagrant up`.

**R16.** Le dossier `.vagrant/` contient l'état local que Vagrant utilise pour savoir comment retrouver et gérer la VM associée à ce Vagrantfile précis : identifiant de la VM dans le provider, provider utilisé, et la clé SSH privée générée. Si ce dossier est supprimé manuellement alors que la VM existe toujours réellement dans VirtualBox/libvirt, Vagrant "perd le fil" : il ne saura plus que cette VM lui appartient, et un nouveau `vagrant up` pourrait tenter de créer une toute nouvelle VM en doublon plutôt que de réutiliser/gérer l'existante, qui devient alors orpheline et doit être supprimée manuellement via l'outil du provider (vboxmanage, virsh).

**R17.** La clé SSH "insecure" est une paire de clés publique/privée distribuée publiquement avec le code source de Vagrant (donc connue de tout le monde l'ayant téléchargée). L'utiliser durablement représenterait un risque de sécurité majeur (n'importe qui connaissant cette clé pourrait potentiellement se connecter). Vagrant la remplace donc automatiquement par une nouvelle paire de clés générée spécifiquement pour chaque VM dès la première connexion réussie, garantissant que seule cette installation précise de Vagrant détient la clé privée correspondante.

**R18.** Un synced folder synchronise un dossier de la machine hôte avec un dossier dans la VM. Le type `virtualbox` utilise le mécanisme natif vboxsf des Guest Additions (rapide, bidirectionnel en temps réel, mais dépendant de la compatibilité de version des Guest Additions). Le type `rsync` copie les fichiers au démarrage (et sur demande via `vagrant rsync`), sans synchronisation temps réel automatique mais sans dépendance aux Guest Additions (plus robuste face aux problèmes de version). Le type `nfs` utilise le protocole réseau NFS, performant pour de gros volumes de fichiers mais nécessitant une configuration NFS côté hôte, parfois complexe selon l'OS.

**R19.** Plusieurs causes racines possibles : (1) absence de déclaration explicite de `synced_folder` pour une VM spécifique dans un Vagrantfile à plusieurs machines (Vagrant ne propage pas toujours automatiquement le partage à toutes les VMs définies) ; (2) décalage de version entre les Guest Additions installées dans la box et la version de VirtualBox sur l'hôte, cassant le bon fonctionnement de vboxsf ; (3) absence du plugin `vagrant-vbguest` pour corriger automatiquement ce décalage ; (4) le module noyau `vboxguest`/`vboxsf` chargé mais sans qu'aucun dossier partagé n'ait réellement été déclaré côté VirtualBox pour cette VM précise (visible avec `VBoxControl sharedfolder list` retournant 0 résultat).

**R20.** `vagrant provision` réexécute uniquement les scripts de provisioning, sans toucher au cycle de vie (démarrage/arrêt) de la VM — utile si la VM tourne déjà et qu'on veut juste relancer le script modifié rapidement. `vagrant reload --provision` redémarre complètement la VM (relisant aussi les éventuels changements réseau/ressources du Vagrantfile) ET relance ensuite les scripts. On utiliserait `provision` seul pour un test rapide d'un script modifié sur une VM déjà stable, et `reload --provision` si on a aussi modifié la configuration réseau/ressources qui nécessite un redémarrage complet pour être pris en compte.

**R21.** Sans cette option, chaque `vagrant up` contacte Vagrant Cloud pour vérifier l'existence d'une version plus récente de la box, ajoutant une latence réseau et une dépendance à la connectivité Internet à chaque lancement. En contexte de soutenance, où le réseau peut être instable, limité, ou simplement pour gagner du temps et de la fiabilité (éviter un blocage en cas de coupure réseau), désactiver cette vérification (`box_check_update = false`) rend le démarrage plus rapide et plus robuste, sans dépendre d'un appel réseau non essentiel.

**R22.** En l'absence de spécification explicite (ni argument `--provider`, ni variable d'environnement `VAGRANT_DEFAULT_PROVIDER`), Vagrant applique un ordre de priorité interne basé sur les plugins installés et disponibles sur le système, choisissant généralement le premier provider compatible détecté selon cet ordre de préférence interne (qui peut varier selon les versions et plugins installés, ce qui explique pourquoi une même machine peut "basculer" silencieusement entre VirtualBox et libvirt selon le contexte d'installation).

**R23.** Allouer le minimum nécessaire plutôt que le maximum disponible permet de pouvoir faire tourner plusieurs VMs simultanément sans saturer les ressources de la machine hôte (RAM notamment), garde de la marge pour le système hôte lui-même et les autres applications, et respecte l'esprit du sujet qui recommande explicitement le strict minimum (1 CPU, 512 Mo/1024 Mo de RAM) pour rester dans un contexte pédagogique léger et reproductible sur des machines aux capacités variables.

**R24.** Les scripts de provisioning de type `shell` permettent d'exécuter automatiquement des commandes ou un script complet à l'intérieur de la VM, dès sa création (ou à chaque démarrage selon configuration), pour installer et configurer logiciels et services sans intervention manuelle. Ils sont exécutés en tant que root par défaut car la plupart des opérations qu'ils réalisent (installation de paquets, modification de fichiers système, démarrage de services) nécessitent justement des privilèges administrateur.

**R25.** Si un script de provisioning échoue (retourne un code de sortie non nul) lors d'un `vagrant up` portant sur plusieurs VMs définies dans le même Vagrantfile, Vagrant interrompt généralement le processus pour la VM concernée et signale l'échec (avec le message "The SSH command responded with a non-zero exit status"), mais le comportement précis sur les VMs suivantes peut dépendre de l'ordre et du parallélisme : dans un cas séquentiel classique, les VMs déjà traitées avec succès restent opérationnelles, mais celles non encore atteintes ne seront pas créées tant que l'erreur n'est pas corrigée et la commande relancée.

**R26.** Sans accès root sur la machine hôte de l'école, il est impossible d'installer Vagrant, VirtualBox ou Docker directement sur le système existant. Un SSD externe avec son propre système d'exploitation complet (sur lequel on dispose de droits root complets, puisqu'on en est administrateur) permet de contourner cette contrainte : on démarre la machine physique sur cet OS externe (via le boot menu), et on y installe librement tous les outils nécessaires, sans jamais toucher au système protégé de l'école, tout en bénéficiant du matériel de la machine (CPU, RAM) pour l'exécution.

---

## Section 2.C — Réseau

**R27.** NAT (Network Address Translation) permet à la VM d'accéder à Internet en faisant transiter et traduire son trafic via l'adresse de l'hôte, mais sans donner par défaut un accès direct entrant depuis l'hôte vers la VM (sauf port forwarding explicite). Host-only (private_network) crée un réseau isolé d'Internet où l'hôte et les VMs peuvent se voir et communiquer librement entre eux via des IPs fixes ou dynamiques sur ce segment dédié, sans accès direct à Internet par ce biais (sauf si combiné avec une autre interface, comme c'est le cas dans le projet où NAT et private_network coexistent sur la même VM).

**R28.** Des IPs fixes garantissent que le serveur et le worker (ou les applications) restent toujours joignables aux mêmes adresses connues à l'avance, ce qui est indispensable pour configurer correctement K3S_URL, les scripts de healthcheck, et les tests curl du sujet sans dépendre d'une attribution DHCP potentiellement différente à chaque redémarrage de VM, ce qui casserait la reproductibilité et la prévisibilité exigées par le sujet et les scripts d'automatisation.

**R29.** Un masque de sous-réseau définit, combiné à une adresse IP, quelle portion de l'adresse désigne le réseau (partie commune à toutes les machines du même segment) et quelle portion désigne l'hôte spécifique au sein de ce réseau. Sans masque, une adresse IP seule ne permet pas de savoir où s'arrête le réseau local et où commencerait un autre réseau nécessitant un routage.

**R30.** `/24` signifie que les 24 premiers bits (sur 32 bits totaux d'une adresse IPv4) sont réservés à la partie réseau, laissant 8 bits pour la partie hôte. Le nombre d'adresses hôtes utilisables se calcule par 2^(bits restants) moins 2 (adresse réseau et broadcast réservées), soit 2^8 - 2 = 254 adresses utilisables pour un /24.

**R31.** Deux machines appartenant à des sous-réseaux différents (déterminés par l'application du masque à leur IP respective) ne peuvent pas communiquer directement au niveau 2/3 du modèle réseau, car elles ne partagent pas le même segment local : un routeur (gateway) doit explicitement faire transiter et router les paquets entre les deux réseaux distincts pour permettre la communication, sinon les paquets ne trouvent simplement pas de chemin direct.

**R32.** Une gateway est l'adresse IP d'un routeur connu d'une machine, vers laquelle elle envoie tout paquet destiné à une adresse hors de son propre sous-réseau local. Le rôle de la gateway est de relayer ce trafic vers le réseau de destination (potentiellement après plusieurs sauts à travers d'autres routeurs), permettant ainsi la communication inter-réseaux, notamment vers Internet.

**R33.** TCP est orienté connexion (établissement préalable via un handshake en trois temps), garantit la livraison ordonnée et la retransmission en cas de perte de paquets, au prix d'un overhead plus important. UDP est sans connexion, plus rapide et léger, mais sans aucune garantie de livraison ni d'ordre. L'API Kubernetes utilise TCP car la fiabilité et l'intégrité des échanges (créer/modifier/supprimer des ressources du cluster) sont critiques : on ne peut pas se permettre de perdre silencieusement une partie d'une requête de configuration sans s'en rendre compte.

**R34.** Un port est un numéro (de 0 à 65535) qui identifie un service ou processus spécifique en écoute sur une machine ayant une adresse IP donnée. Plusieurs services peuvent coexister sur la même IP car chacun écoute sur un port distinct (par exemple SSH sur 22, l'API K3s sur 6443, HTTP sur 80) : le système distingue le trafic destiné à chaque service grâce à ce numéro de port associé à l'IP de destination.

**R35.** Une socket est formellement définie par la combinaison d'une adresse IP, d'un numéro de port, et d'un protocole de transport (TCP ou UDP). C'est cette combinaison qui identifie de façon unique un point de communication réseau, permettant à un système d'exploitation de distinguer plusieurs connexions ou écoutes simultanées même sur la même IP.

**R36.** Quand Traefik (l'Ingress Controller de K3s) reçoit une requête HTTP sur le port 80 (à l'IP 192.168.56.110), il examine l'en-tête `Host` de cette requête. Il compare cette valeur (par exemple "app1.com") aux règles définies dans les objets Ingress du cluster. Si une règle correspond exactement à ce Host, Traefik route la requête vers le Service associé (app-one), même si l'adresse IP et le port de la requête initiale restent strictement identiques pour les trois applications : c'est le contenu de la requête HTTP (l'en-tête Host), pas l'adresse réseau, qui permet la distinction.

**R37.** ICMP (utilisé par ping) et TCP (utilisé pour la plupart des connexions applicatives) sont des protocoles distincts et indépendants. Un pare-feu (sur l'hôte, dans le réseau, ou même au niveau applicatif) peut être configuré pour bloquer spécifiquement le trafic ICMP tout en laissant passer le trafic TCP sur un port précis autorisé, car ce sont deux règles de filtrage totalement séparées dans la configuration du pare-feu.

**R38.** DHCP attribue dynamiquement une adresse IP (et d'autres paramètres réseau comme la gateway, le masque, le DNS) à une machine se connectant au réseau, sans configuration manuelle. Dans la Partie 1 du projet, le sujet exige des IPs fixes et connues à l'avance (192.168.56.110 et .111) pour garantir la reproductibilité et permettre aux scripts d'automatisation (server.sh, worker.sh) de référencer ces adresses de façon fiable et prévisible, ce qui serait impossible avec une attribution DHCP potentiellement variable à chaque redémarrage.

**R39.** DNS (Domain Name System) traduit des noms de domaine lisibles par l'humain en adresses IP exploitables par les protocoles réseau sous-jacents. Dans un cluster Kubernetes/K3s, ce rôle est assuré par CoreDNS, qui résout notamment les noms internes des Services (comme `app-one.default.svc.cluster.local`) en leur ClusterIP correspondante, permettant aux pods de communiquer entre eux par nom plutôt que par IP brute potentiellement changeante.

**R40.** Une erreur HTTP 401 signifie que la requête a été correctement reçue, traitée par le serveur applicatif (ici l'API Kubernetes), qui a analysé la demande et a délibérément choisi de refuser l'accès faute d'authentification valide. Cela implique nécessairement que toute la chaîne réseau sous-jacente (connexion TCP établie, certificat TLS négocié, requête HTTP transmise et comprise) a fonctionné correctement — seule la couche d'autorisation applicative bloque la réponse complète, ce qui est un signal positif de bonne santé réseau, contrairement à une absence totale de réponse qui indiquerait un vrai problème de connectivité.

**R41.** Le port 6443 est celui sur lequel l'API Server K3s écoute les connexions. Pour qu'un worker rejoigne le cluster (via K3S_URL pointant vers ce port) et continue ensuite à communiquer en permanence avec le Control Plane (rapporter son état, recevoir des instructions sur les pods à lancer), ce port doit rester accessible en continu. Si un pare-feu le bloquait, le worker ne pourrait initialement jamais effectuer la jonction (timeout sur K3S_URL), ou s'il avait déjà rejoint, perdrait progressivement la communication, basculant potentiellement en état NotReady après expiration des health checks internes.

**R42.** Sur un simple réseau privé Vagrant à deux machines partageant exactement le même sous-réseau (même masque, même plage d'adresses), les deux machines sont directement voisines au niveau 2/3 du modèle réseau : elles peuvent s'envoyer directement des paquets sans intermédiaire, car elles appartiennent au même segment local. Un routeur ne devient nécessaire que pour relier des sous-réseaux différents entre eux, situation qui ne se présente pas ici.

---

## Section 2.D — Linux / Alpine / Système

**R43.** Alpine Linux est nettement plus légère (quelques dizaines de Mo contre plusieurs centaines pour Ubuntu), démarre plus rapidement, et consomme moins de RAM/disque au repos — des qualités précieuses pour des VMs dédiées exclusivement à faire tourner K3s avec des ressources volontairement limitées (comme exigé par le sujet). Sa surface d'attaque réduite (moins de paquets installés par défaut) est également un atout en termes de sécurité, bien que ce ne soit pas l'enjeu premier ici.

**R44.** musl libc est une implémentation alternative et plus légère de la bibliothèque C standard, comparée à la glibc (GNU C Library) utilisée par la majorité des distributions traditionnelles (Ubuntu, Debian, Fedora...). musl vise la simplicité, la légèreté en taille binaire, et la conformité stricte aux standards, au prix parfois d'une compatibilité moindre avec certains logiciels compilés en supposant des comportements spécifiques de la glibc (ce qui peut occasionnellement causer des problèmes de compatibilité avec certains binaires précompilés non prévus pour musl).

**R45.** OpenRC est un système d'init léger qui gère le démarrage, l'arrêt et la supervision des services sur Alpine, à travers des scripts simples et une hiérarchie de runlevels. Contrairement à systemd (utilisé par Ubuntu/Debian), OpenRC ne propose pas de gestionnaire de journaux intégré unifié de la même ampleur (`journalctl`), n'utilise pas d'unités déclaratives complexes du même type, et reste globalement plus simple/minimaliste dans son fonctionnement interne, en cohérence avec la philosophie générale d'Alpine.

**R46.** `systemctl` est l'outil de contrôle spécifique à systemd, qui n'est pas installé sur Alpine (lequel utilise OpenRC par défaut). La commande échoue donc car le binaire `systemctl` lui-même n'existe pas sur le système. La commande équivalente sur Alpine est `rc-service NOM status` (ou `rc-status` pour une vue d'ensemble de tous les services).

**R47.** Sur un fichier, le bit `x` (exécution) permet de lancer ce fichier comme un programme/script. Sur un répertoire, le bit `x` a un sens différent : il permet de *traverser* ce répertoire (y accéder, par exemple via `cd` ou pour atteindre des fichiers qu'il contient), distinct du bit `r` qui permettrait seulement de *lister* le contenu du répertoire sans pouvoir y accéder en profondeur.

**R48.** `sudo` et `mount`/`apk add` nécessitent des privilèges root car ces opérations modifient l'état global du système (installation de logiciels affectant tous les utilisateurs, montage de systèmes de fichiers affectant l'arborescence globale) — des actions qu'un utilisateur normal ne doit pas pouvoir effectuer librement pour des raisons de sécurité et de stabilité du système. `sudo` représente concrètement une élévation temporaire et tracée des privilèges du processus exécuté, vers ceux d'un autre utilisateur (typiquement root), sans changer durablement l'identité de l'utilisateur connecté.

**R49.** Un point de montage est le répertoire via lequel un système de fichiers externe devient accessible. Dans le projet, `/vagrant` est censé être ce point de montage pour le dossier partagé contenant le Vagrantfile et les scripts. Quand ce montage échoue ou n'est pas effectué (absence de déclaration synced_folder, décalage de version Guest Additions), `/vagrant` reste un dossier vide ou inexistant, provoquant l'échec en cascade de toute opération en dépendant : le script ne peut pas copier le node-token, le worker ne peut jamais le récupérer, et l'installation entière du cluster échoue.

**R50.** Un PID (Process ID) est un identifiant numérique unique attribué par le noyau à chaque processus actif sur le système, à l'instant de sa création. Deux exécutions successives du même programme reçoivent des PID différents car le noyau attribue ces identifiants de façon séquentielle/cyclique à chaque nouveau processus créé, sans jamais réutiliser immédiatement un PID encore potentiellement associé à un processus récemment terminé (pour éviter toute ambiguïté).

**R51.** Un processus est une instance en cours d'exécution d'un programme, identifiée par son PID, gérée directement par le noyau. Un service (au sens OpenRC/systemd) est une abstraction de plus haut niveau représentant une fonctionnalité système gérée (démarrage, arrêt, surveillance, redémarrage automatique en cas de crash), qui repose concrètement sur un ou plusieurs processus sous-jacents, mais ajoute une couche de gestion de cycle de vie et de configuration que le simple concept de processus n'offre pas nativement.

**R52.** Les messages affichés par Vagrant pendant le provisioning ne montrent que la sortie standard/erreur du script au moment de son exécution, qui peut être tronquée, incomplète, ou ne pas refléter des événements survenus après la fin apparente du script (par exemple un service qui crashe quelques secondes après son démarrage initial apparemment réussi). Les logs systèmes complets et persistants permettent de remonter dans le temps, de voir l'historique détaillé d'un service, et de capturer des informations de diagnostic bien plus riches (stack traces, erreurs internes détaillées) que ce qu'affiche Vagrant en surface.

**R53.** Le fait qu'un module noyau comme `vboxguest` apparaisse dans `lsmod` signifie uniquement que ce module a été chargé en mémoire et est disponible pour être utilisé par le noyau — cela ne garantit absolument pas qu'un dossier partagé spécifique a été correctement déclaré côté VirtualBox et qu'un montage a réellement été tenté ou réussi pour ce dossier précis. C'est exactement le piège rencontré dans le débogage du projet : modules chargés, mais "Shared Folder mappings (0): No Shared Folders available" côté VirtualBox, prouvant l'absence de déclaration effective malgré la disponibilité théorique du mécanisme.

**R54.** Tester manuellement une commande en SSH avant de l'intégrer dans un script automatisé permet d'observer immédiatement et précisément le comportement réel, les messages d'erreur exacts, et d'itérer rapidement sans attendre un cycle complet de `vagrant destroy`/`vagrant up` (potentiellement plusieurs minutes) à chaque tentative de correction. Cela isole également la variable du provisioning automatisé pour se concentrer uniquement sur la commande elle-même, facilitant grandement l'identification de la cause exacte d'un problème.

---

## Section 2.E — Shell et scripting

**R55.** `sh` (souvent `ash` sur Alpine via BusyBox) implémente un sous-ensemble POSIX minimal et standardisé, tandis que `bash` ajoute de nombreuses extensions non-POSIX (tableaux, `[[ ]]`, substitution de processus, certaines syntaxes de boucles étendues). Un script écrit en utilisant des fonctionnalités spécifiques à bash mais exécuté avec `#!/bin/sh` sur un système où `sh` est réellement `ash` (comme Alpine) échouera ou se comportera de façon imprévisible, d'où l'importance de rester strictement POSIX si l'on déclare `#!/bin/sh`.

**R56.** `set -e` arrête immédiatement le script dès qu'une commande échoue (code de sortie non nul). Sans cette option, par exemple si `curl -sfL https://get.k3s.io | sh -` échouait silencieusement (réseau indisponible), le script continuerait son exécution comme si K3s avait été installé avec succès, menant potentiellement bien plus tard à des erreurs cryptiques et déconnectées de la cause réelle (par exemple un timeout sur `kubectl get nodes` sans qu'on comprenne immédiatement que l'installation initiale avait déjà échoué).

**R57.** `$(commande)` exécute la commande dans un sous-shell, capture tout ce qu'elle écrit sur sa sortie standard (stdout), et remplace cette expression par le contenu capturé (en tant que chaîne de caractères), utilisable ensuite dans une affectation de variable ou directement dans une autre commande. Exemple tiré du projet : `NODE_TOKEN=$(cat "$TOKEN" | tr -d '\n')` capture le contenu du fichier token (sans le saut de ligne final) dans la variable NODE_TOKEN.

**R58.** Sans guillemets, si la variable est vide, `[ $VAR = "valeur" ]` se réduit après expansion à `[ = "valeur" ]`, ce qui constitue un nombre incorrect d'arguments pour la commande `[` et provoque une erreur de syntaxe ("unary operator expected" ou similaire). Avec guillemets, `[ "$VAR" = "valeur" ]` devient au pire `[ "" = "valeur" ]`, qui reste syntaxiquement valide (comparaison entre chaîne vide et "valeur", qui sera simplement fausse), évitant ainsi le crash du test.

**R59.** `while condition; do ... done` exécute le corps tant que la condition reste VRAIE. `until condition; do ... done` exécute le corps tant que la condition reste FAUSSE (s'arrêtant dès qu'elle devient vraie). Dans le projet, `until [ -f "$TOKEN" ]` est plus naturel et lisible que l'équivalent `while [ ! -f "$TOKEN" ]` pour exprimer directement l'intention "continue jusqu'à ce que le fichier existe", sans double négation.

**R60.** Le code de sortie (exit code) est une valeur numérique (0 à 255) que toute commande retourne en se terminant, indiquant son succès (0) ou un type d'échec spécifique (toute valeur non nulle, dont la signification précise dépend de la commande). On y accède immédiatement après l'exécution via la variable spéciale `$?`, qui contient le code de sortie de la DERNIÈRE commande exécutée (et qui est donc écrasée par toute commande suivante, y compris un simple `echo`).

**R61.** stdout (descripteur 1) est le flux de sortie "normal" d'un programme (résultats attendus), tandis que stderr (descripteur 2) est dédié spécifiquement aux messages d'erreur et de diagnostic, intentionnellement séparé pour permettre de filtrer/rediriger indépendamment les deux flux. Lors du débogage, séparer ces flux (par exemple rediriger stderr vers un fichier de log distinct) permet d'isoler facilement les messages d'erreur du résultat normal attendu, sans qu'ils se mélangent dans la même sortie.

**R62.** `2>/dev/null` redirige spécifiquement le flux d'erreurs (stderr) vers `/dev/null` (un fichier spécial qui ignore/jette tout ce qu'on y écrit), supprimant ainsi l'affichage des messages d'erreur sans affecter la sortie standard. Dans le projet, cette pratique a été utilisée par exemple pour les tentatives de montage de `/vagrant` (`mount -t virtiofs ... 2>/dev/null`) afin de ne pas polluer les logs avec des erreurs attendues lors d'un essai qui échouera potentiellement avant de réussir avec une méthode alternative. Ce n'est pas toujours une bonne idée car cela peut aussi masquer de vraies erreurs imprévues qu'on aurait dû voir pour bien déboguer.

**R63.** `<<EOF ... EOF` (sans guillemets autour du délimiteur) interpole normalement les variables et substitutions de commandes à l'intérieur du bloc, comme dans le reste du script. `<<'EOF' ... EOF` (avec guillemets simples autour du délimiteur) désactive complètement cette interpolation : tout le contenu est traité littéralement, mot pour mot, sans substitution de variable même si elle est présente syntaxiquement dans le texte (par exemple `$HOSTNAME` resterait affiché tel quel, pas remplacé par sa valeur).

**R64.** Si on écrit `curl ... | INSTALL_K3S_EXEC="..." \` puis, sur une LIGNE SÉPARÉE après les guillemets fermants, `sh -`, le shell peut interpréter cela comme deux instructions distinctes plutôt qu'une seule commande continue reliée par le pipe et l'environnement préfixé. Concrètement dans le bug du projet, le `\` était placé après la fermeture des guillemets de `INSTALL_K3S_EXEC`, créant une coupure logique : le `curl | ...` se terminait sans jamais transmettre son flux à un `sh -` qui devenait une commande indépendante sans entrée, n'installant donc jamais réellement K3s malgré l'absence d'erreur immédiate visible.

**R65.** Une fonction shell se définit par `nom() { commandes }`. On lui passe des arguments en les plaçant après son nom lors de l'appel (`ma_fonction arg1 arg2`), accessibles à l'intérieur via `$1`, `$2`, etc. Elle communique un résultat principalement via son code de sortie (`return N`, ou implicitement le code de sortie de la dernière commande exécutée dans la fonction), et peut aussi "retourner" des données en les affichant sur stdout, récupérables par l'appelant via `$(ma_fonction)`.

**R66.** Cette construction permet d'attendre activement, par tentatives répétées espacées (ici toutes les 5 secondes implicitement via la boucle), que l'API Kubernetes devienne réellement opérationnelle avant de continuer le script. Comme l'installation de K3s est asynchrone (le service démarre mais l'API peut prendre plusieurs secondes à devenir pleinement fonctionnelle), cette boucle évite d'enchaîner immédiatement sur des commandes kubectl qui échoueraient à coup sûr si exécutées trop tôt.

**R67.** `[ $? -ne 0]` (sans espace avant `]`) provoque une erreur car le shell traite `[` comme une commande à part entière dont `]` doit être le dernier argument, séparé par un espace comme tout autre argument de commande. Sans cet espace, le shell concatène `0]` en un seul token qu'il ne reconnaît pas comme l'argument de fermeture attendu, provoquant une erreur de syntaxe ("missing ]" ou équivalent) — le shell n'a aucun moyen de "deviner" l'intention humaine derrière cette absence d'espace, car il interprète strictement la syntaxe caractère par caractère sans tolérance implicite.

**R68.** `[ ]` est la commande de test POSIX standard, portable sur tous les shells conformes (y compris `ash`/BusyBox sur Alpine). `[[ ]]` est une extension propre à bash (et quelques autres shells avancés comme zsh ou ksh), offrant une syntaxe plus riche (comparaisons de motifs, opérateurs logiques natifs `&&`/`||` à l'intérieur) mais non disponible nativement dans un `#!/bin/sh` sur Alpine, où elle provoquerait une erreur de syntaxe ("[[: not found" ou équivalent), car BusyBox ash ne l'implémente pas.

---

## Section 2.F — Ruby et Vagrantfile

**R69.** `Vagrant.configure("2")` appelle la méthode de classe `configure` sur le module/objet `Vagrant`, avec l'argument `"2"` précisant la version d'API de configuration. `do |config| ... end` est un bloc Ruby : une portion de code passée en argument à la méthode `configure`, où `config` est la variable locale représentant l'objet de configuration que le bloc reçoit en paramètre et peut manipuler à l'intérieur du bloc.

**R70.** `#{}` est la syntaxe d'interpolation de chaîne en Ruby : tout code Ruby placé entre les accolades est évalué, et son résultat (converti en chaîne) est inséré directement dans la chaîne de caractères englobante. Exemple : `SERVER_NAME = "#{LOGIN}S"` évalue la variable `LOGIN` (par exemple "ankammer") et construit dynamiquement la chaîne "ankammerS", combinant la variable et le suffixe littéral "S".

**R71.** `config.vm.define SERVER_NAME do |server| ... end` ouvre un nouveau contexte de configuration limité exclusivement à la VM nommée par `SERVER_NAME`. La variable `server` à l'intérieur de ce bloc référence un objet de configuration spécifique à cette VM, distinct de `config` qui reste, lui, l'objet de configuration global potentiellement partagé par toutes les VMs définies dans le même Vagrantfile (pour les réglages communs comme la box ou les synced_folders globaux).

**R72.** `LOGIN = "ankammer"` est une variable Ruby de portée globale au sein du fichier (constante par convention de nommage en majuscules), accessible depuis n'importe quel bloc imbriqué plus bas dans le même fichier, y compris à l'intérieur de `config.vm.define ... do |server| ... end`, car les blocs Ruby (closures) ont accès aux variables définies dans leur portée englobante (closure scope), sans qu'il soit nécessaire de la redéclarer ou de la passer explicitement en argument.

**R73.** `server.vm.provider "virtualbox" do |vb| ... end` ouvre un bloc de configuration spécifique au provider VirtualBox pour cette VM précise (`server`), où `vb` représente l'objet de configuration VirtualBox correspondant. Cette structure est nécessaire car les réglages comme RAM/CPU sont spécifiques à chaque provider (la syntaxe et les options peuvent différer pour libvirt par exemple) — il faut donc explicitement entrer dans ce sous-contexte "provider" pour personnaliser ces paramètres matériels, plutôt que de les définir au niveau générique de `server.vm`.

**R74.** Si `config.vm.synced_folder` est déclaré au niveau global (avant tout bloc `define`), il s'applique par défaut à TOUTES les VMs définies ensuite dans le même Vagrantfile. S'il est déclaré uniquement à l'intérieur d'un bloc `define` spécifique (par exemple seulement pour `server`), il ne s'applique qu'à cette VM précise, et les autres VMs (comme `worker`) n'en bénéficient pas automatiquement, ce qui explique le bug observé dans le débogage du projet où `/vagrant` fonctionnait sur le serveur mais pas sur le worker tant que la déclaration n'était pas remontée au niveau global.

**R75.** Un `end` manquant dans un fichier Ruby comportant plusieurs blocs imbriqués provoque une erreur de syntaxe à l'analyse (parsing) du fichier, généralement un message du type "syntax error, unexpected end-of-input, expecting `end`" ou similaire, car Ruby ne peut pas déterminer où se termine réellement le bloc resté ouvert. Vagrant, ne pouvant pas charger un Vagrantfile syntaxiquement invalide, refusera immédiatement de s'exécuter, sans même tenter de créer ou modifier quoi que ce soit côté VM.

**R76.** `path: "scripts/server.sh"` exécute un script externe dont le contenu est lu depuis le fichier indiqué (chemin relatif au Vagrantfile), tandis que `inline: "..."` exécute directement le texte fourni comme commande(s) shell, écrit en dur dans le Vagrantfile lui-même, sans fichier séparé. `path` est généralement préféré pour des scripts longs et réutilisables/versionnés indépendamment, tandis que `inline` convient à de petites commandes ponctuelles ne justifiant pas un fichier dédié.

---

## Section 2.G — Kubernetes et K3s

**R77.** Trois différences concrètes : (1) K3s est distribué en un seul binaire compact regroupant la plupart des composants, contre plusieurs binaires/processus séparés pour K8s standard ; (2) K3s utilise SQLite par défaut comme backend de stockage léger, contre etcd généralement pour K8s standard en production ; (3) K3s inclut par défaut des composants prêts à l'emploi comme Traefik (Ingress Controller) et un CNI léger (Flannel), alors que K8s standard (via kubeadm) ne fournit aucun Ingress Controller ni CNI par défaut, laissant le choix entièrement à l'administrateur.

**R78.** Le modèle déclaratif consiste à décrire l'ÉTAT DÉSIRÉ final souhaité (par exemple "je veux 3 réplicas de cette image"), et à laisser le système (les contrôleurs Kubernetes) déterminer lui-même comment atteindre et maintenir cet état, plutôt que de lister étape par étape les actions à effectuer (modèle impératif). Avec un Deployment, on écrit simplement `replicas: 3` dans le YAML et on l'applique : Kubernetes se charge ensuite de créer, surveiller, et recréer automatiquement les pods nécessaires pour toujours respecter ce nombre, sans qu'on ait besoin de scripter manuellement chaque création ou remplacement de pod individuellement.

**R79.** L'**API Server** est le point d'entrée unique exposant l'API REST pour toutes les opérations de lecture/écriture sur le cluster. **etcd/SQLite** stocke physiquement et de façon persistante tout l'état du cluster (configuration, statut des ressources). Le **Scheduler** décide sur quel nœud placer chaque nouveau pod en fonction des ressources disponibles. Le **Controller Manager** exécute en continu des boucles de contrôle qui comparent l'état réel à l'état désiré et corrigent automatiquement les écarts détectés (par exemple recréer un pod manquant pour respecter le nombre de réplicas voulu).

**R80.** Un Pod est éphémère car, en cas de suppression ou de crash, Kubernetes ne "redémarre" pas littéralement le même pod : il en crée un nouveau, avec une nouvelle adresse IP attribuée dynamiquement. Si on ciblait directement l'IP d'un pod pour y accéder, cette adresse deviendrait invalide dès le premier remplacement de pod, cassant immédiatement toute communication. C'est pourquoi on utilise systématiquement un Service, dont l'IP (ClusterIP) reste stable indépendamment des changements internes des pods qu'il sélectionne dynamiquement via leurs labels.

**R81.** Le Deployment délègue à un ReplicaSet la responsabilité de surveiller en continu le nombre de pods correspondant à son selector. Si ce nombre descend sous la valeur désirée (`replicas: N`), suite à un crash ou une suppression manuelle, le ReplicaSet (via le Controller Manager) détecte cet écart lors de sa boucle de réconciliation périodique et déclenche immédiatement la création d'un nouveau pod identique au modèle (`template`) défini, jusqu'à revenir exactement à N pods en fonctionnement.

**R82.** Un Rolling Update remplace progressivement les anciens pods par de nouveaux (avec la nouvelle configuration/image), pod par pod, plutôt que de tout arrêter puis tout redémarrer simultanément. `maxSurge` définit combien de pods supplémentaires (au-delà du nombre de réplicas normal) peuvent être créés temporairement pendant la transition, et `maxUnavailable` définit combien de pods peuvent être temporairement indisponibles pendant ce processus. En combinant `maxSurge: 1` et `maxUnavailable: 0`, on garantit qu'il y a toujours au moins le nombre normal de réplicas disponibles, tout en autorisant un pod supplémentaire temporaire pour faciliter la transition sans aucune interruption de service.

**R83.** Même si chaque pod possède sa propre IP, ces IPs changent à chaque recréation de pod (crash, mise à jour, scaling). Un Service fournit une IP virtuelle stable et un nom DNS constant, indépendants du cycle de vie individuel des pods, permettant aux autres composants du cluster (ou aux clients externes via Ingress/NodePort) de toujours utiliser la même référence d'accès, sans avoir à suivre manuellement les changements d'IP des pods sous-jacents au fil du temps.

**R84.** La requête `curl -H "Host:app1.com" http://192.168.56.110` arrive sur le port 80 du nœud, où Traefik (Ingress Controller) l'intercepte. Traefik examine l'en-tête Host ("app1.com"), le compare aux règles de l'objet Ingress, trouve la correspondance vers le Service "app-one", puis transmet la requête à ce Service (sur son ClusterIP interne, port 80). Le Service sélectionne un pod sain parmi ceux correspondant à son selector (`app: app-one`), via les Endpoints maintenus à jour par kube-proxy, et route finalement la requête vers ce pod précis (sur son IP de pod, port correspondant au targetPort défini), qui traite la requête et renvoie sa réponse HTML en remontant exactement le même chemin inverse.

**R85.** Exiger 3 réplicas pour l'application 2 (et pas pour les deux autres) permet de démontrer concrètement la capacité de Kubernetes à load-balancer le trafic entre plusieurs instances identiques d'une même application via un seul Service, ainsi que la résilience offerte (si un des 3 pods plante, les deux autres continuent de servir le trafic sans interruption visible), illustrant des concepts de haute disponibilité et de scalabilité horizontale que l'évaluateur peut vérifier en observant quel pod répond à chaque requête successive.

**R86.** Cette annotation indique explicitement à l'API Kubernetes (et aux Ingress Controllers qui la respectent) que CET objet Ingress doit être géré par Traefik spécifiquement. En son absence, si plusieurs Ingress Controllers étaient installés simultanément dans le cluster (par exemple Traefik ET Nginx Ingress), chacun pourrait potentiellement tenter de traiter le même objet Ingress, menant à des comportements ambigus, conflictuels, ou imprévisibles selon lequel des deux contrôleurs "gagne" le traitement de cette règle.

**R87.** Le node-token est stocké sur le serveur dans le fichier `/var/lib/rancher/k3s/server/node-token`. Sa confidentialité est cruciale en production car toute personne en sa possession (combinée à l'URL du serveur) peut faire rejoindre n'importe quelle machine à ce cluster en tant qu'agent légitime, obtenant potentiellement un accès significatif aux ressources et données du cluster — un risque de sécurité majeur en environnement réel, même si dans un contexte pédagogique local et isolé ce risque reste largement théorique et sans conséquence pratique grave.

**R88.** Le script worker.sh attend d'abord que le fichier token soit accessible (via dossier partagé ou méthode alternative). Une fois récupéré et validé (non vide), il teste la disponibilité de l'API du serveur (curl sur le port 6443). Une fois l'API confirmée disponible, il exécute le script d'installation officiel K3s en mode agent, en fournissant K3S_URL (adresse du serveur) et K3S_TOKEN (le token récupéré) comme variables d'environnement. K3s installe alors l'agent, qui contacte automatiquement le serveur indiqué, s'authentifie via le token, et rejoint officiellement le cluster — devenant alors visible côté serveur via `kubectl get nodes` après quelques secondes nécessaires à la synchronisation complète.

**R89.** Le protocole de communication interne entre composants K3s (API, certificats, format de données) peut évoluer entre versions majeures/mineures. Une incompatibilité de version entre serveur et worker peut provoquer des erreurs d'authentification, de communication API, ou des comportements instables/imprévisibles, car les deux composants pourraient ne pas s'attendre exactement aux mêmes formats ou protocoles internes — d'où l'importance de fixer explicitement la même `INSTALL_K3S_VERSION` sur les deux scripts pour garantir une compatibilité totale et prévisible.

**R90.** `kubectl get nodes -o wide` ajoute des colonnes supplémentaires absentes de l'affichage par défaut : notamment l'adresse IP interne (INTERNAL-IP) et externe (EXTERNAL-IP) du nœud, l'image de l'OS utilisé, la version du noyau, et le runtime de conteneurs utilisé — des informations précieuses pour le débogage réseau et la vérification de configuration, qui ne sont pas visibles avec la commande simple.

**R91.** Avec seulement 1 CPU et 1 Go de RAM, les ressources allouées à SQLite (la base de données interne de K3s) et aux nombreux processus K3s (API Server, Scheduler, Controller Manager, etc. tous regroupés) peuvent rapidement devenir insuffisantes face à la charge des versions récentes de K3s, plus gourmandes que les précédentes. Cela se traduit concrètement par des requêtes SQL qui prennent anormalement longtemps (visible dans les logs comme "Slow SQL", parfois plusieurs dizaines de secondes), provoquant des timeouts en cascade sur kubectl et une instabilité générale. Les solutions concrètes incluent : augmenter la RAM/CPU alloués à la VM, ou utiliser une version antérieure et plus légère de K3s (comme v1.28) via `INSTALL_K3S_VERSION`.

**R92.** `prune: true` autorise Argo CD à SUPPRIMER automatiquement, dans le cluster, les ressources qui ont été retirées du dépôt Git (si un fichier YAML est supprimé du repo, la ressource correspondante sera supprimée du cluster lors de la prochaine synchronisation). `selfHeal: true` autorise Argo CD à CORRIGER automatiquement toute modification manuelle effectuée directement dans le cluster (par exemple via `kubectl edit`) qui diverge de ce qui est défini dans Git, en restaurant l'état conforme au dépôt — garantissant ainsi que Git reste la seule et unique source de vérité, conformément au principe du GitOps.

---

## Section 2.H — YAML et manifestes

**R93.** YAML utilise l'indentation pour déterminer la structure hiérarchique des données (qui est enfant de qui). Les tabulations ne sont pas autorisées par la spécification YAML car leur largeur d'affichage peut varier selon l'éditeur ou le terminal, rendant l'indentation ambiguë et imprévisible ; les espaces, eux, ont une largeur strictement constante et universelle, garantissant une interprétation cohérente et déterministe de la hiérarchie peu importe l'outil utilisé pour visualiser ou éditer le fichier.

**R94.** Une liste YAML utilise le préfixe `-` pour chaque élément (par exemple une liste de conteneurs dans un pod : `containers:` suivi de plusieurs lignes commençant par `- name: ...`). Un dictionnaire (map) associe des clés à des valeurs avec la syntaxe `clé: valeur` (par exemple `metadata:` suivi de `name: mon-app` indenté dessous). Un manifeste Kubernetes mélange typiquement les deux : `spec.containers` est une liste, tandis que `metadata` est un dictionnaire contenant lui-même d'autres paires clé-valeur.

**R95.** Le séparateur `---` indique le début d'un nouveau document YAML distinct au sein du même fichier physique. Dans le contexte Kubernetes, cela permet de regrouper plusieurs manifestes indépendants (par exemple un Deployment suivi de son Service associé) dans un seul fichier `.yaml`, que `kubectl apply -f` traitera comme plusieurs objets séparés à créer/mettre à jour, sans qu'on ait besoin de créer un fichier physique distinct pour chacun.

**R96.** Le champ `replicas` dans la spécification d'un Deployment attend strictement un type entier (integer) selon le schéma de l'API Kubernetes. Écrire `replicas: "3"` (avec guillemets) en fait une chaîne de caractères (string) au sens du parsing YAML, ce qui ne correspond pas au type attendu par le schéma de validation de l'API Kubernetes, provoquant une erreur de validation lors de l'application du manifeste (`kubectl apply` rejettera la requête avec un message d'erreur de type incorrect).

**R97.** Si `selector.matchLabels` (dans la spec du Deployment) ne correspond pas exactement aux labels effectivement appliqués aux pods créés (`template.metadata.labels`), le Deployment ne pourra pas reconnaître ses propres pods comme étant sous sa gestion. Concrètement, cela peut provoquer une erreur de validation immédiate au moment de la création du Deployment (Kubernetes exige cette cohérence dès la déclaration), ou dans des cas où la correspondance est partiellement satisfaite, des comportements de gestion erratiques et incohérents du nombre réel de réplicas observés.

**R98.** Le caractère `|` introduit un bloc de texte littéral multi-lignes en YAML, préservant fidèlement tous les retours à la ligne du contenu tel qu'écrit. Dans un manifeste Kubernetes, cela est utile par exemple pour définir un script shell complet inline dans le champ `command`/`args` d'un conteneur (comme observé dans la Partie 2 du projet pour générer dynamiquement une page HTML via une commande nginx personnalisée), sans avoir besoin d'un fichier séparé monté via ConfigMap.

**R99.** En YAML, l'indentation détermine seule la relation parent-enfant entre les éléments. Décaler un champ d'un seul caractère vers la gauche peut le faire "remonter" d'un niveau hiérarchique (devenant frère plutôt qu'enfant d'un autre champ), changeant radicalement la structure logique interprétée par le parseur, sans qu'aucune erreur de syntaxe explicite ne soit nécessairement levée (le YAML reste valide syntaxiquement, mais sa signification structurelle réelle diverge totalement de l'intention de l'auteur).

**R100.** `kubectl apply --dry-run=client -f fichier.yaml` valide la syntaxe et la structure du manifeste localement, côté client, sans réellement l'envoyer à l'API Server ni modifier l'état du cluster. Cela permet de détecter des erreurs évidentes (syntaxe YAML invalide, champs manquants ou mal typés) avant tout impact réel, particulièrement précieux en production où une erreur appliquée directement pourrait provoquer une interruption de service ou un comportement inattendu sur des ressources critiques déjà en fonctionnement.

---

*Fin du corrigé de la Partie 2. Le corrigé de la Partie 3 (Shell) suit.*
# CORRIGÉ PARTIE 3 — ANALYSE DE CODE SHELL

**Corrigé 3.1**
Ce script ne fait PAS ce qu'il semble vouloir faire. Le pipe `curl ... | INSTALL_K3S_EXEC="..." \` est suivi d'un retour à la ligne puis `sh -` sur la ligne suivante. Le `\` continue la chaîne de caractères `INSTALL_K3S_EXEC`, mais une fois cette chaîne fermée par le guillemet, `sh -` se retrouve être une commande complètement séparée, sans lien avec le `curl | ...` qui précède. Concrètement : le contenu téléchargé par curl n'est envoyé à aucun interpréteur, et `sh -` démarre un shell interactif qui attend une entrée standard qui ne viendra jamais (ou se termine immédiatement selon le contexte d'exécution), si bien que K3s n'est jamais réellement installé, malgré l'absence d'erreur immédiate visible et le message "K3s installed" qui s'affichera quand même juste après. Correction : tout doit être sur une seule instruction logique, par exemple `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=${SERVER_IP}" sh -` sans retour à la ligne coupant le pipe.

**Corrigé 3.2**
Le bloc `if [ ! -f "$TOKEN_FILE" ]; then echo "Error..."; fi` affiche un message d'erreur si le fichier n'existe pas, mais ne fait pas `exit 1` ensuite : le script continue son exécution et tente quand même `cp "$TOKEN_FILE" /vagrant/node-token` à la ligne suivante, qui échouera nécessairement puisque le fichier source n'existe pas. Le message d'erreur est donc affiché mais totalement inefficace pour empêcher la suite du script de planter avec une erreur différente et moins claire ("cp: cannot stat..."). Correction : ajouter `exit 1` après le message d'erreur dans le bloc `if`.

**Corrigé 3.3**
Deux bugs distincts : premièrement, `cat TOKEN` (sans `$` ni guillemets) tente de lire un fichier littéralement nommé "TOKEN" dans le répertoire courant, au lieu de lire le fichier dont le CHEMIN est stocké dans la variable `TOKEN` (qui devrait être `cat "$TOKEN"`). Deuxièmement, `[ -z NODE_TOKEN ]` teste si la chaîne littérale "NODE_TOKEN" est vide (ce qui est toujours faux puisque cette chaîne n'est jamais vide), au lieu de tester la valeur de la variable, qui devrait être écrite `[ -z "$NODE_TOKEN" ]`.

**Corrigé 3.4**
La redirection `> 2>&1` est syntaxiquement incorrecte et incomplète : il manque la destination du `>` (normalement `/dev/null`). Le shell interprète probablement `2>&1` comme argument suivant cette redirection mal formée, ce qui produit une erreur de syntaxe ou un comportement non voulu (selon l'implémentation exacte du shell), empêchant potentiellement le test `if ping ...` de s'exécuter comme prévu. Le comportement réel observé peut être une erreur immédiate du script plutôt qu'un simple test de connectivité silencieux. Correction : `> /dev/null 2>&1`.

**Corrigé 3.5**
Premier bug : l'URL contient un `/` superflu avant `:6443`, donnant `https://${SERVER_IP}/:6443/healthz` au lieu de `https://${SERVER_IP}:6443/healthz` — cette URL malformée ne correspond à aucune route valide et échouera systématiquement. Second bug : `if [ TRIES -ge 12 ]` compare la chaîne littérale "TRIES" (pas la valeur de la variable) à 12, ce qui provoque une erreur de syntaxe car `[` attend un entier et non une chaîne arbitraire dans ce contexte de comparaison numérique ; il manque le `$` devant TRIES.

**Corrigé 3.6**
L'erreur précise est l'absence d'espace entre `0` et `]` dans `[ $? -ne 0]`. En shell, `[` est interprété comme une commande dont `]` doit être le dernier argument, séparé comme tout autre argument par un espace. Sans cet espace, le shell concatène `0]` en un unique token qu'il ne reconnaît pas comme la fermeture attendue de la commande `[`, provoquant une erreur de syntaxe du type "missing `]`" — le shell analyse littéralement caractère par caractère sans tolérance implicite pour cette omission, même si l'intention est limpide pour un lecteur humain.

**Corrigé 3.7**
Le problème conceptuel grave : `mkdir -p /vagrant/` crée un dossier `/vagrant` purement LOCAL à cette VM, totalement indépendant du mécanisme de partage VirtualBox (synced_folder). Ce dossier n'est donc PAS partagé avec l'autre VM (le worker), même s'il porte le même nom `/vagrant`. Le fichier copié dedans (`node-token`) reste enfermé dans cette VM précise et ne sera jamais visible ni accessible par le worker qui chercherait au même chemin apparent `/vagrant/node-token` sur SA propre VM, qui est un système de fichiers totalement distinct. C'est exactement le bug rencontré en pratique dans le débogage du projet réel.

**Corrigé 3.8**
`systemctl rc-service k3s-agent status` mélange deux commandes système incompatibles : `systemctl` est l'outil de contrôle de systemd (absent sur Alpine), et `rc-service` est l'outil natif d'OpenRC (le système d'init réellement utilisé sur Alpine). Les utiliser combinés comme un seul appel (`systemctl rc-service ...`) n'a aucun sens : le shell tenterait d'exécuter `systemctl` avec `rc-service` comme simple argument, ce qui échouerait immédiatement avec "command not found" puisque `systemctl` lui-même n'existe pas sur Alpine. La ligne de fallback `status k3s-agent --no-pager` invente aussi une commande "status" qui n'existe pas non plus en tant que telle. La forme correcte sur Alpine est simplement `rc-service k3s-agent status`.

**Corrigé 3.9**
Avec `set -e`, une chaîne de commandes reliées par `||` ne provoque PAS l'arrêt du script même si certaines d'entre elles échouent, à condition que le `||` final aboutisse à une commande qui réussit (ici `echo` réussit toujours). En effet, `set -e` ne considère l'ensemble d'une liste de commandes chaînées par `||` comme un échec global que si la TOUTE DERNIÈRE commande de la chaîne échoue elle-même. Comme la chaîne se termine par un `echo` qui réussit systématiquement, ce bloc ne déclenchera jamais l'arrêt du script sous `set -e`, même si les deux tentatives de montage précédentes échouent — c'est le comportement voulu et correct ici, pas un risque.

**Corrigé 3.10**
Ce script affiche `${PASSED}s` à la fin comme temps d'attente, mais cette valeur a été incrémentée à l'intérieur de la boucle `while [ ! -f "$TOKEN" ]; do ... done` APRÈS le test de la condition, ce qui signifie que `PASSED` aura été incrémenté une fois de trop au moment de sortir de la boucle par rapport au temps réellement écoulé avant que le fichier soit détecté (décalage potentiel de 5 secondes par rapport à la réalité, selon le timing exact de détection). Ce n'est pas un bug fonctionnel critique, mais un défaut de précision d'affichage qui peut légèrement induire en erreur quelqu'un essayant de chronométrer précisément le délai réel d'apparition du token pour optimiser un timeout.

**Corrigé 3.11**
Si ce script est exécuté par un utilisateur normal sans privilèges suffisants (et non via le mécanisme de provisioning Vagrant qui s'exécute par défaut en root), `apk update` et `apk add` échoueront avec une erreur de permission ("Permission denied"), car la modification de la base de paquets système nécessite des droits root. Il faudrait vérifier que le script est bien exécuté avec les privilèges adéquats (root, ou via `sudo` explicite si exécuté manuellement plutôt que via le provisioning automatique de Vagrant qui gère cela automatiquement).

**Corrigé 3.12**
Ce script manque l'affichage de logs de diagnostic (par exemple le contenu de `/var/log/k3s.log` ou `rc-service k3s status`) directement dans le message d'erreur final avant le `exit 1`, plutôt que de simplement suggérer une commande à exécuter manuellement plus tard. Une version plus robuste afficherait automatiquement les dernières lignes de logs pertinents au moment même de l'échec, économisant une étape de connexion manuelle supplémentaire pour le débogage immédiat.

**Corrigé 3.13**
La faille de séquencement : `docker run -d ...` lance le conteneur en arrière-plan (`-d`) et la commande retourne immédiatement, sans garantir que l'application interne (sur le port 8888) soit déjà prête à répondre. Le `curl http://localhost:8888/` qui suit immédiatement peut donc s'exécuter AVANT que l'application n'ait fini de démarrer réellement à l'intérieur du conteneur, provoquant un échec intermittent ("Connection refused") selon la rapidité de démarrage de l'application, sans lien avec un bug de syntaxe shell. Il manque une attente explicite (sleep, ou idéalement une boucle de vérification de disponibilité) entre le lancement du conteneur et le test curl.

**Corrigé 3.14**
La commande affichera littéralement : `vagrant ssh ankammerS` — ce qui est en réalité le résultat CORRECT et attendu ici (contrairement à l'exercice 3.15 qui suit). La concatenation de chaînes Ruby... pardon, ici on est en shell : `"vagrant ssh "${NAME}"S"` concatène la chaîne littérale "vagrant ssh " avec la valeur de `$NAME` ("ankammer") suivie de la chaîne littérale "S", produisant bien "vagrant ssh ankammerS", qui est le résultat voulu et fonctionnel dans ce cas précis.

**Corrigé 3.15**
`${SERVER_IP%.*}` est une substitution de paramètre qui supprime le plus court suffixe correspondant au motif `.* ` (un point suivi de n'importe quoi) depuis la fin de la chaîne — concrètement, cela retire le dernier groupe après le dernier point, transformant "192.168.56.110" en "192.168.56". En ajoutant ensuite "S", le résultat final est "192.168.56S", qui n'a absolument aucun sens dans le contexte voulu (afficher un nom de login suivi de "S" pour désigner la VM serveur) : cette expression confond manifestement une manipulation de chaîne IP avec ce qui devrait être une manipulation du login de l'utilisateur, c'est une erreur de logique/conception, pas seulement de syntaxe.

**Corrigé 3.16**
Sans `set -u` (qui n'est pas activé ici), une variable non définie comme `NODE_TOKEN` (si elle n'a jamais été assignée plus haut dans ce contexte précis) sera silencieusement traitée comme une chaîne vide lors de son utilisation, sans aucune erreur ni avertissement. Le script continuera donc avec `TOKEN_LENGTH=0` sans planter, masquant potentiellement un vrai problème (variable censée contenir un token réel mais jamais correctement assignée). Avec `set -u` activé, l'utilisation d'une variable non définie provoquerait immédiatement une erreur explicite ("unbound variable"), rendant ce genre de bug bien plus facile à détecter rapidement.

**Corrigé 3.17**
Ce script suppose implicitement que le cluster Kubernetes est déjà pleinement opérationnel et que l'API répond correctement au moment où `kubectl apply` est exécuté pour chaque application. Sans `set -e` et sans vérification préalable de la disponibilité de l'API (contrairement aux scripts vus précédemment qui font une boucle d'attente explicite), si l'API n'est pas encore prête, chaque `kubectl apply` échouera silencieusement (le message d'erreur s'affichera mais le script continuera), et le message final "All apps deployed" s'affichera de façon trompeuse même si aucune application n'a réellement été déployée avec succès.

**Corrigé 3.18**
Le risque principal d'une boucle `while true` sans timeout dans un script de provisioning Vagrant : si le serveur ne démarre jamais correctement (panne, bug, configuration incorrecte), cette boucle tournera INDÉFINIMENT, bloquant le provisioning du worker pour une durée illimitée. Cela peut donner l'impression que `vagrant up` est "gelé" sans qu'aucun message d'erreur clair n'apparaisse jamais, rendant le diagnostic difficile pour quelqu'un ne connaissant pas l'existence de cette boucle infinie volontaire, contrairement aux autres scripts du projet qui utilisent systématiquement un `LIMIT`/timeout explicite pour éviter ce piège.

**Corrigé 3.19**
`nohup` ("no hang up") empêche le processus lancé de recevoir le signal SIGHUP qui serait normalement envoyé si la session/terminal qui l'a lancé se ferme (par exemple à la fin du script de provisioning ou de la session SSH) — sans `nohup`, le serveur Python pourrait être tué prématurément dès que le script de provisioning se termine. `$!` contient le PID du dernier processus lancé en arrière-plan (ici le serveur Python), utile pour pouvoir potentiellement le surveiller ou le terminer plus tard. Le `&` est indispensable car sans lui, la commande `python3 -m http.server` resterait bloquante au premier plan indéfiniment (un serveur HTTP ne se termine jamais de lui-même), empêchant le script de continuer son exécution au-delà de cette ligne.

**Corrigé 3.20**
Il manque la commande pour ATTENDRE que K3s soit réellement opérationnel avant de considérer le script terminé, typiquement une boucle `until kubectl get nodes ...` comme vue dans d'autres scripts du projet. Sans cette attente, le script peut se terminer "avec succès" en apparence immédiatement après le lancement asynchrone de l'installation, alors que K3s n'a pas encore fini de démarrer réellement (génération des certificats, démarrage de l'API, etc.), laissant le cluster dans un état transitoire non garanti si une commande dépendante de ce nouveau cluster était exécutée juste après.

**Corrigé 3.21 (Complétion attendue)**
```sh
#!/bin/sh
TOKEN="/vagrant/node-token"
LIMIT=300
PASSED=0

while [ ! -f "$TOKEN" ]; do
    sleep 5
    PASSED=$((PASSED + 5))
    if [ $PASSED -ge $LIMIT ]; then
        echo "Timeout: token introuvable après ${LIMIT}s"
        exit 1
    fi
done

echo "Token trouvé"
NODE_TOKEN=$(cat "$TOKEN" | tr -d '\n')
```
Les éléments clés attendus : la boucle `while [ ! -f "$TOKEN" ]` avec un compteur incrémenté et une condition de sortie par timeout explicite, et la lecture du fichier avec `cat "$TOKEN"` (guillemets et `$`) suivi de `tr -d '\n'` pour retirer le saut de ligne final.

**Corrigé 3.22 (Complétion attendue)**
```sh
#!/bin/sh
SERVER_IP="192.168.56.110"
PING_OK=0

for i in 1 2 3; do
    if ping -c 1 -W 2 "$SERVER_IP" > /dev/null 2>&1; then
        PING_OK=1
        break
    fi
    sleep 2
done

if [ $PING_OK -eq 0 ]; then
    echo "Avertissement: ping a échoué, on continue malgré tout"
fi
```
Les éléments clés attendus : une boucle `for i in 1 2 3` (exactement 3 tentatives), un test `ping -c 1` avec redirection complète vers `/dev/null 2>&1`, un `break` dès succès pour ne pas continuer inutilement, et `sleep 2` entre chaque tentative.

**Corrigé 3.23**
L'hypothèse implicite problématique : ce script suppose qu'un service nommé "docker" existe et peut être démarré directement via `rc-service docker start` après une simple installation par `apk add docker`. Or, sur Alpine, après l'installation du paquet docker, il faut généralement aussi explicitement activer le service au démarrage (`rc-update add docker default`) et parfois charger des modules noyau spécifiques ; de plus, l'utilisateur exécutant ce script doit appartenir au groupe approprié ou utiliser sudo pour interagir avec le socket Docker, sinon `docker run hello-world` échouera avec une erreur de permission malgré une installation et un démarrage de service apparemment réussis.

**Corrigé 3.24**
Les versions de K3s à partir d'environ la v1.26 ont renforcé la sécurité de l'endpoint `/healthz`, qui requiert désormais une authentification et retourne une erreur 401 Unauthorized plutôt que la chaîne "ok" en clair attendue par ce script écrit pour d'anciennes versions. La condition `grep -q "ok"` ne trouvera donc jamais cette correspondance dans la réponse 401 reçue, et la boucle continuera indéfiniment jusqu'à atteindre les 12 tentatives et provoquer une sortie en erreur, même si le serveur K3s fonctionne en réalité parfaitement bien — c'est un faux négatif du script de test, pas un vrai problème du cluster.

**Corrigé 3.25**
Le délimiteur `<< 'HTMLEOF'` (avec guillemets simples autour) désactive explicitement toute interpolation de variable à l'intérieur du bloc here-document : tout le contenu, y compris `$HOSTNAME`, est traité littéralement comme du texte brut, sans substitution. Pour que la vraie valeur du nom d'hôte soit insérée dynamiquement dans le HTML généré, il aurait fallu utiliser `<< HTMLEOF` (sans les guillemets simples), permettant l'interpolation normale des variables à l'intérieur du bloc.

**Corrigé 3.26**
Il manque une vérification (ou une boucle d'attente) que le fichier `$TOKEN_FILE` existe réellement avant de tenter la commande `cp`. Si ce script s'exécute trop rapidement après le démarrage de K3s (avant que le serveur ait eu le temps de générer effectivement ce fichier token), la commande `cp` échouera avec une erreur explicite "No such file or directory", car K3s a besoin d'un certain délai pour finaliser son initialisation et créer ce fichier spécifique, qui n'apparaît pas instantanément dès le lancement du service.

**Corrigé 3.27**
La Version B est nettement plus robuste face à un changement de version de K3s. La Version A dépend strictement du fait que la réponse contienne exactement la chaîne "ok", ce qui était vrai pour d'anciennes versions de K3s mais ne l'est plus pour les versions récentes qui retournent "Unauthorized" (HTTP 401) sur cet endpoint sans authentification. La Version B accepte plusieurs réponses possibles ("Unauthorized", "ok", "Bad Request") via une expression régulière étendue (`grep -qE`), ce qui couvre à la fois les anciennes ET les nouvelles versions de K3s : dans les deux cas, recevoir n'importe laquelle de ces réponses prouve que l'API répond effectivement, ce qui est le seul fait réellement pertinent à vérifier ici (la disponibilité de l'API, pas le contenu exact attendu d'une réponse non authentifiée).

**Corrigé 3.28**
Le message "Serveur démarré" ne s'affichera jamais car la commande `python3 -m http.server 9999 > /tmp/http-token.log 2>&1` (SANS le `&` final pour la mettre en arrière-plan) est une commande BLOQUANTE qui ne se termine jamais d'elle-même (un serveur HTTP reste en écoute indéfiniment). Le script reste donc figé sur cette ligne pour toujours (ou jusqu'à interruption manuelle), et n'atteint donc jamais la ligne `echo "Serveur démarré"` qui suit. Il manque le `&` à la fin de la commande pour la lancer réellement en arrière-plan et permettre au script de continuer.

**Corrigé 3.29 (Script complet — 6+ erreurs identifiées)**
1. `cat TOKEN` devrait être `cat "$TOKEN"` (variable non référencée correctement, lit un fichier littéralement nommé TOKEN).
2. `[ -z NODE_TOKEN ]` devrait être `[ -z "$NODE_TOKEN" ]` (teste la chaîne littérale au lieu de la variable).
3. `ping -c 1 -W 2 "$SERVER_IP" > 2>&1` devrait être `> /dev/null 2>&1` (redirection incomplète, destination manquante).
4. `https://${SERVER_IP}/:6443/healthz` devrait être `https://${SERVER_IP}:6443/healthz` (slash superflu cassant l'URL).
5. `if [ TRIES -ge 12 ]` devrait être `if [ $TRIES -ge 12 ]` ($ manquant devant la variable).
6. `if [ $? -ne 0]` devrait être `if [ $? -ne 0 ]` (espace manquant avant le crochet fermant).
Bonus (7ème observation) : le script n'utilise `set -e` à aucun moment, ce qui signifie que même les erreurs non explicitement testées par le script pourraient passer silencieusement inaperçues.

**Corrigé 3.30**
Deux erreurs distinctes : premièrement, la commande `sed -i s/wil42\/playground:v1/wil42\/playground:v2/g ...` omet les délimiteurs de l'expression sed (normalement entourée de guillemets comme `'s/.../.../'`), ce qui peut provoquer une interprétation incorrecte par le shell des caractères spéciaux (notamment les `/` échappés et les espaces potentiels), risquant une erreur de syntaxe sed ou un comportement incorrect du remplacement. Deuxièmement, `git commit -m update v2` est syntaxiquement incorrect : sans guillemets autour du message, seul "update" est pris comme argument de `-m` (le message du commit), tandis que "v2" est interprété par Git comme un argument supplémentaire inattendu (potentiellement un nom de fichier ou de chemin), provoquant une erreur Git du type "pathspec 'v2' did not match any files". La forme correcte serait `git commit -m "update v2"`.

---

*Fin du corrigé de la Partie 3 (Shell). Le corrigé de la Partie 4 (Vagrantfile/Ruby) suit.*
# CORRIGÉ PARTIE 4 — ANALYSE DE VAGRANTFILE / RUBY

**Corrigé 4.1**
`Vagrant` est le module/objet Ruby exposé par la gem Vagrant. `configure` est une méthode de classe appelée sur ce module, recevant `"2"` comme argument indiquant la version d'API de configuration à utiliser. `do |config| ... end` est un bloc Ruby passé comme argument implicite à `configure` : `config` est la variable locale qui référence l'objet de configuration que la méthode fournit à l'intérieur du bloc. Si on oublie le `end` final, Ruby lève une erreur de syntaxe au chargement du fichier ("syntax error, unexpected end-of-input, expecting `end`"), et Vagrant refuse totalement de s'exécuter, n'effectuant aucune action sur les VMs.

**Corrigé 4.2**
`puts SERVER_NAME` affichera "ankammerS". Le mécanisme de `#{LOGIN}` : à l'intérieur d'une chaîne de caractères délimitée par des guillemets doubles, Ruby évalue toute expression placée entre `#{` et `}`, convertit son résultat en chaîne, et l'insère directement à cet emplacement dans la chaîne finale. Ici, `LOGIN` vaut "ankammer", donc `"#{LOGIN}S"` devient "ankammer" + "S" = "ankammerS".

**Corrigé 4.3**
On utilise `server.vm.hostname` plutôt que `config.vm.hostname` car on se trouve à l'intérieur d'un bloc `config.vm.define SERVER_NAME do |server| ... end`, qui crée un sous-contexte de configuration spécifique à cette VM précise. Utiliser `config.vm.hostname` à cet endroit appliquerait potentiellement le réglage de façon globale ou de manière incohérente avec l'intention de cibler uniquement cette VM ; `server` (la variable locale du bloc) garantit que ce réglage de hostname s'applique exclusivement à la VM en cours de définition.

**Corrigé 4.4**
Les deux arguments de la méthode `network` sont : la chaîne `"private_network"` (le type de réseau demandé) et `ip: SERVER_IP` (un argument nommé/mot-clé). Cette syntaxe `ip: SERVER_IP` est un "hash argument" ou argument avec mot-clé en Ruby : `ip` est un symbole utilisé comme clé, associé à la valeur de la variable `SERVER_IP`, permettant de passer des paramètres optionnels nommés explicitement à une méthode plutôt que de se fier uniquement à leur position dans la liste d'arguments.

**Corrigé 4.5**
Si ce bloc `server.vm.provider "virtualbox" do |vb| ... end` était écrit avec `config.vm.provider` (donc à l'extérieur de tout bloc `define`, directement sous `Vagrant.configure`), il s'appliquerait alors par défaut à TOUTES les VMs définies dans ce Vagrantfile, sauf si une configuration plus spécifique au niveau de chaque `define` venait ensuite la surcharger. Cela transformerait un réglage destiné à une seule VM en un réglage global partagé, ce qui n'est généralement pas l'intention recherchée quand on veut des ressources différentes pour le serveur et le worker (comme dans le projet, où le serveur a plus de RAM que le worker).

**Corrigé 4.6**
Il manque un `end` à la fin du fichier. En comptant : `Vagrant.configure("2") do |config|` ouvre 1 bloc, `config.vm.define "machine1" do |m1|` en ouvre un second (fermé correctement par son `end`), `config.vm.define "machine2" do |m2|` en ouvre un troisième... mais le fichier se termine après `m2.vm.hostname = "machine2"` sans jamais fermer ce troisième bloc, ni le premier bloc englobant `Vagrant.configure`. Il manque donc 2 `end` au minimum pour que ce fichier soit syntaxiquement valide.

**Corrigé 4.7**
Placé avant tout bloc `config.vm.define`, `config.vm.synced_folder` s'applique au niveau de l'objet de configuration GLOBAL (`config`), ce qui signifie que ce réglage sera hérité par défaut par TOUTES les VMs définies ensuite dans le même Vagrantfile, sans qu'il soit nécessaire de le redéclarer individuellement pour chacune. C'est précisément cette portée globale qui résout le bug observé dans le projet où le dossier partagé ne fonctionnait que sur la VM pour laquelle il avait été déclaré localement, et pas sur les autres.

**Corrigé 4.8**
Cela dépend entièrement de l'endroit où `config.vm.synced_folder` a été déclaré dans le reste du Vagrantfile (information non visible dans cet extrait isolé). Si elle est déclarée au niveau GLOBAL (avant les blocs `define`, au niveau de `config` et non de `server`/`worker`), alors oui, le worker en hérite automatiquement même sans déclaration explicite dans son propre bloc. Si elle n'est déclarée QUE dans le bloc spécifique du serveur (`server.vm.synced_folder`), alors non, le worker n'en hérite absolument pas et doit la déclarer lui-même explicitement dans son propre bloc `define`.

**Corrigé 4.9**
Le chemin `"scripts/server.sh"` est interprété par Vagrant comme relatif au dossier où se trouve le Vagrantfile sur la MACHINE HÔTE (pas dans la VM). Cependant, ces deux interprétations sont en pratique équivalentes dans ce projet précis, car le dossier contenant le Vagrantfile est lui-même partagé et monté dans la VM à l'emplacement `/vagrant` — donc le fichier accessible sur l'hôte à `./scripts/server.sh` correspond exactement au même fichier accessible dans la VM à `/vagrant/scripts/server.sh`, les deux chemins désignant en réalité le même contenu physique grâce au mécanisme de synced_folder.

**Corrigé 4.10**
Bug de recopie : le bloc `define WORKER_NAME` utilise par erreur `SERVER_IP` au lieu de `WORKER_IP` pour configurer son réseau privé. Conséquence concrète : la VM worker recevra la MÊME adresse IP (192.168.56.110) que celle prévue pour le serveur, provoquant un conflit d'adressage IP sur le même segment réseau si les deux VMs tournent simultanément — comportement réseau imprévisible, accès intermittent ou impossible à l'une ou l'autre des deux machines, et la jonction du worker au cluster échouera certainement puisque K3S_URL pointerait probablement vers la même IP que celle que le worker lui-même tente d'utiliser.

**Corrigé 4.11**
Avec `box_check_update` à sa valeur par défaut (`true`), chaque `vagrant up` déclencherait une requête réseau vers Vagrant Cloud pour vérifier l'existence d'une version plus récente de la box "generic/alpine319", ajoutant une latence supplémentaire (potentiellement plusieurs secondes selon la qualité de la connexion) à chaque lancement, voire un risque de blocage ou de ralentissement si la connectivité réseau de l'environnement de soutenance est instable ou limitée — un risque non négligeable et facilement évitable en désactivant explicitement cette vérification non essentielle au bon fonctionnement du projet.

**Corrigé 4.12**
`if Vagrant.has_plugin?("vagrant-vbguest") ... end` est une structure conditionnelle Ruby classique : la méthode `has_plugin?` retourne un booléen (true/false), et le code à l'intérieur du `if...end` ne s'exécute QUE si cette condition est vraie. Si le plugin `vagrant-vbguest` n'est PAS installé sur la machine exécutant ce Vagrantfile, la condition est fausse, le bloc interne (`config.vbguest.auto_update = true`) est simplement ignoré et n'est jamais exécuté, sans provoquer d'erreur : le Vagrantfile continue de fonctionner normalement, juste sans ce réglage spécifique au plugin absent.

**Corrigé 4.13**
Il manque un `end` pour fermer le bloc `server.vm.provider "virtualbox" do |vb| ... end` avant que le bloc `config.vm.define SERVER_NAME do |server| ... end` lui-même ne se ferme. En comptant précisément : `do |server|` (1) → `do |vb|` (2) → un seul `end` ferme le bloc provider... mais ensuite un second `end` devrait fermer le bloc `define`, et on ne voit dans cet extrait qu'un seul `end` avant l'ouverture du second `config.vm.define WORKER_NAME`. Il manque donc un `end` supplémentaire pour fermer correctement le premier bloc `define` avant l'ouverture du second.

**Corrigé 4.14**
`vb.memory = "1024"` (avec guillemets, donc une chaîne de caractères Ruby) au lieu de `vb.memory = 1024` (un entier Ruby natif) peut poser problème selon ce que la méthode `memory=` attend strictement en interne : si VirtualBox/Vagrant attend explicitement une valeur numérique pour configurer la RAM, passer une chaîne pourrait soit être automatiquement convertie sans erreur (selon l'implémentation interne du plugin provider), soit provoquer une erreur de type ou un comportement par défaut/incorrect si aucune conversion implicite n'est prévue — en pratique, il est plus sûr et idiomatique d'utiliser directement l'entier sans guillemets pour ce type de paramètre numérique.

**Corrigé 4.15**
Oui, ces deux instructions sont exécutées dans un ordre garanti : l'ordre d'écriture dans le Vagrantfile (server.sh d'abord, puis deploy.sh). Cet ordre est important dans le projet car certains scripts dépendent du résultat du précédent : par exemple, dans la Partie 2, il faut que K3s soit pleinement installé et opérationnel (typiquement via un script équivalent à server.sh) AVANT de pouvoir déployer les manifestes applicatifs (deploy.sh, qui utiliserait kubectl apply), sinon cette seconde étape échouerait faute de cluster Kubernetes fonctionnel pour la recevoir.

**Corrigé 4.16**
Un espace dans `LOGIN` (par exemple "ankammer 42") provoquerait que `SERVER_NAME` devienne "ankammer 42S", une chaîne contenant un espace. Cela poserait potentiellement problème pour `config.vm.hostname`, car les noms d'hôte (hostnames) au sens des standards réseau (RFC 1123 notamment) n'autorisent généralement pas les espaces — selon le comportement de VirtualBox/Vagrant et du système invité, cela pourrait provoquer une erreur explicite au moment de configurer le hostname, ou un hostname tronqué/déformé silencieusement de façon imprévisible.

**Corrigé 4.17**
En Ruby, deux affectations successives à la même propriété (`config.vm.box = "..."` puis `config.vm.box = "..."` à nouveau) se comportent simplement comme deux instructions séquentielles classiques : la SECONDE affectation écrase purement et simplement la première. La valeur finale réellement utilisée par Vagrant sera donc "generic/alpine319" (la dernière ligne exécutée), la première ligne devenant complètement sans effet, comme si elle n'avait jamais été écrite.

**Corrigé 4.18**
`vb.gui = true` force VirtualBox à afficher la fenêtre graphique de la VM (au lieu du mode headless/sans interface par défaut), permettant de voir littéralement l'écran de démarrage de la VM comme si on était devant un écran physique. Cette option serait utile en débogage pour observer visuellement des problèmes de démarrage très précoces (avant même que SSH ne soit disponible), par exemple des erreurs de boot, des messages kernel bloquants, ou des écrans de login inattendus — des informations qu'on ne peut pas obtenir via les seuls logs texte de Vagrant en mode headless normal.

**Corrigé 4.19**
`config.vm.network "forwarded_port", guest: 80, host: 8080` créerait une redirection de port : toute connexion arrivant sur le port 8080 de la machine HÔTE serait automatiquement transférée vers le port 80 de la VM invitée (typiquement via l'interface NAT). C'est fondamentalement différent de `private_network` qui attribue une IP propre et dédiée à la VM sur un segment réseau séparé permettant une communication bidirectionnelle complète sur tous les ports : le port forwarding ne redirige qu'un port spécifique choisi explicitement, sans donner d'adresse IP distincte ni d'accès complet à la VM comme le ferait un réseau privé dédié.

**Corrigé 4.20**
Cette ligne, placée avant `Vagrant.configure`, définit une variable d'environnement Ruby/système (`ENV['VAGRANT_DEFAULT_PROVIDER']`) qui force Vagrant à utiliser explicitement le provider "virtualbox" par défaut pour toutes les opérations de ce Vagrantfile, même si libvirt est également installé et serait potentiellement choisi par défaut selon l'ordre de priorité interne de Vagrant en l'absence de cette précision. Cela résout l'ambiguïté de provider de façon fiable et explicite, sans nécessiter de passer systématiquement `--provider=virtualbox` manuellement à chaque commande `vagrant up`.

**Corrigé 4.21 (Complétion attendue)**
```ruby
config.vm.define WORKER_NAME do |worker|
  worker.vm.hostname = WORKER_NAME
  worker.vm.network "private_network", ip: WORKER_IP
  worker.vm.provider "virtualbox" do |vb|
    vb.memory = 512
  end
  worker.vm.provision "shell", path: "scripts/worker.sh"
end
```
Les éléments clés attendus : utilisation du bon nom de variable (`WORKER_NAME`, `WORKER_IP`), respect de la structure identique au bloc serveur déjà présent, et fermeture correcte de tous les `end` correspondants (provider, puis define).

**Corrigé 4.22**
Vagrant, face à deux blocs `config.vm.define` utilisant le même nom (`SERVER_NAME` dans les deux cas), va généralement traiter le second bloc comme une RECONFIGURATION supplémentaire de la même VM logique plutôt que de créer deux VMs distinctes portant le même nom (ce qui créerait une ambiguïté de gestion impossible à résoudre). En pratique, les réglages des deux blocs peuvent fusionner ou le second peut écraser certains aspects du premier selon l'ordre et le type de réglage, mais il n'y aura qu'UNE seule VM réelle créée au final, pas deux VMs identiques nommées pareil.

**Corrigé 4.23**
Par défaut (sans `run: "always"`), un script de provisioning shell ne s'exécute qu'UNE SEULE FOIS, lors de la création initiale de la VM (premier `vagrant up`), sauf si on force manuellement sa réexécution via `vagrant provision` ou `vagrant up --provision`. Avec `run: "always"`, le script s'exécuterait à CHAQUE démarrage de la VM (y compris un simple `vagrant up` après un `vagrant halt`), ce qui serait dangereux pour le script `server.sh` du projet car il réinstallerait complètement K3s à chaque redémarrage, potentiellement en écrasant un cluster déjà fonctionnel et configuré, perdant l'état accumulé (pods déployés, configuration personnalisée) à chaque simple redémarrage de routine de la VM.

**Corrigé 4.24**
Deux scripts de provisioning distincts sont exécutés pour cette VM : d'abord le script externe `scripts/worker.sh` (via `path:`), puis la commande inline `echo Done` (via `inline:`). Oui, ils sont exécutés dans l'ordre d'écriture dans le Vagrantfile : d'abord le premier `provision` rencontré dans le fichier, puis le second, de façon strictement séquentielle, jamais en parallèle ou dans un ordre différent.

**Corrigé 4.25**
La RAM finale réellement allouée à la VM sera 1024 Mo, car c'est la DERNIÈRE affectation à `vb.memory` dans le bloc qui prévaut, écrasant simplement la valeur précédente (512) comme toute affectation séquentielle classique en Ruby — exactement le même principe que pour `config.vm.box` vu dans l'exercice 4.17.

**Corrigé 4.26 (Prédiction de comportement)**
Ce Vagrantfile définit deux VMs distinctes (machineA et machineB) qui utilisent toutes les deux EXACTEMENT la même adresse IP (192.168.56.100) pour leur réseau private_network. Lors de l'exécution de `vagrant up`, Vagrant créera probablement les deux VMs sans erreur de syntaxe ou de configuration immédiate (Vagrant ne valide pas nécessairement ce conflit au moment du parsing), mais au démarrage effectif et à la configuration réseau, un conflit d'adresse IP se produira sur le réseau privé partagé : les deux machines tenteront de répondre pour la même IP, provoquant des comportements réseau imprévisibles (paquets perdus, accès intermittent et erratique à l'une ou l'autre VM, possibles messages d'avertissement ARP dans les logs système), sans qu'aucune des deux VMs ne soit fiable pour communiquer via cette IP commune.

**Corrigé 4.27**
`vb.customize` permet d'invoquer directement des commandes `VBoxManage` personnalisées et avancées, non couvertes par les méthodes Vagrant de haut niveau habituelles (`vb.name`, `vb.memory`...). Ici, `["modifyvm", :id, "--name", SERVER_NAME]` équivaut à exécuter `VBoxManage modifyvm <id_de_la_vm> --name <SERVER_NAME>` en ligne de commande. Le symbole spécial `:id` est remplacé AUTOMATIQUEMENT par Vagrant, au moment de l'exécution réelle, par l'identifiant unique (UUID) effectivement attribué à cette VM précise dans VirtualBox — une valeur qui n'est connue qu'au runtime et ne peut pas être écrite en dur dans le Vagrantfile à l'avance.

**Corrigé 4.28**
Oui, c'est une syntaxe parfaitement valide en Ruby/Vagrant : chaque bloc `define` peut effectivement définir sa propre valeur de `box` indépendamment, sans nécessiter de valeur globale commune via `config.vm.box`. La conséquence sur la cohérence du cluster K3s prévu ensuite peut être significative : utiliser deux versions différentes d'Alpine Linux (3.17 pour le serveur, 3.19 pour le worker) introduit potentiellement des différences de versions de paquets système, de noyau, ou de comportement subtil entre les deux machines, ce qui n'est généralement pas souhaitable pour la cohérence et la prévisibilité d'un cluster où l'on s'attend à un environnement système homogène entre le control plane et les workers.

**Corrigé 4.29 (Détection de toutes les erreurs)**
1. `WORKER_NAME = "#{LOGIN}SW` — guillemet de fermeture manquant à la fin de cette ligne (chaîne non terminée), provoquant une erreur de syntaxe Ruby immédiate.
2. Dans le bloc `define SERVER_NAME`, il manque un `end` pour fermer le bloc `server.vm.provider "virtualbox" do |vb| ... end` avant la fermeture du bloc `define` lui-même (un seul `end` visible après `vb.cpus = 1` ferme potentiellement le provider, mais il en manque alors un second pour fermer le `define SERVER_NAME` avant que `config.vm.define WORKER_NAME` ne commence).
3. Erreur de structure générale : avec les deux erreurs précédentes cumulées, le fichier entier devient syntaxiquement invalide et Ruby ne pourra même pas commencer à l'analyser correctement, Vagrant refusant tout simplement de s'exécuter.

**Corrigé 4.30 (Synthèse — explication ligne par ligne)**
Les variables `LOGIN`, `SERVER_NAME`, `WORKER_NAME`, `SERVER_IP`, `WORKER_IP` sont définies en constantes Ruby globales au fichier, permettant de centraliser la configuration et d'éviter la répétition de valeurs en dur. `Vagrant.configure("2") do |config|` ouvre le bloc de configuration principal avec l'API version 2. `config.vm.box = "generic/alpine317"` définit Alpine 3.17 comme image de base, choisie pour sa légèreté adaptée aux contraintes de ressources du projet. `config.vm.box_check_update = false` évite une vérification réseau systématique à chaque lancement, gagnant en fiabilité et rapidité. `config.vm.synced_folder ".", "/vagrant", type: "virtualbox"` est déclaré au niveau GLOBAL pour garantir que TOUTES les VMs définies ensuite (serveur ET worker) héritent correctement du dossier partagé, corrigeant le bug observé quand cette déclaration était absente ou mal placée. `config.vm.provision "shell", path: "scripts/common.sh"` exécute un script commun à toutes les VMs avant les provisionings spécifiques. Le bloc `define SERVER_NAME` configure le hostname, le réseau privé avec IP fixe .110, alloue 2048 Mo de RAM et 2 CPU (volume augmenté suite au débogage face aux lenteurs SQL de K3s récent), puis exécute `server.sh`. Le bloc `define WORKER_NAME` suit une logique similaire avec l'IP .111, mais avec des ressources moindres (1024 Mo, 1 CPU) car le worker n'héberge pas le Control Plane et a des besoins plus légers, puis exécute `worker.sh`. Chaque choix de ressource reflète les leçons tirées du débogage réel du projet (notamment l'augmentation de RAM nécessaire pour éviter les lenteurs SQL observées avec K3s v1.35 sur des VMs trop légères initialement).

---

*Fin du corrigé de la Partie 4 (Vagrantfile/Ruby). Le corrigé de la Partie 5 (Réseau) suit.*
# CORRIGÉ PARTIE 5 — RÉSEAU

## Section 5.A — Calculs CIDR et sous-réseaux

**Corrigé 5.1**
`/8` = `255.0.0.0` ; `/16` = `255.255.0.0` ; `/24` = `255.255.255.0` ; `/25` = `255.255.255.128` ; `/30` = `255.255.255.252`.
Méthode : chaque tranche de 8 bits à 1 donne 255 dans l'octet correspondant ; pour /25, le 25ème bit tombe dans le 4ème octet (8+8+8=24, donc 1 bit supplémentaire dans le 4ème octet = 128) ; pour /30, 24+6=30, donc 6 bits à 1 dans le 4ème octet = 11111100 = 252.

**Corrigé 5.2**
Adresse réseau : `192.168.56.0`. Adresse de broadcast : `192.168.56.255`. Plage d'adresses utilisables : `192.168.56.1` à `192.168.56.254` (254 adresses).
Méthode : avec un masque /24, les 3 premiers octets désignent le réseau (192.168.56), le dernier octet varie de 0 (réseau) à 255 (broadcast), les valeurs intermédiaires (1 à 254) sont utilisables pour des hôtes.

**Corrigé 5.3**
Un `/26` laisse 32-26 = 6 bits pour la partie hôte, soit 2^6 = 64 adresses totales, moins 2 (réseau et broadcast) = **62 adresses hôtes utilisables**.

**Corrigé 5.4**
Oui, ces deux adresses appartiennent au même sous-réseau /24. Calcul : avec un masque /24 (255.255.255.0), seul le dernier octet varie au sein du même réseau ; 192.168.56.110 et 192.168.56.111 partagent les mêmes 3 premiers octets (192.168.56), donc la même adresse réseau (192.168.56.0/24) — elles sont bien voisines sur le même segment.

**Corrigé 5.5**
Avec un masque /29, 32-29 = 3 bits pour la partie hôte, donc des blocs de 2^3 = 8 adresses. Les blocs /29 dans le 4ème octet se découpent ainsi : 0-7, 8-15, ..., 104-111, 112-119... L'adresse .110 appartient au bloc 104-111 (réseau 192.168.56.104/29, broadcast 192.168.56.111). L'adresse .111 appartient ÉGALEMENT à ce même bloc 104-111. Donc oui, .110 et .111 restent dans le MÊME sous-réseau même avec un /29 plus restrictif, car elles tombent dans le même intervalle de 8 adresses.

**Corrigé 5.6**
Découper un /24 en 4 sous-réseaux égaux nécessite d'ajouter 2 bits au préfixe (2^2=4 sous-réseaux), donnant un préfixe /26 pour chaque sous-réseau résultant. Les 4 sous-réseaux de `10.0.0.0/24` découpé en /26 sont :
- `10.0.0.0/26` (plage .0 à .63)
- `10.0.0.64/26` (plage .64 à .127)
- `10.0.0.128/26` (plage .128 à .191)
- `10.0.0.192/26` (plage .192 à .255)

**Corrigé 5.7**
32-30 = 2 bits pour la partie hôte, soit 2^2 = 4 adresses totales, moins 2 (réseau et broadcast) = **2 adresses hôtes utilisables**. Ce préfixe est classiquement utilisé pour des liaisons point-à-point car exactement 2 adresses suffisent pour les deux extrémités de la liaison (par exemple deux routeurs reliés directement), sans gaspiller des adresses supplémentaires inutiles comme le ferait un masque plus large.

**Corrigé 5.8**
Non, ce n'est pas une adresse IPv4 valide. Chaque octet d'une adresse IPv4 doit être compris entre 0 et 255 inclus ; 256 dépasse cette limite (un octet ne peut représenter au maximum que 2^8-1 = 255 en valeur décimale).

**Corrigé 5.9**
192 = 11000000 ; 168 = 10101000 ; 56 = 00111000 ; 110 = 01101110.
Donc 192.168.56.110 en binaire complet : `11000000.10101000.00111000.01101110`.

**Corrigé 5.10**
Pour un /22, 32-22 = 10 bits pour la partie hôte, donc des blocs de 2^10 = 1024 adresses. Dans le 3ème octet (où le découpage /22 se produit, car 22 = 16+6, donc 6 bits dans le 3ème octet réservés au réseau, 2 bits restants + le 4ème octet entier pour les hôtes), les blocs de réseau se répètent par paliers de 4 dans le 3ème octet (1024/256=4). Pour 172.16.5.200/22 : le 3ème octet est 5, qui appartient au bloc [4-7] (puisque les paliers sont 0-3, 4-7, 8-11...). L'adresse réseau résultante est donc `172.16.4.0/22`.

**Corrigé 5.11**
Non, l'adresse `192.168.56.0` ne peut pas être attribuée à une machine hôte dans ce sous-réseau /24. Cette adresse, avec tous les bits de la partie hôte à 0, est réservée pour désigner le réseau lui-même (l'adresse réseau), pas une machine spécifique — c'est une convention universelle du protocole IP.

**Corrigé 5.12**
La plage de classe C des adresses privées RFC 1918 est `192.168.0.0` à `192.168.255.255`, généralement représentée par le préfixe CIDR `192.168.0.0/16` pour couvrir l'ensemble de cette plage en une seule notation.

**Corrigé 5.13**
Un préfixe /32 signifie que les 32 bits de l'adresse IPv4 (la totalité) sont réservés à la partie réseau, ne laissant aucun bit pour la partie hôte (2^0 = 1 seule adresse possible). C'est donc une façon de désigner exactement et uniquement UNE adresse IP précise, sans aucune notion de "réseau" au sens habituel avec plage d'hôtes — utile notamment pour des règles de routage ou de filtrage ciblant une machine unique de façon exacte.

**Corrigé 5.14**
Cette erreur signifie que la plage configurée pour le réseau host-only (`192.168.56.0/24`) sur l'HÔTE n'est pas (ou plus) déclarée comme autorisée dans la configuration système de VirtualBox concernant les réseaux host-only acceptés. Depuis certaines versions de VirtualBox (6.1.28+), un fichier de configuration (`/etc/vbox/networks.conf` sur Linux) doit explicitement lister les plages d'adresses autorisées pour ce type de réseau, par mesure de sécurité ; sans cette déclaration, VirtualBox refuse de créer ou configurer le réseau host-only avec cette plage, même si elle est tout à fait valide en tant qu'adresse privée RFC 1918.

**Corrigé 5.15**
32-27 = 5 bits pour la partie hôte au sein de chaque sous-réseau /27, donc 2^5 = 32 adresses par sous-réseau. Un bloc /24 contient 256 adresses au total. Le nombre de sous-réseaux /27 possibles dans un /24 est donc 256/32 = **8 sous-réseaux /27**.

---

## Section 5.B — Vagrant et types de réseaux

**Corrigé 5.16**
```
[Machine hôte]
      |
      | (interface réseau host-only virtuelle, ex: vboxnet0)
      | IP hôte sur ce réseau : souvent 192.168.56.1
      |
[Switch virtuel VirtualBox - réseau private_network]
      |
      | (interface réseau eth1 de la VM)
      |
[VM ankammerS - IP: 192.168.56.110]
```
Le paquet part de l'interface réseau virtuelle créée par VirtualBox sur l'hôte (souvent nommée vboxnet0 ou similaire), transite par le "switch" virtuel interne au réseau host-only, et arrive directement sur l'interface réseau secondaire de la VM configurée avec l'IP 192.168.56.110 — sans passer par Internet ni aucun routeur physique, le tout restant confiné dans la couche de virtualisation de VirtualBox sur la machine hôte.

**Corrigé 5.17**
```
[VM Vagrant - interface NAT (eth0), IP interne 10.0.2.15]
      |
      | (traduction NAT effectuée par VirtualBox)
      |
[Machine hôte - interface réseau physique/Wi-Fi]
      |
      | (routage normal via la gateway du réseau de l'hôte)
      |
[Routeur / Box Internet]
      |
[Internet - serveur get.k3s.io]
```
Le paquet sortant de la VM via son interface NAT (typiquement adressée en 10.0.2.15 par convention VirtualBox) est intercepté par le mécanisme NAT de VirtualBox, qui le traduit pour qu'il semble provenir de l'adresse IP réelle de la machine hôte sur le réseau physique, permettant ainsi au paquet de transiter normalement à travers le routeur de l'hôte jusqu'à Internet, exactement comme si la requête venait de la machine hôte elle-même.

**Corrigé 5.18**
La VM possède deux adresses IP distinctes car elle a deux interfaces réseau virtuelles configurées simultanément par Vagrant/VirtualBox : une interface NAT (créée automatiquement par défaut, généralement adressée en 10.0.2.15) pour l'accès sortant à Internet, et une interface private_network (explicitement déclarée dans le Vagrantfile, avec l'IP fixe 192.168.56.110 par exemple) pour la communication isolée avec l'hôte et les autres VMs du même réseau privé.

**Corrigé 5.19**
Non, le script échouerait probablement, car `curl https://get.k3s.io` nécessite un accès à Internet pour télécharger le script d'installation et le binaire K3s depuis les serveurs GitHub/K3s. Sans l'interface NAT (qui fournit cet accès sortant à Internet), seule resterait l'interface private_network qui, par définition, isole délibérément la VM d'Internet pour ne permettre la communication qu'avec l'hôte et les autres VMs du même segment privé — aucun chemin réseau ne permettrait alors d'atteindre les serveurs externes nécessaires au téléchargement de K3s.

**Corrigé 5.20**
Tant que les deux VMs ne tournent jamais simultanément (l'une est arrêtée/détruite avant que l'autre ne démarre), il n'y a aucun conflit possible car une seule VM à la fois occupe réellement cette adresse sur le réseau virtuel actif à un instant donné. Si elles tournaient simultanément, un conflit d'adresse IP se produirait exactement comme dans le cas de deux VMs définies dans le même Vagrantfile avec la même IP : comportements réseau imprévisibles, réponses ARP contradictoires, accès intermittent et non fiable à l'une ou l'autre des deux machines partageant cette même adresse.

**Corrigé 5.21**
```
                    [Machine hôte]
                          |
          (réseau private_network 192.168.56.0/24)
                          |
        +-----------------+-----------------+
        |                                   |
   [ankammerS]                       [ankammerSW]
   IP: 192.168.56.110                IP: 192.168.56.111
   Rôle: K3s server                  Rôle: K3s agent
   (Control Plane + API)             (Worker node)
        |                                   |
        +------- communication directe -----+
              (notamment port 6443)
```

**Corrigé 5.22**
On le qualifie de "host-only" car, par défaut et sans configuration supplémentaire, ce type de réseau isole complètement les VMs et l'hôte de tout réseau externe (notamment Internet) — le terme "host-only" souligne cette restriction à l'hôte et son écosystème de VMs associées, par opposition à un accès plus large. Le fait qu'il permette AUSSI la communication inter-VMs (pas seulement avec l'hôte) est une extension naturelle de ce même réseau isolé : toutes les machines connectées à ce segment privé (hôte ET VMs) peuvent se voir mutuellement, ce qui ne contredit pas son caractère "host-only" au sens d'isolation du monde extérieur.

**Corrigé 5.23**
Sur Linux, la commande `ip addr show` (ou `ifconfig` historiquement) permet de lister toutes les interfaces réseau de la machine hôte, incluant l'interface virtuelle créée par VirtualBox pour le réseau host-only (souvent nommée vboxnet0 ou similaire), confirmant ainsi son existence et son adressage sur le système.

**Corrigé 5.24**
Le fichier à modifier sur Linux est `/etc/vbox/networks.conf`, qui doit contenir une ligne déclarant explicitement la plage d'adresses autorisée, par exemple `* 192.168.56.0/21` (ou une plage plus large englobant celle utilisée), afin que VirtualBox accepte de créer ou configurer un réseau host-only utilisant cette plage d'IP spécifique sans la rejeter pour des raisons de sécurité par défaut introduites dans les versions récentes du logiciel.

**Corrigé 5.25**
On choisit `private_network` plutôt que `public_network` car le projet nécessite un environnement isolé, prévisible et reproductible : `private_network` garantit des IPs fixes connues à l'avance, sans dépendre de la configuration du réseau physique réel de l'utilisateur (qui pourrait varier selon où la VM est exécutée), et n'expose jamais directement le cluster K3s au réseau local physique ou à Internet, ce qui correspond davantage à un contexte d'apprentissage contrôlé et sécurisé, conforme à l'esprit pédagogique du sujet qui ne demande à aucun moment une exposition réseau publique du cluster.

---

## Section 5.C — Détection d'erreurs de configuration

**Corrigé 5.26**
Le serveur (192.168.56.110/24) et le worker (192.168.57.111/24) appartiennent à deux sous-réseaux DIFFÉRENTS (192.168.56.0/24 contre 192.168.57.0/24), bien qu'ils semblent superficiellement proches en notation décimale. Sans route explicite entre ces deux sous-réseaux distincts (ce qui n'est généralement pas configuré automatiquement par Vagrant dans ce contexte simple), la communication directe échoue, expliquant pourquoi le worker ne peut jamais joindre l'API du serveur sur le port 6443 malgré l'absence d'erreur au démarrage des VMs elles-mêmes (qui démarrent indépendamment du succès de cette communication réseau ultérieure).

**Corrigé 5.27**
Oui, cela pose potentiellement un problème, bien que le symptôme exact dépende du contexte précis. Un masque différent change la perception qu'a CHAQUE machine de l'étendue de "son" réseau local : le serveur avec /24 considère son réseau local comme 192.168.56.0-255, tandis que le worker avec /16 considère son réseau local comme bien plus large (192.168.0.0-192.168.255.255). Dans ce cas précis, comme les deux adresses tombent bien dans les deux interprétations de réseau local respectives, la communication directe a des chances de fonctionner malgré l'incohérence, mais cette configuration reste une mauvaise pratique risquée pouvant provoquer des comportements de routage incohérents dans des scénarios plus complexes (plusieurs sous-réseaux, présence de routeurs intermédiaires).

**Corrigé 5.28**
Au moins 3 causes possibles distinctes : (1) le service K3s n'est tout simplement pas démarré ou a planté sur le serveur (`rc-service k3s status` le confirmerait) ; (2) K3s est démarré mais écoute uniquement sur une interface différente de celle attendue (par exemple 127.0.0.1 au lieu de 192.168.56.110, visible via `ss -tlnp | grep 6443`) suite à un argument `--bind-address` incorrect ou absent à l'installation ; (3) un pare-feu (sur l'hôte ou dans la VM) bloque spécifiquement les connexions entrantes sur le port 6443 malgré que le service écoute correctement sur la bonne interface.

**Corrigé 5.29**
Avec ces variables inversées, le script worker va tenter de se connecter à `K3S_URL="https://192.168.56.111:6443"` (qu'il croit être le "serveur" alors que c'est en réalité sa propre IP supposée), pendant que l'IP qu'il s'attribue lui-même via `--node-ip` sera 192.168.56.110 (qu'il croit être sa propre IP, mais qui est en réalité celle du véritable serveur). Le worker tentera donc de rejoindre un cluster à sa propre adresse (qui n'a pas d'API K3s en écoute puisque c'est censé être lui-même), provoquant un échec de connexion (timeout ou connection refused) lors de la tentative de jonction, sans jamais réussir à rejoindre le véritable cluster.

**Corrigé 5.30**
Le port 6444 n'étant pas celui sur lequel l'API K3s écoute réellement (6443 par défaut), toute tentative de connexion sur ce port échouera avec une erreur de type "Connection refused" (le système répond explicitement qu'aucun service n'écoute sur ce port précis à cette adresse), distincte d'un timeout réseau pur — c'est une erreur immédiate et claire plutôt qu'un blocage silencieux, facilitant en théorie le diagnostic si l'on prête attention au message d'erreur exact retourné.

**Corrigé 5.31**
K3s, dans ce cas, n'écoute que sur l'interface loopback (127.0.0.1), pas sur l'interface réseau privée attendue (192.168.56.110). Cela signifie typiquement que le paramètre `--bind-address` (et potentiellement `--advertise-address`) n'a pas été correctement transmis à l'installation de K3s — exactement le bug rencontré dans le débogage réel du projet quand le pipe `INSTALL_K3S_EXEC="..." sh -` était cassé par un retour à la ligne mal placé, empêchant ces arguments de jamais atteindre effectivement la commande d'installation, K3s utilisant alors ses valeurs par défaut (souvent localhost uniquement pour certains contextes).

**Corrigé 5.32**
Le réseau private_network de VirtualBox (192.168.56.0/24) est un réseau VIRTUEL, entièrement interne et isolé, géré exclusivement par l'hyperviseur sur la machine où tournent les VMs. Il n'a aucune existence ni visibilité sur le réseau Wi-Fi physique domestique (192.168.1.0/24) : ce sont deux réseaux totalement distincts et non reliés entre eux par défaut, le téléphone connecté au Wi-Fi domestique ne pouvant donc absolument pas atteindre une adresse appartenant à ce réseau virtuel isolé, qui n'existe que dans le contexte de virtualisation sur cet ordinateur précis.

**Corrigé 5.33**
Le port 6443 (>1024) étant explicitement supérieur à 1024, cette règle de pare-feu hypothétique le bloquerait par défaut, empêchant toute connexion entrante sur ce port sauf si une exception explicite était ajoutée pour ce port précis (ou pour la plage incluant 6443). Cela empêcherait concrètement le worker de joindre l'API du serveur, peu importe que K3s soit parfaitement bien configuré et en écoute sur la bonne interface — le pare-feu intercepterait et rejetterait la connexion avant même qu'elle n'atteigne le service K3s.

**Corrigé 5.34**
Avec un masque /25 sur la base 192.168.56.0, le réseau est découpé en deux blocs de 128 adresses chacun : 192.168.56.0-127 (premier /25) et 192.168.56.128-255 (second /25). L'IP 192.168.56.200 appartient clairement au SECOND bloc (128-255), pas au premier bloc évoqué (0-127) dans l'énoncé — si le worker était censé appartenir au même /25 que défini (0-127), alors 192.168.56.200 est invalide pour ce sous-réseau précis car elle dépasse la plage autorisée de ce bloc spécifique.

**Corrigé 5.35**
Au-delà du conflit d'IP basique, une adresse MAC dupliquée peut provoquer une confusion supplémentaire au niveau de la couche 2 du modèle réseau (liaison de données) : les tables ARP (qui associent IP à adresse MAC) des autres machines du réseau peuvent devenir incohérentes ou changer constamment de cible, le switch virtuel peut avoir des difficultés à déterminer où envoyer réellement les trames destinées à cette MAC, provoquant des pertes de paquets ou des routages erratiques encore plus difficiles à diagnostiquer qu'un simple conflit d'IP au niveau 3 (réseau) seul.

---

## Section 5.D — DNS, DHCP, TCP/UDP

**Corrigé 5.36**
Le navigateur tenterait d'abord de résoudre "app1.com" via DNS, en interrogeant les serveurs DNS configurés sur le système (typiquement ceux du fournisseur d'accès Internet ou un service public comme 8.8.8.8). Comme "app1.com" est un nom de domaine fictif inventé pour ce projet, non enregistré dans le système DNS mondial réel, cette résolution échouerait avec une erreur du type "Ce site est inaccessible" ou "DNS_PROBE_FINISHED_NXDOMAIN", car aucune adresse IP ne serait jamais retournée pour ce nom de domaine — le navigateur ne saurait simplement pas où envoyer la requête.

**Corrigé 5.37**
`curl -H "Host:app1.com" http://192.168.56.110` fonctionne car curl reçoit explicitement l'adresse IP de destination (192.168.56.110) en argument direct, contournant ainsi totalement le besoin d'une résolution DNS préalable — aucune traduction nom-vers-IP n'est nécessaire puisque l'IP est déjà fournie. L'en-tête `Host` est simplement injecté manuellement dans la requête HTTP envoyée à cette IP, sans lien avec le mécanisme de résolution DNS qu'un navigateur effectuerait normalement avant même de connaître quelle IP contacter.

**Corrigé 5.38**
Il faudrait ajouter une ligne dans `/etc/hosts` (sur la machine hôte, pas dans la VM) associant manuellement le nom de domaine fictif à l'IP réelle de l'Ingress, par exemple : `192.168.56.110 app1.com`. Cette entrée locale ferait que le système, avant même d'interroger un serveur DNS externe, trouverait cette correspondance directement dans ce fichier local et résoudrait "app1.com" vers 192.168.56.110, permettant alors au navigateur de fonctionner exactement comme si un vrai enregistrement DNS existait pour ce domaine.

**Corrigé 5.39**
CoreDNS est le serveur DNS interne déployé par défaut dans K3s, chargé de résoudre les noms de Services (et d'autres ressources) internes au cluster vers leur ClusterIP correspondante. Pour un Service nommé "app-one" dans le namespace "default", le nom DNS interne complet généré automatiquement serait `app-one.default.svc.cluster.local`, résolvable depuis n'importe quel pod du cluster ayant la configuration DNS standard de Kubernetes pointant vers CoreDNS.

**Corrigé 5.40**
Le sujet impose des adresses IP FIXES et connues à l'avance (192.168.56.110 et .111) précisément pour garantir la reproductibilité et la prévisibilité de la configuration, permettant aux scripts d'automatisation de référencer ces adresses de façon fiable. DHCP, qui attribue dynamiquement des adresses potentiellement différentes à chaque redémarrage ou selon l'ordre de démarrage des machines, casserait cette prévisibilité essentielle au bon fonctionnement des scripts (K3S_URL devrait alors être déterminé dynamiquement, ajoutant une complexité inutile et un risque d'erreur pour ce contexte pédagogique).

**Corrigé 5.41**
Un exemple classique est le streaming vidéo en direct ou les jeux en ligne en temps réel : dans ces contextes, perdre occasionnellement un petit paquet de données (causant un léger artefact visuel ou un micro-lag) est largement préférable à la latence supplémentaire qu'imposerait TCP pour garantir et retransmettre chaque paquet perdu — la rapidité et la fluidité globale sont privilégiées par rapport à une fiabilité absolue de chaque paquet individuel, ce qui correspond exactement aux forces d'UDP (rapide, sans overhead de connexion ni de retransmission automatique).

**Corrigé 5.42**
HTTPS (qui encapsule HTTP avec TLS) nécessite un canal de communication fiable et ordonné pour garantir l'intégrité du contenu chiffré échangé, ainsi qu'un véritable dialogue bidirectionnel structuré (négociation TLS, requête, réponse) — c'est exactement ce que TCP fournit nativement via son handshake initial. UDP, sans connexion ni garantie d'ordre ou de livraison, ne convient pas à ce besoin : un paquet TLS perdu ou désordonné corromprait potentiellement toute la session chiffrée sans mécanisme natif de récupération, contrairement à TCP qui gère cela de façon transparente et automatique.

**Corrigé 5.43**
Cette affirmation est techniquement incorrecte car `ping` utilise le protocole ICMP, totalement distinct et indépendant du protocole TCP utilisé pour les connexions applicatives réelles sur un port spécifique comme 6443. Un `ping` réussi prouve seulement que la machine répond aux requêtes ICMP, ce qui ne garantit absolument rien sur l'état d'ouverture ou de fermeture d'un port TCP particulier — ICMP et TCP sont gérés par des règles de pare-feu et des mécanismes complètement séparés.

**Corrigé 5.44**
Une résolution DNS réussie mais un service inaccessible signifie que le nom de domaine a bien été traduit correctement en une adresse IP, mais que la connexion à cette IP (sur le port concerné) échoue ensuite pour une raison distincte (service arrêté, pare-feu, mauvais port). Un échec de résolution DNS pur signifie que le système n'a même pas pu déterminer QUELLE adresse IP contacter en premier lieu, le processus échouant donc à une étape bien antérieure, avant même la moindre tentative de connexion réseau effective vers un service quelconque.

**Corrigé 5.45**
Aucune configuration DNS n'est nécessaire car Traefik examine directement le CONTENU de la requête HTTP déjà reçue (l'en-tête Host explicitement inclus dans les données envoyées par curl), plutôt que de devoir lui-même résoudre un nom de domaine pour savoir où router. Le client (curl) a déjà fourni l'adresse IP de destination directement en argument et a injecté manuellement l'en-tête Host souhaité dans sa requête : Traefik n'a donc besoin que de lire ce contenu déjà présent dans le paquet reçu, sans avoir à effectuer lui-même une quelconque résolution DNS pour accomplir son rôle de routage applicatif.

---

## Section 5.E — Schémas et architecture réseau

**Corrigé 5.46**
```
[Machine hôte]
   localhost:8080 -----> [k3d-loadbalancer (Traefik)] -----> port 80 interne
   localhost:8443 -----> [k3d-loadbalancer (Traefik)] -----> port 443 interne
        |
   [Docker Engine]
        |
   +----+----+--------------------+
   |              |                |
[k3d-server-0]  [k3d-agent-0]   [autres agents...]
(Control Plane) (Worker)
```
Le trafic entrant sur la machine hôte (ports 8080/8443) est intercepté par le conteneur load balancer de K3d, qui le redirige ensuite vers les conteneurs server/agent appropriés à l'intérieur du réseau Docker interne créé spécifiquement pour ce cluster K3d.

**Corrigé 5.47**
```
curl -H "Host:app2.com" http://192.168.56.110
        |
        v
[Traefik Ingress Controller] -- lit le Host header --> règle "app2.com"
        |
        v
[Service app-two (ClusterIP)]
        |
   (répartition de charge entre les 3 pods correspondant au selector)
        |
   +----+----+----+
   |         |         |
[Pod 1]   [Pod 2]   [Pod 3]
(un seul de ces 3 pods traite réellement CETTE requête précise)
```

**Corrigé 5.48**
```
[Machine hôte] ---(réseau private_network 192.168.56.0/24)---
        |
        +--- [ankammerS]  IP: 192.168.56.110    rôle: K3s server (Control Plane)
        |
        +--- [ankammerSW] IP: 192.168.56.111    rôle: K3s agent (Worker)
```

**Corrigé 5.49**
Pour que K3s fonctionne pleinement, il manque a minima une flèche de communication continue du SERVEUR vers le WORKER également (pas uniquement worker vers serveur), notamment pour les opérations du kubelet recevant des instructions, ainsi que potentiellement le port 10250 (kubelet API) utilisé par le serveur/API pour communiquer directement avec le kubelet de chaque worker (par exemple pour `kubectl logs` ou `kubectl exec` qui établissent une connexion directe vers le kubelet du nœud concerné, pas seulement vers l'API centrale).

**Corrigé 5.50**
```
PARTIE 1 (VMs séparées) :
[Hôte] --(réseau virtuel)--> [VM1: VirtualBox/hyperviseur]--(noyau complet)--[K3s server]
                         --> [VM2: VirtualBox/hyperviseur]--(noyau complet)--[K3s agent]
   Sauts: hôte -> hyperviseur -> noyau invité -> K3s (à CHAQUE machine, dupliqué)

PARTIE 3 (K3d/Docker) :
[Hôte] --(Docker Engine, noyau hôte partagé)--> [Conteneur server: K3s]
                                              --> [Conteneur agent: K3s]
   Sauts: hôte -> Docker (espace utilisateur seulement) -> K3s (noyau PARTAGÉ, pas dupliqué)
```
La Partie 3 nécessite moins de "sauts" car les conteneurs partagent directement le même noyau Linux que l'hôte (pas de noyau invité séparé à traverser pour chaque "nœud"), contrairement à la Partie 1 où chaque VM embarque et traverse son propre noyau complet et indépendant, ajoutant une couche d'indirection supplémentaire à chaque machine virtuelle.

---

*Fin du corrigé de la Partie 5 (Réseau). Le corrigé de la Partie 6 (Kubernetes/K3s) suit.*
# CORRIGÉ PARTIE 6 — KUBERNETES / K3S

## Section 6.A — Architecture et composants

**Corrigé 6.1**
API Server : point d'entrée REST unique pour toutes les opérations sur le cluster. etcd/SQLite : stockage persistant de l'état complet du cluster. Scheduler : décide sur quel nœud placer chaque nouveau pod. Controller Manager : exécute les boucles de contrôle qui maintiennent l'état réel conforme à l'état désiré.

**Corrigé 6.2**
kubectl communique exclusivement avec l'API Server via des requêtes HTTP/REST authentifiées ; il n'établit jamais de connexion directe vers les pods eux-mêmes. Même des commandes qui semblent interagir directement avec un pod (`kubectl exec`, `kubectl logs`) passent en réalité par l'API Server, qui relaie ensuite la demande au kubelet du nœud concerné, qui lui-même interagit avec le conteneur runtime pour exécuter l'action demandée sur le pod.

**Corrigé 6.3**
K3s n'installe pas etcd par défaut car c'est un composant relativement lourd en ressources (RAM/CPU/disque), pensé pour des clusters de production à grande échelle avec haute disponibilité multi-master. K3s utilise SQLite par défaut, une base de données embarquée bien plus légère, suffisante pour les cas d'usage visés (apprentissage, edge computing, petits clusters single-node ou peu de nœuds) — etcd reste néanmoins disponible en option si l'on configure explicitement K3s pour un déploiement HA multi-serveurs.

**Corrigé 6.4**
Le kubelet tourne potentiellement sur N'IMPORTE QUEL nœud, y compris celui du Control Plane, pas exclusivement sur les workers. Dans la Partie 1 du projet avec une seule VM serveur, cette même machine assume à la fois le rôle de Control Plane ET héberge effectivement des pods système (CoreDNS, Traefik, metrics-server...), ce qui est confirmé en observant que `kubectl get nodes` montre ce nœud avec le rôle `control-plane,master` mais qu'il exécute bel et bien des pods système visibles via `kubectl get pods -n kube-system -o wide`.

**Corrigé 6.5**
Le Scheduler décide UNIQUEMENT du placement initial (sur quel nœud lancer un nouveau pod), une décision ponctuelle prise au moment de la création. Le Controller Manager, lui, surveille en CONTINU l'état du cluster à travers plusieurs boucles de contrôle indépendantes (ReplicaSet Controller, Node Controller, etc.), corrigeant automatiquement les écarts détectés au fil du temps (recréer un pod manquant, détecter un nœud devenu indisponible) — le Scheduler décide UNE FOIS où placer, le Controller Manager surveille et corrige EN PERMANENCE après coup.

**Corrigé 6.6**
Non, les pods déjà en cours d'exécution sur les workers continuent normalement de fonctionner même si l'API Server tombe temporairement en panne, car le kubelet de chaque nœud gère localement le cycle de vie des conteneurs déjà lancés indépendamment de la disponibilité immédiate de l'API. Cependant, aucune NOUVELLE opération de gestion du cluster ne sera possible pendant cette panne (pas de nouveaux déploiements, pas de mise à jour, pas de détection/correction automatique de nouveaux problèmes), et certaines fonctionnalités dépendant de communications continues avec l'API pourraient progressivement se dégrader.

**Corrigé 6.7**
kube-proxy traduit la définition abstraite d'un Service (un selector de labels et une IP virtuelle) en règles réseau CONCRÈTES et effectivement appliquées sur chaque nœud (typiquement via iptables ou IPVS), qui déterminent réellement comment le trafic destiné à cette IP virtuelle de Service est redirigé vers l'un des pods réels correspondants. Sans kube-proxy, l'objet Service existerait dans l'API mais n'aurait aucune implémentation réseau effective, le rendant inopérant en pratique.

**Corrigé 6.8**
Un Container Runtime est le logiciel responsable de l'exécution effective des conteneurs (téléchargement des images, création des namespaces/cgroups Linux, démarrage/arrêt des processus conteneurisés), communiquant avec le kubelet via l'interface standardisée CRI (Container Runtime Interface). K3s utilise par défaut **containerd**, un runtime léger et largement adopté dans l'écosystème Kubernetes moderne.

**Corrigé 6.9**
Regrouper les composants en un seul binaire réduit drastiquement l'empreinte mémoire/disque globale (pas de duplication de bibliothèques partagées entre plusieurs processus séparés), simplifie l'installation et la maintenance (un seul binaire à télécharger, démarrer, mettre à jour), et facilite le déploiement sur des environnements aux ressources contraintes (edge, IoT, Raspberry Pi) où K3s vise spécifiquement à être performant, contrairement à Kubernetes standard qui distribue ces composants en processus séparés pour une flexibilité et une scalabilité accrues adaptées aux grands clusters de production.

**Corrigé 6.10**
Le serveur K3s de la Partie 1 assure simultanément les DEUX rôles : Control Plane ET exécution de pods applicatifs/système. Ceci est confirmé par `kubectl get nodes`, où la colonne ROLES affiche typiquement `control-plane,master` pour ce nœud (signalant son rôle de Control Plane), tout en étant parfaitement capable, comme tout nœud Kubernetes, d'exécuter des pods (sauf configuration explicite de "taint" l'en empêchant), ce qui est le comportement par défaut sur un cluster K3s single-node tel que configuré dans cette partie du projet.

**Corrigé 6.11**
`kubectl get nodes` nécessite que l'API Server soit pleinement opérationnel pour répondre correctement à cette requête. Si le script de provisioning copiait le node-token AVANT que cette commande ne réussisse, cela signifierait que K3s n'a pas encore terminé son démarrage complet (l'API pourrait ne pas être prête, et le fichier de token lui-même pourrait même ne pas encore avoir été généré sur disque), risquant de copier un token absent, incomplet, ou invalide, ce qui ferait échouer la jonction du worker plus tard de façon difficile à diagnostiquer sans cette vérification préalable.

**Corrigé 6.12**
Un Control Plane unique constitue un point de défaillance unique car si cette seule machine tombe en panne (matériel, réseau, crash logiciel), l'ENSEMBLE du cluster perd sa capacité de gestion centrale (plus de nouvelles opérations possibles, plus de détection/correction automatique des problèmes), même si les workers et leurs pods déjà lancés peuvent continuer à fonctionner temporairement. Cela reste acceptable dans un contexte pédagogique car l'objectif est l'apprentissage des concepts fondamentaux de Kubernetes, pas la mise en place d'une infrastructure de production critique nécessitant une haute disponibilité réelle (qui ajouterait une complexité significative sans valeur pédagogique supplémentaire proportionnelle pour ce projet).

---

## Section 6.B — Pods, Deployments, ReplicaSets

**Corrigé 6.13**
Un Pod créé directement n'est pas géré par un contrôleur de plus haut niveau : s'il plante ou est supprimé, RIEN ne le recréera automatiquement, contrairement à un pod géré par un Deployment. En production, on utilise systématiquement un Deployment (ou parfois StatefulSet, DaemonSet selon le besoin), qui garantit la résilience automatique (recréation en cas de panne), permet les mises à jour progressives (rolling update), et le scaling horizontal (changement du nombre de réplicas) — des fonctionnalités essentielles absentes d'un Pod géré manuellement et isolément.

**Corrigé 6.14**
Le Controller Manager, via le ReplicaSet associé au Deployment, détecte lors de sa boucle de réconciliation périodique que le nombre de pods réels (2) est inférieur au nombre désiré (3, défini par `replicas: 3`). Il déclenche alors la création d'un nouveau pod, en utilisant exactement le même `template` (image, configuration) que les pods existants. Le Scheduler assigne ce nouveau pod à un nœud disposant de ressources suffisantes, le kubelet de ce nœud le lance effectivement via le container runtime, et une fois ce nouveau pod opérationnel et Ready, le cluster revient à l'état stable désiré de 3 réplicas en fonctionnement.

**Corrigé 6.15**
Le ReplicaSet est un objet intermédiaire généré et géré AUTOMATIQUEMENT par le Deployment, qui s'en sert comme mécanisme interne d'implémentation pour gérer le cycle de vie des pods (notamment lors des rolling updates, où plusieurs ReplicaSets coexistent temporairement : l'ancien en train d'être réduit, le nouveau en train d'être augmenté). L'utilisateur interagit normalement uniquement avec le Deployment (niveau d'abstraction plus simple et adapté aux besoins courants), le ReplicaSet restant un détail d'implémentation généralement invisible et non manipulé directement, sauf besoin de débogage très spécifique.

**Corrigé 6.16**
La pratique à interroger est l'utilisation de `nginx:latest` plutôt qu'un tag de version explicite (comme `nginx:alpine` ou `nginx:1.25.3`). Utiliser `:latest` signifie que l'image effectivement téléchargée peut varier dans le temps (chaque nouvelle publication de l'image "latest" change le contenu réel), rendant les déploiements non reproductibles de façon fiable et rendant le débogage plus difficile (on ne sait jamais avec certitude quelle version exacte tourne réellement sans inspecter directement l'image utilisée), ce qui est généralement déconseillé en bonne pratique professionnelle, même si ce n'est pas une erreur de syntaxe.

**Corrigé 6.17**
`nginx:latest` change de contenu réel au fil du temps (à chaque nouvelle publication de l'image taguée "latest" sur le registre), rendant impossible de garantir qu'un déploiement reproduit exactement le même comportement à deux moments différents. Dans un contexte GitOps (Partie 3), où l'on souhaite que l'état du cluster soit déterminé de façon prévisible et traçable uniquement par le contenu versionné dans Git, utiliser un tag flou comme "latest" casserait ce principe : on ne saurait jamais avec certitude, en lisant uniquement le commit Git, quelle version précise de l'image est réellement déployée, ni reproduire exactement cet état plus tard si nécessaire.

**Corrigé 6.18**
Exemple concret : un pod nommé "app-one-7d9f8c-xk2p1" tourne avec l'IP interne 10.42.0.15. Ce pod crashe ou est supprimé volontairement. Kubernetes (via le ReplicaSet) crée un NOUVEAU pod pour le remplacer, qui reçoit un nom différent (par exemple "app-one-7d9f8c-mn4q9") ET une nouvelle adresse IP différente (par exemple 10.42.0.23) — l'ancien pod et son IP n'existent plus du tout, ils sont définitivement remplacés par une nouvelle instance avec une nouvelle identité réseau, illustrant concrètement le caractère éphémère et non persistant de l'identité d'un Pod individuel.

**Corrigé 6.19**
Avec `maxSurge: 1` et `replicas: 3`, le nombre maximal de pods simultanément en cours d'exécution (anciens + nouveaux confondus) pendant la mise à jour est de **4** (3 réplicas normaux + 1 pod supplémentaire temporaire autorisé par maxSurge).

**Corrigé 6.20**
Avec `maxUnavailable: 0` et `replicas: 3`, le nombre minimum de pods garantis disponibles à tout instant pendant la mise à jour est de **3** (puisque maxUnavailable: 0 signifie explicitement qu'aucun pod ne peut être indisponible par rapport au nombre normal de réplicas désiré, garantissant donc zéro interruption de service pendant toute la durée de la transition).

**Corrigé 6.21**
Un échec de `livenessProbe` indique au système que le conteneur est dans un état défaillant ou bloqué (par exemple une application figée qui ne répond plus du tout), justifiant un redémarrage complet pour tenter de retrouver un état sain. Un échec de `readinessProbe` indique plutôt que le conteneur, bien que potentiellement toujours en vie et fonctionnel, n'est PAS encore (ou plus temporairement) prêt à traiter du trafic correctement (par exemple en cours de chargement d'une cache initiale, ou temporairement surchargé) — il est alors simplement retiré du Service pour ne pas recevoir de trafic pendant cette phase, sans qu'un redémarrage drastique du conteneur entier soit nécessaire ou pertinent pour ce type de situation transitoire.

**Corrigé 6.22**
Le sujet exige 3 réplicas pour l'application 2 spécifiquement pour démontrer concrètement la capacité de répartition de charge (load balancing) automatique de Kubernetes via un Service unique distribuant le trafic entre plusieurs instances identiques, ainsi que la résilience offerte par cette redondance (la perte d'un pod parmi 3 n'interrompt pas le service, contrairement à une application avec une seule réplique). Cela permet à l'évaluateur de vérifier visuellement, en multipliant les requêtes curl, que les réponses proviennent effectivement de pods différents (souvent visible si la réponse inclut le nom du pod ou son hostname interne), preuve tangible du fonctionnement réel de cette répartition.

---

## Section 6.C — Services et réseau interne

**Corrigé 6.23**
Un Ingress route le trafic HTTP/HTTPS entrant en se basant sur des règles (domaine, chemin), mais il a TOUJOURS besoin de cibler un Service Kubernetes comme destination finale de ce routage — un Ingress backend ne peut jamais pointer directement vers un pod individuel. Le Service reste donc indispensable comme couche d'abstraction stable (IP virtuelle, sélection dynamique des pods sains) sur laquelle l'Ingress s'appuie pour effectivement atteindre les bonnes instances applicatives, peu importe leurs changements internes d'IP au fil du temps.

**Corrigé 6.24**
Ce Service sélectionne tous les pods qui possèdent SIMULTANÉMENT les deux labels exacts `app: app-one` ET `tier: frontend` (une correspondance AND implicite entre toutes les paires clé-valeur listées dans `selector`). Si un pod ne porte QUE le label `app: app-one` sans le label `tier: frontend` additionnel, il ne sera PAS inclus dans ce Service, car la correspondance doit être satisfaite sur l'ENSEMBLE des critères du selector, pas seulement une partie d'entre eux.

**Corrigé 6.25**
`port: 80` est le port sur lequel le SERVICE lui-même écoute et expose son ClusterIP — c'est ce port que les clients (autres pods, ou Ingress) doivent utiliser pour se connecter au Service. `targetPort: 8080` est le port sur lequel le CONTENEUR à l'intérieur du pod écoute réellement son application. Le Service effectue donc une traduction : une requête arrivant sur le port 80 du Service est automatiquement redirigée vers le port 8080 du conteneur cible, permettant de découpler le port d'exposition "logique" du port d'écoute réel interne de l'application.

**Corrigé 6.26**
Un Service ClusterIP attribue une adresse IP virtuelle qui n'est routable et accessible QUE depuis l'intérieur du réseau du cluster Kubernetes lui-même (entre pods, ou depuis le Control Plane). Cette IP n'est pas exposée sur le réseau de la machine hôte ni a fortiori sur Internet : aucune route réseau externe ne sait comment atteindre cette plage d'adresses internes au cluster, contrairement à NodePort (qui expose un port sur chaque nœud, accessible depuis l'extérieur) ou LoadBalancer (qui obtient une IP publique externe dans un contexte cloud).

**Corrigé 6.27**
Au moins 2 causes distinctes possibles : (1) aucun pod actuellement créé/existant ne porte les labels exacts attendus par le `selector` du Service (erreur de configuration des labels dans le Deployment associé) ; (2) des pods existent bien avec les bons labels, mais ils ne sont pas (ou plus) dans un état "Ready" (par exemple readinessProbe en échec permanent), car seuls les pods Ready sont effectivement inclus dans les Endpoints d'un Service, même s'ils correspondent par ailleurs parfaitement au selector au niveau des labels.

**Corrigé 6.28**
Ce mécanisme repose sur le Endpoints Controller (un composant du Controller Manager) qui surveille en permanence, via l'API Server, l'apparition et la disparition de pods correspondant au selector de chaque Service existant. Dès qu'un nouveau pod (correspondant aux labels) devient Ready, il est automatiquement ajouté à la liste des Endpoints de ce Service ; dès qu'un pod disparaît ou devient non-Ready, il en est automatiquement retiré — ce processus est entièrement automatique et continu, sans intervention manuelle nécessaire à chaque changement du cycle de vie des pods sous-jacents.

**Corrigé 6.29**
Le format complet est `<nom-service>.<namespace>.svc.cluster.local` : `app-one` est le nom du Service lui-même, `default` est le namespace dans lequel il a été créé, `svc` indique explicitement qu'il s'agit d'un Service Kubernetes (par opposition à d'autres types d'enregistrements DNS internes possibles), et `cluster.local` est le domaine racine par défaut utilisé pour tout le DNS interne du cluster (configurable, mais `cluster.local` est la valeur conventionnelle par défaut la plus courante).

**Corrigé 6.30**
Non, pas directement avec juste `curl http://app-one` sans précision additionnelle. Depuis un pod du namespace `dev`, le nom court "app-one" seul serait interprété par défaut comme appartenant au MÊME namespace que le pod appelant (donc cherchant "app-one" dans "dev", pas dans "default"), ce qui échouerait si le Service existe réellement dans "default". Il faudrait soit utiliser le nom qualifié `app-one.default` (au minimum), soit le FQDN complet `app-one.default.svc.cluster.local`, pour cibler explicitement le Service situé dans cet autre namespace.

**Corrigé 6.31**
`svc/` indique le type de ressource ciblée (un Service, par opposition à `pod/` par exemple). `wil-playground` est le nom de ce Service spécifique. `-n dev` précise le namespace dans lequel chercher ce Service (sans cette précision, kubectl chercherait par défaut dans le namespace courant configuré, souvent "default"). `8888:8888` définit le mapping de ports : le premier nombre est le port LOCAL sur la machine où tourne kubectl, le second est le port distant du Service à l'intérieur du cluster vers lequel rediriger ce trafic local.

**Corrigé 6.32**
`kubectl port-forward` établit une connexion TEMPORAIRE et locale, qui dépend de la session active du terminal exécutant cette commande (kubectl doit continuer de tourner activement) — si cette session se termine (fermeture du terminal, perte de connexion), l'accès cesse immédiatement. Ce n'est ni persistant, ni accessible par d'autres utilisateurs/machines, ni scalable. Un Ingress ou un LoadBalancer, eux, fournissent un point d'accès stable, persistant et accessible de façon continue et partagée, indépendamment de toute session kubectl active sur une machine spécifique — adaptés à un usage de production réel plutôt qu'au débogage ponctuel pour lequel port-forward est conçu.

---

## Section 6.D — Ingress et Traefik

**Corrigé 6.33**
Le problème est l'ORDRE des règles dans ce manifeste : la règle SANS `host` spécifié (donc la règle "par défaut" censée capturer tout le trafic non explicitement matché ailleurs, ici vers app-three) est placée EN PREMIER, avant la règle spécifique à "app1.com". Selon le comportement habituel d'évaluation des règles Ingress (souvent dans l'ordre de déclaration, bien que cela puisse varier légèrement selon l'implémentation exacte du contrôleur), cette règle par défaut placée en premier risque de capturer/intercepter le trafic AVANT même que la règle plus spécifique pour "app1.com" n'ait la chance d'être évaluée, empêchant potentiellement le routage spécifique attendu vers app-one de fonctionner correctement. La bonne pratique est de toujours placer la règle par défaut (sans host) en DERNIER dans la liste.

**Corrigé 6.34**
Sans Ingress Controller actif (par exemple si Traefik n'était pas installé ou avait été désactivé), l'objet Ingress reste une simple déclaration enregistrée dans l'API Kubernetes, sans qu'AUCUN composant ne lise réellement cette déclaration pour configurer un proxy effectif qui appliquerait concrètement ces règles de routage au trafic réel. C'est l'Ingress Controller qui fait le travail effectif de mise en œuvre ; sans lui, l'objet Ingress est purement informatif et n'a aucun effet pratique sur le comportement réel du trafic réseau.

**Corrigé 6.35**
`pathType: Prefix` fait correspondre toute URL qui COMMENCE par le chemin spécifié : avec `path: /api`, cela matcherait `/api`, `/api/users`, `/api/v1/something`, etc. `pathType: Exact` exige une correspondance EXACTE et complète de l'URL, sans aucune extension possible : avec `path: /api`, seule l'URL exactement `/api` (et rien après) correspondrait, tandis que `/api/users` ne matcherait PAS cette règle Exact.

**Corrigé 6.36**
L'annotation `kubernetes.io/ingress.class` (ou le champ `ingressClassName` dans les versions plus récentes de l'API) indique explicitement à QUEL Ingress Controller spécifique cet objet Ingress est destiné à être traité. Avec deux contrôleurs installés simultanément, sans cette précision, les deux pourraient potentiellement tenter de traiter le même objet Ingress de façon ambiguë et conflictuelle ; avec l'annotation correctement définie, seul le contrôleur correspondant exactement à la valeur indiquée traitera effectivement cette règle, l'autre l'ignorant délibérément.

**Corrigé 6.37**
K3s, étant conçu pour une installation rapide et fonctionnelle "out of the box" sans configuration manuelle préalable extensive (philosophie de simplicité et de légèreté visée par le projet), inclut Traefik par défaut afin que les utilisateurs disposent immédiatement d'une solution de routage HTTP fonctionnelle sans étape d'installation supplémentaire. Kubernetes standard (via kubeadm), conçu pour des déploiements de production variés et personnalisés, laisse délibérément ce choix à l'administrateur, qui peut avoir des préférences spécifiques (Nginx Ingress, Traefik, ou d'autres solutions) selon son contexte précis, sans imposer un choix par défaut qui pourrait ne pas convenir à tous les cas d'usage de production envisageables.

**Corrigé 6.38**
Deux causes possibles liées spécifiquement à l'Ingress : (1) l'annotation `kubernetes.io/ingress.class` est absente ou incorrecte sur cet objet Ingress précis, empêchant Traefik de le reconnaître et de le traiter correctement ; (2) la règle pour "app2.com" dans le manifeste Ingress contient une faute de frappe dans le nom du Service cible (référençant un Service inexistant ou mal nommé), faisant que même si la règle de routage par hostname est correctement matchée, le backend désigné ne peut jamais être atteint correctement, générant potentiellement cette erreur 404.

**Corrigé 6.39**
Cela force l'étudiant à véritablement comprendre et savoir manipuler `kubectl get ingress`, `kubectl describe ingress` lui-même devant l'évaluateur, plutôt que de se contenter de présenter une capture d'écran pré-préparée potentiellement obtenue par copier-coller ou apprentissage superficiel sans compréhension réelle. Cela teste la capacité de l'étudiant à naviguer en temps réel dans son propre cluster et à expliquer ce qu'il observe à l'instant présent, une compétence bien plus révélatrice de la compréhension réelle qu'une simple image statique préparée à l'avance.

**Corrigé 6.40**
La colonne ADDRESS d'un Ingress est typiquement remplie automatiquement par le contrôleur lorsqu'une IP externe stable (souvent fournie par un LoadBalancer cloud) est attribuée à l'Ingress. En contexte K3s local sans LoadBalancer cloud, cette colonne peut légitimement rester vide même si l'Ingress fonctionne parfaitement, car le trafic est en réalité géré directement via l'IP du nœud lui-même (192.168.56.110 dans notre cas) sur lequel Traefik écoute directement, sans qu'une adresse externe distincte ne soit nécessaire ou attribuée dans ce contexte simplifié et local.

---

## Section 6.E — Namespaces, Labels, Selectors

**Corrigé 6.41**
Créer des namespaces distincts (`argocd`, `dev`) permet d'isoler logiquement les ressources d'infrastructure (Argo CD lui-même, ses composants internes) des ressources applicatives qu'il déploie et gère (l'application wil-playground), facilitant la lisibilité, la gestion des permissions (RBAC potentiellement différencié), et évitant toute collision de noms entre ressources système et applicatives qui pourraient sinon entrer en conflit si tout était mélangé dans le même namespace `default` sans cette séparation organisationnelle claire.

**Corrigé 6.42**
Par défaut, `kubectl get pods` (sans `-n` explicite) agit sur le namespace `default`, sauf si un namespace différent a été configuré comme contexte courant. Pour changer ce namespace par défaut de façon persistante (sans avoir à retaper `-n` à chaque commande), on utilise `kubectl config set-context --current --namespace=NOM_NAMESPACE`, qui modifie la configuration du contexte kubectl actif pour que toutes les commandes suivantes ciblent automatiquement ce namespace par défaut jusqu'à nouvelle modification.

**Corrigé 6.43**
Oui, sans problème : les labels ne sont pas des identifiants uniques au sens strict (contrairement au `metadata.name` qui doit être unique par type de ressource dans un namespace donné). Plusieurs objets de types différents (ou même du même type) peuvent parfaitement partager exactement le même label, car le rôle des labels est justement de permettre un regroupement/filtrage logique flexible (par exemple, un Service ET le Deployment qu'il cible portent souvent volontairement le même label `app: app-one` pour exprimer leur relation logique, sans que cela cause le moindre conflit technique).

**Corrigé 6.44**
Le Deployment a besoin d'une correspondance STRICTE et EXACTE car il doit pouvoir identifier sans aucune ambiguïté quels pods spécifiques sont "les siens" pour les gérer correctement (les compter pour vérifier le nombre de réplicas, les mettre à jour lors d'un rolling update) — toute divergence créerait une confusion fonctionnelle critique. Un Service, en revanche, a un rôle plus simple de simple sélection/routage de trafic : il peut se permettre de cibler un SOUS-ENSEMBLE plus large de labels (par exemple juste `app: app-one` sans exiger `tier: frontend` en plus), captant potentiellement plusieurs groupes de pods différents partageant ce label commun, sans que cela pose de problème de gestion équivalent à celui d'un Deployment.

**Corrigé 6.45**
Supprimer un namespace avec `kubectl delete namespace dev` supprime CASCADE tous les objets qui s'y trouvaient : tous les Deployments, Pods, Services, ConfigMaps, Secrets, et toute autre ressource appartenant à ce namespace sont définitivement supprimés en même temps que le namespace lui-même, sans possibilité de récupération automatique (sauf sauvegarde préalable explicite). C'est une opération potentiellement très destructrice à utiliser avec une grande prudence en pratique.

**Corrigé 6.46**
Une Annotation n'est PAS utilisée par les mécanismes de sélection (`selector`) de Kubernetes — seuls les Labels le sont. Si l'on définissait par erreur le label attendu par un Service (`app: app-one`) comme une Annotation à la place sur les pods, le Service ne trouverait alors AUCUN pod correspondant à son selector (qui cherche spécifiquement dans les Labels, jamais dans les Annotations), résultant en des Endpoints vides et un Service totalement non fonctionnel malgré la présence apparente de l'information voulue, simplement stockée au mauvais endroit conceptuel (Annotation au lieu de Label).

---

## Section 6.F — K3s spécifique et installation

**Corrigé 6.47**
`K3S_TOKEN` seul authentifie l'identité/l'autorisation du futur agent à rejoindre UN cluster, mais sans `K3S_URL`, l'agent n'aurait absolument aucune information sur OÙ se trouve physiquement (quelle IP, quel port) ce cluster auquel se connecter pour présenter ce token. Les deux informations sont complémentaires et indispensables ensemble : K3S_URL répond à la question "où contacter le serveur", K3S_TOKEN répond à la question "comment prouver mon autorisation à le rejoindre une fois contacté".

**Corrigé 6.48**
Fixer une version précise garantit une reproductibilité totale et un comportement prévisible et testé, évitant les régressions ou changements de comportement inattendus qui pourraient survenir avec une nouvelle version "stable" publiée entre deux exécutions du script (par exemple le changement de comportement de l'endpoint `/healthz` observé entre différentes versions de K3s dans le débogage du projet réel). Cela évite aussi les problèmes de compatibilité entre serveur et worker s'ils étaient installés à des moments légèrement différents avec des versions "stable" different sans cette précision explicite de version fixe partagée.

**Corrigé 6.49**
La chaîne de causalité : une VM avec seulement 1 CPU et 1 Go de RAM alloue des ressources insuffisantes pour les besoins de K3s v1.35 (plus gourmand que les versions antérieures) → SQLite (la base de données interne utilisée par K3s) doit effectuer ses opérations de lecture/écriture avec des ressources CPU/RAM très limitées disponibles → les requêtes SQL internes deviennent anormalement lentes (visible dans les logs comme "Slow SQL" avec des durées de plusieurs dizaines de secondes au lieu de millisecondes) → ces lenteurs en cascade provoquent des timeouts sur l'API Server qui dépend de cette base de données pour répondre → `kubectl get nodes` et autres commandes deviennent extrêmement lentes voire bloquées indéfiniment, symptôme final observé par l'utilisateur sans lien évident immédiat avec la cause racine réelle (ressources insuffisantes).

**Corrigé 6.50**
Les versions anciennes de K3s (avant environ la v1.26) retournaient la chaîne littérale "ok" sur `/healthz` sans authentification requise, tandis que les versions plus récentes ont renforcé la sécurité de cet endpoint, exigeant désormais une authentification et retournant une erreur 401 Unauthorized en son absence. Pour rester robuste face à ce changement de comportement selon la version installée, un script doit adapter sa logique de vérification pour accepter plusieurs réponses possibles comme preuve de disponibilité de l'API (par exemple vérifier la présence de "ok" OU "Unauthorized" dans la réponse), plutôt que de chercher strictement et exclusivement la chaîne "ok" qui ne sera jamais retournée par les versions récentes même quand le serveur fonctionne parfaitement.

---

*Fin du corrigé de la Partie 6 (Kubernetes/K3s). Le corrigé de la Partie 7 (Debugging) suit.*
# CORRIGÉ PARTIE 7 — DEBUGGING

**Corrigé 7.1 — Worker absent du cluster**
Démarche : (1) `vagrant status` pour confirmer que les deux VMs sont bien `running`. (2) `vagrant ssh ankammerSW` puis vérifier les logs de provisioning du worker, en particulier chercher où le script s'est arrêté ou a échoué (souvent visible directement dans la sortie de `vagrant up` elle-même, à relire). (3) Sur le worker, `rc-service k3s-agent status` pour voir si le service agent a même été installé/démarré. (4) Si le service n'existe pas, le script a probablement échoué avant d'atteindre l'installation K3s (problème de token, par exemple). (5) Vérifier les logs spécifiques avec `cat /var/log/k3s.log` ou équivalent sur le worker. Cause typique : token jamais récupéré (dossier partagé cassé) ou échec de connectivité réseau vers le serveur empêchant la jonction.

**Corrigé 7.2 — Token absent**
Démarche : (1) Sur le SERVEUR, vérifier que K3s a bien terminé son installation et généré le token : `ls -la /var/lib/rancher/k3s/server/node-token`. (2) Vérifier que `/vagrant` est bien monté sur le serveur : `mount | grep vagrant` et `ls /vagrant`. (3) Si le token existe sur le serveur mais pas dans `/vagrant`, le script de copie a probablement échoué (timing, ou dossier partagé non fonctionnel). (4) Sur le WORKER, vérifier également que `/vagrant` est bien monté de son côté : `ls /vagrant`. Si absent côté worker uniquement, le problème vient typiquement d'une absence de déclaration `synced_folder` au niveau global du Vagrantfile (la déclarant seulement pour le serveur, oubliant le worker).

**Corrigé 7.3 — API totalement inaccessible**
Démarche : (1) Vérifier que la VM serveur est bien `running` via `vagrant status`. (2) `vagrant ssh ankammerS` puis `rc-service k3s status` pour confirmer que le service tourne réellement. (3) `ss -tlnp | grep 6443` sur le serveur pour voir sur quelle(s) interface(s) l'API écoute réellement — si elle n'écoute que sur 127.0.0.1 et pas sur l'IP private_network, c'est la cause. (4) Si elle écoute bien sur la bonne IP, tester depuis la VM elle-même avec `curl -sk https://192.168.56.110:6443` pour isoler si le problème est réseau (entre hôte et VM) ou applicatif (K3s lui-même). (5) Vérifier les règles de pare-feu éventuelles sur l'hôte qui bloqueraient ce port spécifique.

**Corrigé 7.4 — Pod CrashLoopBackOff**
Démarche : (1) `kubectl describe pod NOM_POD` et lire attentivement la section Events en bas, qui révèle souvent directement la cause. (2) `kubectl logs NOM_POD` pour voir la sortie du conteneur lors de sa dernière tentative. (3) `kubectl logs NOM_POD --previous` pour voir spécifiquement les logs du crash PRÉCÉDENT (souvent plus informatif que les logs du tout dernier redémarrage, qui peut être trop récent pour avoir produit beaucoup de sortie). (4) Vérifier la commande/l'entrypoint définie dans l'image et le Deployment : une commande incorrecte ou un fichier manquant dans l'image provoque souvent ce symptôme. (5) Vérifier les ressources allouées (`resources.limits`) qui, si trop restrictives, peuvent provoquer un OOMKilled répété ressemblant à un CrashLoopBackOff.

**Corrigé 7.5 — Service inaccessible malgré pod Running**
Démarche : (1) `kubectl get endpoints NOM_SERVICE` pour vérifier que le Service a bien des pods associés (si vide, c'est un problème de labels/selector, pas de réseau). (2) Vérifier que le `targetPort` du Service correspond exactement au port sur lequel le conteneur écoute réellement à l'intérieur (vérifiable via `kubectl exec` puis test interne, ou simplement relire la config de l'application). (3) Tester depuis un autre pod du cluster (`kubectl run debug --image=alpine --rm -it -- /bin/sh` puis `wget` ou `curl` vers le Service) pour isoler si le problème est interne au cluster ou lié à l'accès externe (port-forward, Ingress). (4) Vérifier que le pod est bien `Ready` (pas seulement `Running`), car un pod non-Ready est automatiquement exclu des Endpoints même s'il tourne.

**Corrigé 7.6 — Erreur Vagrant VT-x**
Démarche : (1) Identifier le type de processeur (Intel ou AMD). (2) Redémarrer la machine et entrer dans le BIOS/UEFI (touche F2/F10/Del/Suppr selon le constructeur). (3) Chercher une option nommée "Intel Virtualization Technology", "Intel VT-x", "SVM Mode" ou "AMD-V" selon le fabricant, généralement dans les menus Advanced/CPU Configuration. (4) Activer cette option, sauvegarder et redémarrer. (5) Vérifier ensuite avec `vagrant up` que l'erreur a disparu. Si le BIOS ne montre aucune option de ce type, vérifier aussi qu'aucun autre logiciel de virtualisation (Hyper-V sur Windows notamment) ne monopolise déjà cette fonctionnalité matérielle de façon conflictuelle.

**Corrigé 7.7 — Erreur "VM already exists"**
Démarche : (1) `vboxmanage list vms` pour confirmer la présence d'une VM portant ce nom résiduel. (2) Vérifier l'état avec `vboxmanage showvminfo NOM_VM | grep State`. (3) Si elle est arrêtée et orpheline (Vagrant ne la gère plus, dossier `.vagrant` supprimé ou désynchronisé), la supprimer manuellement : `vboxmanage unregistervm NOM_VM --delete`. (4) Relancer `vagrant up`. Cause typique : un précédent `vagrant destroy` interrompu, ou une suppression manuelle du dossier `.vagrant/` sans avoir préalablement détruit proprement la VM via Vagrant.

**Corrigé 7.8 — Erreur Libvirt storage pool**
Commande d'investigation : `virsh pool-list --all` pour voir l'état de tous les storage pools connus de libvirt (actif/inactif). `virsh pool-info default` pour les détails du pool concerné. Si le pool est inactif, `virsh pool-start default` peut le réactiver. Si le pool n'existe pas du tout, il peut falloir le redéfinir avec `virsh pool-define` en pointant vers le bon répertoire de stockage, suivi de `virsh pool-build` et `virsh pool-start`.

**Corrigé 7.9 — DNS interne K3s cassé**
Démarche : (1) `kubectl get pods -n kube-system | grep coredns` pour vérifier que CoreDNS tourne bien et est Ready. (2) `kubectl logs -n kube-system deployment/coredns` pour chercher des erreurs explicites. (3) Depuis un pod de test, `kubectl exec -it POD -- nslookup app-one.default.svc.cluster.local` (ou `wget`/`getent hosts` selon les outils disponibles dans l'image utilisée) pour confirmer concrètement l'échec de résolution. (4) Vérifier le fichier `/etc/resolv.conf` à l'intérieur du pod de test, qui doit pointer vers l'IP du Service CoreDNS (souvent visible via `kubectl get svc -n kube-system kube-dns`). (5) Si CoreDNS lui-même est en CrashLoopBackOff, traiter cela comme un cas classique de Scénario 7.4.

**Corrigé 7.10 — Ingress retourne 404 systématique**
Démarche : (1) `kubectl get ingress -o yaml` pour relire attentivement TOUTES les règles, en vérifiant particulièrement l'ordre (règle par défaut bien en dernier) et la présence de l'annotation `ingress.class`. (2) `kubectl get pods -n kube-system | grep traefik` pour confirmer que Traefik tourne effectivement. (3) `kubectl logs -n kube-system deployment/traefik` pour chercher des erreurs de configuration spécifiques à cet Ingress. (4) Vérifier que la requête curl utilise bien la syntaxe exacte attendue pour l'en-tête Host (`-H "Host:app1.com"`, attention aux espaces/casse). (5) Tester en contournant l'Ingress (via port-forward direct vers le Service) pour confirmer que le problème est bien isolé au niveau de l'Ingress et pas plus profond dans la chaîne.

**Corrigé 7.11 — Worker "NotReady" en permanence**
Démarche : (1) `kubectl describe node NOM_WORKER` et lire la section Conditions pour voir le message d'erreur précis associé à l'état NotReady. (2) Sur le worker lui-même, `rc-service k3s-agent status` et consulter ses logs spécifiques. (3) Vérifier la connectivité réseau persistante worker→serveur sur le port 6443 (pas seulement au moment de la jonction initiale, mais en continu). (4) Vérifier que le CNI (réseau de pods, Flannel par défaut pour K3s) fonctionne correctement sur ce nœud — un problème de CNI est une cause fréquente de NotReady persistant malgré une jonction initiale apparemment réussie. (5) Vérifier les ressources disponibles sur le worker (RAM/disque) qui, si épuisées, peuvent provoquer cet état.

**Corrigé 7.12 — vagrant ssh refuse la connexion**
Démarche : (1) `vagrant ssh-config ankammerS` pour voir les paramètres SSH exacts utilisés (port, clé). (2) Tenter une connexion SSH manuelle avec ces paramètres exacts pour voir le message d'erreur précis (`ssh -i CHEMIN_CLE -p PORT vagrant@127.0.0.1`). (3) Vérifier dans VirtualBox/vboxmanage que la VM répond effectivement (pas juste "running" au sens Vagrant, mais réellement opérationnelle, en testant `vboxmanage list runningvms`). (4) Si la VM vient de démarrer, le service SSH peut ne pas encore être complètement opérationnel — attendre quelques secondes et réessayer. (5) Vérifier qu'aucun pare-feu local ne bloque la connexion sur le port forwardé.

**Corrigé 7.13 — Guest Additions version mismatch**
Démarche de diagnostic : comparer explicitement `vboxmanage --version` (hôte) et `VBoxService --version` ou `VBoxControl --version` (dans la VM) pour confirmer précisément l'écart de version. Solutions possibles (au moins 2) : (1) installer/configurer le plugin `vagrant-vbguest` pour qu'il mette à jour automatiquement les Guest Additions au démarrage de la VM ; (2) changer de box pour une version plus récente d'Alpine dont les Guest Additions intégrées sont plus proches de la version VirtualBox installée sur l'hôte ; (3) en solution de contournement, désactiver complètement le dossier partagé natif et utiliser une alternative (serveur HTTP local, ou `rsync` comme type de synced_folder) qui ne dépend pas du bon fonctionnement de vboxsf.

**Corrigé 7.14 — /vagrant introuvable sur une seule VM**
Démarche : (1) Relire intégralement le Vagrantfile pour vérifier si `config.vm.synced_folder` est déclaré au niveau GLOBAL (avant tout `define`) ou seulement à l'intérieur d'un bloc `define` spécifique (souvent celui du serveur uniquement, par oubli). (2) Sur la VM en échec, `sudo VBoxControl sharedfolder list` pour confirmer qu'aucun dossier partagé n'est effectivement déclaré côté VirtualBox pour cette VM précise (contrairement à l'autre VM où la liste ne serait pas vide). (3) Corriger en remontant la déclaration au niveau global du Vagrantfile, puis `vagrant reload` (ou destroy/up) de la VM concernée pour appliquer le changement.

**Corrigé 7.15 — kubectl se bloque indéfiniment**
Démarche : (1) Tester la connectivité réseau brute vers le port de l'API avec un timeout court explicite : `curl -sk --max-time 5 https://192.168.56.110:6443`. Si ÇA aussi se bloque/timeout sans réponse, le problème est probablement que K3s lui-même est figé ou surchargé (pas un simple problème de credentials). (2) Consulter les logs K3s en cherchant spécifiquement des motifs comme "Slow SQL" qui indiqueraient une base de données interne surchargée, symptôme classique de ressources insuffisantes (RAM/CPU) allouées à la VM. (3) Si confirmé, la solution est d'augmenter les ressources allouées à la VM dans le Vagrantfile, ou de revenir à une version antérieure plus légère de K3s.

**Corrigé 7.16 — Token copié mais invalide**
Démarche : (1) Comparer attentivement le contenu exact du token sur le serveur (`cat /var/lib/rancher/k3s/server/node-token`) avec celui récupéré côté worker (`cat /vagrant/node-token` ou équivalent), caractère par caractère si nécessaire, pour détecter une troncature ou corruption lors de la copie. (2) Vérifier qu'aucun caractère de fin de ligne supplémentaire ou caractère invisible n'a été introduit lors de la copie (le `tr -d '\n'` est-il bien appliqué au bon moment ?). (3) Vérifier que le token utilisé correspond bien à l'installation K3s CURRENTE du serveur (si K3s a été réinstallé/redémarré entre-temps, un ancien token copié précédemment pourrait être devenu obsolète/invalide).

**Corrigé 7.17 — Argo CD reste OutOfSync**
Démarche : (1) `kubectl describe application NOM_APP -n argocd` pour lire en détail le message exact expliquant pourquoi l'état est OutOfSync (souvent très explicite sur la nature précise de la différence détectée). (2) Vérifier dans l'interface web Argo CD (ou via CLI `argocd app diff`) exactement QUELLES ressources/champs sont en différence entre Git et le cluster réel. (3) Vérifier que `syncPolicy.automated` est bien présent ET correctement formé dans le manifeste de l'Application (une simple faute d'indentation YAML pourrait désactiver silencieusement cette automatisation attendue). (4) Vérifier qu'aucune modification manuelle persistante n'est réappliquée en boucle par un autre processus en parallèle du contrôle d'Argo CD.

**Corrigé 7.18 — Argo CD ComparisonError**
Démarche : (1) Vérifier que l'URL du dépôt Git (`spec.source.repoURL`) est exactement correcte et accessible publiquement (tester en l'ouvrant directement dans un navigateur). (2) Vérifier que le chemin (`spec.source.path`) correspond exactement à un dossier EXISTANT dans le dépôt à la révision ciblée. (3) Vérifier que `targetRevision` (souvent `HEAD` ou un nom de branche) existe bien et est orthographié correctement. (4) Consulter les logs du composant `argocd-repo-server` (`kubectl logs -n argocd deployment/argocd-repo-server`) qui est spécifiquement responsable du clonage et du parsing du dépôt Git, pour un message d'erreur plus détaillé sur la cause exacte de l'échec de chargement.

**Corrigé 7.19 — Image Docker introuvable**
Démarche : (1) `kubectl describe pod NOM_POD` pour lire le message d'erreur exact dans les Events (souvent très explicite, indiquant le nom exact de l'image recherchée). (2) Tester manuellement `docker pull NOM_IMAGE:TAG` depuis un terminal pour confirmer si l'image existe réellement et est accessible publiquement sous ce nom/tag exact. (3) Vérifier l'orthographe exacte dans le manifeste YAML (espace, majuscule, faute de frappe dans le nom d'utilisateur Docker Hub ou le tag). (4) Si l'image est privée, vérifier la présence et la configuration correcte d'un `imagePullSecrets` dans le manifeste, absent ici par défaut.

**Corrigé 7.20 — Pod Pending indéfiniment**
Démarche : (1) `kubectl describe pod NOM_POD` (la commande réflexe systématique) et lire attentivement la section Events qui révèle PRESQUE TOUJOURS la cause exacte d'un Pending (contrairement à `kubectl get pods` seul qui ne montre que l'état final sans explication). (2) Causes fréquentes à vérifier spécifiquement : ressources insuffisantes sur tous les nœuds disponibles (`Insufficient cpu` ou `Insufficient memory` explicitement mentionné), absence de nœud disponible correspondant aux contraintes (taints/tolerations, nodeSelector), ou problème de PersistentVolumeClaim non satisfaite si le pod en référence un.

**Corrigé 7.21 — Port K3d déjà utilisé**
Démarche et résolution : `sudo lsof -i :8080` (Linux/macOS) ou `netstat -ano | findstr 8080` (Windows) pour identifier précisément quel processus occupe déjà ce port sur la machine hôte. Soit arrêter ce processus conflictuel s'il n'est plus nécessaire, soit choisir un port différent et inutilisé pour la création du cluster K3d : `k3d cluster create mycluster --port "9080:80@loadbalancer"` en remplaçant 8080 par un port confirmé libre.

**Corrigé 7.22 — Docker daemon inaccessible**
Démarche : (1) Vérifier que le service Docker tourne réellement : `sudo systemctl status docker` (ou équivalent OpenRC sur Alpine). (2) Si "permission denied" précisément (pas "cannot connect"), vérifier l'appartenance de l'utilisateur courant au groupe `docker` : `groups $USER`. (3) Si absent de ce groupe, l'ajouter (`sudo usermod -aG docker $USER`) puis IMPÉRATIVEMENT se reconnecter (nouvelle session, ou `newgrp docker` en attendant) pour que ce changement de groupe soit effectivement pris en compte par le shell courant. (4) Si le service lui-même n'est pas démarré, le démarrer explicitement avant de retester.

**Corrigé 7.23 — Conflit IP entre deux projets Vagrant**
Symptôme attendu : si les deux VMs (l'une du projet p1/, l'autre du projet p2/) tournent simultanément avec la même IP 192.168.56.110, on observerait des comportements réseau erratiques : `ping` vers cette IP donnant des réponses incohérentes ou alternées, des connexions SSH se connectant parfois à l'une, parfois à l'autre VM de façon imprévisible, ou des échecs intermittents inexpliqués. Démarche de diagnostic : `vboxmanage list runningvms` pour lister toutes les VMs actuellement actives tous projets confondus, et vérifier si plus d'une VM utilise effectivement cette même adresse IP simultanément, ce qui confirmerait la cause du problème observé.

**Corrigé 7.24 — Worker ne ping pas le serveur**
Démarche : (1) Vérifier sur les DEUX VMs que l'interface réseau private_network est bien active et correctement configurée : `ip a` doit montrer l'IP attendue sur l'interface secondaire (souvent eth1). (2) Vérifier qu'aucune erreur de configuration réseau n'apparaît dans les logs de démarrage de chaque VM. (3) Tenter un ping DANS L'AUTRE SENS (serveur vers worker) pour voir si le problème est unidirectionnel (suggérant un souci de routage spécifique) ou bidirectionnel (suggérant un problème plus fondamental d'interface ou de configuration réseau globale). (4) Vérifier qu'aucun pare-feu interne à la VM (iptables) ne bloque spécifiquement le trafic ICMP entre les deux machines.

**Corrigé 7.25 — Provisioning silencieusement en échec**
Démarche : (1) Relire ATTENTIVEMENT l'intégralité de la sortie de `vagrant up` (souvent très longue, mais l'erreur précise s'y trouve généralement, même si elle peut être noyée dans le volume de texte). (2) Vérifier si le script utilisait `set -e` : sans cette option, une commande en échec en plein milieu du script pourrait ne générer qu'un message d'erreur visuel sans interrompre l'exécution ni faire échouer formellement le provisioning aux yeux de Vagrant, qui considérerait le script comme "réussi" globalement (code de sortie final à 0) malgré l'échec interne d'une étape critique. (3) Se connecter manuellement (`vagrant ssh`) et vérifier explicitement l'état réel de K3s pour confirmer cette hypothèse.

**Corrigé 7.26 — SQL lentes**
Démarche et lien avec les ressources : confirmer d'abord la présence de ces messages dans `/var/log/k3s.log` ou via `rc-service k3s status`/logs équivalents. Vérifier ensuite les ressources réellement allouées à la VM via le Vagrantfile (`vb.memory`, `vb.cpus`) et les comparer aux besoins réels de la version de K3s installée. Si la VM a, par exemple, seulement 1 Go de RAM et 1 CPU pour une version récente et gourmande de K3s (v1.35+), c'est la cause quasi certaine : la base SQLite interne, contrainte par ces ressources limitées, ne peut traiter les requêtes qu'avec une latence anormalement élevée. Solution : augmenter `vb.memory` à au moins 2048 et `vb.cpus` à 2, ou utiliser une version antérieure de K3s plus légère via `INSTALL_K3S_VERSION`.

**Corrigé 7.27 — Endpoints vides**
Démarche complète (au moins 3 pistes) : (1) Comparer EXACTEMENT les labels du selector du Service (`kubectl get svc NOM -o yaml`) avec les labels effectivement présents sur les pods candidats (`kubectl get pods --show-labels`) pour détecter toute divergence, même minime (faute de frappe, casse différente). (2) Vérifier que les pods candidats sont bien dans l'état `Ready` (`kubectl get pods -o wide`), pas seulement `Running`, car seuls les pods Ready sont inclus dans les Endpoints. (3) Vérifier que les pods existent bien dans le MÊME namespace que le Service (un Service ne peut cibler que des pods de son propre namespace, sauf configuration cross-namespace spécifique via ExternalName, non applicable ici).

**Corrigé 7.28 — Application Argo CD jamais créée**
Démarche : (1) Vérifier que la commande `kubectl apply -f argocd-app.yaml` ciblait bien le BON namespace : un objet Application DOIT être créé dans le namespace `argocd` spécifiquement pour qu'Argo CD le surveille (`metadata.namespace: argocd` dans le manifeste lui-même, vérifié avec `kubectl get application -n argocd` plutôt que `-n default` par erreur). (2) Vérifier qu'aucune erreur silencieuse n'est survenue lors de l'apply (`kubectl apply -f argocd-app.yaml -o yaml` pour voir la réponse complète du serveur, pas juste le message de succès court par défaut). (3) Vérifier que le CRD (Custom Resource Definition) `Application` d'Argo CD est bien installé dans le cluster (normalement automatique avec l'installation Argo CD elle-même), sans quoi l'API rejetterait silencieusement ou explicitement la création de cet objet de type inconnu.

**Corrigé 7.29 — Mise à jour Git non détectée**
Démarche : (1) Vérifier que le commit a bien été poussé sur la BONNE branche, celle référencée par `targetRevision` dans l'Application Argo CD (souvent `main` ou `HEAD`, mais vérifier la correspondance exacte). (2) Vérifier directement sur GitHub que le fichier modifié apparaît bien à jour dans le commit le plus récent visible sur la branche concernée. (3) Argo CD poll généralement le dépôt toutes les 3 minutes par défaut : patienter ce délai, ou forcer une synchronisation manuelle immédiate via l'interface web (bouton "Refresh" puis "Sync") ou la CLI (`argocd app sync NOM_APP`) pour ne pas attendre passivement. (4) Vérifier que le chemin (`spec.source.path`) surveillé par Argo CD correspond bien au dossier où le fichier modifié se trouve réellement dans le dépôt.

**Corrigé 7.30 — Erreur de certificat TLS**
Démarche : Ce message indique typiquement que l'adresse à laquelle le worker tente de se connecter ne correspond pas aux adresses (IP/noms) pour lesquelles le certificat TLS du serveur a été initialement généré lors de l'installation de K3s. Vérifier les arguments `--tls-san` éventuellement nécessaires si le serveur est accessible par plusieurs adresses différentes (NAT et private_network par exemple), ou vérifier simplement que `K3S_URL` côté worker utilise EXACTEMENT la même adresse IP que celle déclarée via `--node-ip`/`--advertise-address` côté serveur lors de l'installation initiale, sans confusion entre les différentes interfaces réseau possibles de la VM serveur.

**Corrigé 7.31 — VM bloquée au boot**
Démarche : (1) Activer temporairement le mode graphique (`vb.gui = true` dans le Vagrantfile) pour OBSERVER VISUELLEMENT ce qui se passe réellement à l'écran de la VM pendant ce blocage, plutôt que de rester aveugle en mode headless. (2) Vérifier les ressources disponibles sur la machine hôte (RAM/CPU déjà fortement utilisés par d'autres VMs ou applications, pouvant ralentir drastiquement le boot d'une VM supplémentaire). (3) Vérifier que la virtualisation matérielle (VT-x/AMD-V) est bien active, son absence pouvant aussi causer des lenteurs de boot extrêmes plutôt qu'un échec immédiat selon la configuration exacte. (4) Essayer d'augmenter le timeout de boot par défaut de Vagrant si la VM finit par démarrer mais juste trop lentement pour le délai standard.

**Corrigé 7.32 — kubectl pointe vers l'ancien cluster**
Démarche : (1) `kubectl config get-contexts` pour voir tous les contextes configurés et identifier lequel est actuellement actif (marqué par une étoile). (2) `k3d cluster list` pour confirmer la liste réelle des clusters K3d actuellement existants côté Docker. (3) Si l'ancien cluster apparaît encore dans la config kubectl mais plus dans `k3d cluster list`, le kubeconfig contient une entrée obsolète à nettoyer : `kubectl config delete-context NOM_ANCIEN_CONTEXTE` et `kubectl config delete-cluster NOM_ANCIEN_CLUSTER`. (4) Régénérer proprement le contexte pour le nouveau cluster avec `k3d kubeconfig merge NOUVEAU_CLUSTER --kubeconfig-switch-context`.

**Corrigé 7.33 — rc-service introuvable**
Démarche : cela indique presque certainement que la VM n'utilise PAS Alpine/OpenRC comme attendu, mais une autre distribution (par exemple si la box a été changée par erreur pour une box Ubuntu/Debian utilisant systemd). Vérifier la box réellement utilisée : `cat /etc/os-release` ou `cat /etc/alpine-release` dans la VM pour confirmer précisément quel système tourne réellement, et adapter le script de provisioning pour utiliser la commande de gestion de service appropriée à cet OS (systemctl si c'est effectivement systemd détecté, par exemple suite à un changement de `config.vm.box` non répercuté dans les scripts).

**Corrigé 7.34 — apk update timeout réseau**
Démarche : (1) Vérifier que l'interface NAT de la VM est bien active et fonctionnelle (`ip a` doit montrer une interface avec une IP de type 10.0.2.x typique du NAT VirtualBox). (2) Tester une connectivité Internet basique depuis la VM : `ping -c 3 8.8.8.8` pour isoler si c'est un problème de routage général ou spécifique aux mirrors Alpine. (3) Si le ping IP fonctionne mais que la résolution de noms échoue, vérifier `/etc/resolv.conf` dans la VM pour confirmer la présence d'un serveur DNS fonctionnel configuré. (4) Vérifier que l'hôte lui-même dispose d'une connexion Internet active à ce moment précis (panne réseau côté hôte affectant indirectement tout le trafic NAT de la VM qui transite par lui).

**Corrigé 7.35 — GitLab pods Pending après Helm**
Démarche : (1) `kubectl describe pod NOM_POD -n gitlab` pour chacun des pods bloqués, et lire la section Events — la cause la plus fréquente pour une installation GitLab complète est `Insufficient memory` ou `Insufficient cpu`, car GitLab est très gourmand en ressources (recommandation officielle de plusieurs Go de RAM disponibles). (2) Vérifier les ressources totales disponibles sur le cluster K3d/K3s utilisé : `kubectl describe nodes` et regarder la section Allocated resources. (3) Si confirmé comme un problème de ressources insuffisantes, soit augmenter significativement les ressources allouées au cluster/à la machine hôte, soit désactiver davantage de composants GitLab non essentiels lors de l'installation Helm (déjà partiellement fait dans le script du cours, mais potentiellement insuffisant selon le contexte).

**Corrigé 7.36 — Mot de passe Argo CD refusé**
Démarche : (1) Vérifier que le secret récupéré est bien le bon : `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d`, en s'assurant de bien décoder le base64 (oublier ce décodage est une erreur fréquente, copiant la valeur encodée brute par erreur comme mot de passe). (2) Vérifier qu'aucun espace ou caractère invisible supplémentaire n'a été copié accidentellement lors de la récupération manuelle de ce mot de passe. (3) Vérifier que ce secret n'a pas déjà été supprimé suite à un changement de mot de passe admin antérieur (Argo CD supprime ce secret initial après le premier changement de mot de passe réussi, rendant cette méthode de récupération obsolète si un changement a déjà eu lieu).

**Corrigé 7.37 — Ingress fonctionne pour un domaine pas l'autre**
Démarche : (1) `kubectl get ingress -o yaml` et comparer scrupuleusement, ligne par ligne, les deux règles (app1.com qui fonctionne vs app2.com qui échoue) pour détecter toute différence de configuration entre les deux (nom de Service incorrect, faute de frappe dans le nom de domaine lui-même, pathType différent). (2) Vérifier indépendamment que le Service "app-two" lui-même fonctionne correctement (Endpoints non vides, accessible via port-forward direct sans passer par l'Ingress). (3) Vérifier l'ordre des règles dans le manifeste (la règle par défaut placée AVANT plutôt qu'après pourrait intercepter le trafic destiné à app2.com avant que sa règle spécifique ne soit évaluée, selon le comportement exact de Traefik face à cet ordre).

**Corrigé 7.38 — destroy ne supprime pas réellement**
Démarche : (1) Vérifier le message exact retourné par `vagrant destroy -f` pour confirmer s'il indique réellement un succès ou une erreur silencieuse non remarquée. (2) Si la VM apparaît toujours dans `vboxmanage list vms` mais que Vagrant la considère comme détruite (absente de `vagrant global-status`), cela suggère une désynchronisation entre l'état Vagrant et VirtualBox — possiblement causée par une suppression manuelle antérieure du dossier `.vagrant/` ayant fait perdre le lien à Vagrant. (3) Supprimer manuellement la VM orpheline directement via VirtualBox : `vboxmanage unregistervm NOM_VM --delete` pour forcer sa suppression complète indépendamment de l'état de Vagrant.

**Corrigé 7.39 — K3s consomme 100% CPU**
Démarche : (1) `top` ou `htop` dans la VM pour confirmer précisément quel processus exact (k3s lui-même, ou un sous-processus comme containerd) consomme ce CPU. (2) Vérifier les logs K3s pour des messages répétitifs en boucle qui pourraient indiquer un problème (par exemple des tentatives de reconnexion infinies, des erreurs de santé répétées). (3) Vérifier si ce comportement coïncide avec les symptômes de "Slow SQL" déjà identifiés ailleurs : une base de données SQLite sous tension extrême peut effectivement monopoliser le CPU disponible en tentant désespérément de traiter une charge de requêtes que les ressources allouées ne permettent pas de gérer efficacement. (4) Solution probable : augmenter les ressources de la VM, comme pour le Scénario 7.26.

**Corrigé 7.40 — Confusion de labels entre Deployments**
Démarche centrée sur les labels : (1) `kubectl get pods --show-labels -A` (ou filtré sur le namespace concerné) pour lister explicitement TOUS les labels de TOUS les pods candidats, en cherchant un chevauchement involontaire entre les labels utilisés par les deux Deployments distincts (par exemple si les deux utilisent par erreur exactement `app: myapp` sans différenciation supplémentaire). (2) `kubectl get svc NOM_SERVICE -o yaml` pour relire précisément le selector utilisé par le Service affecté, et le comparer méthodiquement à l'ensemble des labels identifiés à l'étape précédente. (3) Corriger en différenciant clairement les labels entre les deux Deployments distincts (ajout d'un label plus spécifique comme `component: frontend` vs `component: backend` en plus du label générique partagé), puis ajuster le selector du Service pour qu'il cible précisément et uniquement le bon ensemble voulu.

**Corrigé 7.41 — Solution HTTP token inaccessible**
Démarche : (1) Vérifier sur le serveur que le processus Python (`ps aux | grep http.server`) tourne réellement et écoute sur le port attendu (`ss -tlnp | grep 9999`). (2) Vérifier que ce serveur HTTP écoute bien sur TOUTES les interfaces (0.0.0.0) et pas seulement sur localhost (127.0.0.1), ce qui empêcherait toute connexion externe même depuis le worker sur le même réseau privé. (3) Tester la connectivité réseau de base entre les deux VMs indépendamment de ce serveur HTTP spécifique (ping simple). (4) Vérifier qu'aucun pare-feu interne à la VM serveur ne bloque spécifiquement ce port 9999 non standard, qui pourrait ne pas être explicitement autorisé contrairement à des ports plus courants déjà ouverts par défaut.

**Corrigé 7.42 — Cluster K3d perd ses données après reboot hôte**
Démarche : (1) `docker ps -a` après le redémarrage pour vérifier si les conteneurs du cluster K3d existent encore (même arrêtés) ou ont complètement disparu. (2) Si les conteneurs existent mais sont arrêtés, un simple `docker start` ou `k3d cluster start NOM_CLUSTER` devrait suffire à les relancer sans perte de données. (3) Si les conteneurs ont véritablement disparu (improbable sauf configuration explicite de nettoyage automatique au démarrage du système, ou utilisation de `--rm` lors de la création), cela suggère que Docker lui-même n'a pas démarré automatiquement au boot de la machine hôte avant que K3d n'ait pu vérifier leur état, ou une configuration système de nettoyage automatique des conteneurs arrêtés à redémarrer.

**Corrigé 7.43 — kubectl logs vide**
Démarche : (1) Vérifier que l'application écrit réellement ses logs sur stdout/stderr (sortie standard du conteneur) et non dans un fichier interne au conteneur, seul cas où `kubectl logs` peut effectivement capturer quelque chose nativement sans configuration additionnelle. (2) Vérifier `kubectl logs NOM_POD --previous` au cas où le conteneur aurait redémarré très récemment sans que l'application n'ait encore eu le temps de produire de nouvelle sortie. (3) Vérifier que le pod contient bien un seul conteneur (sinon spécifier `-c NOM_CONTENEUR` explicitement, car sans cette précision avec plusieurs conteneurs, le comportement par défaut de quel conteneur cibler peut varier). (4) `kubectl exec` dans le pod pour vérifier manuellement si l'application elle-même tourne et produit effectivement une activité quelconque en temps réel.

**Corrigé 7.44 — readinessProbe en échec**
Démarche centrée sur les probes : (1) `kubectl describe pod NOM_POD` et chercher spécifiquement dans les Events les messages liés à "Readiness probe failed", qui révèlent généralement directement la raison exacte (timeout, code de retour HTTP différent de 2xx attendu, connexion refusée sur le port testé). (2) Vérifier manuellement, via `kubectl exec`, que le chemin et le port définis dans le `readinessProbe` du manifeste correspondent EXACTEMENT à ce que l'application expose réellement à l'intérieur du conteneur (faute de frappe dans le chemin, port incorrect). (3) Vérifier le délai `initialDelaySeconds` : si l'application a besoin de plus de temps pour démarrer réellement que ce délai initial configuré, les premières vérifications échoueront systématiquement avant même que l'application n'ait eu la chance de devenir réellement prête.

**Corrigé 7.45 — Versions K3s en conflit après réinstallation**
Symptôme côté worker : le worker pourrait échouer à se connecter avec des erreurs de compatibilité de version ou de protocole (par exemple un format de communication interne différent entre les versions), ou dans certains cas se connecter apparemment mais avec des comportements instables/incohérents (fonctionnalités manquantes ou différentes selon la version effective de chacun). Démarche de diagnostic : comparer explicitement `k3s --version` exécuté sur le serveur ET sur le worker pour confirmer une éventuelle divergence, et vérifier que le `node-token` utilisé correspond bien au moment de cette installation actuelle du serveur (un ancien token généré par une précédente installation avant réinstallation pourrait être devenu invalide ou incompatible avec la nouvelle instance du serveur).

**Corrigé 7.46 — 0 CPU disponible**
Démarche : penser effectivement à la sur-allocation CUMULÉE : si plusieurs VMs sont déjà actives simultanément (par exemple celles du projet p1/ ET p2/ lancées en parallèle par erreur, ou simplement plusieurs VMs du même projet), la somme totale des CPU virtuels alloués à TOUTES ces VMs actives peut dépasser ce que l'hôte peut raisonnablement fournir selon sa configuration de virtualisation, même si chaque VM individuellement demande un nombre de CPU modeste et raisonnable. Vérifier `vboxmanage list runningvms` pour identifier toutes les VMs actuellement actives, et `vagrant halt` celles qui ne sont pas strictement nécessaires au moment présent pour libérer des ressources CPU avant de retenter le démarrage de la nouvelle VM.

**Corrigé 7.47 — No space left on device pendant provisioning**
Démarche : (1) `df -h` sur la VM elle-même pour confirmer l'épuisement réel de l'espace disque ALLOUÉ à cette VM (différent de l'espace disque de la machine hôte). (2) Vérifier la taille du disque virtuel configurée pour cette box/VM, qui peut être insuffisante par défaut pour l'ensemble des opérations cumulées (téléchargement K3s, images de conteneurs système, logs). (3) Sur la machine HÔTE également, `df -h` pour vérifier que ce n'est pas plutôt l'espace disque physique de l'hôte lui-même qui est épuisé (affectant indirectement la capacité du disque virtuel dynamique de la VM à grossir comme prévu). (4) Nettoyer l'espace si possible (`apk cache clean`, suppression d'anciennes images/boxes Vagrant inutilisées) ou augmenter la taille du disque virtuel alloué si la box/configuration le permet.

**Corrigé 7.48 — Argo CD Synced mais ancienne version visible**
Démarche : penser spécifiquement à `imagePullPolicy` et au cache local de l'image — si ce champ est absent ou réglé sur `IfNotPresent` plutôt que `Always`, et que la NOUVELLE image porte exactement le MÊME tag que l'ancienne (par exemple toutes les deux taguées simplement "latest" ou un tag réutilisé sans changement), le kubelet/container runtime pourrait se contenter de réutiliser l'ancienne image déjà présente en cache local sur le nœud, sans la retélécharger, même si Argo CD a correctement appliqué le changement de manifeste YAML (qui, lui, ne change peut-être même pas si le tag reste identique). Vérifier et corriger en utilisant des tags explicitement DIFFÉRENTS pour chaque version (v1, v2, comme fait dans le projet), garantissant que chaque changement de version corresponde à un changement réel et détectable du nom d'image complet.

**Corrigé 7.49 — K3s ne redémarre pas après reload**
Démarche : penser à la configuration OpenRC du service — vérifier si le service k3s a bien été ajouté au runlevel par défaut pour démarrer automatiquement au boot (`rc-update show` pour lister les services activés par runlevel, en cherchant k3s dans la liste). Si l'installation initiale de K3s a configuré correctement ce démarrage automatique (ce qui est le comportement normal du script d'installation officiel), un simple `vagrant reload` (qui redémarre l'OS de la VM) DEVRAIT normalement relancer K3s automatiquement avec le reste du système — si ce n'est pas le cas, vérifier explicitement avec `rc-update show default` que k3s y figure bien, et sinon l'ajouter manuellement avec `rc-update add k3s default`.

**Corrigé 7.50 — GitLab Runner introuvable pour CI/CD**
Démarche et lien avec la configuration Helm : ce symptôme est directement lié au fait que l'installation Helm de GitLab effectuée dans le cours a explicitement désactivé le composant GitLab Runner via l'option `--set gitlab-runner.install=false`, précisément pour économiser des ressources non essentielles à la démonstration du GitOps avec Argo CD. Pour activer le CI/CD GitLab fonctionnel, il faudrait soit réinstaller/mettre à jour le déploiement Helm en passant cette fois `gitlab-runner.install=true` (avec les ressources supplémentaires que cela implique), soit déployer un GitLab Runner de façon totalement indépendante et le connecter manuellement à cette instance GitLab via un token d'enregistrement de runner généré depuis l'interface d'administration GitLab.

---

*Fin du corrigé de la Partie 7 (Debugging). Le corrigé de la Partie 8 (Oral blanc) suit — c'est la dernière section du document.*
# CORRIGÉ PARTIE 8 — ORAL BLANC 42

**R1.** Réponse libre attendue couvrant : Vagrant pour les VMs (Partie 1), K3s manuel avec serveur/worker, applications avec Ingress/Traefik (Partie 2), puis K3d + Argo CD pour le GitOps (Partie 3), et éventuellement le bonus GitLab. L'évaluateur attend une présentation fluide, structurée, sans relire de notes, démontrant une vision d'ensemble claire avant tout détail technique.

**R2. [PIÈGE]** Affirmation fausse à corriger : K3s utilise **SQLite** par défaut, pas etcd. etcd reste disponible en option pour des déploiements HA multi-serveurs, mais n'est absolument pas le choix par défaut de K3s, contrairement à Kubernetes standard où etcd est effectivement la norme. Un bon candidat doit corriger immédiatement cette affirmation erronée plutôt que de la confirmer par complaisance.

**R3.** Alpine est plus légère (taille, RAM, démarrage), utilise musl libc et BusyBox, adaptée aux contraintes de ressources du projet, contrairement à Ubuntu plus lourde mais plus proche d'un environnement de production "classique".

**R4.** Réponse attendue avec lecture directe du Vagrantfile réel de l'étudiant : `server.vm.network "private_network", ip: SERVER_IP`, expliquant le type de réseau (host-only) et le rôle de l'IP fixe.

**R5.** Non, par défaut `private_network` n'offre PAS d'accès Internet : c'est précisément l'interface NAT (créée automatiquement séparément) qui assure cet accès sortant. private_network est volontairement isolé pour la communication interne hôte/VMs uniquement.

**R6.** `kubectl get pods -A` (ou `--all-namespaces`).

**R7. [PIÈGE]** Confusion à corriger : kubectl est un CLIENT, exécuté ponctuellement à chaque commande tapée par l'utilisateur — il ne tourne JAMAIS en permanence comme un service/daemon sur le serveur. C'est l'API Server (composant serveur, lui, bien permanent) que kubectl contacte à chaque appel.

**R8.** Le Deployment (via son ReplicaSet) détecte que le nombre de pods réels est tombé sous le nombre désiré, et crée immédiatement un nouveau pod identique pour compenser — le pod supprimé manuellement est donc rapidement "remplacé" par un nouveau pod (avec une nouvelle identité/IP), pas littéralement ressuscité.

**R9.** `vagrant halt` éteint proprement l'OS de la VM (conservant le disque, libérant RAM/CPU) ; `vagrant destroy` supprime DÉFINITIVEMENT la VM et son disque, nécessitant une recréation complète depuis zéro au prochain `vagrant up`.

**R10. [PIÈGE]** À vérifier avec le candidat : le sujet du projet Partie 2 utilise typiquement un Service de type ClusterIP combiné à un Ingress, pas nécessairement NodePort. Le candidat doit confirmer EXACTEMENT ce qu'il a réellement implémenté plutôt que de suivre l'affirmation de la question sans vérification — c'est un test d'honnêteté et de connaissance précise de son propre travail.

**R11.** Unique à chaque cluster K3s : le token est généré aléatoirement lors de l'installation initiale du serveur, spécifique à cette instance précise du cluster, jamais partagé ou identique entre différents clusters K3s indépendants.

**R12.** Pour démontrer concrètement le load balancing et la résilience de Kubernetes via plusieurs réplicas identiques derrière un seul Service, contrairement aux deux autres applications qui n'illustrent pas spécifiquement cet aspect.

**R13.** Colonnes supplémentaires : INTERNAL-IP, EXTERNAL-IP, OS-IMAGE, KERNEL-VERSION, CONTAINER-RUNTIME — informations absentes de l'affichage par défaut.

**R14. [PIÈGE]** À vérifier : les scripts du projet utilisent typiquement `#!/bin/sh` (POSIX, compatible Alpine/ash), pas `#!/bin/bash` (qui n'est généralement pas installé par défaut sur Alpine et nécessiterait une installation supplémentaire). Le candidat doit vérifier et corriger cette affirmation selon ce qu'il a réellement écrit.

**R15.** `[ ]` est POSIX standard (fonctionne sur ash/BusyBox d'Alpine) ; `[[ ]]` est une extension bash spécifique non supportée par défaut sur le `/bin/sh` d'Alpine, provoquant une erreur si utilisée dans un script déclaré `#!/bin/sh` exécuté sur ce système.

**R16.** Oui, comme observé dans la Partie 1 du projet où la VM serveur assume simultanément le rôle de Control Plane ET exécute des pods (système, voire applicatifs), visible via le rôle `control-plane,master` dans `kubectl get nodes` tout en hébergeant des pods comme CoreDNS.

**R17.** `set -e` arrête le script dès la première commande en échec, évitant qu'il continue sur un état incohérent. Exemple pertinent : un `curl | sh -` pour installer K3s qui échouerait silencieusement sans `set -e`, laissant le script continuer comme si K3s était installé alors qu'il ne l'est pas, menant à des erreurs bien plus tard et déconnectées de la cause réelle.

**R18. [PIÈGE]** Erreur à corriger : `nginx.ingress.kubernetes.io/rewrite-target` est une annotation spécifique au contrôleur **Nginx Ingress**, pas à Traefik (utilisé par défaut dans K3s). Si le candidat a réellement utilisé Traefik (cas par défaut du projet), cette annotation n'aurait simplement aucun effet : il faut vérifier et corriger quel Ingress Controller est réellement utilisé.

**R19.** Les deux Deployments tenteraient de gérer/réclamer les mêmes pods correspondant à ce selector partagé, provoquant des comportements de gestion incohérents et conflictuels (chacun pourrait tenter de "corriger" le nombre de réplicas selon sa propre vision, créant une instabilité).

**R20.** TCP orienté connexion et fiable (utilisé par l'API K3s sur le port 6443, HTTP des applications) ; UDP sans connexion et sans garantie (moins présent explicitement dans ce projet, mais utilisé par exemple par DNS pour de petites requêtes).

**R21.** 254 adresses hôtes utilisables (256 - 2 pour réseau et broadcast).

**R22.** Sans cette attente, le worker tenterait de lire un fichier token inexistant, provoquant une erreur immédiate (cp/cat échoue) avant même d'avoir pu tenter la jonction au cluster — l'attente garantit que le serveur a eu le temps de générer ce fichier avant que le worker n'essaie de l'utiliser.

**R23. [PIÈGE]** Affirmation à corriger fermement : Docker Swarm n'a jamais été demandé ni pertinent dans ce projet, qui utilise K3s/K3d (Kubernetes), un système d'orchestration totalement différent de Docker Swarm. Le candidat ne doit jamais confirmer une confusion technologique aussi fondamentale.

**R24.** `kubectl get endpoints NOM_SERVICE` — si la liste retournée n'est pas vide, des pods sont effectivement associés au Service.

**R25.** Pour simuler le routage par nom de domaine sans nécessiter une vraie configuration DNS ou un nom de domaine réellement enregistré, simplifiant les tests dans un environnement local isolé sans accès Internet public nécessaire pour cette démonstration.

**R26.** K3s est une distribution Kubernetes complète tournant sur des VMs ou machines physiques classiques ; K3d fait tourner K3s À L'INTÉRIEUR de conteneurs Docker, offrant un déploiement encore plus rapide et léger pour le développement/test local.

**R27. [PIÈGE]** À vérifier : le sujet du projet exige normalement une synchronisation AUTOMATIQUE (via `syncPolicy.automated`), pas manuelle. Si le candidat a configuré Argo CD en mode manuel uniquement, cela ne respecterait pas l'exigence implicite du sujet de démonstration automatique du GitOps ; il doit vérifier honnêtement sa configuration réelle.

**R28.** Un ReplicaSet garantit qu'un nombre spécifié de pods identiques (selon un template) tournent en permanence ; il est généré et géré automatiquement par un Deployment, qui l'utilise comme mécanisme interne, notamment lors des rolling updates où plusieurs ReplicaSets coexistent temporairement.

**R29.** Le masque détermine quelle portion de l'adresse désigne le réseau et laquelle désigne l'hôte ; sans lui, on ne peut pas savoir où s'arrête le réseau local pour déterminer si une communication directe est possible ou nécessite un routage.

**R30.** Réponse personnelle attendue, typiquement le décalage entre la version des Guest Additions intégrées à la box (par exemple 7.0.2) et la version de VirtualBox installée sur l'hôte (par exemple 7.2), provoquant des dysfonctionnements des dossiers partagés.

**R31. [PIÈGE]** À vérifier honnêtement : 512 Mo est probablement insuffisant pour K3s v1.35 récent (comme observé concrètement dans le débogage réel du projet, nécessitant souvent une augmentation à 1024-2048 Mo). Le candidat doit confirmer la configuration RÉELLEMENT utilisée et fonctionnelle, pas une valeur théorique minimale qui aurait pu être abandonnée en pratique suite à des problèmes de lenteur.

**R32.** `mount | grep NOM` (vérifie les montages actifs réels) plutôt que simplement `ls -d /chemin` (qui confirmerait juste l'existence du dossier, potentiellement vide et non monté du tout, ce qui ne prouve rien sur le fonctionnement réel du partage).

**R33.** Les versions récentes de K3s (depuis environ v1.26) sécurisent l'endpoint `/healthz`, exigeant une authentification et retournant 401 sans elle. Adaptation : vérifier la présence de "Unauthorized" (ou simplement qu'une réponse HTTP quelconque est reçue) plutôt que de chercher strictement "ok" qui ne sera jamais retourné sur ces versions récentes.

**R34. [PIÈGE]** Confusion à clarifier : le kubeconfig contient des CERTIFICATS clients (client-certificate-data, client-key-data) pour l'authentification TLS mutuelle, pas un mot de passe au sens traditionnel. C'est un mécanisme cryptographique différent, et le candidat doit éviter de simplifier excessivement en parlant de "mot de passe".

**R35.** Une socket est définie formellement par la combinaison adresse IP + port + protocole (TCP ou UDP), identifiant de façon unique un point de communication réseau.

**R36.** Pour laisser le temps à K3s de finaliser son initialisation complète (base de données, certificats TLS, démarrage des composants internes comme Traefik/CoreDNS) avant de tester l'API, évitant des tests prématurés qui échoueraient systématiquement si effectués trop tôt.

**R37. [PIÈGE]** Erreur à corriger : K3s utilise **Flannel** comme CNI par défaut, pas Calico. Calico est un CNI alternatif possible dans Kubernetes standard, mais n'est absolument pas le choix par défaut de K3s. Le candidat doit corriger cette affirmation erronée plutôt que de tenter de justifier un choix qu'il n'a probablement jamais réellement fait.

**R38.** `apk` est spécifique à Alpine (basé sur des paquets .apk, gestion différente des dépendances), `apt` est spécifique à Debian/Ubuntu (paquets .deb) — au-delà du nom, ce sont des écosystèmes de paquets et des formats de distribution complètement distincts et non interchangeables.

**R39.** `INSTALL_K3S_EXEC` permet de passer des arguments/flags additionnels directement à la commande d'installation de K3s (comme `--node-ip`, `--bind-address`, `--advertise-address`), personnalisant ainsi le comportement de l'installation au-delà des valeurs par défaut.

**R40.** Pas nécessairement un problème : `Completed` indique typiquement qu'un pod de type Job (tâche ponctuelle censée se terminer) a terminé son exécution avec succès, ce qui est l'état NORMAL et attendu pour ce type de ressource — contrairement à un Deployment où un pod en `Completed` inattendu serait anormal et nécessiterait investigation.

**R41.** Pour que le worker puisse prouver son autorisation à rejoindre CE cluster précis : le token agit comme un secret partagé connu uniquement par le serveur légitime, empêchant n'importe quelle machine de rejoindre arbitrairement le cluster sans cette preuve d'autorisation provenant directement du serveur lui-même.

**R42.** `$?` contient le code de sortie (exit code) de la DERNIÈRE commande exécutée, une valeur numérique de 0 (succès) à 255 (divers types d'échec selon la commande).

**R43. [PIÈGE]** Erreur de conception à signaler : un backend Ingress doit toujours pointer vers un **Service** Kubernetes (`backend.service.name`), jamais directement vers une IP de pod individuel. Si le candidat affirme avoir fait cela, c'est soit une erreur de configuration réelle à corriger, soit une confusion dans sa compréhension de l'architecture qu'il doit clarifier immédiatement.

**R44.** `git push` → Argo CD détecte le changement (polling périodique ou webhook) → compare l'état Git désiré à l'état cluster réel → détecte une différence (OutOfSync) → applique automatiquement les changements (si syncPolicy.automated) → le Deployment effectue un rolling update → le nouveau pod avec la nouvelle image remplace l'ancien.

**R45.** `prune: true` peut être dangereux si mal compris car il SUPPRIME automatiquement, dans le cluster réel, toute ressource qui a été retirée du dépôt Git — une suppression accidentelle ou mal anticipée d'un fichier YAML dans le repo pourrait ainsi entraîner la suppression automatique et inattendue de ressources réelles potentiellement critiques en production.

**R46.** Non, le sujet n'impose pas explicitement que `config.vm.box` soit identique pour toutes les VMs (c'est syntaxiquement possible de les différencier comme vu dans l'exercice 4.28), mais c'est une bonne pratique fortement recommandée pour la cohérence du cluster que le candidat doit pouvoir justifier indépendamment de toute exigence stricte du texte du sujet lui-même.

**R47.** `kubectl apply` crée OU met à jour une ressource (idempotent, peut être relancé sans erreur) ; `kubectl create` ne fait que créer, et échoue si la ressource existe déjà — `apply` est généralement préféré en pratique et dans les scripts d'automatisation pour cette raison.

**R48.** Pour éviter qu'une variable vide ou contenant des espaces ne provoque une erreur de syntaxe du test `[ ]` en réduisant le nombre d'arguments attendus après expansion de la variable.

**R49. [PIÈGE]** Affirmation fausse à corriger : Kubernetes natif ne centralise PAS automatiquement les logs de tous les pods par défaut — chaque pod garde ses propres logs localement (accessibles via `kubectl logs`), sans agrégation centralisée native. Une solution de logging centralisé (comme la stack EFK/ELK, ou Loki) doit être déployée séparément pour obtenir cette fonctionnalité, qui n'est pas native à K8s/K3s.

**R50.** Réponse personnelle attendue, typiquement liée au décalage de version des Guest Additions VirtualBox empêchant le montage automatique correct de `/vagrant`, ou à l'absence de déclaration `synced_folder` au niveau global du Vagrantfile pour toutes les VMs.

**R51.** Non, sans gateway/routeur explicite reliant ces deux sous-réseaux distincts, ils ne peuvent pas communiquer directement : ce sont deux segments réseau séparés au sens de leur masque /24 respectif, nécessitant un routage explicite pour les interconnecter.

**R52.** Parce que ces pods système résident dans le namespace `kube-system`, distinct du namespace `default` ciblé implicitement par `kubectl get pods` sans précision — il faut explicitement utiliser `-n kube-system` ou `-A` pour les voir apparaître.

**R53.** Réponse personnelle, typiquement non nécessaire car les applications de la Partie 2 sont stateless (sans besoin de stockage persistant entre redémarrages de pods) ; un simple Deployment sans volume persistant suffit pour ce type de démonstration de routage/load-balancing.

**R54.** `vagrant provision` exécute le script DANS le contexte géré de Vagrant, garantissant cohérence avec la configuration définie (variables d'environnement, contexte d'exécution standard) ; relancer manuellement via SSH peut omettre certains aspects de ce contexte automatisé, bien que le résultat final puisse être similaire pour un script simple.

**R55.** `-sk` (s=silent, k=insecure) ignore la vérification de la chaîne de certification TLS, acceptant des certificats auto-signés ou non vérifiables sans erreur. En production, cela exposerait à un risque d'attaque de l'homme du milieu (MITM), où un certificat malveillant non détecté pourrait intercepter le trafic chiffré sans alerte.

**R56. [PIÈGE]** Erreur à corriger immédiatement : le port standard de l'API K3s/Kubernetes est **6443**, pas 8080. Le candidat doit confirmer la valeur réellement utilisée dans son propre projet plutôt que de valider cette affirmation incorrecte.

**R57.** Pour éviter une latence réseau systématique à chaque `vagrant up` due à la vérification de mise à jour de la box auprès de Vagrant Cloud, gagnant en rapidité et fiabilité particulièrement en contexte de soutenance où le réseau peut être limité.

**R58.** `INSTALL_K3S_VERSION` fixe une version EXACTE et précise de K3s à installer ; `INSTALL_K3S_CHANNEL` sélectionne un canal de publication (comme "stable" ou "latest"), qui peut référencer une version différente au fil du temps selon les nouvelles publications sur ce canal — la première garantit une reproductibilité totale, la seconde reste potentiellement variable.

**R59.** GitOps : Git comme source de vérité unique, où tout changement d'infrastructure passe par un commit, synchronisé automatiquement vers le système réel. Exemple Partie 3 : modifier `deployment.yaml` (v1→v2) et `git push` déclenche automatiquement la mise à jour du pod réel via Argo CD, sans intervention manuelle de `kubectl apply`.

**R60.** Réponse personnelle souvent affirmative (l'installation par défaut d'Argo CD accorde généralement des permissions cluster-admin étendues) ; l'implication de sécurité est qu'Argo CD, ainsi configuré, a la capacité de modifier potentiellement N'IMPORTE QUELLE ressource du cluster, ce qui en production nécessiterait normalement une restriction plus fine via RBAC, bien que ce ne soit pas un enjeu critique dans ce contexte pédagogique isolé.

**R61.** ICMP (ping) et TCP sont des protocoles indépendants gérés par des règles de pare-feu potentiellement distinctes ; bloquer ICMP n'affecte en rien la capacité du trafic TCP à transiter normalement sur un port spécifiquement autorisé.

**R62.** Non, le sujet n'impose généralement pas exclusivement Docker Hub : tout registre accessible publiquement (GitHub Container Registry, GitLab Registry, etc.) serait techniquement acceptable, à condition que l'image soit effectivement accessible par le cluster pour le téléchargement.

**R63.** `argocd app sync NOM_APPLICATION` (via la CLI Argo CD authentifiée), forçant une synchronisation immédiate sans attendre le prochain cycle de polling automatique périodique.

**R64.** Pas toujours strictement équivalentes en lisibilité, même si logiquement inversibles : `until [ -f "$FICHIER" ]` est plus naturel pour exprimer "attendre jusqu'à ce que le fichier existe" que l'équivalent `while [ ! -f "$FICHIER" ]` qui nécessite une double négation mentale (tant que PAS), légèrement moins immédiate à lire.

**R65.** Avantage : contourne les problèmes de Guest Additions/dossiers partagés VirtualBox. Compromis : ajoute une dépendance à un port réseau supplémentaire ouvert, une complexité de script additionnelle (gestion du serveur HTTP en arrière-plan), et un léger délai de configuration supplémentaire par rapport à un dossier partagé natif fonctionnel.

**R66.** Le sujet recommande généralement le minimum nécessaire sans imposer une limite stricte universelle de RAM identique pour chaque VM ; le candidat doit citer le texte précis du sujet utilisé pour son école/version spécifique, qui mentionne typiquement des valeurs recommandées (souvent autour de 512 Mo-1024 Mo) plutôt qu'une contrainte absolue unique.

**R67.** Sans ce flag, le fichier kubeconfig généré (`/etc/rancher/k3s/k3s.yaml`) aurait des permissions restrictives par défaut (lisible uniquement par root), empêchant un utilisateur normal d'exécuter `kubectl` sans `sudo` à chaque commande — ce flag rend le fichier lisible (mode 644) pour simplifier l'usage quotidien.

**R68.** Réponse personnelle, généralement non implémenté dans ce projet car SQLite stocke ses données directement sur le disque virtuel de la VM elle-même (pas dans un volume Kubernetes séparé) ; ce n'est pertinent que si l'on souhaite explicitement faire survivre les données K3s à une destruction complète de la VM, ce qui n'est généralement pas l'objectif pédagogique de cette partie du projet.

**R69.** `kubectl rollout restart` force un redémarrage progressif (rolling) de tous les pods d'un Deployment sans changer la configuration elle-même (image, variables...), utile pour forcer une relecture de configuration externe (ConfigMap modifié) ou simplement résoudre un état dégradé sans modification de version.

**R70.** Non exclusivement, mais Helm est largement recommandé pour sa simplicité (une commande contre des dizaines de manifestes YAML manuels complexes à gérer individuellement pour une application aussi complexe que GitLab) ; d'autres méthodes (manifestes manuels, Kustomize) seraient théoriquement possibles mais bien plus laborieuses pour ce cas précis.

**R71.** `kubectl logs pod` montre les logs du conteneur ACTUEL en cours d'exécution ; `--previous` montre spécifiquement les logs de l'INSTANCE PRÉCÉDENTE du conteneur, avant son dernier redémarrage — très utile pour diagnostiquer la cause d'un crash juste avant un redémarrage automatique.

**R72.** Vérifier immédiatement `kubectl get pods` pour l'état exact des 3 pods attendus (un pourrait être en Pending, CrashLoopBackOff, ou en cours de remplacement), et `kubectl describe deployment` pour voir si un rolling update est en cours ou si une erreur de ressources empêche le 3ème pod de démarrer correctement sur les nœuds disponibles.

**R73.** Si les Guest Additions ne correspondent pas à la version VirtualBox de l'hôte, le mécanisme vboxsf sous-jacent au dossier partagé peut ne pas fonctionner correctement, empêchant le worker d'accéder au fichier token copié par le serveur dans ce dossier supposément partagé, bloquant ainsi toute la chaîne de jonction du cluster qui en dépend.

**R74.** K3S_URL doit pointer vers l'IP **private_network** de la VM serveur (192.168.56.110), car c'est cette interface qui est explicitement configurée pour la communication inter-VMs fixe et prévisible dans ce projet, contrairement à l'IP NAT qui est typiquement identique (10.0.2.15) pour toutes les VMs et non distinctive/adressable de l'extérieur de chaque VM individuelle.

**R75.** Réponse honnête attendue : un bon candidat devrait effectivement avoir testé ce scénario de redémarrage complet pour s'assurer de la robustesse de sa configuration, notamment vérifier que les scripts de provisioning ne sont pas relancés par erreur de façon destructive (sans `run: "always"` non désiré) et que l'état du cluster persiste correctement après un simple `vagrant reload` sans `--provision`.

**R76.** Parce que kubectl ne conserve aucune session ou mémoire entre deux invocations : chaque commande kubectl établit une nouvelle connexion HTTP indépendante vers l'API Server, récupère ou envoie les données nécessaires pour CETTE requête précise, puis se termine sans garder le moindre état pour l'appel suivant, contrairement à un client avec état (stateful) qui maintiendrait une session continue.

**R77.** Non typiquement pas configuré dans ce projet, car le sujet ne l'exige pas explicitement et l'objectif pédagogique se concentre sur les concepts fondamentaux (Deployment, Service, Ingress) plutôt que sur la sécurisation avancée du trafic réseau inter-pods, qui serait un sujet plus avancé hors du périmètre principal visé.

**R78.** Le rolling update remplace progressivement, pod par pod, les anciennes instances par les nouvelles (avec la nouvelle image définie), en respectant les contraintes `maxSurge`/`maxUnavailable` pour garantir la disponibilité continue du service pendant toute la transition, sans interruption brutale et complète comme le ferait une stratégie "Recreate".

**R79.** Parce que K3s installe automatiquement, lors de son démarrage initial, plusieurs composants système essentiels au fonctionnement du cluster (CoreDNS pour le DNS interne, Traefik pour l'Ingress, metrics-server pour les métriques, local-path-provisioner pour le stockage) — ces pods sont créés par K3s lui-même comme partie intégrante de l'installation, pas explicitement par l'utilisateur.

**R80.** Réponse à vérifier avec la configuration réelle du candidat ; typiquement le Service écoute sur le port 80 (`port: 80`) tandis que le conteneur applicatif écoute réellement sur un port différent (par exemple 8080), avec un `targetPort` faisant la traduction entre les deux, sauf si volontairement configurés identiques par simplicité.

**R81.** Le sujet recommande généralement un nombre minimal de CPU (souvent 1 CPU par VM) sans imposer de maximum strict, l'esprit étant de rester économe en ressources plutôt que d'imposer une limite haute particulière — le candidat doit citer la formulation précise utilisée dans le texte du sujet de SON école.

**R82.** Avantage : moins de complexité réseau à gérer (une seule machine, pas de communication inter-VM à orchestrer) et un déploiement plus rapide. Inconvénient potentiel : moins représentatif d'une architecture distribuée réelle multi-nœuds, et toutes les ressources (CPU/RAM) doivent être partagées par une seule machine pour héberger à la fois le Control Plane et toutes les applications déployées.

**R83.** Cette erreur est insidieuse car elle ne produit AUCUN message d'erreur shell explicite et immédiat : le script continue son exécution normalement en apparence (pas de crash visible), K3s "semble" s'être installé sans incident signalé, et ce n'est que BIEN PLUS TARD, lors d'une tentative complètement différente (comme `kubectl get nodes` qui timeout), que le symptôme apparaît, rendant le lien de causalité avec ce bug syntaxique initial très difficile à établir sans une relecture attentive et méthodique du script complet.

**R84.** `sh script.sh` exécute explicitement le script avec l'interpréteur `sh`, peu importe le shebang déclaré en première ligne du fichier (qui est alors ignoré). `./script.sh` (avec permission d'exécution) utilise le SHEBANG du fichier lui-même pour déterminer quel interpréteur utiliser réellement — un script avec `#!/bin/bash` exécuté via `./script.sh` utiliserait réellement bash, tandis que le forcer via `sh ./script.sh` l'exécuterait avec sh même si le shebang indique bash, pouvant changer le comportement si le script utilise des syntaxes spécifiques à bash non supportées par sh.

**R85.** Non, K3s n'inclut pas le Kubernetes Dashboard par défaut. Pour visualiser l'état du cluster, on utilise principalement kubectl en ligne de commande (`get`, `describe`), éventuellement complété par des outils tiers installés séparément (Lens, K9s, ou le Dashboard officiel installable manuellement si désiré, mais non fourni nativement par K3s).

**R86.** `kubectl get pods --watch` établit une connexion persistante vers l'API Server qui PUSH en temps réel les changements d'état dès qu'ils surviennent (création, suppression, changement de statut), sans délai d'attente entre chaque mise à jour. Un script relançant `kubectl get pods` en boucle (polling) interroge à intervalles fixes, pouvant manquer des changements survenus entre deux interrogations, et générant une charge réseau/API répétitive inutile comparée à la connexion unique et continue de `--watch`.

**R87.** La règle par défaut (sans `host` spécifié dans le manifeste Ingress) doit être positionnée en DERNIER dans la liste des règles, afin de ne capturer QUE le trafic qui n'a correspondu à AUCUNE des règles plus spécifiques précédentes (app1.com, app2.com), agissant ainsi comme un véritable "fallback" plutôt que d'intercepter prématurément du trafic destiné aux règles plus spécifiques si elle était placée avant elles.

**R88.** Cette précision illustre que les noms d'interfaces réseau peuvent varier selon le système, la version du noyau, et la méthode de nomination utilisée (les noms prédictibles comme `enp0s8` étant la norme sur les systèmes Linux modernes via systemd-udev, contrairement aux noms traditionnels `eth0`/`eth1` plus anciens) — le candidat doit savoir adapter son interprétation des captures du sujet à ce qu'il observe réellement sur SON propre système, qui peut différer légèrement sans que cela indique un problème.

**R89.** Un build multi-stage utilise PLUSIEURS instructions `FROM` dans un même Dockerfile, permettant de compiler/préparer l'application dans une première étape (avec tous les outils de build nécessaires, potentiellement lourds), puis de copier UNIQUEMENT les artefacts finaux nécessaires dans une image finale beaucoup plus légère (sans les outils de compilation), réduisant significativement la taille de l'image de production finale par rapport à un build classique en un seul stage qui inclurait tous les outils de build dans l'image finale.

**R90.** Réponse personnelle attendue, exemple typique : `kubectl exec -it NOM_POD -- /bin/sh` pour ouvrir un shell interactif à l'intérieur du conteneur en cours d'exécution, permettant d'inspecter directement les fichiers, processus, ou configuration réseau interne pour diagnostiquer un comportement inattendu.

**R91.** Parce qu'il n'y a qu'UNE SEULE instance du Control Plane (un seul serveur K3s) : en cas de panne de cette unique machine, l'ensemble du cluster perd sa capacité de gestion centrale, contrairement à une architecture HA véritable qui répliquerait le Control Plane sur plusieurs machines (via etcd distribué notamment) pour tolérer la panne d'une instance sans interruption de service globale.

**R92.** Si le worker reste sur une ancienne version pendant que le serveur a été mis à jour (ou inversement), des incompatibilités de protocole de communication interne, de format de certificats, ou de comportement API peuvent survenir, le worker pouvant échouer à communiquer correctement avec le serveur ou présenter des comportements instables/incohérents malgré une jonction apparemment réussie initialement.

**R93. [PIÈGE]** À vérifier précisément avec le texte du sujet réel : généralement, le bonus GitLab peut effectivement tourner sur la même instance K3d que la Partie 3 (économisant des ressources et simplifiant la démonstration), mais le candidat doit citer la formulation EXACTE de son sujet plutôt que de supposer une contrainte qui pourrait ne pas être explicitement formulée ainsi.

**R94.** CIDR signifie "Classless Inter-Domain Routing" (routage inter-domaines sans classe), la notation moderne remplaçant l'ancien système de classes d'adresses IP rigides (A, B, C) par une notation flexible de préfixe (`/24` par exemple) indiquant directement le nombre de bits réservés à la partie réseau.

**R95.** Réponse honnête personnelle attendue, idéalement positive avec une démonstration concrète possible en direct devant l'évaluateur si demandé, prouvant une maîtrise réelle plutôt qu'une mémorisation de résultats déjà obtenus une seule fois.

**R96.** Pour vérifier que le candidat comprend réellement les MÉCANISMES de résilience automatique de Kubernetes (pas seulement qu'il sache les nommer théoriquement), en observant en temps réel devant l'évaluateur que la suppression d'un pod déclenche effectivement sa recréation automatique par le ReplicaSet/Deployment sous-jacent, démonstration bien plus convaincante et révélatrice qu'une simple explication verbale non vérifiée.

**R97. [PIÈGE]** À vérifier avec le texte exact du sujet : si le sujet impose effectivement des noms précis (`argocd`, `dev`), le candidat doit le confirmer en citant la formulation exacte ; si ce sont des conventions qu'il a lui-même choisies sans contrainte explicite du sujet, il doit le préciser honnêtement plutôt que d'attribuer une contrainte au sujet qui n'existerait pas réellement dans le texte.

**R98.** La Partie 1 (Vagrant + VMs + installation manuelle de K3s via scripts) ressemble à une gestion d'infrastructure traditionnelle où l'on provisionne et configure manuellement des serveurs, similaire à des pratiques on-premise historiques. La Partie 3 (conteneurs légers K3d + GitOps automatisé via Argo CD) illustre des pratiques bien plus modernes et caractéristiques du DevOps actuel : infrastructure as code poussée à l'extrême, déploiement continu automatisé sans intervention manuelle, conteneurisation légère plutôt que VMs lourdes.

**R99.** Réponse personnelle ouverte attendue, pistes possibles : ajout de haute disponibilité (multi-master), mise en place de monitoring (Prometheus/Grafana), renforcement de la sécurité (Network Policies, RBAC plus fin, scan de vulnérabilités des images), gestion de secrets plus robuste (Vault plutôt que Secrets Kubernetes basiques), tests automatisés (CI) en amont du déploiement GitOps.

**R100.** Réponse personnelle et réflexive attendue, sans notes, démontrant une compréhension synthétique et personnelle des apports du projet : automatisation de l'infrastructure, principes de l'orchestration de conteneurs pour la résilience et la scalabilité, et philosophie GitOps pour des déploiements traçables, reproductibles et fiables — illustrant concrètement des pratiques utilisées quotidiennement par des entreprises technologiques modernes pour gérer leurs applications en production à grande échelle.

---

*Fin du corrigé de la Partie 8 et de l'intégralité du document de correction.*

---

# 📊 RÉCAPITULATIF FINAL DU DOCUMENT

Ce document complet couvre :
- **120 QCM** corrigés en détail (Partie 1)
- **100 questions théoriques ouvertes** corrigées (Partie 2)
- **30 exercices d'analyse de scripts shell** corrigés (Partie 3)
- **30 exercices d'analyse de Vagrantfile/Ruby** corrigés (Partie 4)
- **50 exercices réseau** avec calculs CIDR corrigés (Partie 5)
- **50 exercices Kubernetes/K3s** corrigés (Partie 6)
- **50 scénarios de debugging** avec démarches complètes (Partie 7)
- **100 questions d'oral blanc** incluant des pièges identifiés et corrigés (Partie 8)

Soit un total de **530 éléments d'évaluation**, chacun avec son explication complète, conçu pour distinguer la compréhension réelle de l'apprentissage par cœur, conformément au niveau d'exigence attendu d'un évaluateur 42 expérimenté sur le projet Inception of Things.

**Conseil final** : si certaines réponses de ce corrigé t'ont surpris ou révélé une lacune, retourne relire le chapitre correspondant du cours complet avant ta soutenance — c'est exactement l'objectif pédagogique de cet exercice.
