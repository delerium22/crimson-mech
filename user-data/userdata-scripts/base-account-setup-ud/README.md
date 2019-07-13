# base tooling user data script

## Purpose

This user data script initiates a list of commands to setup basic functions and connectivity for use within an account.
This server will then provision a tooling server that can be used going forward in an account as the main tooling server.

### Inputs

AWS Secret ID
AWS Secret Key
GIT API Token

### Break down of tasks

1. Install a few basic packages and binaries requiured for setup activites onthis server.
2. Install the aws cli package onteh server.
3. Configure the server so that it can authenticate and use the aws cli commands with the account.
4. Use the aws clie to download files from the S3 bucket (role and git playbook)
5. run the GIT playbook to setup GIT connectivity
6. Run aws cli iam commands to setup an admin role
7. Get the current server ID
8. Make the server assume the new admin role
9. Clone the tooling playbook
10. Run the tooling playbook to generate a new tooling server
11. Terminate the current host
