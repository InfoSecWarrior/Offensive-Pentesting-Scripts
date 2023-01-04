#!/bin/bash

SCRIPT_NAME=$0

#------------------------
# COLORS
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
reset='\033[0m'
bold=$(tput bold)
#------------------------

function Banner() { echo -e "
 ___        __      ____             __        __              _            
|_ _|_ __  / _| ___/ ___|  ___  ___  \ \      / /_ _ _ __ _ __(_) ___  _ __ 
 | || '_ \| |_ / _ \___ \ / _ \/ __|  \ \ /\ / / _  | '__| '__| |/ _ \| '__|
 | || | | |  _| (_) |__) |  __/ (__    \ V  V / (_| | |  | |  | | (_) | |   
|___|_| |_|_|  \___/____/ \___|\___|    \_/\_/ \__,_|_|  |_|  |_|\___/|_|

 github.com/InfoSecWarrior                              by ${green}@ArmourInfosec${reset}

----------------------------------------------------------------------------
"
}


function INFO_PRINT(){ echo -e ${blue} [" "INFO"  "] ${reset}
}


function ERROR_PRINT(){ echo -e ${red} [ ERROR ] ${reset}
}


function WARNING_PRINT(){ echo -e ${yellow} [WARNING] ${reset}
}


function NOTIFY_PRINT(){ echo -e ${purple} [NOTIFY ] ${reset}
}


function HELP_PRINT(){
echo -e "${green} [HELP] ${reset} Flag: -o, --output [directory]
${green} [HELP] ${reset} Example: $SCRIPT_NAME --output /opt/subdomains"
exit 22
}

Banner

#------------------------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------
# getopts
#-------------------------------

if [ "$#" != "0" ]; then

    SHORT=o:
    LONG=output:
    PARSED_ARGUMENTS=$(getopt --alternative --quiet --name $SCRIPT_NAME --options $SHORT --longoptions $LONG -- "$@")
    VALID_ARGUMENTS=$?
        if [ "$VALID_ARGUMENTS" != "0" ] || [ "$#" == "0" ]; then
            HELP_PRINT
        fi

    eval set -- "$PARSED_ARGUMENTS"
    unset PARSED_ARGUMENTS

    while :
    do
      case "$1" in
        '-o' | '--output')
          Outputdir=$2
          shift 2
          ;;

        '--')
          shift
          break
          ;;

        '*')
          HELP_PRINT
          ;;

      esac
    done

# Setting default directory to `pwd` if --output switch is not given
else
    Outputdir=$(pwd)
fi

#----------------------------------------------------
# Checking if directory is valid and writable or not
#----------------------------------------------------

if [ -d $Outputdir ]; then
    if [ -w $Outputdir ]; then
        echo -e "$(INFO_PRINT) Output will be saved in ${bold}'$Outputdir'${reset} directory."
    else
        echo -e "$(ERROR_PRINT) '$Outputdir' is not writable !"
        exit 22
    fi
else
    echo -e "$(ERROR_PRINT) '$Outputdir' is not a valid directory !"
    exit 22
fi

#------------------------------------------------------------------------------------------------------------------------------------------------------

#----------------------------
# duplicut check
#----------------------------

which duplicut &> /dev/null

if [ $? -eq 0 ]; then
    DUPLICUT_INSTALL=true
else
    echo -e "$(ERROR_PRINT) duplicut is not installed! "
    echo -e "$(INFO_PRINT) duplicut installation:
            # git clone https://github.com/nil0x42/duplicut
            # cd duplicut/ && make
            # sudo ln -s /opt/duplicut/duplicut /usr/local/bin/duplicut"
    exit 7
fi


#----------------------------
# Notify check
#----------------------------

which notify &>/dev/null

if [ $? -eq 0 ]; then
    NOTIFY_INSTALL=true
else
    NOTIFY_INSTALL=false
fi

if [[ "${NOTIFY_INSTALL}" = true ]]; then
  echo "Starting $SCRIPT_NAME" | notify -silent &>/dev/null
  if [ $? -eq 0 ]; then
      NOTIFY_CONF=true
      echo -e "$(NOTIFY_PRINT) Notification sent"
  else
      NOTIFY_CONF=false
  fi
fi

if [[ "${NOTIFY_INSTALL}" = false ]]; then
    echo -e "$(WARNING_PRINT) Notify is not installed !"
fi

if [[ "${NOTIFY_CONF}" = false ]]; then
    echo -e "$(WARNING_PRINT) Notify is not configured !"
fi

#------------------------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------
# Downloading gist raw data
#-------------------------------------

mkdir -p $Outputdir/tmpdata/all_resources_data

echo -e "$(INFO_PRINT) ${blue}Downloading gist raw data${reset}"

declare -A not_downloaded_urls

wget -O $Outputdir/tmpdata/all_resources_data/six2dez_permutations_list.txt https://gist.github.com/six2dez/ffc2b14d283e8f8eff6ac83e20a3c4b4/raw &> /dev/null

exit_status=$?

