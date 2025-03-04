# Import data from CSV files
$dp = Import-Csv -Path "ou.csv"
$groups = Import-Csv -Path "group.csv"
$users = Import-Csv -Path "unique_names.csv"

# Step 1: Create Organizational Units (OUs)
foreach ($ou in $dp) {
    $ouName = $ou.ou
    $ouPath = "DC=" + $ou.domain + ",DC=" + $ou.tld
    Write-Host "Creating OU: $ouName at Path: OU=$ouName,$ouPath"

    New-ADOrganizationalUnit -Name $ouName -Path $ouPath -ProtectedFromAccidentalDeletion $false
}

# Step 2: Randomly distribute 7300 computers across OUs
$totalComputers = 7300
$computerCounts = @{}
$random = New-Object System.Random

# Assign a base count to each department
foreach ($ou in $dp) {
    $computerCounts[$ou.ou] = 0
}

# Distribute computers randomly
for ($i = 1; $i -le $totalComputers; $i++) {
    $randomDept = $dp[$random.Next(0, $dp.Count)].ou
    $computerCounts[$randomDept]++
}

# Step 3: Create Computers in AD with randomized distribution
foreach ($comp in $dp) {
    $dept = $comp.ou
    $ouPath = "OU=$dept,DC=$($comp.domain),DC=$($comp.tld)"

    for ($i = 1; $i -le $computerCounts[$dept]; $i++) {
        $cname = "{0}-{1:D3}" -f $dept, $i  
        Write-Host "Creating computer: $cname in $ouPath"

        try {
            New-ADComputer -Name $cname -SamAccountName $cname -Path $ouPath -Enabled $true
        } catch {
            Write-Error "Error creating computer: $cname - $($_.Exception.Message)"
        }
    }
}

# Step 4: Create Users in AD
foreach ($user in $users) {
    $username = $user.name
    $surname = $user.surname
    $sam = $username + $surname
    $userpath = "OU=" + $user.ou + ",DC=" + $user.domain + ",DC=" + $user.tld
    $password = "Salam@123"
    $upn = $username + "." + $surname + "@" + $user.domain + "." + $user.tld

    Write-Host "Creating User: $upn in $userpath"

    try {
        New-ADUser -Name $sam -Path $userpath -UserPrincipalName $upn -GivenName $username -Surname $surname `
            -SamAccountName $sam -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
            -ChangePasswordAtLogon $True -DisplayName $sam -Enabled $True

        Write-Host "Successfully created user: $upn"
    } catch {
        Write-Error "Error creating user: $upn - $($_.Exception.Message)"
    }
}

# Step 5: Create Groups and Assign Users
foreach ($group in $groups) {
    $grname = $group.group
    $grpath = "OU=" + $group.ou + ",DC=" + $group.domain + ",DC=" + $group.tld

    Write-Host "Creating Group: $grname in $grpath"

    try {
        New-ADGroup -Name $grname -SamAccountName $grname -GroupCategory Security -GroupScope Global `
            -DisplayName $grname -Path $grpath
    } catch {
        Write-Error "Error creating group: $grname - $($_.Exception.Message)"
    }

    # Add users to the group if they belong to the same OU
    $usersInGroup = $users | Where-Object { $_.ou -eq $group.ou -and $_.domain -eq $group.domain -and $_.tld -eq $group.tld }

    foreach ($user in $usersInGroup) {
        $dn = "CN=$($user.name)$($user.surname),OU=$($user.ou),DC=$($user.domain),DC=$($user.tld)"
        $upn = "$($user.name).$($user.surname)@$($user.domain).$($user.tld)"

        # Check if user exists before adding to the group
        if (Get-ADUser -Filter { UserPrincipalName -eq $upn } -ErrorAction SilentlyContinue) {
            Write-Host "Adding user $upn to group $grname"
            try {
                Add-ADGroupMember -Identity $grname -Members $dn
            } catch {
                Write-Error "Error adding user $upn to group $grname - $($_.Exception.Message)"
            }
        } else {
            Write-Warning "User $upn does not exist. Skipping..."
        }
    }
}

Write-Host "✅ AD structure creation completed successfully!" -ForegroundColor Cyan