#!/bin/bash

for user in $(cat ./usernames.txt)
  do
  cp -r /jupyter-persistant/skel /jupyter-persistant/$user
  base=$user
  password=$(openssl passwd -1 -salt xyz $base'.123')
  useradd -p $password $user
  ln -s /jupyter-persistant/$user /home/$user
  chown -R $user /jupyter-persistant/$user
  chown -R $user /home/$user
  echo "user $user added successfully!"
  done
