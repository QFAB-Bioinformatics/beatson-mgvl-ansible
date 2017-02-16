# Common Role #

This role is intended to be run on every server. It will setup the SSH key used, 
disable password login, sets the hostname and SSH banner, and makes vim usable.

## Example Playbook ##
    - hosts: all
      roles:
         - common
