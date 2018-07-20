# docker_jupyterhub_config
Configfiles for dockerized-jupyterhub

# Draft instructions

Docker image: https://hub.docker.com/r/jasonjwilliamsny/ubuntu-jhub-dev2.2/

## Setup config files

### Enter usernames for your hub users

1. Clone this repo.
   In `jupyterhub-persistant` edit `usernames.txt`; this file
   should have a valid linux username (one name per line).
   accounts will be created in your container for each user.
   the sample list has `user1`,`user2`, and `user3`. Usernames
   have passwords such that: `some_username.123`.

   Note: Your user will have a home directory at `/home/$user`
   This will be a symbolic link to a folder `$user` that will
   be created on the machine running the docker container.
   In this way, data and changes made by the user will exist
   persistently outside of the container.

### Indicate hub admin users

1. You should setup at least one user from your username list
   to be a hub admin user. In the `jupyterhub_config.py` file,
   edit `c.Authenticator.admin_users`. Include in the brackets,
   quoted, comma-separated usernames.

       c.Authenticator.admin_users = {"user_foo","user_bar"}

### Copy jupyter-persistant
1. Place `jupyterhub-persistant` in a suitable location on the
   machine where Docker is hosted.
2. Make sure `/jupyterhub-persistant/createusers.sh` is executable:

        chmod +x SOMEPATH/jupyterhub-persistant/createusers.sh


## Running the hub

1. Pull the image from dockerhub

        docker pull jasonjwilliamsny/ubuntu-jhub-dev2.2

2. Start the container with this command (remember to edit the location of `jupyterhub-persistant`)

        docker run -p 8000:8000 --name jupyterhub -d -v SOMEPATH/jupyter-persistant:/jupyter-persistant jasonjwilliamsny/ubuntu-jhub-dev2.2:latest

    You can also add options to explicitly allow cpu/memory usage

        docker run -p 8000:8000 --cpus="16" --memory=60g  --name jupyterhub -d -v SOMEPATH/jupyter-persistant:/jupyter-persistant jasonjwilliamsny/ubuntu-jhub-dev2.2:latest

3. Docker will be available at the ip address of the machine

        localhost:8000

## Things to think about/to do

- add instruction for certificate creation for SSL
- Docker container must have enough resources (CPU/MEM/DISK) to run a container
  with many users (need to test)
