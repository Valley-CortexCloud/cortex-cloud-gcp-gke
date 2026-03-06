#! /bin/bash

# Update apt-get
sudo apt-get update -y 

# Install Software
sudo apt-get install -y npm pip git

# Remove old/conflicting Docker files
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo service docker start 

pip install -U "huggingface_hub[cli]"
hf download Qwen/Qwen2.5-Coder-32B-Instruct config.json tokenizer.json tokenizer_config.json
hf download ai21labs/Jamba-v0.1 config.json tokenizer.json tokenizer_config.json
hf download microsoft/Phi-3.5-mini-instruct config.json tokenizer.json tokenizer_config.json
hf download tiiuae/falcon-mamba-7b-instruct config.json tokenizer.json tokenizer_config.json
hf download deepseek-ai/DeepSeek-R1-0528 config.json tokenizer.json tokenizer_config.json
hf download google/flan-t5-xxl config.json tokenizer.json tokenizer_config.json
hf download microsoft/table-transformer-detection config.json tokenizer.json tokenizer_config.json