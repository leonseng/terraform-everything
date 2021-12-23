# Fargate HTTP Load Test

Creates AWS Fargate containers that run load test (by default Apache Benchmark) in one or more AWS regions against a HTTP endpoint.

## Setup

1. Using [all_regions.txt](./all_regions.txt) as reference, create a file `_regions.txt` file containing a list of AWS regions to run the load test from.
1. Run `./generate-tf.sh` to create a `_load.tf` file which will contain the Terraform AWS providers and load test modules for all specified region.
1. Run Terraform commands to create the Fargate containers. See [variables.tf](./variables.tf) for a list of input variables.
    ```
    terraform init
    terraform apply -auto-approve <optional variables>
    ```

## Load test container image

This repository comes with a default load test container image `quay.io/l_seng/ab-dos` that runs Apache Benchmark. To build it from source:

```
docker build --tag quay.io/l_seng/ab-dos ./load-test-container
docker push quay.io/l_seng/ab-dos
```
