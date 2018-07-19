# docker_jupyterhub_config
Configfiles for dockerized-jupyterhub

# Draft instructions

## Setup config files

### Enter usernames for your hub users
1. In `/jupyterhub-persistant` edit `usernames.txt`; this file
   should have a valid linux username (one name per line).
   accounts will be created in your container for each user.

   Note: Your user will have a home directory at `/home/$user`
   This will be a symbolic link to a folder `$user` that will
   be created on the machine running the docker container.
   In this way, data and changes made by the user will exist
   persistently outside of the container.

### Enter hub admin users
1. You should setup at least one user from your username list
   to be a hub admin user. In the `jupyterhub_config.py` file,
   edit `c.Authenticator.admin_users`. Include in the brackets,
   quoted, comma-separated usernames.

       `c.Authenticator.admin_users = {"user_foo","user_bar"}`

### Copy jupyter-persistant
1. Place `/jupyterhub-persistant` in a suitable location on the
   machine where Docker is hosted.



### Running the hub (this will improve)

1. Start the container with this command (remember to edit the location of `/jupyterhub-persistant`)

        docker run -p 8000:8000 -it --name jupyterhub -v path_to/jupyter-persistant:/jupyter-persistant ubuntu-jhub-dev2 bash

2. Inside the container do the following

        cd /jupyter-persistant
        bash createusers.sh
        cd /
        jupyterhub --ip 0.0.0.0 --port 8000 -f /jupyter-persistant/jupyterhub_config.py

  You can detach and leave the container running . CNTRL+

## Things to think about/to do

- re-image without jupyter cookie sql database
- add instruction for certificate creation
- Install NumPy/SciPy/MatPlotlib(plot9)/Pandas
- Docker container must have enough resources (CPU/MEM/DISK) to run a container
  with many users
- This container was created using Docker commit - redo with a proper
  dockerfile.
