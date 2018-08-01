#!/bin/bash
# Is anything with this many if statements going to be a good idea?
# This script will create linux/Jupyterhub users from a list (usernames.txt)
# Multiple conditionals are writen so that users are only created when needed
# and for the case where the hub needs to be resarted.


# Create users if needed
for user in $(cat /jupyter-persistant/usernames.txt)
  do
  if ! id "$user" >/dev/null 2>&1
  then
      cp -r /jupyter-persistant/skel /jupyter-persistant/$user
      echo "Creating persistant folder for $user"
      base=$user
      password=$(openssl passwd -1 -salt xyz $base'.123')
      useradd -p $password $user
      ln -s /jupyter-persistant/$user /home/$user
      chown -R $user /jupyter-persistant/$user
      chown -R $user /home/$user
      echo "user $user added successfully!"
  else
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

# adjust which shell is used so that jupyterhub uses bash
rm /bin/sh
ln -s /bin/bash /bin/sh
echo "SHELL=/bin/bash" >> /etc/environment

jupyterhub --ip 0.0.0.0 --port 8000 -f /jupyter-persistant/jupyterhub_config.py
