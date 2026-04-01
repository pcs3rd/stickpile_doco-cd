# Stickpile.net doco-cd deployment 
If you'd like to see the service declarations, they can be found [here](https://github.com/pcs3rd/stickpile_compose-config/)
## Deployment
**1. Clone this repo, and check out the environment branch**  
``` 
$ git clone https://github.com/pcs3rd/stickpile_doco-cd
```
``` 
$ git switch <branch name> 
```
**2. Start `doco-cd` via `docker-compose`, and wait for it to start the environment.**  
```
$ docker compose up -d
```


## ENV Vars
All services use ENV vars that have been encrypted with SOPS.  
If this is a new deployment, fork `github:pcs3rd/stickpile_compose-config`.   

The env vars in this repo are all encrypted. They are not readable without the correct age key, which you likely won't (and will never) have.

In my current deployment (`github:pcs3rd/nix-config#sevenofnine`), this key lives in `/stateful/sys-data/sops_age_key.txt`, and is explicitly ignored in `.gitignore`. The sops private key _will not_ be published to keep secrets to be safe. 

**2. Encrypt the env files.** 
```
$ sops encrypt --age age1g3lcl... secrets.env > secrets.enc.env
```
If editing a file is needed, either tell SOPS where to look for the key using `SOPS_AGE_KEY_FILE`, place the key in `$XDG_CONFIG_HOME/sops/age/keys.txt`, or provide it directly with the `SOPS_AGE_KEY` env var

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
**- or -**
reference the env var in `environment:`
```
services:  
  app:  
    environment: 
      - supersecretvar1
      - supersecretvar2
```
# Notes 

If you need to map specific variables, call them with just a ``$``. Doco-cd will substitute in-place.
