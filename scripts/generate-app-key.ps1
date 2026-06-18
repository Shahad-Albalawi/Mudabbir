# Generates a Laravel APP_KEY (base64:...) for Render / production .env
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$key = "base64:$([Convert]::ToBase64String($bytes))"
Write-Host $key
Write-Host ""
Write-Host "Copy into Render -> Environment -> APP_KEY"
