$ous = Import-Csv -Path "ou.csv"

foreach ($ou in $ous) {
    $ouPath = "OU="+$ou.ou+",DC="+$ou.domain+",DC="+$ou.tld
    Write-Host $ouPath
    Remove-ADOrganizationalUnit -Identity $ouPath -Recursive -Confirm:$false
}
