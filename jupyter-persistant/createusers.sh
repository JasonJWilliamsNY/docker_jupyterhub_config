#!/bin/bash
# Is anything with this many if statements going to be a good idea?
# This script will create linux/Jupyterhub users from a list (usernames.txt)
# Multiple conditionals are writen so that users are only created when needed
# and for the case where the hub needs to be resarted.


# Create users if needed and deal with existing or missing persistant folders
# and home directory symbolic links inside the container

# Check to see if the user in the usernames.txt exists
for user in $(cat /jupyter-persistant/usernames.txt)
  do
  # Senario where user does not exist on the container (i.e launching or
  # restarting a container )
  if ! id "$user" >/dev/null 2>&1
  then
      # if the user does not exist in the container but they have a folder at
      # jupyter-persistant/$user create the user and use their existing folder
      # in jupyter-persistant/ as a target for a symbolic link to ~/$user
      if [ -d "/jupyter-persistant/$user" ]
      then
          echo "Using existing persistant folder for $user"
          base=$user
          password=$(openssl passwd -1 -salt xyz $base'.123')
          useradd -p $password $user
          usermod -aG sudo $user
          echo "$username  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
          ln -s /jupyter-persistant/$user /home/$user
          chown -R $user /jupyter-persistant/$user
          chown -R $user /home/$user
          echo "user $user added successfully!"
      # if the user does not exist in the container and they do not have a
      # folder in jupyter-persistant/ create jupyter-persistant/$user
      # create the user on the container and use jupyter-persistant/$user as a
      # target for a symbolic link to ~/$user
      else
          echo "Creating persistant folder for $user"
          cp -r /jupyter-persistant/skel /jupyter-persistant/$user
          base=$user
          password=$(openssl passwd -1 -salt xyz $base'.123')
          useradd -p $password $user
          usermod -aG sudo $user
          echo "$username  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
          ln -s /jupyter-persistant/$user /home/$user
          chown -R $user /jupyter-persistant/$user
          chown -R $user /home/$user
          echo "user $user added successfully!"
      fi
  # Senario where user already exists in the container (i.e. restarting hub but
  # not the container )
  else
      # Check to see if the symbolic link ~/$user exists and that its target
      # /jupyter-persistant exists. Create or use existing links and folders
      # as needed
      if [ ! -L "/home/$user" ]
      then
          if [ ! -d "/jupyter-persistant/$user" ]
          then
              cp -r /jupyter-persistant/skel /jupyter-persistant/$user
              echo "Creating persistant folder for $user"
              ln -s /jupyter-persistant/$user /home/$user
              chown -R $user /jupyter-persistant/$user
              chown -R $user /home/$user
          else
              echo "Using existing persistant folder for $user"
              ln -s /jupyter-persistant/$user /home/$user
              chown -R $user /jupyter-persistant/$user
              chown -R $user /home/$user
          fi
      else
          if [ ! -d "/jupyter-persistant/$user" ]
          then
              echo "Creating persistant folder for $user"
              cp -r /jupyter-persistant/skel /jupyter-persistant/$user
              rm /home/$user
              ln -s /jupyter-persistant/$user /home/$user
              chown -R $user /jupyter-persistant/$user
              chown -R $user /home/$user
          else
              echo "Nothing to do"
          fi
      fi
  fi
  done

# adjust which shell is used so that jupyterhub uses bash in the meanest way
# by deleting sh and using /bin/bash
rm /bin/sh
ln -s /bin/bash /bin/sh
# todo: figure out how to get the Jupyter terminal to load bash profile
echo "SHELL=/bin/bash" >> /etc/environment

jupyterhub --ip 0.0.0.0 --port 8000 -f /jupyter-persistant/jupyterhub_config.py
