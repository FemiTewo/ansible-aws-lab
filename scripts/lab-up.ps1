# Run from PowerShell on your PC. Creates the lab and prints the IPs.
param(
  [string]$KeyName = "MyKeyPair3",
  [string]$Region  = "us-east-2",
  [string]$Stack   = "ansible-lab"
)
aws cloudformation create-stack --stack-name $Stack --region $Region `
  --template-body file://infra/lab.yaml `
  --parameters ParameterKey=KeyName,ParameterValue=$KeyName
aws cloudformation wait stack-create-complete --stack-name $Stack --region $Region
aws cloudformation describe-stacks --stack-name $Stack --region $Region `
  --query "Stacks[0].Outputs[].[OutputKey,OutputValue]" --output table
