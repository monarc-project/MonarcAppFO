# Development environment for MONARC using WSL

[WSL](https://docs.microsoft.com/en-us/windows/wsl/)
is convenient to use in order to setup your development environment on Windows OS.

WSL data can be accessible using ```\\wsl$``` on Windows.


## Prerequisites

* You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11.
* Virtual Machine Platform and Windows Subsystem for Linux are enabled
In PowerShell as Administrator run this commands
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
```
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
```


## Installation of WSL

1. In PowerShell Launch install
```powershell
wsl --install -d Ubuntu
```
2. Create WSL user (WSL shell)
3. Make sure that the Ubuntu distribution is set as default
```powershell
wsl -s Ubuntu
```

## Deployment of the front office
In WLS shell:

```bash
    $ cd ~
    $ git clone https://github.com/monarc-project/MonarcAppFO
    $ cd MonarcAppFO/wsl
    $ bash installFO.sh
```

Once the VM will be configured by WSL, go to the address in the browser
```http://localhost/```

The username is *admin@admin.localhost* and the password is *admin*.

The StatsService service will be configured, launched and
accessible on```http://localhost:5005```
