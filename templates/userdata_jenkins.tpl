#! /bin/bash
# install Java package
sudo apt-get update -y
sudo apt-get install openjdk-11-jdk -y 
sudo apt-get install openjdk-11-jre -y 
sudo update-alternatives --config java

# Install jenkins packages
sudo apt-get update -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

## Install jenkins
sudo apt-get update -y
sudo apt-get install jenkins -y

## Start jenkins
sudo systemctl start jenkins