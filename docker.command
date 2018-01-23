#### GITLAB ####

sudo docker run --detach \
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


###############

###############

#### NGINX LET'S ENCRYPT ####

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
  

###############


#### NEXUS ####

docker run \
  -d -p 8280:8081 \
  --name nexus \
  -v /srv/nexus/nexus-data:/nexus-data \
  --network=beaver \
  sonatype/nexus3
  
#################

#### REGISTRY #####
  
  docker run -d --restart=always --network=beaver --name=registry \
  -v /srv/registry/certs:/certs -v /srv/registry/auth:/auth \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.beaverhosting.fr.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.beaverhosting.fr.key -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -p 643:443 \
  registry:2
  
  docker run -d \
  -p 127.0.0.1:5000:5000 \
  --network=beaver \
  --restart=always \
  --name registry \
  -v /srv/registry:/var/lib/registry \
  registry:2
  
  
