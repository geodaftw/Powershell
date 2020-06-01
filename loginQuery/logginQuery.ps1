#################
## Script Name: logginQuery.ps1
## Description: Check if someone is remotely logged into a machine
## How To: Have a file named "hosts.txt" in the same directory as this script (logginQuery.ps1)
## hosts.txt should have 1 host per line
## Script will read the hosts.txt file, line by line, and query if the HKEY_USERS registry key is available. 
## Currently checks if the host is reachable, if not.. move to the next.
## Written by: Eric Guillen
## TODO: Add a way to check if multiple users are logged in
## TODO: Confirm if nobody is logged in, what happens

#whoami
#hostname

# Create output file with date/time as filename
$OutputName = "mybackup-" + (Get-Date -Format "yyyy-MM-dd-hhmmss") + ".txt"

# Loop through hosts.txt line by line
foreach($line in Get-Content .\hosts.txt) {
    if($line -match $regex){
        
        #$hostVariable= 'x7007541'
        # Query AD for computer and # Grab line with "Class" in it, showing someone is logged in
        #$query = reg query \\$hostVariable\HKEY_USERS
        
        # Null out query for each search
        $query = $null;
        # Run query
        $query = reg query \\$line\HKEY_USERS 2>$null # query.. if error, write standard error to null
        
        if ($query -ne $null){ 
            # Can successfully reach
            #write-output "[!] We can successfully reach " + $line + "! Let's see if anyone is logged in..."
            Write-Host -NoNewline "[!] We can successfully reach " $line "! Let's see if anyone is logged in..."
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
                write-host -nonewline "[+] Someone is Logged into" $line ": " -ForegroundColor Green
                write-output "Below is Logged into " $line >> .\$OutputName 
                echo $uSid | foreach { $_.CN }
                echo $uSid | foreach { $_.CN } | Out-File .\$OutputName -Append
                write-output `n | Out-File .\$OutputName -Append
                
            } Else {
            # Nobody is logged in
            write-host "[-] Sorry, nobody is logged into" $line -ForegroundColor Red
            }

        } Else { 
        # If can't reach the computer
        write-host "[-] Sorry, we can't reach" $line -ForegroundColor Red
        }
    }
}
