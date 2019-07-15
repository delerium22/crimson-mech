#!/bin/bash

## variables

#general vars
region=ap-southeast-2

# base install packages
yum -y update yum
yum -y install python
yum -y install wget
yum -y install git
yum update -y nss curl libcurl
easy_install pip
pip install ansible

# base install packages - CENTOS
sudo pip install boto

# aws cli install and setup
pip install awscli --upgrade --user
export PATH=~/.local/bin:$PATH
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
echo -e "\n\n$region \n\n" >> /tmp/aws_cli_cre.txt
aws configure < /tmp/aws_cli_cre.txt
rm -f /tmp/aws_cli_cre.txt

#retrieve the git api token from the ssm store and set to a variable
git_api_token=$(aws ssm get-parameters --with-decryption --query 'Parameters[0].Value' --names "/non_prod/tooling/git_api_token" --output text)

# Checkout the repo for building the tooling server
git clone https://delerium22:$git_api_token@github.com/delerium22/build-tooling-server-playbook.git /tmp/build-tooling-server-playbook

# run the build-tooling-server playbook
ansible-playbook /tmp/build-tooling-server-playbook/build-tooling-server.yml

# terminate self
#aws ec2 terminate-instances --instance-ids $ec2_instance_id