#!/usr/bin/env bash
set -e

VES_API_P12_FILE=$1
VES_API_ENDPOINT=$2
VES_AWS_VPC_SITE_NAME=$3
TF_DESTROY_TIMEOUT_MINUTES=$4

# Run Terraform destroy
curl -s --cert-type P12 \
  --cert $VES_API_P12_FILE:$VES_P12_PASSWORD \
  --data '{
    "action": "DESTROY"
  }' $VES_API_ENDPOINT/terraform/namespaces/system/terraform/aws_vpc_site/$VES_AWS_VPC_SITE_NAME/run

# Check Terraform destroy status every 10 seconds
CHECK_INTERVAL_SECONDS=10
ATTEMPT=$(expr $TF_DESTROY_TIMEOUT_MINUTES \* 60 / $CHECK_INTERVAL_SECONDS)

for i in $(eval echo "{1..$ATTEMPT}"); do
  STATUS=$(curl -s --cert-type P12 \
    --cert $VES_API_P12_FILE:$VES_P12_PASSWORD \
    $VES_API_ENDPOINT/config/namespaces/system/terraform_parameters/aws_vpc_site/$VES_AWS_VPC_SITE_NAME/status \
      | jq -r .status.apply_status.destroy_state);

  echo "Terraform destroy status: $STATUS";

  if [[ $STATUS == DESTROYED ]]; then
    break;
  else
    if [[ $STATUS == DESTROY_ERRORED ]] || [[ $i == $ATTEMPT ]]; then
      echo "Timed out";
      exit 1;
    else
      sleep $CHECK_INTERVAL_SECONDS;
    fi;
  fi;
done;
