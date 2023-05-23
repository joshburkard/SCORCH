Function Get-SCORunbook {
    <#
        .SYNOPSIS
            this function gets one or all System Center Orchestrator (SCORCH) Runbook through the webservice

        .DESCRIPTION
            this function gets one or all System Center Orchestrator (SCORCH) Runbook through the webservice

        .PARAMETER OrchestratorServer
            defines the FQDN of the System Center Orchestration webservice

            this string parameter is mandatory

        .PARAMETER OrchestratorPort
            defines the port of the System Center Orchestration webservice

            this string parameter is not mandatory. if not defined, the default port 81 will be used

        .PARAMETER RunbookName
            defines the name of the Runbook to invoke

            this string parameter is not mandatory

        .PARAMETER RunbookGUID
            defines the name of the Runbook to invoke

            this string parameter is not mandatory

        .PARAMETER Credential
            defines the credential to access the SCORCH web services

            this parameter is not mandatory

        .EXAMPLE
            $Runbooks = Get-SCORunbook -OrchestratorServer 'p-int-inf069.sd.dika.be' -Credential $Credential
            Get-SCORunbook -OrchestratorServer 'p-int-inf069.sd.dika.be' -Credential $Credential -RunbookName '3.2.0 Approve SCOM agent'
            $Runbooks | Out-GridView -PassThru
    #>
    [CmdLetBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$OrchestratorServer
        ,
        [Parameter(Mandatory=$false)]
        [string]$OrchestratorPort = 81
        ,
        [Parameter(Mandatory=$false)]
        [string]$RunbookName
        ,
        [Parameter(Mandatory=$false)]
        [string]$RunbookGUID
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential # = Get-Credential
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    $BaseURI = "http://${OrchestratorServer}:${OrchestratorPort}"
    $URI = "$BaseURI/Orchestrator2012/Orchestrator.svc/Runbooks"
    if ( [boolean]$RunbookName ) {
        $URI += "?`$filter=Name eq '$RunbookName'"
    }
    if ( [boolean]$RunbookGUID ) {
        $URI += "(guid'${RunbookGUID}')"
    }
    $InvokeParams = @{
        URI = $URI
        Method = 'GET'
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
        $responseContent = [XML] ( $result ).content
    }
    else {
        throw "runbook or webservice not found"
    }

    if ( [boolean]$RunbookGUID ) {
        $entries = $responseContent.entry
    }
    else {
        $entries = $responseContent.feed.entry
    }
    # if ( -not [boolean]( $responseContent.feed.entry ) ) {
    if ( -not [boolean]( $entries ) ) {
        throw "runbook not found on name $RunbookName"
    }
    $Runbooks = @()
    foreach ( $entry in $entries ) {
        $Runbooks += [PSCustomObject]@{
            Name = $entry.title.'#text'
            GUID = $entry.content.properties.Id.'#text'
        }
    }
    $ret = $Runbooks
    return $ret
}


