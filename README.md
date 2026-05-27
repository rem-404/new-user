# New-User
*This script is for a lab environment and meant for learning purposes only*

## What does it do
Creates Active Directory user accounts from a CSV file or directly from the command line. For each user it:

- Checks if the account already exists before attempting to create it
- Creates the AD account with full name, UPN, and SAM account name
- Sets a default password and forces a password change on first login
- Places the account in a staging OU
- Sets up a home folder mapped to H:

## What does it solve
- Wraps New-ADUser into a pipeline-friendly function that accepts CSV input directly, handles duplicate checking, and keeps all environment-specific settings in one place as parameters.
- Good for batch onboarding or single user creation with the same consistent command.

## Who's it for
Sysadmins handling user onboarding in a Windows/Active Directory environment.


## Requirements
- PowerShell with the ActiveDirectory module (RSAT)
- Credentials with permissions to create AD users
- The staging OU must already exist: OU=staging users,DC=lab,DC=local — update to match your environment
- Home folder share must exist: \\DC01\Shares\Home\ — update to match your environment

## Usage
```
powershell# Batch import from CSV
Import-Csv .\newusers.csv | New-User

# Single user
New-User -GivenName "John" -SurName "Doe" -SamAccountName "jdoe"

# With explicit credentials
Import-Csv .\newusers.csv | New-User -Credential $cred
CSV format:
GivenName,SurName,SamAccountName
John,Doe,jdoe
Jane,Smith,jsmith
```

## Warning
- Default password is hardcoded as P@ssword1 — fine for a lab, change before using anywhere real
- $ouPath, $domain, and $homeDirectory are default parameter values — override them at runtime or update the defaults to match your environment
- If $Credential is not passed and not set in your session, it will prompt via Get-Credential

## Limitations
- No logging — no record of which accounts were created or skipped
- Duplicate check is by SamAccountName only — doesn't check for duplicate display names
- Home folder directory is set in AD but not physically created on the file server
- Default password is the same for every user in the batch
- END {} block is empty — placeholder for future use

## Notes
Work in progress — logging, physical home folder creation, and improved credential handling coming in a future iteration. 
Built as a learning exercise for BEGIN/PROCESS/END blocks and ValueFromPipelineByPropertyName pipeline binding.
