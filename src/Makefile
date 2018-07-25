
requirements.txt:
	pip freeze > requirements.txt

virtualenv:
	# Unsetting PYTHON_INSTALL_LAYOUT is key for use with virtualenv!
	# Amazon Linux sets the PYTHON_INSTALL_LAYOUT env variable to "amzn"
	# which causes 'distutils' based install packages to get installed in
	# {VENV}/lib64/python3.6/dist-packages instead of the proper
	# {VENV}/lib64/python3.6/site-packages location.
	rm -rf ~/python-3.6-dev-env
	unset PYTHON_INSTALL_LAYOUT && \
	virtualenv --python=python3.6 ~/python-3.6-dev-env && \
	source ~/python-3.6-dev-env/bin/activate && \
	pip install -r fd_supply_services/requirements.txt && \
	python -c 'import yaml'

flake8:
	source ~/dev-env/bin/activate && flake8

find-unowned-files:
	find . ! -user $(USER) -exec ls -lad {} \;

chown: find-unowned-files
	sudo chown $(USER):$(USER) -c -R .

docker-clean:
	docker container prune -f
	-docker rmi `docker images --filter "dangling=true" -q --no-trunc`
	-docker rmi `docker images | grep "none" | awk '/ / { print $3 }'`

delete-postgres:
	-docker volume rm `docker volume ls | awk '{print $2}' | grep 'postgres'`

collect-static:
	source ~/python-3.6-dev-env/bin/activate; \
	./fd_supply_services/manage.py collectstatic --noinput

