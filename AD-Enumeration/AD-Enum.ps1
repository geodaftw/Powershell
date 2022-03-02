####################################
## Script to perform some Computer, 
## Users and Group association
##
## Written by: Eric Guillen
####################################


# Define Parameters
param([string] $computer=$null, # for computers function
      [string] $user=$null,     # for users function
      [string] $group=$null,    # for group function
      [string] $members=$null,  # for members function
      [string] $memberof=$null, # for memberof function  
      [string] $loggedin=$null, # for loggedin function
      [string] $test=$null,     # test param
      [switch] $all)     
      

function Test {
    write-host "#########################"
    write-host "##   TEST FUNCTION     ##"
    write-host "#########################"
    write-host ""
    # Check if the -all switch was used. If so, do a different query
    if ($all.IsPresent) {
        write-host "ALL THE THINGS"
        } else {
        write-host "not all the things"
        }
}

function Computers {
    write-host "#########################"
    write-host "##  Computers Groups   ##"
    write-host "#########################"
    write-host ""
    ([adsisearcher]"(&(objectCategory=computer)(cn=$computer))").FindOne().Properties.memberof -replace '^CN=([^,]+).+$','$1'
}

function Users {
    write-host "#########################"
    write-host "##  Groups user Has    ##"
    write-host "#########################"
    write-host ""
    ([adsisearcher]"(&(objectCategory=user)(cn=$user))").FindOne().properties.memberof -replace '^CN=([^,]+).+$','$1'
}

function Members {
    write-host "#########################"
    write-host "##  Members in Groups  ##"
    write-host "#########################"
    write-host ""
    ([adsisearcher]"(&(objectClass=group)(cn=$members))").Findone().Properties.member
}

function MemberOf {
    write-host "#########################"
    write-host "##     Member Of       ##"
    write-host "#########################"
    write-host ""
    # Extracts Just the Name, info, description, member of
    ([adsisearcher]"(&(objectClass=group)(cn=$memberof))").FindAll().properties | ForEach-Object { write-host "Name:" $_.name, `n"MemberOf:" $_.memberof}
    # Add a way to print all info?
}

function GroupDescription {
    write-host "#########################"
    write-host "##  Group Description  ##"
    write-host "#########################"
    write-host ""
    ([adsisearcher]"(&(objectClass=group)(cn=$group))").FindAll().properties | ForEach-Object { write-host "Name:" $_.name, `n"Distinguished Name:" $_.distinguishedname, `n"Info:" $_.info , `n"Description:" $_.description}
}

function LoggedIn {
    write-host "#########################"
    write-host "##    Whos Logged In   ##"
    write-host "#########################"
    $query = $null;
    $query = reg query \\$loggedin\HKEY_USERS 2>$null

    if ($query -ne $null){ 
            # Can successfully reach
            #write-output "[!] We can successfully reach " + $line + "! Let's see if anyone is logged in..."
            Write-Host -NoNewline "[!] We can successfully reach"$loggedin"! Let's see if anyone is logged in..."
            Write-Host ""
                 
            # See if anyone is logged in, based off the "class" string from the output. Grepping for that string, if not present, nobody is logged in
            $a = write-output $query | Select-String "Classes" # extract ouput with the string classes (this will probably need to be fixed if multiple users logged in)
            
            # If/Else - Someone is logged in, else print nobody is logged in
            if ($a -ne $null) {
                # Someone is logged in
                write-output "[!] Someone is logged in! Let's see who it is.."
            
                # TODO: Better way to handle if multiple users logged in (but no computer to test with multi users yet)

                # Split the string, and join
                $split_a_array = $a -split "-"
                $join = $split_a_array[1,2,3,4,5,6,7]
                $final = $join -join '-'
                $final2 = $final.Substring(0,$final.IndexOf('_'))
                $strSID = "S-" + $final2 # final strSID will look something like "S-1-5-21-1233408591-632565889-2861964239-11218517"

                #write-output $strSID
                $uSid = [ADSI]"LDAP://<SID=$strSID>"

                # Write stuff to file
                write-host -nonewline "[+] " -ForegroundColor Green
                
                #write-output "Below is Logged into " $line >> .\$OutputName 
                echo $uSid | foreach { $_.CN }
                #echo $uSid | foreach { $_.CN } | Out-File .\$OutputName -Append
                #write-output `n | Out-File .\$OutputName -Append
                
            } Else {
            # Nobody is logged in
            write-host "[-] Sorry, nobody is logged into" $line -ForegroundColor Red
            }
    }
}

# Check if anything is given. If not, give instructions
if ($PSBoundParameters.Values.Count -eq 0){
    write-host "#########################"
    write-host "##  Available Options  ##"
    write-host "#########################"
    write-host ""
    write-host "-computer <hostname>     will Enumerate Computers Groups"
    write-host "-user <user>          will Enumerate User Groups"
    write-host "-members <groupName>   will Enumerate Members of a Group"
    write-host "-loggedin <hostname>     will Enumerate Whos Logged into Computer"
    write-host "-group <groupName>     will give details on this Group"
    write-host "-memberof <groupName>  will Enumerate what groups this is a Member Of"
    write-host "-all                     append -all to all and will give more information"
   
return
}

# Begin the script
if ($test -ne ''){
    Test
}

if ($computer -ne ''){
    Computers
    }

if ($user -ne ''){
    Users
    }

if ($group -ne ''){
    GroupDescription
}

if ($members -ne ''){
    Members
    }

if ($memberof -ne ''){
    MemberOf
    }

if ($loggedin -ne ''){
    LoggedIn
    }
