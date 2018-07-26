
.PHONY: all help django-env django-reqs django-root-files django-chown \
		django-collect-static flake8 flake8-env flake8-reqs \
		docker-clean docker-clean

SHELL = /bin/bash
PYTHON_VERSION ?= 3.6
DJANGO_ENV = ~/python-$(PYTHON_VERSION)-django-env
FLAKE8_ENV = ~/python-$(PYTHON_VERSION)-flake8-env

all: help

help:
	@echo
	@echo " Available Make Targets:"
	@echo
	@grep '^[^#[:space:]].*:' Makefile | grep -Ev '(.PHONY|all)' | \
		sed 's/^/  > /g' | sed 's/:.*//g'
	@echo

django-env:
	@# Unsetting PYTHON_INSTALL_LAYOUT is key for use with virtualenv!
	@# Amazon Linux sets the PYTHON_INSTALL_LAYOUT env variable to "amzn"
	@# which causes 'distutils' based install packages to get installed in
	@# {ENV}/lib64/python3.6/dist-packages instead of the proper
	@# {ENV}/lib64/python3.6/site-packages location.
	@echo -e "\nCreating a Python $(PYTHON_VERSION) Environment!"
	@echo -e "\nCleaning the ${DJANGO_ENV} directory"
	@echo "-----------------------------------------------------------"
	rm -rf $(DJANGO_ENV)
	@echo -e "\nCreating a new ${DJANGO_ENV} virtualenv"
	@echo "-----------------------------------------------------------"
	virtualenv --python=python$(PYTHON_VERSION) $(DJANGO_ENV)
	@echo -e "\nInstalling Python Packages:"
	@echo "-----------------------------------------------------------"
	unset PYTHON_INSTALL_LAYOUT && \
		source $(DJANGO_ENV)/bin/activate && \
		pip install -r fd_supply_services/requirements.txt
	@echo -e "\nTesting Python Installation"
	@echo "-----------------------------------------------------------"
	source $(DJANGO_ENV)/bin/activate && \
		python -c 'import yaml' && \
		echo -e "\n\nInstalled the following python packages:\n" && \
		pip list && \
		echo -e "\nSource the environment with:\n" && \
		echo -e "  > source $(DJANGO_ENV)/bin/activate \n"

django-reqs:
	pip freeze > fd_supply_services/requirements.txt

django-root-files:
	find . ! -user $(USER) -exec ls -lad {} \;

django-chown: django-root-files
	sudo chown $(USER):$(USER) -c -R .

django-collect-static:
	chmod +x fd_supply_services/manage.py
	source $(DJANGO_ENV)/bin/activate && \
		./fd_supply_services/manage.py collectstatic --noinput

flake8:
	source $(FLAKE8_ENV)/bin/activate && flake8

flake8-env:
	@# Unsetting PYTHON_INSTALL_LAYOUT is key for use with virtualenv!
	@# Amazon Linux sets the PYTHON_INSTALL_LAYOUT env variable to "amzn"
	@# which causes 'distutils' based install packages to get installed in
	@# {ENV}/lib64/python3.6/dist-packages instead of the proper
	@# {ENV}/lib64/python3.6/site-packages location.
	@echo -e "\nCreating a Python $(PYTHON_VERSION) Environment!"
	@echo -e "\nCleaning the ${FLAKE8_ENV} directory"
	@echo "-----------------------------------------------------------"
	rm -rf $(FLAKE8_ENV)
	@echo -e "\nCreating a new ${FLAKE8_ENV} virtualenv"
	@echo "-----------------------------------------------------------"
	virtualenv --python=python$(PYTHON_VERSION) $(FLAKE8_ENV)
	@echo -e "\nInstalling Python Packages:"
	@echo "-----------------------------------------------------------"
	unset PYTHON_INSTALL_LAYOUT && \
		source $(FLAKE8_ENV)/bin/activate && \
		pip install -r flake8-requirements.txt
	@echo -e "\nTesting Python Installation"
	@echo "-----------------------------------------------------------"
	source $(FLAKE8_ENV)/bin/activate && \
		python -c 'import flake8' && \
		echo -e "\n\nInstalled the following python packages:\n" && \
		pip list && \
		echo -e "\nSource the environment with:\n" && \
		echo -e "  > source $(FLAKE8_ENV)/bin/activate \n"

flake8-reqs:
	pip freeze > flake8-requirements.txt

docker-clean:
	docker container prune -f
	-docker rmi `docker images --filter "dangling=true" -q --no-trunc`
	-docker rmi `docker images | grep "none" | awk '/ / { print $3 }'`

docker-clean-postgres:
	-docker volume rm `docker volume ls | awk '{print $2}' | grep 'postgres'`

