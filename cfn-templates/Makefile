
.PHONY: all help deploy-ea-vpc delete-ea-vpc

SHELL = /bin/bash

# parameters to override and pass in
STACK_NAME ?= TestDeployEA

# conditionally set the --parameter-overrides option
ifdef STACK_PARAMS
	PARAMETER_OVERRIDES = --parameter-overrides $(STACK_PARAMS)
endif

all: help

help:
	@echo
	@echo " Available Make Targets:"
	@echo
	@grep '^[^#[:space:]].*:' Makefile | grep -Ev '(.PHONY|all)' | \
		sed 's/^/  > /g' | sed 's/:.*//g'
	@echo
	@echo " Default Settings:"
	@echo
	@echo "  STACK_NAME   = $(STACK_NAME)"
	@echo "  STACK_PARAMS = $(STACK_PARAMS)"
	@echo
	@echo " Pass in ENV variables to ovveride them:"
	@echo
	@echo "  > make deploy-ea-vpc STACK_NAME=test"
	@echo

deploy-ea-vpc:
	aws cloudformation deploy \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--region us-east-1 \
		--stack-name $(STACK_NAME) \
		$(PARAMETER_OVERRIDES) \
		--template-file enterprise-app-vpc.template

delete-ea-vpc:
	aws cloudformation delete-stack \
		--region us-east-1 \
		--stack-name $(STACK_NAME)

validate:
	aws cloudformation validate-template \
		--region us-east-1 \
		--template-body file://enterprise-app-vpc.template
