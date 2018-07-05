
requirements.txt:
	pip freeze > requirements.txt

root-owned:
	find . ! -user ec2-user

chown:
	sudo chown ec2-user:ec2-user -c -R $(PWD)
