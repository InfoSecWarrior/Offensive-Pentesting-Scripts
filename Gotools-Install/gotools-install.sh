#!/bin/bash

######################################################################
# Requirements:
# -------------------------------------------------------------------
# go
######################################################################

SECONDS=0

# COLORS
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
reset='\033[0m'

function banner(){
echo -e  "    ____      ____     _____            _       __                _           "
echo -e  "   /  _/___  / __/___ / ___/___  ____  | |     / /___ ___________(_)___  _____"
echo -e  "   / // __ \/ /_/ __ \\__ \/ _ \/ ___/  | | /| / / __ \`/ ___/ ___/ / __ \/ ___/"
echo -e  " _/ // / / / __/ /_/ /__/ /  __/ /__   | |/ |/ / /_/ / /  / /  / / /_/ / /    "
echo -e  "/___/_/ /_/_/  \____/____/\___/\___/   |__/|__/\__,_/_/  /_/  /_/\____/_/     "
echo -e  "                                                                              "
echo -e  "  github.com/InfoSecWarrior                                 by @ArmourInfosec "
echo -e  "\n"

}

function INFO_PRINT(){

   echo -e ${blue} [" "INFO"  "] ${reset}
}

function WARNING_PRINT(){

  echo -e ${yellow} [WARNING] ${reset}
}

function ERROR_PRINT(){

    echo -e ${red} [ ERROR ] ${reset}
}

function COMMAND_PRINT(){

    echo -e ${green} [COMMAND] ${reset}
}

function NOTIFY_PRINT(){

    echo -e ${purple} [NOTIFY ] ${reset}
}

# Check if a binary is installed
function CHECK_BINARY() {
    
    # Check if the binary is installed
    if which "$1" &>/dev/null; then
    
        # Binary is installed
        # Declare a global variable indicating that the binary is installed
        declare -g "${1^^}_INSTALLED"=true
    
    else
        # Binary is not installed
        # Declare a global variable indicating that the binary is not installed
        declare -g "${1^^}_INSTALLED"=false
        # Print an error message
        echo "$1 is not installed. "
        exit

    fi
}

banner

######################################################################
# Check REQUIRED BINARYS install or Not
# -------------------------------------------------------------------
# Declare an array of required binary names
REQUIRED_BINARYS=(go)

# For each required binary
for binary in "${REQUIRED_BINARYS[@]}"; do
  # Check if the binary is installed
  CHECK_BINARY "$binary"
done

echo -e "$(INFO_PRINT) Good! Go installed! "

declare -A all_gotools

# Project Discovery Tools
all_gotools["nuclei"]="go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest &> /dev/null"
all_gotools["subfinder"]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &> /dev/null"
all_gotools["httpx"]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest &> /dev/null"
all_gotools["naabu"]="go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest &> /dev/null"
all_gotools["notify"]="go install -v github.com/projectdiscovery/notify/cmd/notify@latest &> /dev/null"
all_gotools["dnsx"]="go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest &> /dev/null"
all_gotools["interactsh-client"]="go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest &> /dev/null"
all_gotools["mapcidr"]="go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest &> /dev/null"
all_gotools["tlsx"]="go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest &> /dev/null"
all_gotools["katana"]="go install -v github.com/projectdiscovery/katana/cmd/katana@latest &> /dev/null"
all_gotools["cdncheck"]="go install -v github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest &> /dev/null"
all_gotools["asnmap"]="go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest &> /dev/null"
all_gotools["uncover"]="go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest &> /dev/null"
all_gotools["pdtm"]="go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest &> /dev/null"

# OWASP Amass
all_gotools["Amass"]="go install -v github.com/owasp-amass/amass/v4/...@master &> /dev/null"
    
