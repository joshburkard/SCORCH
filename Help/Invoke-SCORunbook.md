# Invoke-SCORunbook

## SYNOPSIS

this function invokes a System Center Orchestrator (SCORCH) Runbook through the webservice

## SYNTAX

```powershell
Invoke-SCORunbook -OrchestratorServer <String> [-OrchestratorPort <String>] -RunbookGUID <String> [-Params <Hashtable>] 

[-Credential <PSCredential>] [-wait] [-timeout <Int32>] [<CommonParameters>]


Invoke-SCORunbook -OrchestratorServer <String> [-OrchestratorPort <String>] -RunbookName <String> [-Params <Hashtable>] 

[-Credential <PSCredential>] [-wait] [-timeout <Int32>] [<CommonParameters>]
```

## DESCRIPTION

this function invokes a System Center Orchestrator (SCORCH) Runbook through the webservice

## PARAMETERS

### -OrchestratorServer &lt;String&gt;

defines the FQDN of the System Center Orchestration webservice

this string parameter is mandatory

```
Required?                    true
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -OrchestratorPort &lt;String&gt;

defines the port of the System Center Orchestration webservice

this string parameter is not mandatory. if not defined, the default port 81 will be used

```
Required?                    false
Position?                    named
Default value                81
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -RunbookName &lt;String&gt;

defines the name of the Runbook to invoke

RunbookName or RunbookGUID is mandatory.

```
Required?                    true
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -RunbookGUID &lt;String&gt;

defines the name of the Runbook to invoke

RunbookName or RunbookGUID is mandatory.

```
Required?                    true
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Params &lt;Hashtable&gt;


```
Required?                    false
Position?                    named
Default value                @{}
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Credential &lt;PSCredential&gt;

= Get-Credential

```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -wait &lt;SwitchParameter&gt;


```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -timeout &lt;Int32&gt;


```
Required?                    false
Position?                    named
Default value                300
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS


## EXAMPLES

### EXAMPLE 1

```powershell
$Params = @{
    A = 'Test A'            # String value
    B = 25                  # Integer value
    C = @( 'Test B', 44 )   # Array value
    D = $true               # Boolean parameter ( Switch Parameter must be set like a boolean $true )
    E = '{"Name1":"Value1","Name2":"Value2"}' # JSON
}

Invoke-SCORunbook -OrchestratorServer $OrchestratorServer -OrchestratorPort $OrchestratorPort -RunbookName $RunbookName -Params $Params -wait
```


