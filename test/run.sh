#!/bin/bash
# f5-ansible - Run Tests
# https://github.com/ArtiomL/f5-ansible
# Artiom Lichtenstein
# v1.0.2, 05/03/2018

set -xe
set -o pipefail

REPO="artioml/f5-ansible"

# Linting
for file in */*.yml; do echo "$file"; python -c 'import yaml,sys; yaml.safe_load(sys.stdin)' < "$file"; done

# Ansible check mode
str_TEST="ansible-playbook playbooks/*app.yml --syntax-check;"
str_TEST="$str_TEST ansible-playbook playbooks/app.yml --list-hosts | grep $(cat inventory/hosts | sed -n 2p);"
str_TEST="$str_TEST touch playbooks/f5.http.yml;"
str_TEST="$str_TEST ansible-playbook playbooks/iapp.yml -e @creds.yml --vault-password-file .password --check;"

if [ "$TRAVIS" == "true" ]; then
	docker run $REPO /bin/sh -c "$str_TEST"
	docker run $REPO:dev /bin/sh -c "$str_TEST"
else
	eval "$str_TEST"
fi
