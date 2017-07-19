# To revert changes:

Make backups then:

1. remove related docker services, then volumes and images, then leave swarm
2. remove apps_dir
3. revert changes to /etc/hosts
4. revert changes to ~/.bash_aliases
