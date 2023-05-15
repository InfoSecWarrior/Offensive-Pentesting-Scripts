<h1 align="center">Passive Subdomains Warrior</h1>

<p align="center">
  <a href="#description">Description</a> •
  <a href="#installation">Installation</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#help">Help</a> •
  <a href="#usage">Usage</a> •
  <a href="#tools-used-and-resources">Tools Used and Resources</a>
</p>

## Description
This script finds subdomains using multiple tools and techniques to comprehensively search for subdomains and uncover any hidden subdomains of the targets. It automates the process of searching for subdomains, saving the time and effort of user. This script is a powerful tool for anyone who wants to discover subdomains and gain a deeper understanding of their target website's infrastructure.

## Installation
```
wget https://raw.githubusercontent.com/InfoSecWarrior/Offensive-Pentesting-Scripts/main/Passive-Subdomains-Warrior/passive-subdomains-warrior.sh
```
```
chmod +x passive-subdomains-warrior.sh
```
## Configuration
Set your GitHub token in script (Used by github-subdomains)
```
GITHUBTOKEN=""
```

## Help
```console
Usage:
	 passive-subdomains-warrior.sh [flags] 

Flags:
HELP:
	 -h, --help 		Show this help message and exit

TARGET:
	 -d, --domain domain.tld  	Target Domain
	 -l, --list domain_list.txt   	Path to file containing a List of Target Domains (one per line) 

OUTPUT:
	 -o, --output output/path  	Define Output Folder

MODE:
	 -s, --silent  			Disable Print the Banner
```

## Usage
Running script against a single target.
```
./passive-subdomains-warrior.sh -d example.com
```
Running script against a list of targets.
```
./passive-subdomains-warrior.sh -l targets.txt
```
Saving results to a specific directory, default saving location is current working directory.
```
./passive-subdomains-warrior.sh -l targets.txt -o /directory
```
Do not print banner
```
./passive-subdomains-warrior.sh -l targets.txt -o /directory -s
```
## Tools Used and Resources
- [amass](https://github.com/OWASP/Amass)
- [subfinder](https://github.com/projectdiscovery/subfinder)
- [assetfinder](https://github.com/tomnomnom/assetfinder)
- [findomain](https://github.com/Findomain/Findomain)
- [gauplus](https://github.com/bp0lr/gauplus)
- [waybackurls](https://github.com/tomnomnom/waybackurls)
- [github-subdomains](https://github.com/gwen001/github-subdomains)
- [ctfr](https://github.com/UnaPibaGeek/ctfr)
- [anew](https://github.com/tomnomnom/anew)
- [Notify](https://github.com/projectdiscovery/notify)
