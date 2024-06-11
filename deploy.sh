# Function to check if a container is running by name
container_running() {
  container_name=$1
  container_status=$(docker inspect -f '{{.State.Running}}' ${container_name} 2>/dev/null)
  if [ "$container_status" == "true" ]; then
    echo "Container '$container_name' is running."
    return 0
  else
    echo "Container '$container_name' is not running."
    return 1
  fi
}

container_name="portainer"
image_name="portainer:latest"
certresolver="production"
hostname="strapi.vyzion.pt"
path="vyzion/vyzion-strapi"
# remember that this is used AFTER the cd to $path
env_file="../../local/portainer.env" 

if container_running "$container_name"; then
  echo "Proceeding with the existing container..."
  cd ${path}
  git pull
  docker rename $container_name ${container_name}_old
  docker build -t $image_name --build-arg="CERTRESOLVER=$certresolver" --build-arg="HOSTNAME=$hostname" .
  docker run -d --name $container_name --env-file $env_file -p 9000:9000 $image_name
  container_running "$container_name"
  until [ $? -eq 0 ]; do
    sleep 1
    container_running "$container_name"
  done
  docker stop ${container_name}_old
  docker rm ${container_name}_old
  echo "Container deployed."
else
  echo "Creating a new container..."
  cd ${path}
  git pull
  docker build -t $image_name --build-arg="CERTRESOLVER=${certresolver}" --build-arg="HOSTNAME=${hostname}" .
  docker run -d --name ${container_name} --env-file $env_file -p 9000:9000 $image_name
  container_running "$container_name"
  until [ $? -eq 0 ]; do
    sleep 1
    container_running "$container_name"
  done
  echo "Container deployed."
fi