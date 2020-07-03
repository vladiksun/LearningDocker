#!/usr/bin/env bash

# https://hub.docker.com/r/openidentityplatform/openam/

docker container ls -all
docker ps -a
docker images

################  OpenAM ################
docker run -h <openam.example.com> -p 8081:8080 --name <container_name>

#create new
docker run -h openam.example.com -p 8080:8080 --name openam openidentityplatform/openam

# http://openam.example.com:8080/openam
docker start openam

################  jump into container bash ################
docker exec -t -i openam  /bin/bash
docker exec --user="root" -it openam /bin/bash

docker exec --user="root" -it 3f9f292c85a2 /bin/bash

# Copy a file from Docker container to host:
docker cp openam:/usr/openam/config C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAM\config

# Copy a file from host to container:
docker cp C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAM\config openam:/usr/openam/config

# create an image copy
docker commit openam openam_local_config_image

docker run -it --volume C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAM\config:/usr/openam/config openam_local_config_image /bin/bash

docker run -h openam.example.com -p 8080:8080 --volume C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAM\config:/usr/openam/config --name openam_local_config openam_local_config_image

docker run -h openam.example.com -p 8080:8080 --volume C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAM\config:/usr/openam/config --name openam openidentityplatform/openam

docker run -h openam.example.com -p 8080:8080 --volume C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAM\config:/usr/openam/config --name openam

docker run -h openam.example.com -p 8080:8080 --volume C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAMPath\openam:/usr/openam/config --name openam

docker run -h openam.example.com -p 8080:8080 --volume C:\Users\vladislav.bondarchuk\Downloads\DockerMounts\OpenAMPath\openam:/usr/openam/config --name openam

docker inspect --format "{{.Mounts}}" openam_local_config


kubectl run -it srvlookup --image=tutum/dnsutils --rm --restart=Never -- dig SRV openam-service.default.svc.cluster.local





