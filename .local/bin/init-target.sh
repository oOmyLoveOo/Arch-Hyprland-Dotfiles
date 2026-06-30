#!/bin/bash

CLIENT_NAME=$1
ASSESSMENT_TYPE=$2 # IPT or EPT

# Check if both arguments are provided
if [ -z "$CLIENT_NAME" ] || [ -z "$ASSESSMENT_TYPE" ]; then
    echo "Usage: init-target <Project_Name> <IPT|EPT>"
    exit 1
fi

# Convert type to uppercase for consistency and error handling
ASSESSMENT_TYPE=$(echo "$ASSESSMENT_TYPE" | tr '[:lower:]' '[:upper:]')

# Validate assessment type
if [ "$ASSESSMENT_TYPE" != "IPT" ] && [ "$ASSESSMENT_TYPE" != "EPT" ]; then
    echo "[-] Error: Assessment type must be IPT (Internal) or EPT (External)."
    exit 1
fi

# Set dynamic variables
DATE=$(date +%Y-%m)
ROOT_NAME="${DATE}_${CLIENT_NAME}"
ROOT_PATH="$HOME/Cyber/CyberVault/08_Assessments/${ASSESSMENT_TYPE}/${ROOT_NAME}"

# 1. Create the complete modular directory tree
mkdir -p "$ROOT_PATH"/{01_Admin,02_Scans/{Nmap,Web_Discovery,AD_Bloodhound},03_Notes,04_Findings,05_Logs,06_Report}

# 2. Automatically generate the control skeleton (HTB Academy standard)
touch "$ROOT_PATH/01_Admin/Scope.md"
touch "$ROOT_PATH/01_Admin/Credentials_Provided.md"

# Baseline research notes
touch "$ROOT_PATH/03_Notes/01_Enumeration.md"
touch "$ROOT_PATH/03_Notes/02_Exploitation.md"
touch "$ROOT_PATH/03_Notes/03_Post_Exploitation.md"
touch "$ROOT_PATH/03_Notes/04_Loot_&_Creds.md"

# Technical compliance and audit hygiene logs
touch "$ROOT_PATH/05_Logs/Activity_Log.md"
touch "$ROOT_PATH/05_Logs/Payload_Log.md"

# Deliverable sections
touch "$ROOT_PATH/06_Report/Report_Draft.md"
touch "$ROOT_PATH/06_Report/Executive_Summary.md"
touch "$ROOT_PATH/06_Report/Emergency_OOB_Notification.md"

# Success message
echo "[+] Professional corporate structure for $ASSESSMENT_TYPE -> $ROOT_NAME successfully generated."
