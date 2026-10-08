"WINDOWS SYSTEM HEALTH REPORT"
"----------------------------"
$computer = $env:COMPUTERNAME
$os_name = (Get-ComputerInfo).OsName
$os_version = (Get-ComputerInfo).OsVersion
$cpu_usage = (Get-CimInstance Win32_Processor).LoadPercentage

$cimInst = Get-CimInstance Win32_OperatingSystem

$total_mem = ($cimInst.TotalVisibleMemorySize * 1KB) / 1GB

$free_mem = [Math]::Round(($cimInst.FreePhysicalMemory * 1KB) / 1GB, 2)

$free_mem_pct = [Math]::Round(($free_mem/ $total_mem) * 100, 2)

$used_mem = [Math]::Round($total_mem - $free_mem, 2)

$used_mem_pct = [Math]::Round(($used_mem / $total_mem) * 100, 2)


"COMPUTER NAME: $computer"
"OS: $os_name , $os_version"
"CPU USAGE: $cpu_usage%"
"MEMORY: "
"	Used: $used_mem GB ($used_mem_pct%)"
"	Free: $free_mem GB ($free_mem_pct%)"
"-----------------------------------------------"
"TOP 5 PROCESSES BY CPU"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, Id, CPU | Out-Host
"-----------------------------------------------"
"TOP 5 PROCESSES BY MEMORY"
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 Name, Id, @{Name='Memory (MB)'; Expression={[math]::Round($_.WorkingSet64 / 1MB, 1)}} | Out-Host
"-----------------------------------------------"
"IMPORTANT SERVICES"
Get-Service -Name Dnscache, EventLog, Winmgmt | Select-Object DisplayName, Status| Out-Host
"----------------------------------------------"
"NETWORK STATUS"
if (Test-Connection 8.8.8.8 -Count 1 -Quiet) {Write-Host "PASS" -ForegroundColor Green} else {Write-Host "FAIL" -ForegroundColor Red }
