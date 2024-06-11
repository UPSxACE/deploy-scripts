# Function to check if a container exists by name
container_running() {
  container_name=$1
  container_status=$(docker inspect -f '{{.State.Running}}' ${container_name} 2>/dev/null)
  if [ "$container_status" == "true" ]; then
    echo "Container '$container_name' exists."
    return 0
  else
    echo "Container '$container_name' does not exist."
    return 1
  fi
}

container_name="portainer"
if container_running "$container_name"; then
  echo "Proceeding with the existing container..."
  docker rename ${container_name} ${container_name}_old
  docker build -t portainer:latest .
  docker run -d --name ${container_name} portainer:latest --env-file ../local/portainer.env
  container_status = container_running "$container_name"
  until [ container_status == "true" ]; do
    sleep 0.;
    container_status = container_running "$container_name"
  done;
  docker stop ${container_name}_old
  docker remove ${container_name}_old
  echo "Container deployed."
else
  echo "Creating a new container..."
  docker build -t portainer:latest .
  docker run -d --name ${container_name} portainer:latest --env-file ../local/portainer.env
  container_status = container_running "$container_name"
  until [ container_status == "true" ]; do
    sleep 0.;
    container_status = container_running "$container_name"
  done;
  echo "Container deployed."
fi