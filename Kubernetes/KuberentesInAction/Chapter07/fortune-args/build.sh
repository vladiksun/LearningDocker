# build image
docker build -t docker.io/luksa/fortune:args .

docker push docker.io/luksa/fortune:args

# Configured to generate new fortune every 15 seconds
docker run -it docker.io/luksa/fortune:args 15