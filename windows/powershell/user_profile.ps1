Function SSHIslet {
    if ($env:SERVER_SSH) {
        ssh "$env:SERVER_SSH"
    } else {
        Write-Host "SERVER_SSH environment variable not set" -ForegroundColor Red
        Write-Host "Example: [Environment]::SetEnvironmentVariable('SERVER_SSH', 'user@192.168.1.100', 'User')" -ForegroundColor Yellow
    }
}

# Imports
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module -Name Terminal-Icons
} else {
    Write-Host "Terminal-Icons module not found. Install with: Install-Module -Name Terminal-Icons" -ForegroundColor Yellow
}


# Alias
Set-Alias ssht SSHIslet
