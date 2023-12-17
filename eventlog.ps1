#Simple script to gather data from the event log quickly. 

##First, elevate to admin if not already. Sourced from: https://learn.microsoft.com/en-us/archive/blogs/virtual_pc_guy/a-self-elevating-powershell-script
# Get the ID and security principal of the current user account
 $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

 # Get the security principal for the Administrator role
 $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    # We are running "as Administrator" - so change the title and background color to indicate this
    #$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    #$Host.UI.RawUI.BackgroundColor = "DarkBlue"
    #clear-host
    Write-Host "Processing event logs"
    }
 else
    {
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit
    }


### CSS style

$css = "<style>"

$css = $css+ "BODY{ text-align: center; background-color:white;}"

$css = $css+ "TABLE{    font-family: 'Lucida Sans Unicode', 'Lucida Grande', Sans-Serif;font-size: 12px;margin: 10px;width: 100%;text-align: center;border-collapse: collapse;border-top: 7px solid #004466;border-bottom: 7px solid #004466;}"

$css = $css+ "TH{font-size: 13px;font-weight: normal;padding: 1px;background: #cceeff;border-right: 1px solid #004466;border-left: 1px solid #004466;color: #004466;}"

$css = $css+ "TD{padding: 1px;background: #e5f7ff;border-right: 1px solid #004466;border-left: 1px solid #004466;color: #669;hover:black;}"

$css = $css+  "TD:hover{ background-color:#004466;}"

$css = $css+ "</style>"

 function Read-Eventlog {
    param($level, $saveTo, $start)

    $data = @{logname="Application", "System"; Level=$level; StartTime=(get-date).adddays($start)}
   try {
      $body = Get-WinEvent -FilterHashtable $data -ErrorAction SilentlyContinue
   } catch {
      #This is a vistigial behavior check that may not apply while -ErrorAction SilentlyContinue
      Write-Host "No entries found at level $($level)"
      return
   }
    #Clear the output file destination
    "" | Out-File -FilePath $saveTo
    
    #Create a list and add each item to it, with a duplicates property added
    $bodyFiltered = [System.Collections.Generic.List[object]]::new()
    foreach($item in $body) {
      $item | Add-Member -memberType NoteProperty -name "duplicates" -value 0
      $bodyFiltered.add($item)
    }

    Write-Host -NoNewLine "Level: $($level) -- Entries: $($bodyFiltered.Count)"
    #Loop through each event, comparing each entry to the entries that follow it.
    #If an entry following has the same description as the comparing entry, then the entry following is removed 
    #Mark each duplicate along the way
    for ( $i = 0; $i -lt $($bodyFiltered.count); $i++) {
	    $checkFor = $bodyFiltered[$i].FormatDescription()
	    for ( $k = $i+1; $k -lt $($bodyFiltered.count); $k++) {
         $innerCheck = $bodyFiltered[$k].FormatDescription() 
		    if ( $innerCheck -eq $checkFor ) {
             $bodyFiltered[$i].duplicates += 1
             $bodyFiltered.RemoveAt($k)
             $k = $k - 1
			    continue
		    }
	    }
    }
    $outputHTML = [System.Collections.Generic.List[object]]::new()
    foreach($entry in $bodyFiltered) {
      $outputHTML.Add(($entry | ConvertTo-HTML -Head $css MachineName,ID,TimeCreated,Message,Duplicates))
    } 
   $outputHTML | Out-File -FilePath $saveTo
    Write-Host " -- Squished: $($bodyFiltered.Count)"
}

#Get critical event logs from Windows
Read-Eventlog 1 "$env:USERPROFILE\Desktop\$(get-date -f MM-dd-yyyy)_CriticalEvents.html" -720

#Get error event logs from Windows
Read-Eventlog 2 "$env:USERPROFILE\Desktop\$(get-date -f MM-dd-yyyy)_ErrorEvents.html" -720

