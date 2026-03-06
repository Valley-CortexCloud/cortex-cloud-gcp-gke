#!/bin/bash

curl -OL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

curl -L https://github.com/DataDog/stratus-red-team/releases/download/v2.23.2/stratus-red-team_Linux_x86_64.tar.gz -o stratus.tar.gz
tar -xvzf stratus.tar.gz

sudo apt-get install kubectl

gcloud auth activate-service-account --key-file=prod-k3qqmz8hj8zb-b10552b75f93.json ## Replace w stored GH Action secret
sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
gcloud container clusters get-credentials raygun-gke-cluster  --location=us-central1

# Check if a command-line argument was provided.
if [ -z "$1" ]; then
    echo "Error: No action specified."
    echo "Usage: $0 [detonate|cleanup|revert]"
    exit 1
fi

# Validate the provided action.
ACTION=$1
if [[ "$ACTION" != "detonate" && "$ACTION" != "cleanup" && "$ACTION" != "revert" ]]; then
    echo "Error: Invalid action '$ACTION'."
    echo "Usage: $0 [detonate|cleanup]"
    exit 1
fi


# An array of the test names to be executed.
# You can add or remove test names from this list as needed.
tests=(
    "k8s.credential-access.dump-secrets"
    "k8s.credential-access.steal-serviceaccount-token"
    "k8s.persistence.create-admin-clusterrole"
    "k8s.persistence.create-client-certificate"
    "k8s.persistence.create-token"
    "k8s.privilege-escalation.hostpath-volume"
    "k8s.privilege-escalation.nodes-proxy"
    "k8s.privilege-escalation.privileged-pod"
    "gcp.credential-access.secretmanager-retrieve-secrets"
    "gcp.exfiltration.share-compute-disk"
    "gcp.exfiltration.share-compute-image"
    "gcp.exfiltration.share-compute-snapshot"
    "gcp.persistence.backdoor-service-account-policy"
    "gcp.persistence.create-admin-service-account"
    "gcp.persistence.create-service-account-key"
    "gcp.persistence.invite-external-user"
    "gcp.privilege-escalation.impersonate-service-accounts"
)

# Loop through each test name in the 'tests' array.
for test_name in "${tests[@]}"; do
    # Print which test is currently being run for better tracking.
    echo "=================================================="
    echo "Running test: $test_name"
    echo "=================================================="

    # Execute the command.
    # The "$test_name" is quoted to handle any special characters.
    # The --force flag is included as requested.
    ./stratus "$ACTION" "$test_name" --force

    # Add a small delay between tests if needed, for example:
    # sleep 5
done

echo "All tests have been executed."