if [ $exit_status -eq 0 ]
      then
          echo -e "$(INFO_PRINT) Downloaded https://gist.github.com/six2dez/ffc2b14d283e8f8eff6ac83e20a3c4b4/raw (1/2)"
      else
          echo -e "$(ERROR_PRINT) Unable to download https://gist.github.com/six2dez/ffc2b14d283e8f8eff6ac83e20a3c4b4/raw, try manually (1/2)"
          not_downloaded_urls["https://gist.github.com/six2dez/ffc2b14d283e8f8eff6ac83e20a3c4b4/raw"]="https://gist.github.com/six2dez/ffc2b14d283e8f8eff6ac83e20a3c4b4/raw"
fi

wget -O $Outputdir/tmpdata/all_resources_data/six2dez_subdomains.txt https://gist.github.com/six2dez/a307a04a222fab5a57466c51e1569acf/raw &> /dev/null

exit_status=$?

if [ $exit_status -eq 0 ]
      then
        echo -e "$(INFO_PRINT) Downloaded https://gist.github.com/six2dez/a307a04a222fab5a57466c51e1569acf/raw (2/2)"
      else
        echo -e "$(ERROR_PRINT) Unable to download https://gist.github.com/six2dez/a307a04a222fab5a57466c51e1569acf/raw, try manually (2/2)"
        not_downloaded_urls["https://gist.github.com/six2dez/a307a04a222fab5a57466c51e1569acf/raw"]="https://gist.github.com/six2dez/a307a04a222fab5a57466c51e1569acf/raw"
fi

#------------------------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------
# Mking github resources urls array
#-------------------------------------

declare -a Git_resources=(
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/bitquark-subdomains-top100000.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/combined_subdomains.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top500.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/dns-Jhaddix.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/fierce-hostlist.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/italian-subdomains.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/namelist.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/shubs-stackoverflow.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/shubs-subdomains.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/sortedcombined-knock-dnsrecon-fierce-reconng.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-110000.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-20000.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions01.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions02.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions03.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions04.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions05.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions06.txt"
     "https://raw.githubusercontent.com/script-kiddie-hacker/Subdomain-Wordlists/main/subdomains-33-millions07.txt"
     "https://raw.githubusercontent.com/trickest/wordlists/main/inventory/subdomains.txt"
     "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/tlds.txt"
)

#------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------
# Downloading Assetnote and github resources data
#------------------------------------------------

wget "https://wordlists-cdn.assetnote.io/data/automated.json" -O $Outputdir/tmpdata/assetnote_automated.json &> /dev/null
wget "https://wordlists-cdn.assetnote.io/data/manual.json" -O $Outputdir/tmpdata/assetnote_manual.json &> /dev/null
cat $Outputdir/tmpdata/assetnote_automated.json $Outputdir/tmpdata/assetnote_manual.json | grep -iE "(dns|subdomains)" | awk -F "'" '/"Download"/ {print $2}' > $Outputdir/tmpdata/assetnote_subdomains_files_url.txt
readarray -t Assetnote_resources < $Outputdir/tmpdata/assetnote_subdomains_files_url.txt

# Merging both arrays

All_resources=("${Git_resources[@]}" "${Assetnote_resources[@]}")

echo -e "$(INFO_PRINT) ${blue}Downloading all resources data${reset}"

i=0

for resource in ${All_resources[@]}; do
    i=$((i + 1))
    wget -P $Outputdir/tmpdata/all_resources_data $resource &> /dev/null
    exit_status=$?
    if [ $exit_status -eq 0 ]
    then 
        echo -e "$(INFO_PRINT) Downloaded $resource (${i}/${#All_resources[@]})"
    else 
        echo -e "$(ERROR_PRINT) Unable to download $resource, try manually (${i}/${#All_resources[@]})"
          not_downloaded_urls["$resource"]="$resource"
    fi
done


#------------------------------------------------
# Handling .tlds.txt file
#------------------------------------------------

sed -i 's/^\.//g' $Outputdir/tmpdata/all_resources_data/tlds.txt

#------------------------------------------------
# Merging all subdomains files
#------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Merging all resources subdomains${reset}"

