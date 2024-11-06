# Define the group DN for the target group
$groupDN = "CN=ITS Workstations,OU=SCCM Groups,OU=Groups,DC=goodyearaz,DC=pri"

# Get all computers with "ITS" in the Description field
$computers = Get-ADComputer -Filter {Description -like "*ITS*"} -Properties Description

# Get current members of the AD group
$currentMembers = Get-ADGroupMember -Identity $groupDN -Recursive | Where-Object { $_.objectClass -eq "computer" }

# Add computers that meet the criteria and aren't already members
foreach ($computer in $computers) {
    if ($currentMembers.Name -notcontains $computer.Name) {
        Add-ADGroupMember -Identity $groupDN -Members $computer -ErrorAction SilentlyContinue
        Write-Output "Added $($computer.Name) to $groupDN"
    }
}

# Remove computers that no longer meet the criteria
foreach ($member in $currentMembers) {
    if ($computers.Name -notcontains $member.Name) {
        Remove-ADGroupMember -Identity $groupDN -Members $member -Confirm:$false -ErrorAction SilentlyContinue
        Write-Output "Removed $($member.Name) from $groupDN"
    }
}