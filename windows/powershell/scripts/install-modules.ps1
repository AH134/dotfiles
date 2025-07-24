# Install Terminal-Icons if not present
if (!(Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force
}

Import-Module Terminal-Icons
