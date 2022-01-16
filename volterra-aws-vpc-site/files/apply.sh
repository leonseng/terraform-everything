set -e

VES_API_P12_FILE=$1
VES_API_ENDPOINT=$2
VES_AWS_VPC_SITE_NAME=$3

# Run Terraform apply
curl -s --cert-type P12 \
  --cert $VES_API_P12_FILE:$VES_P12_PASSWORD \
  --data '{
    "action": "APPLY"
  }' $VES_API_ENDPOINT/terraform/namespaces/system/terraform/aws_vpc_site/$VES_AWS_VPC_SITE_NAME/run

# Check Terraform apply status
while true; do
  APPLY_STATUS=$(curl -s --cert-type P12 \
    --cert $VES_API_P12_FILE:$VES_P12_PASSWORD \
    $VES_API_ENDPOINT/config/namespaces/system/terraform_parameters/aws_vpc_site/$VES_AWS_VPC_SITE_NAME/status \
    | jq -r .status.apply_status.apply_state);
  if [[ $APPLY_STATUS == APPLIED ]]; then break; fi;
done;
