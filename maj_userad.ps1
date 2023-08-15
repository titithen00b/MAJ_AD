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

    Write-DebugMessage "Traitement de l'utilisateur $($user.SamAccountName)"

    # Utilisez Where-Object pour filtrer l'utilisateur correspondant
    $adUser = $adUsers | Where-Object { $_.SamAccountName -eq $user.SamAccountName }
    
    if ($adUser) {
        Write-DebugMessage "Utilisateur trouvé dans AD : $($adUser.SamAccountName)"

        # Créez un tableau pour contenir les paramètres de Set-ADUser
        $params = @{
            'Identity' = $adUser.SamAccountName
        }

        if ($user.Adresse) { $params['StreetAddress'] = $user.Adresse }
        if ($user.Ville) { $params['City'] = $user.Ville }
        if ($user.CodePostal) { $params['PostalCode'] = $user.CodePostal }
        if ($user.Fonction) { $params['Title'] = $user.Fonction }
        if ($user.Servi) { $params['Department'] = $user.Servi }
        if ($user.Societe) { $params['Company'] = $user.Societe }

        # Essayez de mettre à jour l'utilisateur
        try {
            Set-ADUser @params
            Write-DebugMessage "Mise à jour de l'utilisateur $($adUser.SamAccountName) réussie."
        } catch {
            Write-Host "Erreur lors de la mise à jour de l'utilisateur $($adUser.SamAccountName) : $($_.Exception.Message)"
        }
    } else {
        Write-DebugMessage "Utilisateur non trouvé dans AD : $($user.SamAccountName)"
    }
}
