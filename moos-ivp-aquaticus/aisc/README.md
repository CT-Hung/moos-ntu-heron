# AISC 2023
General info to run a submission for the AISC Aquaticus Competition

## Docker
### Docker setup (Ubuntu)
This will keep you from having to run sudo each time you use Docker commands
  * $ sudo apt-get install docker
  * $ sudo groupadd docker
  * $ sudo usermod -aG docker $USER
  * $ newgrp docker
  * Restart Computer

### Build Aquaticus image
  * $ docker build -t aquaticus -f Dockerfile . --force-rm
    * $ docker build -t <name:tag(optional)> -f Dockerfile . --force-rm
  * Check that the image is there
    * $ docker images

#### Docker image cleanup
  * Remove <none> tag images if created
    * $ docker rmi -f $(docker images --filter "dangling=true" -q --no-trunc)
    * $ docker image prune

### Spin up a container (CLI)
Here are some basic commands for `docker run` on the Command Line that will launch a container in a terminal windown. Once launched the terminal window will be in the container and you can opperate as you normally would using terminal.

  * docker run -rm -it --net=host -v <path-to-directory-to-mount>:<path-to-mount-directory-in-container> -w <path-to-working-directory-in-container> --name <optional-name> <image-name:tag-name> $@
    * -t : Allocate a pseudo-TTY
    * -i : Keep STDIN open even if not attached
    * -v: Bind mount a volume 
      * You can add a file or directory this way from the host to the container 
      * -v <path-host-computer>:<path-on-container>
    * -w: Starts at this working directory inside container 
    * -e: Environment variables
    * --name : Optional. Names the docker container you are creating
  * Example that adds a meta_surveyor_mitx.bhv file to the container and changes it's name
    * docker run --rm -it --net=host -v ${HOME}/moos-ivp-aquaticus/missions/jervis-2023/surveyor/meta_surveyor_mitx.bhv:/home/moos/moos-ivp-aquaticus/missions/jervis-2023/surveyor/meta_surveyor_mitx2.bhv --name aquaticus -w /home/moos/moos-ivp-aquaticus/missions/jervis-2023/ aquaticus:latest $@

#### Spin up a container (Shell)
I will provide a `run_docker.sh` file that emulates what is being done for the pyquaticus group. This will launch a container and set a few environmental variables that will be needed for the `run_submission.sh` file to launch. This should automatically kick off a mission on the robot. If this fails, remove the `CMD="./run_submission.sh"` command in the `docker run` command of `run_docker.sh`. Or revert to launching the container via CLI and opperate as you normally would logged into a robot. 




















If building based on the moos-ivp docker image from DockerHub (https://hub.docker.com/r/moosivp/moos-ivp/tags). We are not as I don't think it's up to date currently.
  * Pull latest moos-ivp docker image
    * docker pull moosivp/moos-ivp:latest





