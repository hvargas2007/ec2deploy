#!/bin/bash

# Progress bar decorator functions:
decorator () {
    echo -e "Generating Task List: \n"
    echo -ne '[....................](00%)\r'
    sleep 1
    echo -ne '[#####...............](25%)\r'
    sleep 1
    echo -ne '[##########..........](50%)\r'
    sleep 1
    echo -ne '[###############.....](75%)\r'
    sleep 1
    echo -ne '[####################](100%)\r'
    echo -e '\n'
}

# Function to generate a list of task IDs (no aws profile):
generate_task_list () {
    TASK_LIST=$(aws ecs list-tasks --cluster $ECS_CLUSTER --family $CONTAINER_FAMILY --region $AWS_REGION | jq -r '.taskArns' | jq -r '.[]' | awk -F "/" '{print $3}')
    array=(${TASK_LIST/// })
    echo "Task ID List:"
    echo ""
    for i in "${!array[@]}"
        do
            echo "Task ID $i = ${array[i]}"
        done
}

# Function to generate a list of task IDs (when using an aws profile):
generate_task_list_profile () {
    TASK_LIST=$(aws ecs list-tasks --cluster $ECS_CLUSTER --family $CONTAINER_FAMILY --region $AWS_REGION --profile $AWS_PROFILE | jq -r '.taskArns' | jq -r '.[]' | awk -F "/" '{print $3}')
    array=(${TASK_LIST/// })
    echo "Task ID List:"
    echo ""
    for i in "${!array[@]}"
        do
            echo "Task ID $i = ${array[i]}"
        done
}

#Variables to validate:
CMMD1="session-manager-plugin"
CMMD2="jq"
REQUIRED_AWS_CLI_VERSION=2.3.6

# Validate if session-manager-plugin is installed:
if command -v $CMMD1 > /dev/null
	then
		echo "" > /dev/null
	else
		echo "[ERROR] $CMMD1 not installed - Please install $CMMD1 to continue"
        echo -e '\n'
        echo "Ref: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
        echo -e '\n'
		exit 1
fi


# Validate if jq is installed:
if command -v $CMMD2 > /dev/null
	then
		echo "" > /dev/null
	else
		echo "[ERROR] $CMMD2 not installed - Please install $CMMD2 to continue"
        echo -e '\n'
        echo "Ref: https://stedolan.github.io/jq/download/"
        echo -e '\n'
		exit 1
fi

# Validate AWS CLI version:
INSTALLED_AWS_CLI_VERSION=$(aws --version | awk -F "/" '{print $2}' | awk -F " " '{print $1}')
if [[ ("$INSTALLED_AWS_CLI_VERSION" < "$REQUIRED_AWS_CLI_VERSION") ]]; then
    echo -e '\n'
    echo "[ERROR] AWS CLI version $REQUIRED_AWS_CLI_VERSION or higher is required"
    echo "Please update the AWS CLI and try again:"
    echo "Ref: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
else
    echo "" > /dev/null
fi

echo "Container family list from json file:"
echo ""
cat $1 | jq -r '.[]' | jq -r '.CONTAINER_FAMILY'
echo ""
read -p "Input the container family you want to connect to: " CONTAINER_FAMILY
echo ""
echo "The following values will be used:"
echo ""
SELECTION=$(cat $1 | jq -r '.[] | select(.CONTAINER_FAMILY == "'"${CONTAINER_FAMILY}"'")')
echo $SELECTION | jq
HAS_PROFILE=$(jq 'has("AWS_PROFILE")' <<< $SELECTION)

if ($HAS_PROFILE); then
    AWS_PROFILE=$(jq -r '.AWS_PROFILE' <<< $SELECTION)
    AWS_REGION=$(jq -r '.AWS_REGION' <<< $SELECTION)
    ECS_CLUSTER=$(jq -r '.ECS_CLUSTER' <<< $SELECTION)
    CONTAINER_FAMILY=$(jq -r '.CONTAINER_FAMILY' <<< $SELECTION)
    CONTAINER_NAME=$(jq -r '.CONTAINER_NAME' <<< $SELECTION)
    echo ""
    decorator; generate_task_list_profile
    echo -e '\n'
    read -p "Input your Task ID (Copy and paste one of the above): " TASK_ID
    echo -e '\n'
    echo -e "[INFO] Using variales: $AWS_PROFILE $AWS_REGION $ECS_CLUSTER $CONTAINER_NAME $TASK_ID"
    aws ecs execute-command --cluster $ECS_CLUSTER --task $TASK_ID --container $CONTAINER_NAME --command "/bin/bash" --interactive --region $AWS_REGION --profile $AWS_PROFILE
    exit 0
else
    AWS_REGION=$(jq -r '.AWS_REGION' <<< $SELECTION)
    ECS_CLUSTER=$(jq -r '.ECS_CLUSTER' <<< $SELECTION)
    CONTAINER_FAMILY=$(jq -r '.CONTAINER_FAMILY' <<< $SELECTION)
    CONTAINER_NAME=$(jq -r '.CONTAINER_NAME' <<< $SELECTION)
    echo ""
    decorator; generate_task_list
    echo -e '\n'
    read -p "Input your Task ID (Copy and paste one of the above): " TASK_ID
    echo -e '\n'
    echo -e "[INFO] Using variales: $AWS_REGION $ECS_CLUSTER $CONTAINER_NAME $TASK_ID"
    aws ecs execute-command --cluster $ECS_CLUSTER --task $TASK_ID --container $CONTAINER_NAME --command "/bin/bash" --interactive --region $AWS_REGION
    exit 0
fi