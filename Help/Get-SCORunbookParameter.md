# Get-SCORunbookParameter

## SYNOPSIS

this function gets the parameters for one System Center Orchestrator (SCORCH) Runbook through the webservice

## SYNTAX

```powershell
Get-SCORunbookParameter [-OrchestratorServer] <String> [[-OrchestratorPort] <String>] [-RunbookGUID] <String> [[-Credential] 

<PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

this function gets the parameters for one System Center Orchestrator (SCORCH) Runbook through the webservice

## PARAMETERS

### -OrchestratorServer &lt;String&gt;

defines the FQDN of the System Center Orchestration webservice

this string parameter is mandatory

```
Required?                    true
Position?                    1
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -OrchestratorPort &lt;String&gt;

defines the port of the System Center Orchestration webservice

this string parameter is not mandatory. if not defined, the default port 81 will be used

```
Required?                    false
Position?                    2
Default value                81
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -RunbookGUID &lt;String&gt;

defines the name of the Runbook to invoke

this string parameter is not mandatory

```
Required?                    true
Position?                    3
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Credential &lt;PSCredential&gt;

defines the credential to access the SCORCH web services

this parameter is not mandatory

```
Required?                    false
Position?                    4
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS


## EXAMPLES

### EXAMPLE 1

```powershell
$parameters = Get-SCORunbookParameter -OrchestratorServer $OrchestratorServer -Credential $Credential -RunbookGUID '92d21309-de5b-4035-9e15-cdcdbdad3c8e'
$parameters.Inputs
$parameters.Outputs
```


