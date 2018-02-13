# Beaver Hosting Product - Docker commands

List of all docker commands

## Getting Started

### Prerequisites

You need docker

## Commands

### Gitlab
```
docker run --detach \
    --hostname git.beaverhosting.fr \
    --publish 127.0.0.1:543:443 \
    --publish 127.0.0.1:8180:80 \
    --publish 127.0.0.1:122:22 \
    --name gitlab \
    --restart always \
    --network=beaver \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

### Nginx with Letsencrypt
``` 
docker create \
	--cap-add=NET_ADMIN \
	--restart=always \
	--network=beaver \
	--name=nginx \
	-v /srv/nginx:/config \
	-v /srv/nginx/letsencrypt:/etc/letsencrypt \
	-v /srv/nginx/letsencrypt-log:/var/log/letsencrypt \
	-e PGID=1004 \
	-e PUID=1003 \
	-e EMAIL=beaverhosting@protonmail.com \
	-e URL=beaverhosting.fr \
	-e SUBDOMAINS=www,git,nexus,registry \
	-p 80:80 \
	-p 443:443 \
	-e TZ=Europe/Paris \
	linuxserver/letsencrypt
```

### Gitlab Runner

```
docker run -d \
    --name gitlab-runner \
    --restart always \
    --network=beaver \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest
```

#### Docs for Runner 
```
https://docs.gitlab.com/runner/install/docker.html#installing-trusted-ssl-server-certificates
https://docs.gitlab.com/ce/ci/runners/
https://docs.gitlab.com/runner/register/index.html
https://docs.gitlab.com/runner/executors/
```

#### Configure Runner
```
apt-get insall xz-utils

docker exec -it gitlab-runner gitlab-runner register
```

### Run Unsecure jobs
Add this to your .gitlab-ci.yml :
```
variables:
  GIT_SSL_NO_VERIFY: "true"
```

### Insecure Nginx
``` 
docker create \
	--restart=always \
	--network=beaver \
	--name=nginx \
	-v /srv/nginx:/config \
	-e PGID=1004 \
	-e PUID=1003 \
	-p 80:80 \
	-p 443:443 \
	-e TZ=Europe/Paris \
	linuxserver/nginx
``` 

### Nexus
```
docker run \
    -d \
    --restart=always \
    --network=beaver \
    --name nexus \
    -p 8280:8081 \    
    -v /srv/nexus/nexus-data:/nexus-data \
    sonatype/nexus3
```

### Secure registry
```
docker run \
    -d \
    --restart=always \
    --network=beaver \
    --name=registry \
    -v /srv/registry/certs:/certs \
    -v /srv/registry/auth:/auth \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.beaverhosting.fr.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/registry.beaverhosting.fr.key \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    -p 643:443 \
    registry:2
```

### Insecure registry
```
docker run \
    -d \
    -p 127.0.0.1:5000:5000 \
    --network=beaver \
    --restart=always \
    --name registry \
    -v /srv/registry:/var/lib/registry \
    registry:2
```

To access it from your local docker add this to your /etc/docker/daemon.json : 
```
{
  "insecure-registries" : ["registry.beaverhosting.fr"]
}
```

Then try to connect to it :
```
docker login registry.beaverhosting.fr

user: testuser
password: test.......
```

