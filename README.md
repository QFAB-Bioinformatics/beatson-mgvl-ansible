# Beatson Lab mGVL Setup #

This is it.. a readme that I still need to finish!


## Setup ##

This ansible repo relies on the [gvlproject/ansible-galaxy-tools] (https://github.com/gvlproject/ansible-galaxy-tools) role. Install it with:
    
    sudo ansible-galaxy install --force -r requirements.yml

It is good to run this occassionally, in case the role has been updated (check their repo!).

This repo uses [git-crypt](https://github.com/AGWA/git-crypt) to secure the any and all sensitive data. To decrypt them, contact a maintainer of this repo and provide your GPG key. Once that has been done, decrypt them as follows:

    git-crypt unlock

If you do not have `git-crypt` you can install it on OS X with:

    brew install git-crypt

One such protected file is the SSH key used to manage the GVL servers.
Once it is unlocked, enable it with the following command:

    ssh-add files/keys/server.key    

## Running a playbook ##

All playbooks are located in the `playbooks` directory.
Run them as follow:

    ansible-playbook -i inventory/hosts-dev playbooks/{{ playbook }}.yml
Replace `{{ playbook }}` with the desired playbook.

For systems that have not been setup before, use this instead:

    ansible-playbook -i inventory/hosts-dev playbooks/{{ playbook }}.yml --ask-pass

And when prompted, enter the account password. This will install the SSH key for future sessions (and Beatson admins) and disable SSH password logins (for security).

## Advanced Usages ##

### Dry-run ###
Just made changes to a playbook and want to see what it will actually do without actually making changes to a server? Try a dry run! Add the '--check' switch, and what changes a playbook _would_ make are listed without actually changing a single file:

    ansible-playbook -i inventory/hosts-dev playbooks/{{ playbook }}.yml --check


### Single host ###
If the dev or production host inventory files contains more than one server, and you want/need to run a playbook on just a single machine (without limiting using GROUPS), then you specify that with the 'limit' switch:

    ansible-playbook -i inventory/hosts-dev playbooks/{{ playbook }}.yml --limit dev01.beatson.mgvl

You can use the name given in the host file or the IP address directly.

### Verbose output ###
Something failing? Just want to know more about what's happening? Add the verbose switch! Variants of '-v', '-vv', and '-vvv' for increasing levels of verbosity:

    ansible-playbook -i inventory/hosts-dev playbooks/{{ playbook }}.yml -vv

## Notes ##

### New Servers ###
Fill the `hosts-dev` and `hosts-production` inventory files as appropriate. Groups can be set in there for servers with different roles/configurations.

### New Tools ###
Edit the `tool_list_{{ group }.yaml` file as appropriate. Group "all" (`tool_list_all.yaml`) is reserved for all servers.

### GPG Help ###
Don't have GPG installed, or a keypair setup? No fear!

Install GPG with: 

    brew install gpg

Once completed, generate a new key pair with:

    gpg --gen-key

And complete the wizard as appropriate. Once that is completed, you can verify that it is installed with `gpg --list-keys`

Example:
    
```
$ gpg --list-keys
/users/dev/.gnupg/pubring.gpg
---------------------------------------
pub  1024D/BB7576AC 1999-06-04 Dev Worker <dev@qfab.org>
sub  1024g/78E9A8FA 1999-06-04
```
Finally, export the key using:    
    
    gpg --output {{ output.file }} --export {{ keyname }}

So using the example output above:

    gpg --output dev.gpg --export dev@qfab.org

Send the resulting `dev.gpg` files to a repo maintainer.