# Environment Setup

In order to automate cloud account onboarding and other API driven functions in Cortex it is required to first create an API key with the appropriate permissions. The final steps are to add the Cortex tenant URL and API key number as variables and the API key secret value as repo variables and secrets.

1. [Cortex Setup](#cortex-setup)
2. [GitHub Setup](#github-setup)
    - [Cortex Cloud Secrets](#cortex-cloud-secrets)
    - [Cortex Cloud Variables](#cortex-cloud-variables)

---

## Cortex Setup

1. Navigagte to "Settings" -> "Configurations" in the Cortex tenant portal

![image](/images/onboarding/ctx-1.png)

2. Search for "api" in the "Configurations" search bar, select "API Keys", and then click "New Key"

![image](/images/onboarding/ctx-2.png)

3. Choose "Standard" as the key type, enable an expiration date (recommended), select a role (instance administrator grants all access), leave a comment (optional), and click "Generate".

![image](/images/onboarding/ctx-3.png)

4. Copy the generated key value and save this locally as it will be used later as a GitHub secret

![image](/images/onboarding/ctx-4.png)

---

## Github Setup

In order to provision resources through this pipeline we need the URL of the Cortex Tenant, an API key ID, and an API secret. This API key allows the automated onboarding of our cloud account, asset group creation, and building XDR installation packages for k8s and Linux.

### Cortex Cloud Secrets
---

 | Secret |  Type  | Description | Required for Actions |
 |--------|---------|-------------|----------------|
| <pre lang="sh">CORTEX_API_SECRET</pre> | `string` | Cortex API secret value | [cortex-onboard](/.github/workflows/cortex-onboard.yml), [agent-deploy](/.github/workflows/agent-deploy.yml)

### Cortex Cloud Variables
---

 | Variable |  Type  | Description | Required for Actions |
 |--------|---------|-------------|----------------|
| <pre lang="sh">CORTEX_API_ID</pre> | `string` | Cortex API key numeric ID | [cortex-onboard](/.github/workflows/cortex-onboard.yml), [agent-deploy](/.github/workflows/agent-deploy.yml)
| <pre lang="sh">CORTEX_URL</pre> | `string` | URL of Cortex tennt, i.e. ("mytenant.us.paloaltonetworks.com") | [cortex-onboard](/.github/workflows/cortex-onboard.yml), [agent-deploy](/.github/workflows/agent-deploy.yml)