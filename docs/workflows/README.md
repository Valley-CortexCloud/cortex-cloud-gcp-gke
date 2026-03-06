# Trigger Workflows

This template repo contains several pre-built CI/CD pipelines that can be triggered on-demand to perform specific tasks. The pipelines themselves are numbered in the order they should be run. Before running these workflows the initial setup steps should be completed.

> [!WARNING]
> Make certain to complete the [GCP](/docs/onboard/gcp/README.md) and [Cortex](/docs/onboard/cortex/README.md) Setup Instructions before attempting to run a workflow.

1. [Workflows](#workflows)
2. [Prepare First Run](#prepare-first-run)
    - [Setting Project Name](#setting-project-name)
    - [Assigning YOR Tags](#assigning-yor-tags)
3. [Running a Workflow](#running-a-workflow)

---

## Workflows

- Workflows should be run in order from 1-5. 
- Installing the k8s connector is recommended but optional.


 | Name |  File | Description | 
 |--------|---------|-------------|
| 1 - Prepare GCP Environment | [gcp-setup.yml](/.github/workflows/gcp-setup.yml) | Prepare Torque GCP account and create Terraform state bucket.
| 2 - Create Infrastructure and Deploy Applications | [deploy-stack.yml](/.github/workflows/deploy-stack.yml) | Provision GCP infrastructure and deploy applications.
| 3 - Onboard Cortex Cloud | [cortex-onboard.yml](/.github/workflows/cortex-onboard.yml) | Onboard GCP cloud account to specified Cortex tenant and create "Asset Group" with repo name and GCP project ID.
| 4 - Deploy Agents to Workloads | [agent-deploy.yml](/.github/workflows/agent-deploy.yml) | Create agent installation packages and deploy XDR agent to k8s and stand-alone VM instances.
| 5 - Create Security Cases | [simulate-attacks.yml](/.github/workflows/simulate-attacks.yml) | Generate attacks to trigger security cases on k8s cluster and stand-alone VM instances.
| Destroy Environment | [z-destroy.yml](/.github/workflows/z-destroy.yml) | Remove asset group and offboard GCP project from specified Cortex tenant.
| Install Connector - Push to Path | [connector-deploy.yaml](/.github/workflows/connector-deploy.yaml) | Deploys k8s connector helm chart from file placed in the folder [installs/connector/](/installs/connector/)

> [!IMPORTANT]
> All workflows are triggered on-demand with the exception being the "Install Connector - Push to Path" which runs when there is a new file detected in the path [installs/connector/](/installs/connector/)
> As of the 1.3 release of Cortex Cloud it is not possible to create the connector via API so it requires a manual creation of the connector and then placing the created file into the specified directory to trigger the install process.

> [!NOTE]
> The Install Connector - Push to Path workflow may not show up in the Actions view unless it has been run, but it is still present in the repo.

---

## Prepare First Run

Before running a workflow it is required to set your "project name". This variable is used to name and tag resources deployed into your GCP project. The following table displays the resources using this variable for naming.

 | Resource  | Generated Name | 
 |----------------|---------------|
| GKE Cluster |  <project_name>-gke-cluster
| Storage Account |  <project_name>-<random_id_hex_8>
| Tag | project = <project_name>
| VM Instance |  <project_name>-protected
| VM Instance |  <project_name>-unprotected

---

> Example: <pre lang="hcl">project_name = "moonshot"</pre> 

| Resource  | Generated Name | 
|----------------|---------------|
| GKE Cluster |  moonshot-gke-cluster
| Storage Account |  moonshot-she67sg5
| Tag | project = moonshot
| VM Instance |  moonshot-protected
| VM Instance |  moonshot-unprotected

---

### Setting Project Name

Edit the [project-name.tfvars](/terraform/project-name.tfvars) file, provide a project name, save and commit to the main branch of the repo.

1. Navigate to the [project-name.tfvars](/terraform/project-name.tfvars) file

2. Edit the file in the browser (or locally if you have cloned the repo)

![image](/images/workflows/wf-2.png)

3. Provide a name for the project and commit the changes

![image](/images/workflows/wf-3.png)

---

### Assigning YOR Tags

[YOR](https://github.com/bridgecrewio/yor) tags provide a nice mechanism for code-to-cloud tracing that does not require access to sensitive information such as reading a Terraform plan file. Adding these tags to resources is easy, but it does require local compute to execute.
Although GitHub provides VS Code in the browser (via GitHub.dev) you cannot run executables without a GitHub Codespaces environment. 
Cloning the repo locally to your system also allows for code execution, and to leverage YOR will need to install the binary and run a tagging command against your repo.

> [!TIP]
> Cloning the repo to your local workstation enables you to showcase additional capabilities

- [Cortex Cloud VS Code Plugin](https://marketplace.visualstudio.com/items?itemName=PrismaCloud.prisma-cloud)
- CortexCLI
- PR workflows

To tag your infrastructure resources with YOR tags run the following command from the /terraform/ directory in the repo.

```shell
yor tag --tag-local-modules --skip-dirs gcp -t yor_trace -d . 
```

You should see output similar to the following:

![image](/images/workflows/yor-1.png)


Commit the changes to your repo and push them to the main branch.

> [!NOTE]
> Although YOR tags can be applied anytime, doing so may cause infrastructure re-deployment.

---

## Running a Workflow

1. Navigagte to "Actions" in the GitHub portal for your repo
2. Select the action to run from the left side by clicking it
3. Click "Run workflow" to display the workflow drop-down
4. Choose Branch: main (default) and select "Run workflow"

![image](/images/workflows/wf-1.png)