DOCKER_IMAGE ?= k8s-terraform:latest

ENVIRONMENT := ${ENVIRONMENT}

STACK_DIR := $(shell pwd)/kubernetes-install

# Directory for storing persistent environment state
ENV_DIR := $(shell pwd)/environments/${ENVIRONMENT}

# Bucket to store terraform state in
STATE_BUCKET_NAME := ${STATE_BUCKET_NAME}
STATE_BUCKET := gs://${STATE_BUCKET_NAME}/${ENVIRONMENT}

TERRAFORM_VARS := -var-file=${ENV_DIR}/${ENVIRONMENT}.tfvars \
                  ${TERRAFORM_EXTRA} \
				  -var assets_dir=${ENV_DIR}/generated \
				  -state ${ENV_DIR}/terraform.tfstate

OUTPUT_DIR := ${ENV_DIR}/output

TAINT :=

## Utility targets
##################
help:
	# Kubernetes Environment
	#
	# All targets can (and should) be run within Docker, in order
	# to ensure specific versions of tools are consistently used between
	# runs. Prepend any target listed here with `docker_` in order to run
	# within a pre-built Docker container.
	#
	# docker_image - build the docker image used to run terraform etc.
	# tf_init      - initialise a new terraform state file (used for creating new environments)
	# tf_plan      - run terraform plan. This prints out changes that need to be made to sync desired & actual state
	# tf_apply     - sync the desired & actual state. This will run without asking for confirmation! Use `tf_plan`
	#                to verify the changes are as expected first
	# tf_destroy   - 
	# tf_graph     - 

## Terraform targets
####################
tf_init:
	cd ${STACK_DIR}; \
	terraform init \
		-backend-config=bucket=${STATE_BUCKET_NAME} \
		-backend-config=path=${ENVIRONMENT}/${STACK}.tfstate;

tf_output: tf_init
	@cd ${STACK_DIR}; \
	terraform refresh ${TERRAFORM_VARS}; \
	terraform output -json;

tf_plan: tf_init
	@rm ${ENV_DIR}/plan.tfstate || true
	cd ${STACK_DIR}; \
	terraform plan \
		-out=${ENV_DIR}/plan.tfstate \
		${TERRAFORM_VARS};

tf_apply: tf_plan
	@read -p "Are you sure you want to apply the above changes? " yn; \
	case $$yn in \
        [Yy]* ) echo "Applying changes...";; \
        [Nn]* ) exit 1;; \
        * ) echo "Please answer yes or no."; exit 1;; \
    esac; \
	cd ${STACK_DIR}; \
	terraform apply \
		${TERRAFORM_VARS};

tf_get: tf_init
	@cd ${STACK_DIR}; \
	terraform get \
		${STACK_DIR};

tf_destroy: tf_init tf_get
	@cd ${STACK_DIR}; \
	terraform destroy \
		${TERRAFORM_VARS};

tf_taint: tf_init tf_get
	@cd ${STACK_DIR}; \
	terraform taint \
		${TERRAFORM_VARS} \
		${TAINT};

tf_graph: tf_get
	@cd ${STACK_DIR}; \
	terraform graph ${STACK_DIR} | dot -Tpng > ${OUTPUT_DIR}/${ENVIRONMENT}.png;

## Docker targets
#################
docker_image:
	@docker build -t ${DOCKER_IMAGE} .

docker_%: docker_image
	@# create a container
	docker run \
		-e TERRAFORM_EXTRA=${TERRAFORM_EXTRA} \
		-v ${HOME}/.config/gcloud:/root/.config/gcloud \
		-v $(shell pwd)/environments/${ENVIRONMENT}:/terraform/environments/${ENVIRONMENT} \
		-v $${HOME}/.ssh:/root/.ssh \
		-v $${HOME}/.matchbox:/root/.matchbox \
		--rm \
		-it \
		${DOCKER_IMAGE} \
		/bin/bash -c "make $* \
			ENVIRONMENT=${ENVIRONMENT} \
			TAINT=${TAINT} \
			"

shell:
	@bash