#Tom Hudson Tools
all_gotools["gf"]="go install -v github.com/tomnomnom/gf@latest &> /dev/null"
all_gotools["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest &> /dev/null"
all_gotools["waybackurls"]="go install -v github.com/tomnomnom/waybackurls@latest &> /dev/null"
all_gotools["anew"]="go install -v github.com/tomnomnom/anew@latest &> /dev/null"
all_gotools["unfurl"]="go install -v github.com/tomnomnom/unfurl@latest &> /dev/null"
all_gotools["inscope"]="go install -v github.com/tomnomnom/hacks/inscope@latest &> /dev/null"
all_gotools["httprobe"]="go install -v github.com/tomnomnom/httprobe@latest &> /dev/null"
all_gotools["assetfinder"]="go install -v github.com/tomnomnom/assetfinder@latest &> /dev/null"
all_gotools["meg"]="go install github.com/tomnomnom/meg@latest &> /dev/null"
        
# Gwendal Le Coguic  Tools
all_gotools["github-subdomains"]="go install -v github.com/gwen001/github-subdomains@latest &> /dev/null"
all_gotools["github-endpoints"]="go install -v github.com/gwen001/github-endpoints@latest &> /dev/null"

# Josué Encinar Tools
all_gotools["analyticsrelationships"]="go install -v github.com/Josue87/analyticsrelationships@latest &> /dev/null"
all_gotools["gotator"]="go install -v github.com/Josue87/gotator@latest &> /dev/null"
all_gotools["roboxtractor"]="go install -v github.com/Josue87/roboxtractor@latest &> /dev/null"

all_gotools["puredns"]="go install -v github.com/d3mondev/puredns/v2@latest &> /dev/null"
all_gotools["gauplus"]="go install github.com/bp0lr/gauplus@latest &> /dev/null"
all_gotools["dnstake"]="go install -v github.com/pwnesia/dnstake/cmd/dnstake@latest &> /dev/null"
all_gotools["hakrawler"]="go install -v github.com/hakluke/hakrawler@latest &> /dev/null"
all_gotools["hakrevdns"]="go install github.com/hakluke/hakrevdns@latest &> /dev/null"
all_gotools["hakcheckurl"]="go install github.com/hakluke/hakcheckurl@latest &> /dev/null"
all_gotools["ffuf"]="go install -v github.com/ffuf/ffuf@latest &> /dev/null"
all_gotools["gau"]="go install -v github.com/lc/gau/v2/cmd/gau@latest &> /dev/null"
all_gotools["subjs"]="go install -v github.com/lc/subjs@latest &> /dev/null"
all_gotools["Gxss"]="go install -v github.com/KathanP19/Gxss@latest &> /dev/null"
all_gotools["gospider"]="go install -v github.com/jaeles-project/gospider@latest &> /dev/null"
all_gotools["gowitness"]="go install -v github.com/sensepost/gowitness@latest &> /dev/null"
all_gotools["crlfuzz"]="go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest &> /dev/null"
all_gotools["dalfox"]="go install -v github.com/hahwul/dalfox/v2@latest &> /dev/null"
all_gotools["ipcdn"]="go install -v github.com/six2dez/ipcdn@latest &> /dev/null"
all_gotools["gitdorks_go"]="go install -v github.com/damit5/gitdorks_go@latest &> /dev/null"
all_gotools["smap"]="go install -v github.com/s0md3v/smap/cmd/smap@latest &> /dev/null"
all_gotools["dsieve"]="go install -v github.com/trickest/dsieve@master &> /dev/null"
all_gotools["rush"]="go install -v github.com/shenwei356/rush@latest &> /dev/null"
all_gotools["enumerepo"]="go install -v github.com/trickest/enumerepo@latest &> /dev/null"
all_gotools["Web-Cache-Vulnerability-Scanner"]="go install -v github.com/Hackmanit/Web-Cache-Vulnerability-Scanner@latest &> /dev/null"

all_gotools["cent"]="go install -v github.com/xm1k3/cent@latest &> /dev/null"
all_gotools["mksub"]="go install github.com/trickest/mksub@latest &> /dev/null"

echo -e "$(INFO_PRINT) Installing Go tools (${#all_gotools[@]})"

declare -A not_install_gotools

i=0

for gotool in "${!all_gotools[@]}"; do
    i=$((i + 1))
    eval ${all_gotools[$gotool]}
    exit_status=$?
    if [ $exit_status -eq 0 ]
        then
        echo -e "$(INFO_PRINT) $gotool installed (${i}/${#all_gotools[@]})"
    else
        echo -e "$(ERROR_PRINT) Unable to install $gotool, try manually (${i}/${#all_gotools[@]})"
        not_install_gotools["$gotool"]="$gotool"
    fi
done

if [ ${#not_install_gotools[@]} -ne 0 ]; then

    echo -e "$(ERROR_PRINT) Unable to install following go tools (${#not_install_gotools[@]}), try manually."

    i=0
    for not_install_gotool in "${!not_install_gotools[@]}"; do
        i=$((i + 1))
        echo -e "$(ERROR_PRINT) $not_install_gotool (${i}/${#not_install_gotools[@]})"
    done
fi

#copy all go binary into /usr/local/bin
echo -e "$(INFO_PRINT) Copy all Go Tools into ${yellow}/usr/local/bin"
sudo cp $HOME/go/bin/* /usr/local/bin

duration=$SECONDS
echo -e "$(INFO_PRINT) Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
