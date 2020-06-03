#############
## Check if a list of users have reset their password since a specific date
## This is helpful if you send out a mass email to a list of people requesting them to change their password
## ##########

# Put the date in which you want to have a start date (maybe when you sent them an email to change password).
# This will be the Date and time to compare
$original = "Thursday, June 03, 2020 06:00:22 PM"

# The file of users, based off their SamAccount. 1 line per user
$users = 'C:\Path\To\File.txt'

# The file you want to export to csv to
$csv = 'C:\Path\To\csv.csv'

# Begin Script
Write-Output 'The following count have reset their password:'
# Get a count of how many HAVE reset their password
Get-Content $users | Get-ADuser -Properties PasswordLastSet,SamAccountName | Where-Object {$_.PasswordLastSet -gt $original} | select SamAccountName,PasswordLastSet | Measure-Object
# Get a list of the actual people
Get-Content $users | Get-ADuser -Properties PasswordLastSet,SamAccountName | Where-Object {$_.PasswordLastSet -gt $original} | select SamAccountName,PasswordLastSet

Read-Host -Prompt "Press Enter to continue"

Write-Output '***************************'

Write-Output 'The following count have NOT reset their password:'
# Get a count of how many have NOT reset their password
Get-Content $users | Get-ADUser -Properties PasswordLastSet,SamAccountName | Where-Object {$_.PasswordLastSet -lt $original | select SamAccountName,PasswordLastSet | Measure-Object 
# Get a list of the actual people
Get-Content $users | Get-ADUser -Properties PasswordLastSet,SamAccountName | Where-Object {$_.PasswordLastSet -lt $original | select SamAccountName,PasswordLastSet
# Get a list of the actual people and add to csv
Get-Content $users | Get-ADUser -Properties PasswordLastSet,SamAccountName | Where-Object {$_.PasswordLastSet -lt $original | select GivenName,SamAccountName,UserPrincipalName | Export-Csv $csv