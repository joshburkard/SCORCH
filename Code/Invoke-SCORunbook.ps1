function Invoke-SCORunbook {
    <#
        .SYNOPSIS
            this function invokes a System Center Orchestrator (SCORCH) Runbook through the webservice

        .DESCRIPTION
            this function invokes a System Center Orchestrator (SCORCH) Runbook through the webservice

        .PARAMETER OrchestratorServer
            defines the FQDN of the System Center Orchestration webservice

            this string parameter is mandatory

        .PARAMETER OrchestratorPort
            defines the port of the System Center Orchestration webservice

            this string parameter is not mandatory. if not defined, the default port 81 will be used

        .PARAMETER RunbookName
            defines the name of the Runbook to invoke

            RunbookName or RunbookGUID is mandatory.

        .PARAMETER RunbookGUID
            defines the name of the Runbook to invoke

            RunbookName or RunbookGUID is mandatory.

        .EXAMPLE
            $Params = @{
                A = 'Test A'            # String value
                B = 25                  # Integer value
                C = @( 'Test B', 44 )   # Array value
                D = $true               # Boolean parameter ( Switch Parameter must be set like a boolean $true )
                E = '{"Name1":"Value1","Name2":"Value2"}' # JSON
            }

            Invoke-SCORunbook -OrchestratorServer $OrchestratorServer -OrchestratorPort $OrchestratorPort -RunbookName $RunbookName -Params $Params -wait

    #>
    [CmdLetBinding()]
    Param (
        [Parameter(ParameterSetName='Name',Mandatory=$true)]
        [Parameter(ParameterSetName='GUI',Mandatory=$true)]
        [string]$OrchestratorServer
        ,
        [Parameter(ParameterSetName='Name',Mandatory=$false)]
        [Parameter(ParameterSetName='GUI',Mandatory=$false)]
        [string]$OrchestratorPort = 81
        ,
        [Parameter(ParameterSetName='Name',Mandatory=$true)]
        [string]$RunbookName
        ,
        [Parameter(ParameterSetName='GUI',Mandatory=$true)]
        [string]$RunbookGUID
        ,
        [Parameter(ParameterSetName='Name',Mandatory=$false)]
        [Parameter(ParameterSetName='GUI',Mandatory=$false)]
        [HashTable]$Params = @{}
        ,
        [Parameter(ParameterSetName='Name',Mandatory=$false)]
        [Parameter(ParameterSetName='GUI',Mandatory=$false)]
        [switch]$wait
        ,
        [Parameter(ParameterSetName='Name',Mandatory=$false)]
        [Parameter(ParameterSetName='GUI',Mandatory=$false)]
        [int]$timeout = 300
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    $SCORunbookParams = @{
        OrchestratorServer = $OrchestratorServer
        OrchestratorPort = $OrchestratorPort
    }
    if ( [boolean]$Credential ) {
        $SCORunbookParams.Add( 'Credential', $Credential )
    }
    if ( [boolean]$RunbookName ) {
        $SCORunbookParams.Add( 'RunbookName', $RunbookName )
    }
    elseif ( [boolean]$RunbookGUID ) {
        $SCORunbookParams.Add( 'RunbookGUID', $RunbookGUID )
    }
    else {
        throw "you have to define RunbookGUID or RunbookName"
    }
    $Runbook = Get-SCORunbook @SCORunbookParams
    if ( [boolean]$Runbook ) {
        $RunbookGUID = $Runbook.GUID
    }
    else {
        throw "runbook not found"
    }

    $SCORunbookParameter = @{
        OrchestratorServer = $OrchestratorServer
        OrchestratorPort = $OrchestratorPort
        RunbookGUID = $RunbookGUID
    }
    if ( [boolean]$Credential ) {
        $SCORunbookParameter.Add( 'Credential', $Credential )
    }
    $RunbookParams = Get-SCORunbookParameter @SCORunbookParameter

    $RunbookInputParams = $RunbookParams.Inputs
    $POSTBody = @"
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<entry xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns="http://www.w3.org/2005/Atom">
<content type="application/xml">
<m:properties>
<d:RunbookId type="Edm.Guid">{${RunbookGUID}}</d:RunbookId>
<d:Parameters>&lt;Data&gt;
"@
    foreach ( $Key in @( $Params.Keys ) ) {
        $RunbookInputParam = $RunbookInputParams | Where-Object { $_.Name -eq $Key }
        if ( [boolean]$RunbookInputParam ) {
            $ParamID = ( $RunbookInputParams | Where-Object { $_.Name -eq $Key } ).ID
            $POSTBody += "&lt;Parameter&gt;&lt;ID&gt;{${ParamID}}&lt;/ID&gt;&lt;Value&gt;$( $Params."$Key" )&lt;/Value&gt;&lt;/Parameter&gt;"
        } else {
            throw "parameter '$Key' not expected by this runbook"
        }

    }
    $POSTBody += @"
&lt;/Data&gt;</d:Parameters>
</m:properties>
</content>
</entry>
"@

    $BaseURI = "http://${OrchestratorServer}:${OrchestratorPort}"
    $URI = "$BaseURI/Orchestrator2012/Orchestrator.svc/Jobs/"

    $InvokeParams = @{
        URI = $URI
        Method = 'Post'
        Body = $POSTBody
        ContentType = 'application/atom+xml'
    }
    if ( [boolean]$Credential ) {
        $InvokeParams.Add( 'Credential', $Credential )
    }
    else {
        $InvokeParams.Add( 'UseDefaultCredentials', $true )
    }
    try {
        $result = Invoke-WebRequest @InvokeParams -ErrorAction SilentlyContinue
    }
    catch {
        $result = $null
    }
    if ( [boolean]$result ) {
        $resxml = [xml]$result.Content
        if ( [boolean]$wait ) {

            do {
                $StatusContent = Invoke-RestMethod -Uri $resxml.entry.id -Credential $Credential
                $CurrentStatus = $StatusContent.entry.content.properties.Status
                if ( $CurrentStatus -notin @( 'Completed', 'Failed' ) ) {
                    Start-Sleep -Seconds 5
                }
            } while (
                ( $CurrentStatus -notin @( 'Completed', 'Failed' ) )
            )
            $JobID = $StatusContent.entry.content.properties.Id.'#text'
            $ret = @{
                RunbookName = $Runbook.Name
                RunbookGuid = $RunbookGUID
                StartTime = Get-Date $StatusContent.entry.content.properties.CreationTime.'#text'
                JobID = $StatusContent.entry.content.properties.Id.'#text'
                Status = $StatusContent.entry.content.properties.Status
                EndTime = Get-Date $StatusContent.entry.content.properties.LastModifiedTime.'#text'
            }
            $InstanceURI = "$BaseURI/Orchestrator2012/Orchestrator.svc/Jobs(guid'${JobID}')/Instances"
            # $OutputURI = "$BaseURI/Orchestrator2012/Orchestrator.svc/RunbookInstances(guid'$( $StatusContent.entry.content.properties.Id.'#text' )')/Parameters"
            $InstanceRes = Invoke-RestMethod -Uri $InstanceURI -Method Get -Credential $Credential
            $href = ( $InstanceRes.link | Where-Object { $_.title -eq 'Parameters' } ).href
            $OutputURI = "$BaseURI/Orchestrator2012/Orchestrator.svc/$href"
            $OutputRes = Invoke-RestMethod -Uri $OutputURI -Method Get -Credential $Credential
            $Output = $OutputRes.content.properties | Where-Object { $_.Direction -eq 'out' } | Select-Object Name, Value
            $ret.Add( 'Output', $Output )
        }
        else {
            $resxml.entry.id -match "guid'(.*)'"
            $JobID = $Matches[1]
            $ret = @{
                RunbookName = $Runbook.Name
                RunbookGuid = $RunbookGUID
                StartTime = Get-Date $resxml.entry.published
                JobID = $JobID
                Status = $null
                EndTime = $null
            }
        }
    }
    else {
        throw "couldn't invoke runbook"
    }
    return $ret
}
