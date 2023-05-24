# SCORCH

- [Table of Contents](#table-of-contents)
- [Description](#description)
  - [Prerequisites](#prerequisites)
  - [Functions](#functions)
    - [Get-SCORunbook](Help/Get-SCORunbook.md)
    - [Get-SCORunbookParameter](Help/Get-SCORunbookParameter.md)
    - [Invoke-SCORunbook](Help/Invoke-SCORunbook.md)
  - [Examples](#examples)

# Description

this powershell modules interacts with the SCORCH webservices (System Center Orchestrator).

it is able to list and invoke runbooks.

*cause SCORCH is outdated and there is no further developmenmt, i will not do any improvements for this module*

# Prerequisites

you need connection to the SCORCH webservice and valid credentials.

# Functions

this module contains this functions:

- [Get-SCORunbook](Help/Get-SCORunbook.md)
- [Get-SCORunbookParameter](Help/Get-SCORunbookParameter.md)
- [Invoke-SCORunbook](Help/Invoke-SCORunbook.md)

# Examples

## list available runbooks

you can list all available runbooks:

```PowerShell
Get-SCORunbook -OrchestratorServer $OrchestratorServer -Credential $Credential
```

the function returns a list with runbook name and GUID

## get single runbook

you can get a single runbook by Name:

```PowerShell
Get-SCORunbook -OrchestratorServer $OrchestratorServer -RunbookName $RunbookName -Credential $Credential
```

or you can get a single runbook by GUID:

```PowerShell
Get-SCORunbook -OrchestratorServer $OrchestratorServer -RunbookGUID $RunbookGUID -Credential $Credential
```

the function returns a list with runbook name and GUID

## get list of runbook parameters

you can get a list of input and output parameters for a runbook:

```PowerShell
Get-SCORunbookParameter -OrchestratorServer $OrchestratorServer -RunbookGUID $RunbookGUID -Credential $Credential
```

## start a runbook

you can start a runbook. you can pass input parameters to the runbook and get the returned values back.

```PowerShell
$Params = @{
  paramA = 'AAA'
  paramB = 'BBB'
}
Get-SCORunbookParameter -OrchestratorServer $OrchestratorServer -RunbookName $RunbookName -Credential $Credential -Params $Params -wait
```

the function will return a hashtable with this datas:

- RunbookName
- RunbookGuid
- StartTime
- JobID
- only with wait parameter:
  - Status
  - EndTime
  - Output
