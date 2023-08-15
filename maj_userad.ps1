<#
.SYNOPSIS
Mise à jour des attributs des utilisateurs Active Directory à partir d'un fichier CSV.

.DESCRIPTION
Ce script lit un fichier CSV contenant des attributs d'utilisateurs et met à jour les utilisateurs correspondants dans Active Directory. 
Si un attribut est vide dans le CSV, il sera vidé (nettoyé) dans Active Directory.

.PARAMETER csvPath
Chemin d'accès complet du fichier CSV. Par défaut, il est défini sur "C:\Utilisateurs.csv".

.PARAMETER debug
Active ou désactive le mode de débogage. Si défini sur 1, le débogage est activé et des informations supplémentaires seront affichées.
Si défini sur 0, le débogage est désactivé. Par défaut, il est défini sur 1.

.EXAMPLE
.\Mise a jour utilisateurs AD.ps1

Exécute le script en utilisant le chemin par défaut "C:\Utilisateurs.csv" et en mode débogage.

.EXAMPLE
.\Mise a jour utilisateurs AD.ps1 -csvPath "D:\Dossier\MonFichier.csv" -debug 0

Exécute le script en utilisant le fichier CSV spécifié et en désactivant le mode de débogage.

.NOTES
Nom du fichier : Mise a jour utilisateurs AD.ps1
Auteur : Valentin Roche
Date de création : 15/08/2023
Dernière mise à jour : 15/08/2023

#>

# Importer le module ActiveDirectory
Import-Module ActiveDirectory

# Paramètres du script

[string]$csvPath
[int]$debug

# Initialiser les variables avec des valeurs par défaut
if (-not $csvPath) {
    $csvPath = "C:\Utilisateurs.csv"
}

if (-not $debug) {
    $debug = 1
}


# Fonction pour afficher les messages de débogage
function Write-DebugMessage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    if ($debug -eq 1) {
        Write-Host "DEBUG: $Message"
    }
}

# Importer le CSV
$users = Import-Csv -Path $csvPath -Delimiter ";"
Write-DebugMessage "Fichier CSV importé"

# Chercher tous les utilisateurs avec le SamAccountName correspondant
$adUsers = Get-ADUser -Filter * -Properties SamAccountName, streetAddress, l, postalCode, title, department, company

# Parcourir chaque utilisateur dans le CSV
foreach ($user in $users) {
    Write-Host "" # Pour sauter une ligne entre chaque utilisateur
    Write-DebugMessage "Traitement de l'utilisateur $($user.SamAccountName)"

    # Utilisez Where-Object pour filtrer l'utilisateur correspondant
    $adUser = $adUsers | Where-Object { $_.SamAccountName -eq $user.SamAccountName }
    
    if ($adUser) {
        Write-DebugMessage "Utilisateur trouvé dans AD : $($adUser.SamAccountName)"

        $paramsToUpdate = @{
            'Identity' = $adUser.SamAccountName
        }

        $paramsToClear = @()

        # Mise à jour ou suppression des attributs selon la présence de la valeur dans le CSV
        if ($user.Adresse) {
            $paramsToUpdate['StreetAddress'] = $user.Adresse
        } else {
            $paramsToClear += 'StreetAddress'
        }

        if ($user.Ville) {
            $paramsToUpdate['City'] = $user.Ville
        } else {
            $paramsToClear += 'City'
        }

        if ($user.CodePostal) {
            $paramsToUpdate['PostalCode'] = $user.CodePostal
        } else {
            $paramsToClear += 'PostalCode'
        }

        if ($user.Fonction) {
            $paramsToUpdate['Title'] = $user.Fonction
        } else {
            $paramsToClear += 'Title'
        }

        if ($user.Service) {
            $paramsToUpdate['Department'] = $user.Service
        } else {
            $paramsToClear += 'Department'
        }

        if ($user.Societe) {
            $paramsToUpdate['Company'] = $user.Societe
        } else {
            $paramsToClear += 'Company'
        }

        # Mise à jour de l'utilisateur
        try {
            Set-ADUser @paramsToUpdate

            # Nettoyer (supprimer) les attributs si nécessaire
            foreach ($param in $paramsToClear) {
                Set-ADUser -Identity $adUser.SamAccountName -Clear $param
            }
            
            Write-DebugMessage "Mise à jour de l'utilisateur $($adUser.SamAccountName) réussie."
        } catch {
            Write-Host "Erreur lors de la mise à jour de l'utilisateur $($adUser.SamAccountName) : $($_.Exception.Message)"
        }
    } else {
        Write-DebugMessage "Utilisateur non trouvé dans AD : $($user.SamAccountName)"
    }
}
