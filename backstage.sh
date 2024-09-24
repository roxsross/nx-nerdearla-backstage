#!/bin/bash

DOCKER_COMPOSE_FILE="./local/docker/docker-compose.yml"
KIND_CLUSTER_NAME="backstage"

# Valid script invocations
# ./backstage.sh docker start|stop
# ./backstage.sh kubernetes start|stop
# ./backstage.sh terraform apply
# ./backstage.sh terraform destroy

# Check if Node 20 is installed
# Check if Node 20 or higher is installed


if [ "$1" != "docker" ] && [ "$1" != "kubernetes" ] && [ "$1" != "terraform" ]; then
    echo "Invalid first argument: start.sh docker|kubernetes|terraform"
    exit 1
fi

if [ "$2" != "start" ] && [ "$2" != "stop" ] && [ "$2" != "apply" ] && [ "$2" != "destroy" ]; then
    echo "Invalid second argument: start.sh docker|kubernetes|terraform start|stop|apply|destroy"
    exit 1
fi

# Handle local docker deployment
if [ "$1" == "docker" ]; then
    if [ "$2" == "start" ]; then
        cd app
        yarn install
        yarn tsc
        yarn build:backend
        cd ..
        docker compose -f $DOCKER_COMPOSE_FILE up --build
    elif [ "$2" == "stop" ]; then
        docker compose -f $DOCKER_COMPOSE_FILE down
        exit 0
    fi
elif [ "$1" == "kubernetes" ]; then
    K8_MANIFESTS="./local/kubernetes"
    reg_name='kind-registry'

    if [ "$2" == "start" ]; then
        cd app
        yarn install
        yarn
        yarn build:backend
        cd ..
        kind create cluster --name $KIND_CLUSTER_NAME
        docker image build ./app -f ./app/packages/backend/Dockerfile.dev --tag backstage:1.0
        # docker push backstage:1.0
        kind load docker-image backstage:1.0 --name $KIND_CLUSTER_NAME
        # kind create cluster backstage
        # kubectl create namespace backstage
        kubectl apply -f $K8_MANIFESTS/namespace.yaml
        kubectl apply -f $K8_MANIFESTS/postgres.yaml
        kubectl apply -f $K8_MANIFESTS/backstage.yaml

        sleep 10
        kubectl port-forward --namespace=backstage svc/backstage 7007:80
    elif [ "$2" == "stop" ]; then
        # Delete kind cluster and all associated resources
        kind delete cluster -n $KIND_CLUSTER_NAME
        exit 0
    fi
elif [ "$1" == "terraform" ] && [ "$2" == "apply" ]; then
    echo "Creating Terraform Resources..."
    cd .terraform/ecr
    terraform init
    terraform apply -auto-approve
    cd ../../

    # Build and push Backstage Docker image to ECR
    # call build_and_push_to_ecr.sh script to build and push to ECR
    ./build_and_push_to_ecr.sh

    cd .terraform/backstage
    terraform init
    # Target creating resources first since module.ecs can't be
    # created without them ECS task definition requires ALB DNS
    # and RDS Endpoints to be avaliable to assign as variables
    terraform apply -auto-approve \
      -target module.vpc \
      -target module.alb_sg \
      -target module.alb \
      -target module.db

    # Create remaining resources
    terraform apply -auto-approve
    cd ../../

    echo "Terraform resources created successfully!"
    echo "Please visit ALB DNS record to load Backstage"
elif [ "$1" == "terraform" ] && [ "$2" == "destroy" ]; then
    echo "Cleaning up Terraform resources..."
    cd .terraform/backstage
    terraform destroy -auto-approve
    cd ../ecr
    terraform destroy -auto-approve

    # Deregister and delete old task definition
    # Task definition in TF destroy will only be set to inactive
    # https://docs.aws.amazon.com/cli/latest/reference/ecs/deregister-task-definition.html
    task_and_revision="ecsdemo-frontend:1"
    delete_task=$(aws ecs deregister-task-definition --task-definition $task_and_revision)
    echo "Successfully deregistered task definition: $task_and_revision"
fi
