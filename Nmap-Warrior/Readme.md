<h1 align="center">Nmap Warrior Bash Script</h1>

## Description
This bash script automates the process of finding live hosts from a given list of hosts or a single host. and if switch is provided, the script will also perform an open ports scan and version detection scan. This saves a significant amount of time and effort compared to manually performing these tasks. This script is a useful tool for security professionals to quickly gather information about the hosts in their scope.

## What makes this script effective?
It approaches four methods to find live hosts:
* Performs ping scan
* Performs TCP SYN ping scan
* Performs TCP ACK ping scan
* Performs UDP ping scan

It provides results in various useful formats:
* xml
* nmap
* gnmap
* Other grabbable formats


## Installation
```
wget https://raw.githubusercontent.com/InfoSecWarrior/Offensive-Pentesting-Scripts/main/Nmap-Warrior/nmap-warrior.sh
```
```
chmod +x nmap-warrior.sh
```

## Usage
```
./nmap-warrior.sh -h
```
This will display help for the script.
```console
Flags:
HELP:	 -h, --help 			Show this help message and exit

TARGET:	 -u, --target domain.tld  	Target Domain or IP Address
	 -l, --list ip_list.txt   	Path to file containing a List of Target Hosts to scan (one per line) 

OUTPUT:	 -o, --output output/path  	Define Output Folder

MODE:	 -s, --silent  			Disable Print the Banner
	 -p, --portscan  		Port scan
	 -v, --versiondetection  	Service Version Detection (Requires root privileges)
```
## Examples
Running script against a single target
```
./nmap-warrior.sh -u example.com
```
Running script against a list of targets and saving results in a specific directory
```
./nmap-warrior.sh -l targets.txt -o /path/directory
```
Example of `targets.txt`
```console
8.8.8.8
192.168.1.0/24
example.com
```
Open ports and service version detection scan with silent switch
```
./nmap-warrior.sh -l targets.txt -p -v -s -o /path/directory
```
## Tools used
- [Nmap](https://nmap.org/) (Required)
- [Notify](https://github.com/projectdiscovery/notify) (Optional)
