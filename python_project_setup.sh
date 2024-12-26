#!/bin/bash

#This script will set up a basic python project
    #venv setup
  





#check if pip installed, if not install it
if command -v pip >/dev/null 2>&1; then
    echo "pip installed already"
else
    echo "pip not installed.."
    read -p "Which pkg manager do you use (apt/yum):" pkg_manager
    
    if [[ "$pkg_manager" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install python3-pip
        echo "pip installed successfully"

    elif [[ "$pkg_manager" == "yum" ]]; then
        sudo yum update
        sudo yum install python3-pip
        echo "pip installed successfully"
    fi
fi


#venv setup
  #check if virtualenv command is avail on sys PATH
    #redirect std out and error to null
    # -v here returns the path to virtualenv, otherwise  nothing if not found
if command -v virtualenv >/dev/null 2>&1; then
       echo "virtual env installed"
else
    echo "virtual env is not installed"
    echo "installing now..."
    pip install virtualenv
    echo "successfully installed virtualenv"
fi  


#prompt user to enter desired name for virtual env
# -p flag allows for showing msg before getting input
read -p "Enter name for your virtual environment: " env_name
#setting default if user just hits enter
env_name=${env_name:-venv}

#create virtual env using name given by user
virtualenv "$env_name"
echo "Virtual Env created '$env_name'"


#activate venv
echo "Activate your newly created virtual env"
echo "Run command -> 'source $env_name/bin/activate'"


