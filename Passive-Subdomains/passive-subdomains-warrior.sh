#!/bin/bash

######################################################################
# Requirements:
# -------------------------------------------------------------------
# amass
# subfinder
# assetfinder
# findomain
# gauplus
# waybackurls
# github-subdomains
# ctfr
# anew
# Notify
######################################################################


# Set the script start time
SECONDS=0

# Set the name of the script
SCRIPT_NAME=$0

# Set the log file name
LOG_FILE_NAME=LOG-FILE.txt

# Set the name of the temporary directory
TEMP_DIR_NAME=.tmp

# Set the GitHub token (used by github-subdomains)
GITHUBTOKEN=""


######################################################################
# COLORS
# -------------------------------------------------------------------
# Set colors for use in echo statements
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
reset='\033[0m'
bold=$(tput bold)
######################################################################

# ------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------
# Display a banner at the start of the script

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

######################################################################
# Print Functions
# -------------------------------------------------------------------
# Set functions for printing different types of messages

# Info message
function INFO_PRINT(){
    # Echo a blue message
    echo -e ${blue} [" "INFO"  "] ${reset}
}

# Warning message
function WARNING_PRINT(){
    # Echo a yellow message
    echo -e ${yellow} [WARNING] ${reset}
}

# Error message
function ERROR_PRINT(){
    # Echo a red message
    echo -e ${red} [ ERROR ] ${reset}
}

# Command message
function COMMAND_PRINT(){
    # Echo a green message
    echo -e ${green} [COMMAND] ${reset}
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
        # Exit the script
        exit

    fi
}


# Notify message
function NOTIFY_PRINT(){
    # Echo a purple message
    echo -e ${purple} [NOTIFY ] ${reset}
}

# Function to send a notification
function NOTIFY_PRINT_SENT() {

    # Check if notifications are enabled
    if [[ "${NOTIFY_CONF}" = true ]]; then
        
        # Send the notification with the 'notify' command
        echo -e "$(INFO_PRINT) $1 " | notify -silent
        
        # Echo a message indicating that the notification was sent
        echo -e "$(NOTIFY_PRINT) Notification Send"
    
    else
    
        # Echo the message without sending a notification
        echo -e "$(INFO_PRINT) $1"
    
    fi
}


######################################################################
# Usage Help Function
# -------------------------------------------------------------------
# Display the usage help message and exit
function USAGE_HELP()
{
    # Echo the usage message
    echo -e "Usage:"
    echo -e "\t $SCRIPT_NAME [flags] \n"
    echo -e "Flags:"
    echo -e "HELP:"
    echo -e "\t -h, --help \t\tShow this help message and exit\n"
    echo -e "TARGET:"
    echo -e "\t -d, --domain domain.tld  \tTarget Domain"
    echo -e "\t -l, --list domain_list.txt   \tPath to file containing a List of Target Domains (one per line) \n"
    echo -e "OUTPUT:"
    echo -e "\t -o, --output output/path  \tDefine Output Folder\n"
    echo -e "MODE:"
    echo -e "\t -s, --silent  \t\t\tDisable Print the Banner"

  # Exit the script with an exit code of 2
  exit 2
}


######################################################################
# Getopt
# -------------------------------------------------------------------
# Parse the command-line arguments

# Short options
SHORT=d:,l:,o:,r:,s,h
# Long options
LONG=domain:,list:,output:,recursive:,silent,help
# Parse the arguments
PARSED_ARGUMENTS=$(getopt --alternative --quiet --name $SCRIPT_NAME --options $SHORT --longoptions $LONG -- "$@")
# Check if the arguments were parsed successfully
VALID_ARGUMENTS=$?
# If the arguments were not parsed successfully or no arguments were given, display the usage help message and exit
if [ "$VALID_ARGUMENTS" != "0" ] || [ "$#" == "0" ]; then
  USAGE_HELP
fi

# Evaluate the parsed arguments
eval set -- "$PARSED_ARGUMENTS"
# Unset the parsed arguments
unset PARSED_ARGUMENTS

# While loop to iterate through the arguments
while :
do
  # Switch statement for each argument
  case "$1" in

    # Help
    '-h' | '--help')

      # Display the usage help message and exit
      USAGE_HELP
      # Shift to the next argument
      shift ;;

    # Target Domain
    '-d' | '--domain')

      # Set the target domain
      TARGET_DOMAIN=$2
      # Shift to the next argument
      shift 2 ;;
    
    # Target Domain List
    '-l' | '--list')

      # Set the target domain list
      TARGET_DOMAIN_LIST=$2
      # Shift to the next argument
      shift 2 ;;
    
    # Output Directory
    '-o' | '--output')

      # Set the main output directory
      MAIN_OUTPUT_DIR=$2
      # Shift to the next argument
      shift 2 ;;

    # Silent Mode
    '-s' | '--silent')

      # Set the silent mode flag
      SILENT_MODE=true
      # Shift to the next argument
      shift ;;

    # Double dash indicates the end of the arguments
    '--')
      # Shift to the next argument
      shift
      # Break out of the loop
      break ;;

    # Any other argument
    '*')
      # Display the usage help message and exit
      USAGE_HELP ;;

  esac
