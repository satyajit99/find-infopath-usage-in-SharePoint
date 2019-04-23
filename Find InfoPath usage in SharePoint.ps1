#########################################
#### Infopath Usage Identifier       ####
#### Scope - Site Collection         ####
#### Input - Site Collection URL     ####
#########################################

 
$siteCollectionURL =  "http://sharepoint.devbox.com/sites/mysitecollection"

if((Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null)
{
    Add-PSSnapin Microsoft.SharePoint.PowerShell;
}

try
{
    $mySite = Get-SPSite -Identity $siteCollectionURL
    $myWebs = Get-SPWeb -Site $mySite -Limit All
 
    $results = @()
    foreach ($myWeb in $myWebs)
    {
        Write-Host "Looking in WEB: "  $myWeb.Url -ForegroundColor Green
        foreach ($myList in $myWeb.Lists)
        {
            if ($myList.ContentTypes[0].ResourceFolder.Properties["_ipfs_infopathenabled"] -eq $true)
            {
             Write-Host "Found this list using Infopath -  " $myList.Title -ForegroundColor Blue
             $RowDetails = @{
                            "Site Collection"  = $siteCollectionURL
                            "Web"              = $myWeb
                            "List Name"        = $myList.Title
                            "List URL"         = $myList.DefaultViewUrl                            
                        }
             $results += New-Object PSObject -Property $RowDetails
            }
        }
        $myFileName = [Environment]::GetFolderPath("Desktop") + "\InfopathDependencyFinder-SiteCollectionScope-" +  (Get-Date).ToString('MM-dd-yyyy') + ".csv"
        $results | export-csv -Path $myFileName -NoTypeInformation     
    } 
    Write-Host "---------------------Completed--------------------------" -ForegroundColor Green  
}
 
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
}