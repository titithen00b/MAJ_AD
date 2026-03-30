# 👥 MAJ_AD — Mise à jour Active Directory

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=for-the-badge)
![Windows Server](https://img.shields.io/badge/Windows-Server-0078D6?style=for-the-badge)
![Licence](https://img.shields.io/badge/Licence-MIT-green?style=for-the-badge)

Script PowerShell de mise à jour en masse des utilisateurs Active Directory. Permet de modifier les attributs des comptes AD (département, téléphone, manager, etc.) à partir d'une source de données externe (CSV, Excel).

---

## Fonctionnalités

- Mise à jour en masse des attributs utilisateurs AD
- Import depuis un fichier CSV
- Modification de : département, titre, téléphone, bureau, manager, etc.
- Logs des modifications effectuées et des erreurs
- Mode simulation (dry-run) pour vérifier avant d'appliquer

---

## Prérequis

- PowerShell 5.1 ou supérieur
- Module `ActiveDirectory` (RSAT)
- Droits en écriture sur les objets AD ciblés

Installer RSAT si nécessaire :

```powershell
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

---

## Installation

```powershell
git clone https://github.com/titithen00b/MAJ_AD.git
cd MAJ_AD
Unblock-File .\maj_userad.ps1
```

---

## Utilisation

### Lancement simple

```powershell
.\maj_userad.ps1
```

### Avec un fichier CSV personnalisé

```powershell
.\maj_userad.ps1 -CsvPath "C:\users\liste_users.csv"
```

---

## Format du fichier CSV

Le fichier CSV doit contenir au minimum une colonne `SamAccountName` (identifiant AD de l'utilisateur) :

```csv
SamAccountName,Department,Title,Phone,Office,Manager
jdupont,Informatique,Technicien,0123456789,Bureau 12,mmartin
mmartin,Direction,Directeur,0987654321,Bureau 1,
```

Colonnes supportées :

| Colonne CSV | Attribut AD |
|-------------|-------------|
| `SamAccountName` | Identifiant (obligatoire) |
| `Department` | Département |
| `Title` | Titre / fonction |
| `Phone` | Téléphone |
| `Office` | Bureau |
| `Manager` | Manager (SamAccountName) |
| `Description` | Description du compte |

---

## Fichiers du projet

| Fichier | Description |
|---------|-------------|
| `maj_userad.ps1` | Script principal de mise à jour |
| `README.md` | Documentation |

---

## Licence

MIT © Titithen00b
