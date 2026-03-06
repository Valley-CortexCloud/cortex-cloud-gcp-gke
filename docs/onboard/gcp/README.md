# Environment Setup

There are a few manual steps required to provision the GCP environment. The first step is to enable the "Service Usage API". This allows API calls to be made against the GCP environment. The second step is to create a service account that will be used to authenticate and provision resources. The final steps are to add the GCP Project Id and Service Account secret as a repo variable and repo secret.

1. [GCP Setup](#gcp-setup)
2. [GitHub Setup](#github-setup)
    - [GCP Secrets](#gcp-secrets)
    - [GCP Variables](#gcp-variables)

---

## GCP Setup

1. Search for the "Service Usage API" in the GCP portal

![image](/images/onboarding/gcp-1.png)


2. Enable the "Service Usage API"

![image](/images/onboarding/gcp-2.png)


3. Search for "Service Accounts" and navigate to the "Service Accounts" IAM page

![image](/images/onboarding/gcp-3.png)

4. Create a new service account

![image](/images/onboarding/gcp-4.png)

5. Give the service account a name ("terraform") and then select "Create and continue"

![image](/images/onboarding/gcp-5.png)

6. Select the role drop down

![image](/images/onboarding/gcp-6.png)

7. Click the "Owner" role and then click "Continue"

![image](/images/onboarding/gcp-7.png)

8. Click "Done"

![image](/images/onboarding/gcp-8.png)

9. Select the 3 dots under "Actions" for the new service account you created

![image](/images/onboarding/gcp-9.png)

10. Choose "Manage keys"

![image](/images/onboarding/gcp-10.png)

11. Click "Add key" and then "Create new key"

![image](/images/onboarding/gcp-11.png)

12. <a name="step-12"></a>Select "JSON" as the key type and choose "Create"

![image](/images/onboarding/gcp-12.png)

---

## Github Setup

In order to provision resources through this pipeline we need the GCP Project ID and the JSON key for the service account.

### GCP Secrets

Navigate to the repo and create a new secret. Paste the contents of the JSON service account key created in [step 12](#step-12) as the secret value.

![image](/images/onboarding/gh-2.png)

---

 | Secret |  Type  | Description | Required for Actions |
 |--------|---------|-------------|----------------|
| <pre lang="sh">GCP_SA_KEY</pre> | `object` | GCP service account JSON key value | [gcp-setup](/.github/workflows/gcp-setup.yml), [deploy-stack](/.github/workflows/deploy-stack.yml)

### GCP Variables

Navigate to the repo and create a new variable.

![image](/images/onboarding/gh-1.png)

---

 | Variable |  Type  | Description | Required for Actions |
 |--------|---------|-------------|----------------|
| <pre lang="sh">GCP_PROJECT_ID</pre> | `string` | Project ID of GCP project | [gcp-setup](/.github/workflows/gcp-setup.yml), [deploy-stack](/.github/workflows/deploy-stack.yml)