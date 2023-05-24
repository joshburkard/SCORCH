Function Get-SCORunbookParameter {
<#
        .SYNOPSIS
            this function gets the parameters for one System Center Orchestrator (SCORCH) Runbook through the webservice

        .DESCRIPTION
            this function gets the parameters for one System Center Orchestrator (SCORCH) Runbook through the webservice

        .PARAMETER OrchestratorServer
            defines the FQDN of the System Center Orchestration webservice

            this string parameter is mandatory

        .PARAMETER OrchestratorPort
            defines the port of the System Center Orchestration webservice

            this string parameter is not mandatory. if not defined, the default port 81 will be used

        .PARAMETER RunbookGUID
            defines the name of the Runbook to invoke

            this string parameter is not mandatory

        .PARAMETER Credential
            defines the credential to access the SCORCH web services

            this parameter is not mandatory

        .EXAMPLE
            $parameters = Get-SCORunbookParameter -OrchestratorServer $OrchestratorServer -Credential $Credential -RunbookGUID '92d21309-de5b-4035-9e15-cdcdbdad3c8e'
            $parameters.Inputs
            $parameters.Outputs
    #>
    [CmdLetBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$OrchestratorServer
        ,
        [Parameter(Mandatory=$false)]
        [string]$OrchestratorPort = 81
        ,
        [Parameter(Mandatory=$true)]
        [string]$RunbookGUID
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential # = Get-Credential
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    $parametersInput = @()
    $parametersOutput = @()

    $BaseURI = "http://${OrchestratorServer}:${OrchestratorPort}"
    $URI = "$BaseURI/Orchestrator2012/Orchestrator.svc/Runbooks(guid'$RunbookGUID')/Parameters"

    $InvokeParams = @{
        URI = $URI
        Method = 'GET'
    }
    if ( [boolean]$Credential ) {
        $InvokeParams.Add( 'Credential', $Credential )
    } else {
        $InvokeParams.Add( 'UseDefaultCredentials', $true )
    }

    $responseContent = [XML] (Invoke-WebRequest @InvokeParams ).Content # -UseDefaultCredentials

    $responseContent.feed.entry[0].title.'#text'
    $RunbookGUID = $responseContent.feed.entry.content.properties.Id.'#text'

    #Get parameters
    $parametersInput = @()
    $parametersOutput = @()
    foreach ($parameter in $responseContent.feed.entry.content.properties) {
        if ($parameter.Direction -eq "Out") {
            $parametersOutput += [pscustomobject]@{
                Name = $parameter.Name
                Id   = $parameter.Id.'#text'
            }
        }
        else {
            $parametersInput += [pscustomobject]@{
                Name = $parameter.Name
                Id   = $parameter.Id.'#text'
            }
        }
    }

    return [pscustomobject]@{
        # Name    = $RunbookName
        Id      = $RunbookGUID
        Inputs  = $parametersInput
        Outputs = $parametersOutput
    }

}