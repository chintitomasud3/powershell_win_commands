# সব ইউজার ফেচ করা
$users = Get-ADUser -Filter * -Properties Enabled, CanonicalName | Select-Object Name, SamAccountName, Enabled, @{Name="OU"; Expression={($_.DistinguishedName -split ',', 2)[1]}}

# তালিকা প্রিন্ট করা
$users | Format-Table Name, SamAccountName, Enabled, OU -AutoSize

# মোট কাউন্ট প্রিন্ট করা
Write-Host "Total Users: $($users.Count)" -ForegroundColor Green


--------------------------------------------------------------------------------





