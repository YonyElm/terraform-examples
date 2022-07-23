
# Lab 4 - Basic highly available application

### Background

None of the servers/DB are public. Communication is going through public Load Balancer that routes requests to the server location in a private server with limited access.

### Notes

* ec2-server: A simple NGINX application with a simple printing operation

#### Working with NAT and private servers

The application servers are running in a private subnet. In order for the server to access the internet (download/upload resources), communication must be handled by NAT gateway (to hide IP address).
When having NAT only in 1 AZ, if this AZ fails, the application servers would not be able to communicate with the internet. By making NAT Gateway highly available you ensure that communication with internet stays alive even if one AZ fails.