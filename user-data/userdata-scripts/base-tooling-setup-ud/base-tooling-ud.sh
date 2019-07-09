#!/bin/bash

#variables
aws_access_key=????????????????
aws_secret_access_key=?????????????
git_api_token=?????????????
region=ap-southeast-2

#base install packages
yum -y update yum
yum -y install python
yum -y install wget
easy_install pip
pip install ansible

#aws cli install and setup
pip install awscli --upgrade --user
export PATH=~/.local/bin:$PATH
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
echo -e "$aws_access_key \n$aws_secret_access_key \n$region \n\n" >> /tmp/aws_cli_cre.txt
aws configure < /tmp/aws_cli_cre.txt
rm -f /tmp/aws_cli_cre.txt

#copy resources for initial setup
#retrieves the ansaible playbook for adding the git key of the server to enable connectivity
#retrieves the iam role trust files for the role creation commands
aws s3 sync s3://cm22-resources /tmp/

#run the setup playbook for GIT hub use
ansible-playbook /tmp/setup-files/setup-git/setup-git.yml

### Steps to create an admin role for the ec2 to use for aws cli commands
# Create the role and attach the trust policy that allows EC2 to assume this role.
aws iam create-role --role-name admin-role-for-ec2 --assume-role-policy-document file:///tmp/setup-files/iam-admin-role/trustpolicyforec2.json
# Embed the permissions policy (in this example an inline policy) to the role to specify what it is allowed to do.
aws iam put-role-policy --role-name admin-role-for-ec2 --policy-name Permissions-Policy-For-Ec2 --policy-document file:///tmp/setup-files/iam-admin-role/permissionspolicyforec2.json
# Create the instance profile required by EC2 to contain the role
aws iam create-instance-profile --instance-profile-name admin-role-ec2
# Finally, add the role to the instance profile
aws iam add-role-to-instance-profile --instance-profile-name admin-role-ec2 --role-name admin-role-for-ec2

# get the current ev2 instance ID
die() { status=$1; shift; echo "FATAL: $*"; exit $status; }
ec2_instance_id="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\"`"
echo $ec2_instance_id

# assume the new admin role onto this EC2 instance
aws ec2 associate-iam-instance-profile --instance-id $ec2_instance_id --iam-instance-profile Name=admin-role-ec2

aws ssm put-parameter \
    --name "/non_prod/tooling/git_api_token" \
    --value "$git_api_token" \
    --type "SecureString" \
    --tier Standard

# Checkout the repo for building the tooling server
git clone git@github.com:delerium22/build-tooling-server-playbook.git /tmp/build-tooling-server-playbook

# run the build-tooling-server playbook
ansible-playbook /tmp/build-tooling-server-playbook/build-tooling-server.yml

# terminate self
aws ec2 terminate-instances --instance-ids $ec2_instance_id