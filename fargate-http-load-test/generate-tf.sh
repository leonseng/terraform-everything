TF_FILE=_load.tf
REGION_FILE=_regions.txt

template="provider \"aws\" {
  alias  = \"aws_region\"
  region = \"aws_region\"
}

module \"http-load-test-aws_region\" {
  source = \"./modules/http-load-test\"
  providers = {
    aws = aws.aws_region
  }

  target = var.target
  load_test_image = var.load_test_image
}
"

echo -n "" > $TF_FILE

cat $REGION_FILE | while IFS= read -r line; do
  if [[ $line != \#* ]] ; then
    echo "${template//aws_region/"$line"}" >> $TF_FILE
  fi
done
