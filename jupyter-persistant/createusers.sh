#!/bin/bash

for user in $(cat ./usernames.txt)
  do
  mkdir /jupyter-persistant/$user
  touch /jupyter-persistant/$user/.do_not_delete.txt
  base=$user
  password=$(openssl passwd -1 -salt xyz $base'.123')
  useradd -p $password $user
  ln -s /jupyter-persistant/$user /home/$user
  chown -R $user /jupyter-persistant/$user
  chown -R $user /home/$user
  echo "user $user added successfully!"
  done
