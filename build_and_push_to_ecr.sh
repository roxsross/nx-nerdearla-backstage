#!/bin/bash

# Build and push Backstage Docker image to ECR

# Update to match correct AWS profile
AWS_PROFILE="default"

AWS_ACCOUNT_ID=$(aws sts --profile $AWS_PROFILE get-caller-identity | jq -r '.Account')
ECR_REPO_NAME="backstage-default" # From ./terraform/ecr/main.tf
AWS_REGION="us-east-1" # From ./terraform/ecr/main.tf
ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPO_FULL="${ECR_REPO_URL}/${ECR_REPO_NAME}"

# Build Docker image for ECS Fargate
cd ./app && yarn install && yarn tsc && yarn build:backend && cd ..
docker build --platform linux/amd64 -t $ECR_REPO_NAME -f ./app/packages/backend/Dockerfile ./app
docker tag $ECR_REPO_NAME:latest $ECR_REPO_FULL:latest

aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $ECR_REPO_URL

echo "Pushing Docker image to ECR repo: $ECR_REPO_FULL:latest"
docker push $ECR_REPO_FULL:latest

latest_image=$(aws ecr describe-images --repository-name $ECR_REPO_NAME --profile $AWS_PROFILE | jq -r '.imageDetails[0].imageTags[0]')
if [ "$latest_image" != "latest" ]; then
    echo "Error: latest_image does not equal 'latest'"
    exit 1
fi
echo "Successfully pushed Docker image to ECR repo: $ECR_REPO_FULL:latest"

# Temp for building/testing on M1 Mac
# docker build -t backstage -f ./backstage/packages/backend/Dockerfile ./backstage
