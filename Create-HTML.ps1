#requires -version 3
<#
.SYNOPSIS
  Create a HTML website for SCCM Application Downloader

.DESCRIPTION
  Create a HTML website for SCCM Application Downloader 

  THIS CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

.PARAMETER packageShare
  UNC path to Package Share
    e.g. "D:\packages"

.PARAMETER webServer
  Hostname of the web server hosting the site
    e.g. "WEBSERVER"

.PARAMETER outPath
  UNC path to outputted html including the filename
    e.g. "C:\inetpub\wwwroot\Packages\index.html"

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        0.1
  Author:         Sam Brentnall
  Creation Date:  29/03/2017

  Change History:
 0.1 - 29/03/2017 - Purpose/Change: Initial script development

.EXAMPLE
  .\Create-ApplicationDownloaderHTML.ps1 -packageShare "D:\Packages" -webServer "WEBSERVER" -outPath "C:\inetpub\wwwroot\Packages\index.html"
  
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [string]$packageShare = "D:\Packages",
  [string]$webServer = "SCCM12",
  [string]$outPath = "C:\REPO\trunk\SCCM Application Downloader Website\index.html"
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Match for Where-Object
$match = {$_.Name -match "^\d\d\d\d\d[_]|^[aA]\d\d\d\d[_]|^[aA-zZ]\d\d\d\d\d[_]"}

# For HTML Generation
$header = @"
<title>SCCM Application Downloader</title>
<style>

body{
    font-family: "Segoe UI";
    color: #444444;
    margin: 0;

}

table{
    border-collapse: collapse;
    width: 100%;
    margin: auto;
    width: 50%;
    padding: 10px;

}

th{
    background-color: #696969;
    height: 50px;
    color: white;
    font-size: 18px;
    padding: 5px;

}

td{
    border-bottom: 1px solid #ddd;
    padding: 5px;

}

h1{
    font-size: 40px;
    margin-bottom: 0px;

}

p{
    font-size: 12px;
    margin-top: 1px;

}

.MiniHeader {
    width: 100%;
    clear: both;
    height: 44px;
    line-height: 44px;
    background-color: #444444;
    display: block;
    position: relative;

}
.MiniHeader img {
    float: left;
    width: 134.8px;
    height: 43.2px;
    margin top: 10px;
    padding-left: 10px;


}

.header {
    margin: auto;
    width: 50%;
    padding: 10px;


}

.postBody p {
    margin: auto;
    width: 50%;
    padding: 10px;
    font-size: 10px;
}

.footer {
    border-top-width: 1px;
    border-top-style: dotted;
    border-top-color: rgb(225, 232, 237);

}

.footerText {
    margin: auto;
    width: 50%;
    padding: 10px;
    color: #C2C6C9;

}
</style>
"@

$preBody = @"
<div class="MiniHeader">
    <img style="display:block" src="**LOGO**" alt="logo" />
</div>

<div class="header">
    <h1 style="display: inline;">SCCM Application Downloader</h1> 
    <p>Click download to download an application</p> 
</div>
"@

$postBody = @"
<div class="postBody">
    <p>Generated at: $date</p>
</div> 
<div class="footer">
    <div class="footerText">
        <p>For support speak to Sam Brentnall or Matt Cox</p>
    </div>
</div>,
"@

# Other
$date = Get-Date
$results = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#None

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$childItems = Get-ChildItem -Path $packageShare -Directory | Where-Object $match  | select Name, FullName

foreach ($childItem in $childitems) { 

    $Measure = Get-ChildItem $childItem.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    $Sum = [math]::Round($Measure.Sum / "1MB",2)
    $URL = "http:\\" + $webServer + ":8080\download.php?target_folder=packages\" + $childItem.Name + "&zip_file_name=ZIP\" + $childItem.Name + ".zip"
    
#Save to Array
$details = @{    
    "Name"       = $childItem.Name
    "Size(MB)"   = $Sum
    "URL"        = $url
                
    } 

    $results += New-Object psobject -Property $details 

} 

$result = $results | Select-Object Name, "Size(MB)",@{n='URL';e={"<a href='$($_.URL)'>Download</a>"}} | ConvertTo-Html -Head $header -PreContent $preBody -PostContent $postBody

Add-Type -AssemblyName System.Web
[System.Web.HttpUtility]::HtmlDecode($result) | Out-File $outpath 

