#!/bin/bash

set -e
MODE=$1
SECRETS_PATH=$2

function usage() {
    echo -n \
        "Usage: $(basename "$0") <plan/apply> \$SECRETS_PATH
        Run terraform for the application. 
        Requires a secrets path formatted \"s3://<bucket_name>/<prefix>/\" that points to backend.conf and terraform.tfvars.
"
}

if [[ -n "${GIT_COMMIT}" ]]; then
    GIT_COMMIT="${GIT_COMMIT:0:7}"
else
    GIT_COMMIT="$(git rev-parse --short HEAD)"
fi

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [[ "${1:-}" == "--help" ]]; then
        usage
    else
        TERRAFORM_DIR="$(pwd)"

        pushd "${TERRAFORM_DIR}"

        aws s3 sync $SECRETS_PATH $TERRAFORM_DIR

        case "$MODE" in
        plan)
            # Clear stale modules & remote state, then re-initialize
            rm -rf .terraform terraform.tfstate*

            terraform init

            terraform plan \
                -compact-warnings \
                -out="terraform.tfplan"
            ;;
        apply)
            terraform apply "terraform.tfplan"
            ;;
        *)
            echo "ERROR: I don't have support for that Terraform subcommand!"
            exit 1
            ;;
        esac

        popd
    fi
fi

        