done


######################################################################
# Check if a target domain or target domain list was provided
# -------------------------------------------------------------------
# If no target domain or target domain list was provided
if [[ -z "${TARGET_DOMAIN}" ]] && [[ -z "${TARGET_DOMAIN_LIST}" ]]; then
  # Print an error message and exit
  echo -e "$(ERROR_PRINT) Target Domain is missing, try using -d <Target Domain> / -l <Domain_List> "
  echo -e "$(ERROR_PRINT) Please provide any one TARGET Option"
  exit 3
# If both a target domain and target domain list were provided
elif [[ -n "${TARGET_DOMAIN}" ]] && [[ -n "${TARGET_DOMAIN_LIST}" ]]; then
  # Print an error message and exit
  echo -e "$(ERROR_PRINT) Multiple Target are provide, try using -d <Target Domain> / -l <Domain_List> "
  echo -e "$(ERROR_PRINT) Please provide Only one TARGET Option"
  exit 4
fi



######################################################################
# Location for the outputs of the nmap command.
# -------------------------------------------------------------------
# Set the default output directory to the current working directory
MAIN_OUTPUT_DIR="${MAIN_OUTPUT_DIR:=$(pwd)}"
# Set the subdomain output directory name
SUBDOMAIN_OUTPUT_DIR=subdomain_outputs

# If the subdomain output directory already exists
if [[ -d "$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR" ]]; then
  # Print an error message and exit
  echo -e "$(ERROR_PRINT) "$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR" Directory already Exists Please choose a different location"
  exit 5
fi

LOG_FILE="$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR"/"$LOG_FILE_NAME"
# Create the subdomain output directory
mkdir "$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR" 2> /dev/null
# Create the temporary directory inside the subdomain output directory
mkdir "$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR"/"$TEMP_DIR_NAME" 2>> $LOG_FILE
TEMP_DIR="$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR"/"$TEMP_DIR_NAME"


######################################################################
# Check REQUIRED BINARYS install or Not
# -------------------------------------------------------------------
# Declare an array of required binary names
REQUIRED_BINARYS=(amass subfinder assetfinder findomain gauplus waybackurls ctfr anew notify)

# For each required binary
for binary in "${REQUIRED_BINARYS[@]}"; do
  # Check if the binary is installed
  CHECK_BINARY "$binary"
done


######################################################################
# Check notify config or Not
# -------------------------------------------------------------------

# If the notify binary is installed
if [[ "${NOTIFY_INSTALLED}" = true ]]; then

  # Attempt to send a notification
  echo "$SCRIPT_NAME Starting" | notify -silent &>/dev/null

  # If the notification was successful
  if [ $? -eq 0 ]; then
    # Set the NOTIFY_CONF variable to true
    NOTIFY_CONF=true
  else
    # Set the NOTIFY_CONF variable to false
    NOTIFY_CONF=false
  fi
fi

# If the SILENT_MODE variable is not set
if [[ -z "${SILENT_MODE}" ]]; then
  # Print the banner
  banner
fi

# If the NOTIFY_CONF variable is false
if [[ "${NOTIFY_CONF}" = false ]]; then
  # Print an error message
  echo -e "$(ERROR_PRINT) Notify is not config."
fi


######################################################################
# Subdomains Finding Passive Function
# ------------------------------------------------------------------
# This function is used to find subdomains of a given domain using multiple tools: amass, subfinder, 
# assetfinder, findomain, gauplus, waybackurls, github-subdomains, ctfr, and sublist3r.
#
# Arguments:
#   $1: The domain for which subdomains are to be found.

