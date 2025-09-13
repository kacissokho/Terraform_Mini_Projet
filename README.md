# Projet Terraform : Déploiement Automatisé de Jenkins sur AWS

## Contexte
Ce projet Terraform a pour objectif de déployer automatiquement un serveur Jenkins conteneurisé sur AWS. Il comprend plusieurs modules réutilisables permettant un déploiement facile et reproductible, avec export des métadonnées dans un fichier local.

## Architecture du Projet

### Modules Terraform Créés

1. **ec2_instance** - Instance EC2 Ubuntu Jammy
   - Taille et tags variabilisés
   - Attachement automatique EBS et IP publique
   - Installation automatique de Docker et Docker Compose

2. **ebs_volume** - Volume EBS persistant
   - Taille variabilisée
   - Attachement automatique à l'instance EC2

3. **public_ip** - Adresse IP élastique
   - Association automatique à l'instance
   - Enregistrement dans le fichier de sortie

4. **security_group** - Groupe de sécurité
   - Ouverture des ports 80 (HTTP), 443 (HTTPS) et 8080 (Jenkins)
   - Règles SSH configurables

5. **ssh_key** - Génération dynamique de paire de clés
   - Création automatique de clé SSH
   - Stockage sécurisé localement
   - Injection dans l'instance EC2

### Structure des Fichiers
```
terraform-jenkins-aws/
├── modules/
│   ├── ec2_instance/
│   ├── ebs_volume/
│   ├── public_ip/
│   ├── security_group/
│   └── ssh_key/
├── app/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── jenkins_ec2.txt
```

## Fonctionnalités Implémentées

### Déploiement Automatique
- Provisionnement d'une instance EC2 Ubuntu 22.04 LTS (Jammy)
- Attribution automatique d'une IP publique élastique
- Création et attachement d'un volume EBS persistant
- Configuration des règles de sécurité nécessaires

### Installation Jenkins Conteneurisé
- Installation automatique de Docker et Docker Compose
- Déploiement de Jenkins via Docker Compose au premier démarrage
- Configuration persistante via le volume EBS attaché

### Gestion des Secrets et Accès
- Génération automatique de paire de clés SSH
- Stockage sécurisé des clés privées
- Accès SSH configuré pour l'administration

### Export des Métadonnées
- Enregistrement automatique de l'IP publique dans `jenkins_ec2.txt`
- Capture du nom de domaine public dans le fichier de sortie
- Export des informations de connexion essentielles

## Utilisation

### Prérequis
- Compte AWS avec credentials configurés
- Terraform 0.14+ installé localement
- Accès en écriture pour créer les ressources AWS

### Déploiement
```bash
cd app/
terraform init
terraform apply
```

### Accès à Jenkins
Après le déploiement :
1. Consultez `jenkins_ec2.txt` pour l'IP publique
2. Accédez à Jenkins via : `http://<IP_PUBLIQUE>:8080`
3. Connectez-vous en SSH avec la clé générée
Jenkins Tableau de bord:
**![](https://github.com/kacissokho/Terraform_Mini_Projet/blob/master/Jenkins.png)**

### Personnalisation
Modifiez `app/terraform.tfvars` pour :
- Changer la taille de l'instance
- Ajuster la taille du volume EBS
- Personnaliser les tags
- Modifier les règles de sécurité

## Sécurité
- Clés SSH générées dynamiquement et stockées localement
- Groupes de sécurité restrictifs avec seulement les ports nécessaires ouverts
- Aucune information sensible commitée dans le repository

## Maintenance
- `terraform destroy` pour nettoyer toutes les ressources
- Les volumes EBS persistents conservent les données de Jenkins
- Mise à jour facile via modification des variables

Ce projet offre une solution complète et professionnelle pour le déploiement automatisé de Jenkins sur AWS avec une infrastructure as code maintenable et sécurisée.
