# Docker utilities (WIP).
You can work on a containerized environment using `docker` and `docker-compose` (TODO: we don't really need docker-compose, switch to only docker). The script `./dockerization/dockerize.sh` provides some shortcuts to manage containers:
  - Build docker image:
      ```
      ./dockerization/dockerize.sh recreate
      ```
  - Start development containers:
      ```
      ./dockerization/dockerize.sh start
      ```
    *The sptam root directory will be mounted as `${USER_NAME}/catkin_ws/src/sptam`.*

  - Attach a bash terminal to the development container:
      ```
      ./dockerization/dockerize.sh attach
      ```
      *This command will start development containers if needed.*
  - Stop development containers:
      ```
      ./dockerization/dockerize.sh stop
      ```
