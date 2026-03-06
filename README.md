# Cortex Cloud POV / Sandbox Environment

This code repo contains a complete GCP and GitHub environment that automates the process of creating cloud assets, onboarding the cloud account to Cortex Cloud, creating an asset group, building K8s and Linux XDR installation packages, installing XDR onto endpoints, and creating security cases. This template has been tested with and works with [Torque](https://portal.qtorque.io/) provisioned cloud accounts.

> [!NOTE]
> This code repo works as-is, but is currently lacking some documentation on how to deploy. Stay tuned!

1. [Use the Template](#use-the-template)
2. [GCP Setup Instructions](/docs/onboard/gcp/README.md)
3. [Cortex Setup Instructions](/docs/onboard/cortex/README.md)
4. [Running Workflows](/docs/workflows/README.md)

## Use the Template

> [!IMPORTANT]
> This setup only works with 1.3 release or later of Cortex Cloud

This first step is optional, but if you are supporting multiple environments having separate organizations can be helpful but is not required.

1. (Optional) [Create a GitHub Organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch)

> [!TIP]
> Select the free tier

2. Clone this repo into your new organization
    - Use this template -> create a new repository

> [!WARNING]
> If you created a new Organization. make certain you deploy this template in your new organization and not your GitHub account

3. Follow the [GCP](/docs/onboard/gcp/README.md) and [Cortex](/docs/onboard/cortex/README.md) Setup Instructions

4. Run [workflows](/docs/workflows/README.md) to complete the setup