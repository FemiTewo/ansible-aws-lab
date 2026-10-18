# ALWAYS run this when you finish, so the lab stops costing credits.
param([string]$Region = "us-east-2", [string]$Stack = "ansible-lab")
aws cloudformation delete-stack --stack-name $Stack --region $Region
aws cloudformation wait stack-delete-complete --stack-name $Stack --region $Region
Write-Host "Lab deleted."
