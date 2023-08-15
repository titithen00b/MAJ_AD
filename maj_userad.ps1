# Importer le module ActiveDirectory
Import-Module ActiveDirectory

# Variables
$csvPath = "C:\Utilisateurs.csv"
$debug = 1  # Changez cette valeur à 0 pour désactiver le débogage

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
