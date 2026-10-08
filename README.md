# system-health

A PowerShell script that prints a quick health report for a Windows machine. Written as the Windows counterpart to my Bash `server-stats.sh` project.

## What it reports

- Computer name and operating system
- CPU usage
- Memory: total, used, and free, with percentages
- Disk: size, used, and free space on the C: drive, with percentages
- Top 5 processes by CPU
- Top 5 processes by memory
- Status of key Windows services
- Network checks (ping), each printed as PASS or FAIL

## Usage

Run it from a PowerShell window:

```
.\system-health.ps1
```

Windows blocks PowerShell scripts by default. If you see "running scripts is disabled on this system," allow locally written scripts for your account only:

```
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

No extra modules are needed. It uses only cmdlets that ship with Windows.

## Example output

```
PS C:\Users\YourName\system-health> .\system-health.ps1
WINDOWS SYSTEM HEALTH REPORT
----------------------------
COMPUTER NAME: DESKTOP-EXAMPLE
OS: Microsoft Windows 11 Home , 10.0.26200
CPU USAGE: 39%
MEMORY:
        Used: 10.09 GB (51.09%)
        Free: 9.66 GB (48.92%)
-----------------------------------------------
TOP 5 PROCESSES BY CPU

Name           Id         CPU
----           --         ---
Discord     13908  7987.09375
browserhost 23780   7080.0625
Notion      16568  2819.78125
Notion      22352 1517.515625
chrome      33872 1353.671875


-----------------------------------------------
TOP 5 PROCESSES BY MEMORY

Name                  Id Memory (MB)
----                  -- -----------
Memory Compression  2468       928.9
chrome             31360       388.6
Notion              3844       375.5
Discord            13908       355.6
MsMpEng             5004         337


-----------------------------------------------
IMPORTANT SERVICES

DisplayName                         Status
-----------                         ------
DNS Client                         Running
Windows Event Log                  Running
Windows Management Instrumentation Running


----------------------------------------------
NETWORK STATUS
PASS
```

## How it works

| Section | Cmdlets | Notes |
|---------|---------|-------|
| Computer and OS | `Get-ComputerInfo` or `$env:COMPUTERNAME`
| CPU usage | `Get-CimInstance Win32_Processor` | Reads `LoadPercentage`, a snapshot of recent load. |
| Memory | `Get-CimInstance Win32_OperatingSystem` | Values come in kilobytes and are converted to GB. Used is total minus free. |
| Disk | Reports the C: drive only. |
| Top processes | `Get-Process`, `Sort-Object`, `Select-Object` | Sorted by `CPU` and `WorkingSet64`, top 5 each. Memory is converted to MB with a calculated column. |
| Services | `Get-Service` | Checks a short list of services that matter on most machines|
| Network | `Test-Connection` | One-packet pings with `-Quiet`, printed as PASS or FAIL. |

Each value is collected into a variable, then printed in order, so the layout can change without touching the data collection.

## Limitations

- The `CPU` figure in the process list is total processor seconds since each process started, not a percentage. It ranks long-running busy processes higher than ones that are busy right now.
- CPU usage is a single snapshot, so it changes from run to run.
- A failed ping does not always mean the network is down, because some networks block ping traffic.
- Only the C: drive is checked.

## What I learned

PowerShell passes objects through the pipeline, so values are read by property name, not by counting text columns like in Bash. I also practiced calculated properties, formatting numbers, and PASS/FAIL checks with `if` and `else`.
