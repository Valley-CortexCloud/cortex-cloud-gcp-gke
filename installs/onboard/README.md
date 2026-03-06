This folder is used to execute Cortex Cloud onboarding via Terraform. The only files in this directory should be README.md and backend.tf

The backend.tf is used to specify the GCP storage account as the state management location. When onboarding Cortex Cloud the GitHub Action will download the release artifact (TF onboarding files) into this directory, and configure the appropriate storage account to store state. 

> [!WARNING]
> Nothing in this folder/directory should be removed. 