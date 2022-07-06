#!/bin/bash
# You can use this script to access the ecs fargate container
# Session Manager plugin for the AWS CLI is needed. Ref.: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

AWS_REGION=$1
AWS_PROFILE=$2

# Check parameters:
if [ $# -eq 0 ]
then
	echo "[ERROR] Please provide an AWS Region and an AWS Profile. Example: './$(basename $0) us-east-1 defualt'"
	exit 1
fi

if [ $# = 1 ]
then
	PS3='Please select a task famlily: '
	OPTIONS=("demo_flask_app" "Quit")
	select opt in "${OPTIONS[@]}"
	do
		case $opt in
			"demo_flask_app")
				TaskID=$(aws ecs list-tasks --cluster demo-cluster --family demo_flask_app --region $AWS_REGION | jq -r '.taskArns[0]' | awk -F "/" '{print $3}')
				echo "TaskID = ${TaskID}"
				aws ecs execute-command --cluster demo-cluster --task $TaskID --container demo_flask_app --command "/bin/bash" --interactive --region $AWS_REGION
				exit 0
				;;
			"Quit")
				echo "[INFO] Script ended"
				break
				;;
			*)
				echo "[ERROR] $REPLY is an invalid option"
				exit 1
				;;
		esac
	done
fi

PS3='Please select a task famlily: '
OPTIONS=("demo_flask_app" "Quit")
select opt in "${OPTIONS[@]}"
do
	case $opt in
		"demo_flask_app")
			TaskID=$(aws ecs list-tasks --cluster demo-cluster --family demo_flask_app --region $AWS_REGION --profile $AWS_PROFILE | jq -r '.taskArns[0]' | awk -F "/" '{print $3}')
			echo "TaskID = ${TaskID}"
			aws ecs execute-command --cluster demo-cluster --task $TaskID --container demo_flask_app --command "/bin/bash" --interactive --region $AWS_REGION --profile $AWS_PROFILE
			exit 0
			;;
		"Quit")
			echo "[INFO] Script ended"
			break
			;;
		*)
			echo "[ERROR] $REPLY is an invalid option"
			exit 1
			;;
	esac
done

list_task_id () {
	echo "Do something important $1"
}