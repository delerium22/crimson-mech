#!/bin/bash

#variables
aws_access_key=????????????????
aws_secret_access_key=?????????????

#base install packages
yum -y update yum
yum -y install python
easy_install pip
pip install ansible

#aws cli install and setup
pip install awscli --upgrade --user
export PATH=~/.local/bin:$PATH
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
echo -e "$aws_access_key \n$aws_secret_access_key \n\n" >> /tmp/aws_cli_cre.txt
aws configure < /tmp/aws_cli_cre.txt
rm -f /tmp/aws_cli_cre.txt

#copy resources for initial setup
aws s3 sync s3://cm22-resources /tmp/

#run the setup playbook for GIT hub use
ansible-playbook /tmp/setup-files/setup-git/setup-git.yml

# Create the role and attach the trust policy that allows EC2 to assume this role.
$ aws iam create-role --role-name Test-Role-for-EC21 --assume-role-policy-document file://tmp/setup-files/iam-admin-role/trustpolicyforec2.json

# Embed the permissions policy (in this example an inline policy) to the role to specify what it is allowed to do.
$ aws iam put-role-policy --role-name Test-Role-for-EC21 --policy-name Permissions-Policy-For-Ec2 --policy-document file://tmp/setup-files/iam-admin-role/permissionspolicyforec2.json

# Create the instance profile required by EC2 to contain the role
$ aws iam create-instance-profile --instance-profile-name EC2-ListBucket-S31

# Finally, add the role to the instance profile
$ aws iam add-role-to-instance-profile --instance-profile-name EC2-ListBucket-S31 --role-name Test-Role-for-EC21