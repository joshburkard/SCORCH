# Get-SCORunbook

## SYNOPSIS

this function gets one or all System Center Orchestrator (SCORCH) Runbook through the webservice

## SYNTAX

```powershell
Get-SCORunbook [-OrchestratorServer] <String> [[-OrchestratorPort] <String>] [[-RunbookName] <String>] [[-RunbookGUID] 

<String>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

this function gets one or all System Center Orchestrator (SCORCH) Runbook through the webservice

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

### -RunbookName &lt;String&gt;

defines the name of the Runbook to invoke

this string parameter is not mandatory

```
Required?                    false
Position?                    3
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -RunbookGUID &lt;String&gt;

defines the name of the Runbook to invoke

this string parameter is not mandatory

```
Required?                    false
Position?                    4
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Credential &lt;PSCredential&gt;

defines the credential to access the SCORCH web services

this parameter is not mandatory

```
Required?                    false
Position?                    5
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS


## EXAMPLES

### EXAMPLE 1

```powershell
$Runbooks = Get-SCORunbook -OrchestratorServer $OrchestratorServer -Credential $Credential
$Runbooks | Out-GridView -PassThru
```

### EXAMPLE 2

```powershell
Get-SCORunbook -OrchestratorServer $OrchestratorServer -Credential $Credential -RunbookName $RunbookName
```


