
.PHONY: all help deploy-ea-vpc delete-ea-vpc

SHELL = /bin/bash

all: help

help:
	@echo
	@echo " Available Make Targets:"
	@echo
	@grep '^[^#[:space:]].*:' Makefile | grep -Ev '(.PHONY|all)' | \
		sed 's/^/  > /g' | sed 's/:.*//g'
	@echo

deploy-ea-vpc:
	aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--region us-east-1 \
		--stack-name test-deploy-ea-vpc \
		--template-file enterprise-app-vpc.template

delete-ea-vpc:
	aws cloudformation delete-stack \
		--region us-east-1 \
		--stack-name test-deploy-ea-vpc


