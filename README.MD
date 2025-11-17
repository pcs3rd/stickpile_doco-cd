# Stickpile.net doco-cd deployment 
It interacts with a (currently private) repo.  
## Initial configuration (New deployment)
Init a new docker swarm: 
```
docker swarm init  
```
Assign a UID to each node via labels. 
```
$ docker node update --label-add unique_id=<uid> <node_id>
```
Optionally confirm node names are correct.
```
$ docker node ls -q | xargs docker node inspect -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'
```
Create docker secrets for websocket/access token doco-cd should automatically use swarm mode if a swarm exists. 
``` 
$ echo "token" | docker secret create git_access_token -
```
```
$ echo "secret" | docker secret create webhook_secret -
```

## ENV Vars
All services use ENV vars that have been encrypted with SOPS.  
If this is a new deployment, fork `github:pcs3rd/stacks`, then complete the ENV vars using relevent project documentation. 

After configuting env vars, encrypt them using `age`. Call `shell.nix` via `$ nix-shell` to create a shell with the needed programs to create encrypted env vars.

**1. If you haven't already, create an age key.**
> age-keygen -o sops_age_key.txt

In my current deployment (`github:pcs3rd/nix-config#sevenofnine`), this key lives in `/stateful/sys-data/sops_age_key.txt`, and is explicitly ignored in `.gitignore`. The sops private key _may not_ be published for secrets to be safe. 

**2. Encrypt the env files.** 
> sops encrypt --age age1g3lcl... secrets.env > secrets.enc.env

As a side note, if deplying a new stack, make sure. to call the secrets from doco-cd with the following example.
```
services:  
  app:  
    env_file:  
      - secrets.enc.env  
```


Note on `./stacks-reference`:
It actually doesn't matter if this submodule is up-to-date, since doco-cd pulls from the remote repo directly. If needed, doco-cd can be pointed to this directory.