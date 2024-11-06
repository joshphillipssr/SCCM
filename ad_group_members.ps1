# Define the group DN for the target group
$groupDN = "CN=ITS Workstations,OU=SCCM Groups,OU=Groups,DC=goodyearaz,DC=pri"

# Get the list of names of computers matching the criteria
$matchingComputerNames = $computers.Name

# Get current members of the AD group
$currentMembers = Get-ADGroupMember -Identity $groupDN -Recursive | Where-Object { $_.objectClass -eq "computer" }

# Add computers that meet the criteria and aren't already members
foreach ($computer in $computers) {
    if ($currentMembers.Name -notcontains $computer.Name) {
        Add-ADGroupMember -Identity $groupDN -Members $computer -ErrorAction SilentlyContinue
        Write-Output "Added $($computer.Name) to $groupDN"
    }
}

# Remove computers that do not meet the criteria
foreach ($member in $currentMembers) {
    # Retrieve the computer object and Description for each member
    $computerObj = Get-ADComputer -Identity $member.Name -Properties Description
    $description = $computerObj.Description

    # Check if Description does NOT contain "IT -" or "ITS -"
    if ($description -notlike "*ITS -*" -and $description -notlike "*IT -*") {
        Remove-ADGroupMember -Identity $groupDN -Members $member -Confirm:$false -ErrorAction SilentlyContinue
        Write-Output "Removed $($member.Name) from $groupDN due to mismatched description"
    }
}