AWS_PROFILE := default
AWS_DEFAULT_REGION := ap-northeast-1
TERRAFORM_VERSION := 0.12.24

SCOPE :=
TFSTATE_BUCKET := #change here
TFSTATE_KEY = sandbox/$(SCOPE)/terraform.tfstate

PAR := 50

__scope:
ifeq ($(SCOPE),)
	$(error "U should define SCOPE #=> Like make plan SCOPE=hoge")
endif


init: __scope
	docker run --rm -it \
		-v ~/.aws:/root/.aws \
		-e AWS_PROFILE=$(AWS_PROFILE) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		-v $(CURDIR):/app \
		-w /app/$(SCOPE) \
		hashicorp/terraform:$(TERRAFORM_VERSION) init \
			-get=true \
			-get-plugins=true \
			-backend=true \
			-backend-config="region=$(AWS_DEFAULT_REGION)" \
			-backend-config="profile=$(AWS_PROFILE)" \
			-backend-config="bucket=$(TFSTATE_BUCKET)" \
			-backend-config="key=$(TFSTATE_KEY)"

plan: init
	docker run --rm -it \
		-v ~/.aws:/root/.aws \
		-e AWS_PROFILE=$(AWS_PROFILE) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		-v $(CURDIR):/app \
		-w /app/$(SCOPE) \
		hashicorp/terraform:$(TERRAFORM_VERSION) plan -parallelism=$(PAR)

apply: init
	docker run --rm -it \
		-v ~/.aws:/root/.aws \
		-e AWS_PROFILE=$(AWS_PROFILE) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		-v $(CURDIR):/app \
		-w /app/$(SCOPE) \
		hashicorp/terraform:$(TERRAFORM_VERSION) apply -auto-approve=false -parallelism=$(PAR)

__destroy: init
	docker run --rm -it \
		-v ~/.aws:/root/.aws \
		-e AWS_PROFILE=$(AWS_PROFILE) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		-v $(CURDIR):/app \
		-w /app/$(SCOPE) \
		hashicorp/terraform:$(TERRAFORM_VERSION) destroy -auto-approve=false
