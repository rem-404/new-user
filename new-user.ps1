<#
new-user v4
USAGE
Import-Csv .\newusers.csv | new-user
#>

function New-User {
  [cmdletbinding()]
  param (
    [securestring]$SecurePassword = (ConvertTo-SecureString 'P@ssword1' -AsPlainText -Force),
    [string]$ouPath = "OU=staging users,DC=lab,DC=local",
    [string]$domain = "@lab.local",
    [string]$homedrive = "H:",
    [string]$homeDirectory = "\\DC01\Shares\Home\",
        
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$givenname,
        
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$surname,
        
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$samaccountname,

    [pscredential]$credential
  )

  BEGIN {
    if (-not $credential) {
      $credential = get-credential
    }

  }
  PROCESS {
    $exist = get-aduser -filter "samaccountname -eq '$samaccountname'" -erroraction SilentlyContinue

    # I removed the foreach from v1 coz process{} is already looping in each object
    # also removed the splat needed for foreach since foreach is gone
    $fullName = "$givenname $surname"
    $upn = "$samaccountname$domain"
  

    $userParams = @{
      Name                  = $fullName
      GivenName             = $givenname
      SurName               = $surname
      SamAccountName        = $samaccountname
      UserPrincipalName     = $upn
      AccountPassword       = $SecurePassword 
      ChangePasswordAtLogon = $true 
      Enabled               = $true
      Path                  = $ouPath

      # Home Folder Settings
      HomeDrive             = $homedrive
      HomeDirectory         = "$homeDirectory$samaccountname"
      Credential            = $credential # still don't know how to handle this

      # Shell feedback
      PassThru              = $true
    } # userParams
        
    if (-not $exist) {
      try {
        # Execute Active Directory Command
        New-ADUser @userParams
      }
      catch {
        #write-host "something bad happened - but i don't know what :-/" -ForegroundColor Cyan
        write-host "Failed to create $samaccountname : $($_.Exception.Message)"
      }
    }
    else {
      write-warning "Account $samaccountname already exits, skipping..."
    }
  
  } # process
  END {}
} # function

<#
CSV Format:
GivenName,SurName,SamAccountName
#>
