# Stickpile.net doco-cd deployment 
If you'd like to see the service declarations, they can be found [here](https://github.com/pcs3rd/stickpile_compose-config/tree/dev)
## Initial config (New Deployment) [Docker Standalone]
**Step 1:**
```
$ docker compose up
```
**Step 2:**
Depending on what branch is checked out, doco-cd is configured to not poll github, and redeploy when it's websocket endpoint is hit. 

```
echo -n "your-payload-here" | openssl dgst -sha256 -hmac $(cat /stateful/sys-data/secrets/ws-secret.txt)
```

```
curl -X POST \
     -H "Content-Type: application/json" \
     -H "X-Hub-Signature-256: sha256=$(cat /stateful/sys-data/secrets/ws-secret.txt)" \
     --data '{"payload": "your-payload-here"}' \
     http://localhost:1099/v1/api/v1/webhook/us-east-stickpile-prod
```



## Initial configuration (New deployment) [DOCKER SWARM]
**Step 1:** Init a new docker swarm: 
```
$ docker swarm init  
```
**Step 2:** Create a backbone network, so that containers are reachable from the reverse proxy/
```
$ docker network create --driver overlay traefik_backbone --attachable
```
**Step 3:** Assign a UID to each node via labels. 
```
$ docker node update --label-add unique_id=<uid> <node_id>
```
Optionally confirm node names are correct.
```
$ docker node ls -q | xargs docker node inspect -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'
```
**Step 4:** Create docker secrets for websocket/access token doco-cd should automatically use swarm mode if a swarm exists. 
``` 
$ echo "token" | docker secret create git_access_token -
```
```
$ echo "secret" | docker secret create webhook_secret -
```
Alternatively, use files to bring secrets into docker. The current deployment uses that method.


**Step 5:** Create some folders.  
  I don't know where you want to store data, but folders need to be created before deployment in swarm mode. Figure it out.

**Step 6:** Deploy doco-cd.
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

# Notes % Additional

If you need to map specific variables, call them with just a ``$``
