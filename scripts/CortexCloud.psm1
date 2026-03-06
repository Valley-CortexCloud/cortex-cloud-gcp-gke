<#
.SYNOPSIS
    A simple PowerShell module for interacting with the Palo Alto Networks Cortex Cloud API.

.DESCRIPTION
    This module provides functions to authenticate and make REST API calls to Cortex Cloud.
    It handles the required headers (Authorization, x-xdr-auth-id) automatically.

.EXAMPLE
    Set-CortexContext -BaseUrl "https://api-mytenant.xdr.us.paloaltonetworks.com" -ApiKey "AbCd..." -ApiKeyId "123"
    Get-CortexPolicyList
#>

# Global variable to hold session state
$Global:CortexContext = @{
    BaseUrl  = $null
    ApiKey   = $null
    ApiKeyId = $null
}

function Set-CortexContext {
    <#
    .SYNOPSIS
        Sets the authentication context for subsequent API calls.
    .PARAMETER BaseUrl
        The fully qualified API URL for your tenant (e.g., https://api-tenant.xdr.us.paloaltonetworks.com).
    .PARAMETER ApiKey
        The API Key (Authorization Key) generated in the Cortex console.
    .PARAMETER ApiKeyId
        The API Key ID (x-xdr-auth-id) generated in the Cortex console.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$BaseUrl,

        [Parameter(Mandatory=$true)]
        [string]$ApiKey,

        [Parameter(Mandatory=$true)]
        [string]$ApiKeyId
    )

    # Clean up trailing slash from BaseUrl if present
    if ($BaseUrl.EndsWith("/")) {
        $BaseUrl = $BaseUrl.Substring(0, $BaseUrl.Length - 1)
    }

    if ( -not $BaseUrl.StartsWith("https://api-")){
        $BaseUrl = "https://api-$BaseUrl"
    }

    $Global:CortexContext.BaseUrl = $BaseUrl
    $Global:CortexContext.ApiKey = $ApiKey
    $Global:CortexContext.ApiKeyId = $ApiKeyId

    Write-Host "Cortex Context set for: $BaseUrl" -ForegroundColor Green
}

function Invoke-CortexApi {
    <#
    .SYNOPSIS
        Generic function to make calls to any Cortex API endpoint.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Uri,

        [Parameter(Mandatory=$false)]
        [string]$Method = "POST",

        [Parameter(Mandatory=$false)]
        [object]$Body = @{}
    )

    if ([string]::IsNullOrEmpty($Global:CortexContext.BaseUrl)) {
        Throw "Context not set. Please run 'Set-CortexContext' first."
    }

    # Construct URL
    $RequestUrl = if ($Uri.StartsWith("http")) { $Uri } else { "$($Global:CortexContext.BaseUrl)$Uri" }

    # Define Headers
    $Headers = @{
        "Authorization" = $Global:CortexContext.ApiKey
        "x-xdr-auth-id" = $Global:CortexContext.ApiKeyId
        "Content-Type"  = "application/json"
        "Accept"        = "application/json"
    }

    # JSON Body
    $JsonBody = $Body | ConvertTo-Json -Depth 10 -Compress

    # Common parameters for the web request
    $Params = @{
        Uri         = $RequestUrl
        Method      = $Method
        Headers     = $Headers
        Body        = $JsonBody
        ErrorAction = "SilentlyContinue" # We will handle errors manually
    }

    # Add -SkipHttpErrorCheck if available (PowerShell 7.4+) to avoid throwing on 4xx/5xx
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $Params["SkipHttpErrorCheck"] = $true
    }

    # Execute Request
    try {
        $Response = Invoke-WebRequest @Params
        
        # Check Status Code manually
        if ($Response.StatusCode -ge 400) {
            Write-Error "API Call Failed [$($Response.StatusCode)]: $RequestUrl"
            Write-Error "Error Details: $($Response.Content)"
            return $null
        }

        # Convert response back to object (Invoke-WebRequest returns raw content)
        return ($Response.Content | ConvertFrom-Json)
    }
    catch {
        # Fallback for older PowerShell versions or network-level failures (DNS, timeout)
        Write-Error "Network/Client Error: $($_.Exception.Message)"
    }
}

function Get-CortexVulnerabilityPolicy {
    <#
    .SYNOPSIS
        Retrieves the list of policies.
    .DESCRIPTION
        Calls the 'Get Policies List' endpoint. 
        Note: The endpoint path below (/public_api/v1/policies) is a common standard.
        If your specific documentation lists a different path (e.g. /public_api/appsec/v1/policies), 
        update the $EndpointPath variable below.
    #>
    param (
        # Optional: Allow user to override the path if their specific Cortex product uses a different one
        [string]$EndpointPath = "/public_api/uvm_public/v1/list_policies"
    )

    Write-Host "Fetching policies from $EndpointPath..." -ForegroundColor Cyan

    $Payload = @{
        filter_data = @{}
    }
    
    # Call the generic invoker
    $Result = Invoke-CortexApi -Uri $EndpointPath -Method "POST" -Body $Payload
    
    return $Result.DATA
}

