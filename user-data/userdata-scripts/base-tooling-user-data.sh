#!/bin/bash
/bin/echo "Hello World" >> /tmp/userdata_testfile.txt

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