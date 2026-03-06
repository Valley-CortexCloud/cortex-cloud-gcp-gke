param(
    [Parameter(Mandatory=$true)][int]$apiId,
    [Parameter(Mandatory=$true)][string]$apiKey,
    [Parameter(Mandatory=$true)][string]$baseURL
)

# --- Initialization ---
Import-Module ./CortexCloud.psm1 -Force
Set-CortexContext -BaseUrl $baseURL -ApiKey $apiKey -ApiKeyId $apiId

$allVulnPolicy = Get-CortexVulnerabilityPolicy
$refDoc = "REFERENCE: https://arxiv.org/pdf/2506.01220v3"

# --- Define Policy Data ---
#
$policyDefinitions = @(
    @{
        Priority = 1
        Severity = "CRITICAL"
        Name     = "Priority: Critical - Vulnerability Management Chaining"
        Desc     = "These assets require immediate remediation. Prioritize fixing these vulnerabilities. $refDoc"
        Criteria = New-CortexCriteriaRule -RulesEval AND -Rules @(
            (New-CortexCriteria -Field "HAS_KEV" -Operator "-eq" -Value $true),
            (New-CortexCriteria -Field "CVSS_SCORE" -Operator "-gte" -Value 7)
        )
    },
    @{
        Priority = 2
        Severity = "HIGH"
        Name     = "Priority: High - Vulnerability Management Chaining"
        Desc     = "These assets should be scheduled for remediation. Treat these with high priority. $refDoc"
        Criteria = New-CortexCriteriaRule -RulesEval AND -Rules @(
            (New-CortexCriteria -Field "EPSS_SCORE" -Operator "-gte" -Value 0.09),
            (New-CortexCriteria -Field "CVSS_SCORE" -Operator "-gte" -Value 7)
        )
    },
    @{
        Priority = 3
        Severity = "MEDIUM"
        Name     = "Priority: Monitor - Vulnerability Management Chaining"
        Desc     = "Threat hunting and detection engineering teams should monitor these exploited but low-severity vulnerabilities. $refDoc"
        Criteria = New-CortexCriteriaRule -RulesEval OR -Rules @(
            (New-CortexCriteriaRule -RulesEval AND -Rules @(
                (New-CortexCriteria -Field "HAS_KEV" -Operator "-eq" -Value $true),
                (New-CortexCriteria -Field "CVSS_SCORE" -Operator "-lte" -Value 7)
            )),
            (New-CortexCriteriaRule -RulesEval AND -Rules @(
                (New-CortexCriteria -Field "CVSS_SCORE" -Operator "-lte" -Value 7),
                (New-CortexCriteria -Field "EPSS_SCORE" -Operator "-gte" -Value 0.09)
            ))
        )
    }
)

# --- Process Policies (Upsert Logic) ---
foreach ($p in $policyDefinitions) {
    # Check if policy already exists
    $existingPolicy = $allVulnPolicy | Where-Object { $_.Name -eq $p.Name }

    # Prepare common parameters using Splatting
    $policyArgs = @{
        Name         = $p.Name
        Description  = $p.Desc
        Priority     = $p.Priority
        Severity     = $p.Severity
        CriteriaRule = $p.Criteria
    }

    if ($null -ne $existingPolicy) {
        Write-Host "Updating existing policy: $($p.Name)" -ForegroundColor Cyan
        $policyArgs["PolicyId"] = $existingPolicy.ID
        Update-CortexVulnerabilityPolicy @policyArgs
    }
    else {
        Write-Host "Creating new policy: $($p.Name)" -ForegroundColor Green
        New-CortexVulnerabilityPolicy @policyArgs
    }
}