function SUBDOMAINS_FINDING_PASSIVE(){

  declare -A SUBDOMAINS_FINDING_PASSIVE_TOOLS

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["amass"]="amass enum -passive -d $1 -o $TEMP_DIR/$1-amass-output.txt 2>> $LOG_FILE 1> /dev/null"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["subfinder"]="subfinder -all -d $1 -v -o $TEMP_DIR/$1-subfinder-output.txt 2>> $LOG_FILE 1> /dev/null"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["assetfinder"]="assetfinder -subs-only $1 > $TEMP_DIR/$1-assetfinder-output.txt 2>> $LOG_FILE"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["findomain"]="findomain -t $1 -u $TEMP_DIR/"$1"-findomain-output.txt 2>> $LOG_FILE 1> /dev/null"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["gauplus"]="gauplus -t 5 -random-agent -subs $1 |  unfurl -u domains > $TEMP_DIR/$1-gauplus-output.txt 2>> $LOG_FILE"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["waybackurls"]="waybackurls $1 | unfurl -u domains > $TEMP_DIR/$1-waybackurls-output.txt 2>> $LOG_FILE"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["github-subdomains"]="github-subdomains -d $1 -t $GITHUBTOKEN -o $TEMP_DIR/$1-github-subdomains-output.txt 2>> $LOG_FILE 1> /dev/null"

    SUBDOMAINS_FINDING_PASSIVE_TOOLS["ctfr"]="ctfr -d $1 -o $TEMP_DIR/$1-ctfr-output.txt 2>> $LOG_FILE 1> /dev/null"

    i=0

    for SUBDOMAINS_FINDING_PASSIVE_TOOL in "${!SUBDOMAINS_FINDING_PASSIVE_TOOLS[@]}"; do

      i=$((i + 1))
  
      echo -e "$(INFO_PRINT) Start Subdomains Finding using ${green}$SUBDOMAINS_FINDING_PASSIVE_TOOL${reset} on ${yellow}$1${reset} (${purple}${i}${reset}/${#SUBDOMAINS_FINDING_PASSIVE_TOOLS[@]})"

      eval ${SUBDOMAINS_FINDING_PASSIVE_TOOLS[$SUBDOMAINS_FINDING_PASSIVE_TOOL]}

      cat $TEMP_DIR/$1-$SUBDOMAINS_FINDING_PASSIVE_TOOL-output.txt | anew $MAIN_OUTPUT_DIR/$SUBDOMAIN_OUTPUT_DIR/$1-subdomain.txt 2>> $LOG_FILE 1> /dev/null

    done

    cat "$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR"/"$1"-subdomain.txt | rev | cut -d '.' -f 3,2,1 | rev | sort | uniq -c | sort -nr | grep -v '1 ' | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f 2 > $TEMP_DIR/$TARGET_DOMAIN-first-level-subdomains.txt 2>> $LOG_FILE
        
    cat "$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR"/"$1"-subdomain.txt | rev | cut -d '.' -f 4,3,2,1 | rev | sort | uniq -c | sort -nr | grep -v '1 ' | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f 2 > $TEMP_DIR/$TARGET_DOMAIN-second-level-subdomains.txt 2>> $LOG_FILE

    NOTIFY_PRINT_SENT "Passive Subdomains Finding Completed on ${yellow}$1${reset}" 

    duration=$SECONDS
    echo -e "$(INFO_PRINT) Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
    echo -e "$(INFO_PRINT) All Subdomains of ${green}$1${reset} are saved in : ${green}"$MAIN_OUTPUT_DIR"/"$SUBDOMAIN_OUTPUT_DIR"/"$1"-subdomain.txt ${reset}"
    echo -e "$(INFO_PRINT) Top Used SubDomains (First Level) of ${green}$1${reset} are saved in : ${green}$TEMP_DIR/$TARGET_DOMAIN-first-level-subdomains.txt ${reset}"
    echo -e "$(INFO_PRINT) Top Used SubDomains (Second Level) of ${green}$1${reset} are saved in : ${green}$TEMP_DIR/$TARGET_DOMAIN-second-level-subdomains.txt ${reset}"
    echo -e "$(INFO_PRINT) All Other Files of ${green}$1${reset} are saved in : ${green}$TEMP_DIR ${reset}"

}

if [[ -n "${TARGET_DOMAIN}" ]]; then

    NOTIFY_PRINT_SENT "Start Passive Subdomains Finding on ${yellow}$TARGET_DOMAIN ${reset}"

    SUBDOMAINS_FINDING_PASSIVE $TARGET_DOMAIN

fi


if [[ -s "${TARGET_DOMAIN_LIST}" ]]; then

    readarray -t ALL_TARGET_DOMAINS < "$TARGET_DOMAIN_LIST"

    NOTIFY_PRINT_SENT "Start Passive Subdomains Finding on Target Domains List ${yellow}$TARGET_DOMAIN_LIST ${reset}"

    a=0

    for TARGET_DOMAIN_KEY in ${!ALL_TARGET_DOMAINS[@]}; do

      a=$((a + 1))

      NOTIFY_PRINT_SENT "Start Passive Subdomains Finding on ${yellow}${ALL_TARGET_DOMAINS[$TARGET_DOMAIN_KEY]}${reset} (${blue}${a}${reset}/${green}${#ALL_TARGET_DOMAINS[@]}${reset})"

      SUBDOMAINS_FINDING_PASSIVE ${ALL_TARGET_DOMAINS[$TARGET_DOMAIN_KEY]}

    done

fi

NOTIFY_PRINT_SENT "All Task ${yellow}Done ${reset}"