for file in $Outputdir/tmpdata/all_resources_data/*.txt; do
    cat $file >> $Outputdir/tmpdata/allresources_subdomains_merge_tmp.txt
done

duplicut $Outputdir/tmpdata/allresources_subdomains_merge_tmp.txt -o $Outputdir/tmpdata/allresources_subdomains_merge.txt &> /dev/null


#-----------------------------------------[ First Level Subdomains Wordlist ]--------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making first level subdomains wordlist${reset}"

rev $Outputdir/tmpdata/allresources_subdomains_merge.txt > $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt

awk -F '.' '{print $1}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev > $Outputdir/tmpdata/first_level_subdomains_wordlist_tmp_1.txt

sed 's/\./\n/g' $Outputdir/tmpdata/allresources_subdomains_merge.txt > $Outputdir/tmpdata/first_level_subdomains_wordlist_tmp_2.txt

cat $Outputdir/tmpdata/first_level_subdomains_wordlist_tmp_1.txt $Outputdir/tmpdata/first_level_subdomains_wordlist_tmp_2.txt | duplicut -o $Outputdir/first_level_subdomains_wordlist.txt &> /dev/null


#-----------------------------------------[ Second Level Subdomains Wordlist ]-------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making second level subdomains wordlist${reset}"

awk -F '.' 'NF>=2 {print $1"."$2}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/second_level_subdomains_wordlist.txt &> /dev/null


#-----------------------------------------[ Third Level Subdomains Wordlist ]-------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making third level subdomains wordlist${reset}"

awk -F '.' 'NF>=3 {print $1"."$2"."$3}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/third_level_subdomains_wordlist.txt &> /dev/null


#-----------------------------------------[ Fourth Level Subdomains Wordlist ]------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making fourth level subdomains wordlist${reset}"

awk -F '.' 'NF>=4 {print $1"."$2"."$3"."$4}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/fourth_level_subdomains_wordlist.txt &> /dev/null


#------------------------------------------[ Fifth Level Subdomains Wordlist ]------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making fifth level subdomains wordlist${reset}"

awk -F '.' 'NF>=5 {print $1"."$2"."$3"."$4"."$5}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/fifth_level_subdomains_wordlist.txt &> /dev/null


#------------------------------------------[ Sixth Level Subdomains Wordlist ]------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making sixth level subdomains wordlist${reset}"

awk -F '.' 'NF>=6 {print $1"."$2"."$3"."$4"."$5"."$6}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/sixth_level_subdomains_wordlist.txt &> /dev/null


#----------------------------------------[ Seventh Level Subdomains Wordlist ]------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making seventh level subdomains wordlist${reset}"

awk -F '.' 'NF>=7 {print $1"."$2"."$3"."$4"."$5"."$6"."$7}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/seventh_level_subdomains_wordlist.txt &> /dev/null


#-----------------------------------------[ Eighth Level Subdomains Wordlist ]------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making eighth level subdomains wordlist${reset}"

awk -F '.' 'NF>=8 {print $1"."$2"."$3"."$4"."$5"."$6"."$7"."$8}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt | rev | duplicut -o $Outputdir/eighth_level_subdomains_wordlist.txt &> /dev/null


#-----------------------------------------[ Ninth and above Level Subdomains Wordlist ]-------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making ninth and above level subdomains wordlist${reset}"

awk -F '.' 'NF>=9 {print $1"."$2"."$3"."$4"."$5"."$6"."$7"."$8"."$9}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt > $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt
awk -F '.' 'NF>=10 {print $1"."$2"."$3"."$4"."$5"."$6"."$7"."$8"."$9"."$10}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt >> $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt
awk -F '.' 'NF>=11 {print $1"."$2"."$3"."$4"."$5"."$6"."$7"."$8"."$9"."$10"."$11}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt >> $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt
awk -F '.' 'NF>=12 {print $1"."$2"."$3"."$4"."$5"."$6"."$7"."$8"."$9"."$10"."$11"."$12}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt >> $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt
awk -F '.' 'NF>=13 {print $1"."$2"."$3"."$4"."$5"."$6"."$7"."$8"."$9"."$10"."$11"."$12"."$13}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt >> $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt
awk -F '.' 'NF>=14 {print}' $Outputdir/tmpdata/allresources_subdomains_merge_rev.txt >> $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt

rev $Outputdir/tmpdata/ninth_and_above_level_subdomains_wordlist_tmp.txt | duplicut -o $Outputdir/ninth_and_above_level_subdomains_wordlist.txt &> /dev/null


#-----------------------------------------[ Master Subdomains Wordlist ]------------------------------------------------------------------------------------

echo -e "$(INFO_PRINT) ${blue}Making master level subdomains wordlist${reset}"

cat $Outputdir/first_level_subdomains_wordlist.txt $Outputdir/second_level_subdomains_wordlist.txt $Outputdir/third_level_subdomains_wordlist.txt $Outputdir/fourth_level_subdomains_wordlist.txt $Outputdir/fifth_level_subdomains_wordlist.txt $Outputdir/sixth_level_subdomains_wordlist.txt $Outputdir/seventh_level_subdomains_wordlist.txt $Outputdir/eighth_level_subdomains_wordlist.txt > $Outputdir/master_subdomains_wordlist.txt

#------------------------------------------------------------------------------------------------------------------------------------------------------


if [ ${#not_downloaded_urls[@]} -gt 0 ]; then
  echo -e "$(ERROR_PRINT) ${red}These are resources which are unable to download, try manually${reset}"
  for url in ${!not_downloaded_urls[@]}; do
    echo $url
  done
fi

if [[ "${NOTIFY_CONF}" = true ]]; then
    echo -e "$SCRIPT_NAME All Tasks Done" | notify -silent
    echo -e "$(NOTIFY_PRINT) Notification Sent"
else
    echo -e "$(INFO_PRINT) All Task Done, subdomains Wordlists are Ready"
    wc -l $Outputdir/*.txt
fi