function New-CortexVulnerabilityPolicy {
    <#
    .SYNOPSIS
        Retrieves the list of policies.
    .DESCRIPTION
        Calls the 'Create Policy Public' endpoint. 
        This endpoint is used to create vulnerability policy in Cortex Cloud.
    #>
    param (
        # Optional: Allow user to override the path if their specific Cortex product uses a different one
        [string]$EndpointPath = "/public_api/uvm_public/v1/create_policy",

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        [int]$Priority,

        [Parameter(Mandatory=$false)][ValidateSet('CREATE_ISSUE', 'BLOCK')]
        [string]$Action = "CREATE_ISSUE",

        [Parameter(Mandatory=$false)][ValidateSet('ENABLED', 'DISABLED')]
        [string]$Status = "ENABLED",

        [Parameter(Mandatory=$true)]
        [object]$CriteriaRule,

        [Parameter(Mandatory=$true)][ValidateSet('CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO', 'USE_CVE_SEVERITY')]
        [string]$Severity,

        [Parameter(Mandatory=$false)]
        [array]$Scope = @()
    )

    $Payload = @{
        name = $Name
        description = $Description
        priority = $Priority
        status = $Status
        match_criteria = $CriteriaRule
        severity = $Severity
        action_category = $Action
        action = @(
            @{
                action_type = if($Action -eq 'BLOCK'){ 'BLOCK_BUILD' } else { $Action }
                take_action = $true
                category = $Action
            }
        )
        asset_group_scope = $Scope

    }
    
    # Call the generic invoker
    $Result = Invoke-CortexApi -Uri $EndpointPath -Method "POST" -Body $Payload
    
    return $Result.DATA
}

function Update-CortexVulnerabilityPolicy {
    <#
    .SYNOPSIS
        Retrieves the list of policies.
    .DESCRIPTION
        Calls the 'Create Policy Public' endpoint. 
        This endpoint is used to create vulnerability policy in Cortex Cloud.
    #>
    param (
        # Optional: Allow user to override the path if their specific Cortex product uses a different one
        [string]$EndpointPath = "/public_api/uvm_public/v1/update_policy/",

        [Parameter(Mandatory=$true)]
        [string]$PolicyId,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        [int]$Priority,

        [Parameter(Mandatory=$false)][ValidateSet('CREATE_ISSUE', 'BLOCK')]
        [string]$Action = "CREATE_ISSUE",

        [Parameter(Mandatory=$false)][ValidateSet('ENABLED', 'DISABLED')]
        [string]$Status = "ENABLED",

        [Parameter(Mandatory=$true)]
        [object]$CriteriaRule,

        [Parameter(Mandatory=$true)][ValidateSet('CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO', 'USE_CVE_SEVERITY')]
        [string]$Severity,

        [Parameter(Mandatory=$false)]
        [array]$Scope = @()
    )

    $EndpointPath = $EndpointPath + $PolicyId

    $Payload = @{
        name = $Name
        description = $Description
        priority = $Priority
        status = $Status
        match_criteria = $CriteriaRule
        severity = $Severity
        action_category = $Action
        action = @(
            @{
                action_type = if($Action -eq 'BLOCK'){ 'BLOCK_BUILD' } else { $Action }
                take_action = $true
                category = $Action
            }
        )
        asset_group_scope = $Scope

    }
    
    # Call the generic invoker
    $Result = Invoke-CortexApi -Uri $EndpointPath -Method "PUT" -Body $Payload
    
    return $Result.DATA
}

function New-CortexCriteria {
    param(
        [Parameter(Mandatory)] [string]$Field,
        [Parameter(Mandatory)] [string]$Operator,
        [Parameter(Mandatory)] $Value
    )
    # Map PowerShell ops to your JSON ops
    $OpMap = @{ '-eq' = 'EQ'; '-gt' = 'GT'; '-gte' = 'GTE'; '-lt' = 'LT'; '-lte' = 'LTE' }
    
    return [PSCustomObject]@{
        SEARCH_FIELD = $Field
        SEARCH_TYPE  = $OpMap[$Operator]
        SEARCH_VALUE = $Value
    }
}

function New-CortexCriteriaRule {
    param(
        [ValidateSet('AND', 'OR')] [string]$RulesEval,
        [PSCustomObject[]]$Rules
    )
    return [PSCustomObject]@{
        $RulesEval = $Rules
    }
}

Export-ModuleMember -Function Set-CortexContext, Invoke-CortexApi, Get-CortexVulnerabilityPolicy, New-CortexCriteriaRule, New-CortexCriteria, New-CortexVulnerabilityPolicy, Update-CortexVulnerabilityPolicy
