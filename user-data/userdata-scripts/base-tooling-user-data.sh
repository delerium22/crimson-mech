#!/bin/bash
/bin/echo "Hello World" >> /tmp/testfile.txt
yum update yum
yum install python
easy_install pip
pip install ansible
pip install awscli --upgrade --user
export PATH=~/.local/bin:$PATH
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
aws configure