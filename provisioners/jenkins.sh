#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# Update packages
sudo apt-get update -y

# Install Jenkins and Java
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-11-jre
sudo apt-get install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait for Jenkins to fully start (this might take a moment)
sleep 30
# Path to the Jenkins initial admin password file
JENKINS_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

# Read the password from the file and output it
JENKINS_PASSWORD=$(sudo cat $JENKINS_PASSWORD_FILE)
echo "Jenkins initial admin password: $JENKINS_PASSWORD"

# Download Jenkins CLI jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# Jenkins URL and credentials
JENKINS_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)	
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $ADMIN_USER:$ADMIN_PASSWORD install-plugin serenity:1.4	
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $ADMIN_USER:$ADMIN_PASSWORD safe-restart
# List of plugins to install
PLUGINS=("Git" "Jira")
# Install Jenkins plugins using Jenkins CLI
for PLUGIN in "${PLUGINS[@]}"; do
  java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASSWORD" install-plugin "$PLUGIN"
done
# Restart Jenkins after installing plugins
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASSWORD" safe-restart
