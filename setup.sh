## Install AWS CLI for Mac OS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm -rf AWSCLIV2.pkg

## Sign up to aws using CLI
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html

## Install Terraform Mac
# https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180#3ec6
brew tap hashicorp/tap
brew update
brew install hashicorp/tap/terraform