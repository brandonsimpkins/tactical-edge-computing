
requirements.txt:
	pip freeze > requirements.txt

virtualenv:
	virtualenv ~/dev-env; \
	source ~/dev-env/bin/activate; \
	pip install -r requirements.txt

find-unowned-files:
	find . ! -user $(USER) -exec ls -lad {} \;

chown: find-unowned-files
	sudo chown $(USER):$(USER) -c -R .

