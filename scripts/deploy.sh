#!/bin/bash
set -eo pipefail

usage ()
{
  echo 'Deploys terraform module.'
  echo ''
  echo 'Usage : deploy.sh -e <environment> -r <region> -p <profile> -m <terraform-module'
  echo ''
  echo '-environment | -e <environment> The project name used to initialize remote state repositories'
  echo '-region      | -r <aws-region>  The target AWS region. Defaults to [us-west-2]'
  echo '-profile     | -p <aws-profile> Name of the AWS profile'
  echo '-module      | -m <terraform-module> Terraform module (folder) to deploy'
  exit
}

COMPONENT='anycable_go'
COMPONENT_SANITIZED=$(tr '-' '_'<<< $COMPONENT)
REGION='ca-central-1'
BACKEND_PROFILE=''
TERRAFORM_PROFILE=''
AWS_PROFILE=''

while [ "$1" != "" ]
do
    case $1 in
        -environment|-e   ) shift
                        ENVIRONMENT=$1
                        ;;
        -region|-r ) shift
                        REGION=$1
                        ;;
        -profile|-p ) shift
                        PROFILE=$1
                        BACKEND_PROFILE="-backend-config=profile=$1"
                        TERRAFORM_PROFILE="-var=profile=$1"
                        AWS_PROFILE="--profile $1"
                        ;;
        -module|-m ) shift
                        MODULE=$1
                        ;;
    esac
    shift
done

if [ "$ENVIRONMENT" = "" ] || [ "$MODULE" = "" ]
then
    usage
fi

AWS_REGION="--region $REGION"

MODULE_FOLDER="$(dirname "$0")/../infrastructure/${MODULE}"

pushd $MODULE_FOLDER

aws ${AWS_PROFILE} ${AWS_REGION} ssm get-parameters-by-path --with-decryption --recursive --path "/ava/${ENVIRONMENT}/" --query "Parameters[*].{Name:Name,Value:Value}" > parameters.json
BACKEND_CONFIG_ARGUMENTS=$(jq -r ".[] | select(.Name==\"/ava/${ENVIRONMENT}/config/backend_config_arguments\") | .Value" parameters.json)
MODULE_BACKEND_CONFIG_ARGUMENTS="${BACKEND_CONFIG_ARGUMENTS} -backend-config=key=${MODULE}/terraform.tfstate"
MODULE_BACKEND_CONFIG_ARGUMENTS+=" $BACKEND_PROFILE"


rm -f terraform.tfvars

for VARIABLE in $(jq -r ".variables|keys[]" ssm_variables.json)
do
  VARIABLE_KEY=$(jq -r ".variables.\"${VARIABLE}\"" ssm_variables.json)
  VARIABLE_PATH="/ava/${ENVIRONMENT}/${VARIABLE_KEY}"
  VARIABLE_VALUE=$(jq ".[] | select(.Name==\"${VARIABLE_PATH}\") | .Value" parameters.json)
  if [ "${VARIABLE_VALUE}" != "" ]
  then
    if [[ $VARIABLE_PATH == *_json ]]
    then
      VARIABLE_VALUE=$(echo $VARIABLE_VALUE | jq -r . | tr -d '\n')
    fi  
    echo "$VARIABLE=$VARIABLE_VALUE" >> terraform.tfvars
  fi
done

VARIABLES_HASH=$(sha256sum terraform.tfvars | cut -d ' ' -f 1)
EXISTING_VARIABLES_HASH=$(jq -r ".[] | select(.Name==\"/ava/${ENVIRONMENT}/config/$MODULE/variables_hash\") | .Value" parameters.json)

MODULE_COMMIT_ID='local'
MODULE_FORCE_DEPLOY='false'

if [[ -f "../../../deployment_tags.json" && $(jq -r ".\"${COMPONENT}\".force" ../../../deployment_tags.json) == "true" ]]
then
  MODULE_FORCE_DEPLOY=true
fi

if [[ -f "../../../deployment_commits.json" ]]
then
  MODULE_COMMIT_ID=$(jq -r ".\"${COMPONENT}\"" ../../../deployment_commits.json)
fi

MODULE_DEPLOYED_COMMIT_ID_SSM="${COMPONENT_SANITIZED}_deployed_commit"
MODULE_DEPLOYED_COMMIT_ID=$(jq -r ".[] | select(.Name==\"/ava/${ENVIRONMENT}/config/$MODULE/${MODULE_DEPLOYED_COMMIT_ID_SSM}\") | .Value" parameters.json)

if [[ ("${VARIABLES_HASH}" != "${EXISTING_VARIABLES_HASH}") || ("${MODULE_COMMIT_ID}" != "${MODULE_DEPLOYED_COMMIT_ID}") || ("${MODULE_COMMIT_ID}" == "local") || (MODULE_FORCE_DEPLOY == "true") ]]
then
  
  tofu init -input=false $MODULE_BACKEND_CONFIG_ARGUMENTS
  tofu apply -input=false -auto-approve  -var="region=$REGION" $TERRAFORM_PROFILE -var="environment=$ENVIRONMENT"

  aws ${AWS_PROFILE} ${AWS_REGION} ssm put-parameter --name "/ava/${ENVIRONMENT}/config/$MODULE/variables_hash" --value ${VARIABLES_HASH} --type String --overwrite
  aws ${AWS_PROFILE} ${AWS_REGION} ssm put-parameter --name "/ava/${ENVIRONMENT}/config/$MODULE/${MODULE_DEPLOYED_COMMIT_ID_SSM}" --value ${MODULE_COMMIT_ID} --type String --overwrite
else
  echo "Skipping deployment of module ${MODULE} in $ENVIRONMENT environment."
fi

popd