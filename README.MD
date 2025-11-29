# Stickpile.net doco-cd deployment 
It interacts with a (currently private) repo.  
## Initial configuration (New deployment)
**Step 1:** Init a new docker swarm: 
```
docker swarm init  
```
**Step 2:** Assign a UID to each node via labels. 
```
$ docker node update --label-add unique_id=<uid> <node_id>
```
Optionally confirm node names are correct.
```
$ docker node ls -q | xargs docker node inspect -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'
```
**Step 3:** Create docker secrets for websocket/access token doco-cd should automatically use swarm mode if a swarm exists. 
``` 
$ echo "token" | docker secret create git_access_token -
```
```
$ echo "secret" | docker secret create webhook_secret -
```
**Step 4:** Create some folders.  
  I don't know where you want to store data, but folders need to be created before deployment in swarm mode. Figure it out.

**Step 5:** Deploy doco-cd.
```
$ docker stack deploy doco-cd --compose-file compose.yaml -d
```
Alternatively, if you've already called ```shell.nix```, cd to the root of this repo and run ```deploy```

## ENV Vars
All services use ENV vars that have been encrypted with SOPS.  
If this is a new deployment, fork `github:pcs3rd/stickpile_compose-config`, then complete the ENV vars using relevent project documentation. 

After configuting env vars, encrypt them using `age`. Call `shell.nix` via `$ nix-shell` to create a shell with the needed programs to create encrypted env vars.

**1. If you haven't already, create an age key.**
```
$ age-keygen -o sops_age_key.txt
```

In my current deployment (`github:pcs3rd/nix-config#sevenofnine`), this key lives in `/stateful/sys-data/sops_age_key.txt`, and is explicitly ignored in `.gitignore`. The sops private key _may not_ be published for secrets to be safe. 

**2. Encrypt the env files.** 
```
$ sops encrypt --age age1g3lcl... secrets.env > secrets.enc.env
```
If editing a file is needed, either tell SOPS where to look for the key using `SOPS_AGE_KEY_FILE`, place the key in `$XDG_CONFIG_HOME/sops/age/keys.txt`, or provide it directly with the ` SOPS_AGE_KEY` env var

```
$ sops secrets.enc.env
```
As a side note, if deplying a new stack, make sure. to call the secrets from doco-cd with the following example.
```
services:  
  app:  
    env_file:  
      - secrets.enc.env  
```
