
requirements.txt:
	pip freeze > requirements.txt

virtualenv:
	rm -rf ~/python-3.6-dev-env
	virtualenv --python=python3.5 ~/python-3.6-dev-env; \
	source ~/python-3.6-dev-env/bin/activate; \
	pip install -r fd_supply_services/requirements.txt

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
