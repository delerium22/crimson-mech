#!/bin/bash
/bin/echo "Hello World" >> /tmp/testfile.txt
yum update yum
yum install python
easy_install pip
pip install ansible