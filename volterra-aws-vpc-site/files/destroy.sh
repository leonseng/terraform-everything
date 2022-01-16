set -e

VES_API_P12_FILE=$1
VES_API_ENDPOINT=$2
VES_AWS_VPC_SITE_NAME=$3

# Run Terraform destroy
curl -s --cert-type P12 \
  --cert $VES_API_P12_FILE:$VES_P12_PASSWORD \
  --data '{
    "action": "DESTROY"
  }' $VES_API_ENDPOINT/terraform/namespaces/system/terraform/aws_vpc_site/$VES_AWS_VPC_SITE_NAME/run

# Check Terraform destroy status
while true; do
  APPLY_STATUS=$(curl -s --cert-type P12 \
    --cert $VES_API_P12_FILE:$VES_P12_PASSWORD \
    $VES_API_ENDPOINT/config/namespaces/system/terraform_parameters/aws_vpc_site/$VES_AWS_VPC_SITE_NAME/status \
      | jq -r .status.apply_status.destroy_state);
  if [[ $APPLY_STATUS == DESTROYED ]]; then break; fi;
done;
