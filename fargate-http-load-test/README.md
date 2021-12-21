# Fargate HTTP Load Test

Creates AWS Fargate containers that run Apache Benchmark against a HTTP endpoint.

## Building container image

```
docker build --tag quay.io/l_seng/ab-dos .
docker push quay.io/l_seng/ab-dos
```

## Todo
[] Create module that accepts region/providers with different regions as input
[] Create main.tf that loops through regions to deploy containers/or script that loops through terraform workspaces for each region
