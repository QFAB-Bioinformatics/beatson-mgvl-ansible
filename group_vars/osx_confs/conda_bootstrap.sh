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

TMP_FOLDER="${TMPDIR}/conda_bootstrap_envs"
mkdir -p ${TMP_FOLDER}
rm -rdf ${TMP_FOLDER}
mkdir -p ${TMP_FOLDER}

pip install ruamel.yaml -q

cat <<EOF | python -
import ruamel.yaml

with open("${ANSIBLE_FILE}", "r") as stream:
    data = ruamel.yaml.load(stream, Loader=ruamel.yaml.RoundTripLoader)
    for env in data['conda']['environments']:
        if env['state'] == 'present':
            del env['state']
            with open('${TMP_FOLDER}/' + env['name'] + '.yml', 'a') as outfile:
              outfile.write(ruamel.yaml.round_trip_dump(env))
EOF

for ENV_FILE in `find ${TMP_FOLDER}/ -type f -exec basename {} \;`; do
    ENV_NAME="${ENV_FILE%.*}"
    if $(conda env list | awk '{print $1}' | grep -q "^${ENV_NAME}$"); then
        echo "Conda environment \"${ENV_NAME}\" already exists"
        echo
        echo "You can attempt to UPDATE the existing environment"
        echo "Or REPLACE the existing environment with the one defined in ${ANSIBLE_FILE}"
        echo
        read -p "Confirm (u)pdate or (r)eplace environment? " -n 1 -r
        echo 
        if [[ ${REPLY} =~ ^[Rr]$ ]]; then 
            conda remove --name ${ENV_NAME} --all --yes
            conda env create -f ${TMP_FOLDER}/${ENV_FILE}
        elif [[ ${REPLY} =~ ^[Uu]$ ]]; then 
            conda env update -f ${TMP_FOLDER}/${ENV_FILE}
        else
            echo "Incorrect input received. Skipping environment."
            continue
        fi
    else
        conda env create -f ${TMP_FOLDER}/${ENV_FILE} 
    fi
    
done

echo "Finishing processing ${ANSIBLE_FILE} for Conda environments"
rm -rdf ${TMP_FOLDER}
