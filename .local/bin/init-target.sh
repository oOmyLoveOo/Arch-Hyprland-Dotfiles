#!/usr/bin/env bash
set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
# Path to your vault ON THIS HOST. Arch host = ~/Cyber/CyberVault.
# (On the Kali VM it would be ~/CyberVault — adjust if you ever run it there.)
VAULT="$HOME/Cyber/CyberVault"
# ─────────────────────────────────────────────────────────────────────

CLIENT_NAME="${1:-}"
ASSESSMENT_TYPE="${2:-}"

if [ -z "$CLIENT_NAME" ] || [ -z "$ASSESSMENT_TYPE" ]; then
    echo "Usage: init-target <Project_Name> <IPT|EPT>"
    exit 1
fi

# Normalize type to uppercase
ASSESSMENT_TYPE=$(echo "$ASSESSMENT_TYPE" | tr '[:lower:]' '[:upper:]')

if [ "$ASSESSMENT_TYPE" != "IPT" ] && [ "$ASSESSMENT_TYPE" != "EPT" ]; then
    echo "[-] Error: type must be IPT (Internal) or EPT (External)."
    exit 1
fi

# Safety: the vault MUST exist, otherwise we'd create an orphan tree outside it
if [ ! -d "$VAULT" ]; then
    echo "[-] Error: vault not found at '$VAULT'."
    echo "    Edit the VAULT variable at the top of this script with the correct path for this host."
    exit 1
fi

DATE=$(date +%Y-%m)
ROOT_NAME="${DATE}_${CLIENT_NAME}"
ROOT_PATH="$VAULT/05_Assessments/${ASSESSMENT_TYPE}/${ROOT_NAME}"

if [ -d "$ROOT_PATH" ]; then
    echo "[!] Warning: '$ROOT_NAME' already exists. Continuing without overwriting existing files."
fi

# 1. Modular directory tree
mkdir -p "$ROOT_PATH"/{01_Admin,02_Scans/{Nmap,Web_Discovery,AD_Bloodhound},03_Notes,04_Findings,05_Logs,06_Report,Loot,Tools}

# Helper: write a template to a file only if it doesn't already exist (idempotent, never clobbers your notes)
write_if_absent() {
    if [ -f "$1" ]; then
        echo "    [=] kept existing: ${1#$VAULT/}"
        return 0
    fi
    cat > "$1"
    echo "    [+] seeded: ${1#$VAULT/}"
}

# 2. Seed each file with a ready-to-fill template ──────────────────────

write_if_absent "$ROOT_PATH/01_Admin/Scope.md" << 'TPL'
# Scope

## In-Scope
- IP ranges / CIDRs:
- Domains / hosts:
- Cloud accounts:

## Out-of-Scope (explicit)
-

## Assessment Type
- IPT / EPT:
- Box: Black / Grey / White
- Assumed breach? (Y/N):

## Testing Window
- Start:
- End:
- Allowed hours:

## Rules of Engagement
- DoS-risk testing authorized? (Y/N):
- Social engineering in scope? (Y/N):
- Notes:

## Emergency Contacts
- Client:
- Tester:
- OOB notification channel:
TPL

write_if_absent "$ROOT_PATH/01_Admin/Credentials_Provided.md" << 'TPL'
# Credentials Provided

| Username | Password / Hash | Type | Source | Notes |
|----------|-----------------|------|--------|-------|
|          |                 |      |        |       |
TPL

write_if_absent "$ROOT_PATH/03_Notes/01_Enumeration.md" << 'TPL'
# Enumeration

## Hosts Discovered
| IP | Hostname | OS | Role / Notes |
|----|----------|----|--------------|
|    |          |    |              |

## Services (per host)
### <IP>
- Open ports:
- Service versions:
- Findings / tells:

## Web
- URLs / vhosts:
- Tech stack (whatweb):
- Interesting paths:

## Active Directory
- Domain / DC:
- Users:
- Groups of interest:
- BloodHound path:
TPL

write_if_absent "$ROOT_PATH/03_Notes/02_Exploitation.md" << 'TPL'
# Exploitation

## <Target>
- Vector:
- Tell (what in enum pointed here):
- Steps / exact commands:
- Result (foothold user / shell):
- Screenshot / evidence ref:
TPL

write_if_absent "$ROOT_PATH/03_Notes/03_Post_Exploitation.md" << 'TPL'
# Post-Exploitation

## <Host>
- Privesc vector:
- Tell:
- Steps / exact commands:
- Privilege gained:
- Pillaged (creds / configs / keys / sensitive data):
- Persistence created (to clean up):
TPL

write_if_absent "$ROOT_PATH/03_Notes/04_Loot_&_Creds.md" << 'TPL'
# Loot & Credentials

| Username | Password / Hash | Domain / Host | Source | Used for |
|----------|-----------------|---------------|--------|----------|
|          |                 |               |        |          |
TPL

write_if_absent "$ROOT_PATH/04_Findings/_Finding_Template.md" << 'TPL'
# Finding: <Title>

- **Severity:** Critical / High / Medium / Low / Info
- **CVSS:** (vector)
- **Affected:** (host / URL / component)
- **Status:** Draft / Confirmed / Reported

## Description
What the issue is.

## Impact
What an attacker gains / business risk.

## Steps to Reproduce
1.

## Evidence
(screenshots — redact with solid black shapes, never blur)

## Remediation
How to fix it.

## References
-
TPL

write_if_absent "$ROOT_PATH/05_Logs/Activity_Log.md" << 'TPL'
# Activity Log
> Timestamped record of every significant action (audit hygiene).

| Timestamp | Source IP | Target | Action / Tool | Result |
|-----------|-----------|--------|---------------|--------|
|           |           |        |               |        |
TPL

write_if_absent "$ROOT_PATH/05_Logs/Payload_Log.md" << 'TPL'
# Payload Log
> Every payload/file dropped on a target, so nothing is left behind.

| Timestamp | Payload / File | Dropped at (path) | Target | Cleaned up? |
|-----------|----------------|-------------------|--------|-------------|
|           |                |                   |        |             |
TPL

write_if_absent "$ROOT_PATH/06_Report/Report_Draft.md" << 'TPL'
# Report Draft
> Transcribe polished findings here from 03_Notes / 04_Findings,
> then move the final version into SysReptor (CPTS template).

## Attack Chain (narrative)
1.

## Findings (ordered by severity)
-
TPL

write_if_absent "$ROOT_PATH/06_Report/Executive_Summary.md" << 'TPL'
# Executive Summary
> Non-technical. For management. Concrete figures, no jargon.

## Overview
Scope, dates, and what was tested.

## Key Findings
- (plain-language, business impact)

## Overall Risk
Critical / High / Medium / Low + one-line justification.

## Recommendations (high-level)
1.
TPL

write_if_absent "$ROOT_PATH/06_Report/Emergency_OOB_Notification.md" << 'TPL'
# Emergency Out-of-Band Notification
> Use ONLY for issues needing immediate client contact:
> active third-party compromise, critical vuln, system instability, PII/PCI exposure.

- Date / Time:
- Issue:
- Affected system(s):
- Immediate risk:
- Recommended action:
- Notified (who / when / how):
TPL

echo ""
echo "[+] $ASSESSMENT_TYPE structure -> $ROOT_NAME created at:"
echo "    $ROOT_PATH"
echo "    Start with 01_Admin/Scope.md before touching anything."
