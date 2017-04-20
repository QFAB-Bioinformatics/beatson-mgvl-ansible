#!/bin/bash
# -*- coding: utf-8 -*-

### QFAB Conda Version Tool Deployment Script
#
# (c) 2017, Thom Cuddihy <t.cuddihy@qfab.org>
#
# Bash script to deploy conda environment files 
# as used in the QFAB Conda ansible module:
# (https://github.com/QFAB-Bioinformatics/qfab-ansible-modules)
# to local OSX/linux machine
#
# Example Conda install file:
# https://github.com/QFAB-Bioinformatics/beatson-mgvl-ansible/blob/master/group_vars/all.yml
#
# Example use:
#   ./conda_bootstrap.sh all.yml
#
# Minimum tested version of Conda is 4.0.11

ANSIBLE_FILE=${1}
ANSIBLE_FILE='all.yml'

mkdir -p env
rm -rdf env
mkdir -p env

cat <<EOF | python -
import yaml

with open("${ANSIBLE_FILE}", "r") as stream:
    data = yaml.load(stream)
    for env in data['conda']['environments']:
        if env['state'] == 'present':
            with open('envs/' + env['name'] + '.yml', 'a') as outfile:
              yaml.dump(env, outfile)
EOF

for ENV_FILE in `find ./envs -type f -exec basename {} \;`; do
    conda env create -f envs/${ENV_FILE}
done

