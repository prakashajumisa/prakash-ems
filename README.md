In this document we are going to discuss, what is a packer and how it is working

What is Packer?

- Packer is an open-source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef or Puppet. In fact, when building images, Packer is able to use tools like Chef or Puppet to install software onto the image.

- A machine image is a single static unit that contains a pre-configured operating system and installed software which is used to quickly create new running machines. Machine image formats change for each platform. Some examples include AMIs for EC2, VMDK/VMX files for VMware, etc.

- For using the Packer, first, we have to install the packer on our Local Machine** Mostly we are using the system package manager for installing the Packer, we will install the packer in the local machine in following ways:

a. For Mac Operating System: We are going to use Homebrew. Homebrew is a free and open-source package management system for Mac OS X. Install the official Packer from the terminal.

First, install the HashiCorp tap, a repository of all our Homebrew packages. The Commands are

<img width="470" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/ecab6506-b9ae-4630-bf58-ef9b49e15357">

b. For Linux Operating System:

<img width="580" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/8e21d52c-68d7-4546-a4cd-67e189a17c74">

c. For Windows Operating: For Windows Operating System we are going to use Chocolatey for Packer installation. Chocolatey is a free and open-source package management system for Windows.

<img width="593" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/e26670a2-1e80-4ac0-a917-3c0eed4cf1f2">

After installing Packer, verify the installation worked by opening a new command prompt or console, and checking that Packer is available
<img width="628" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/d8abf284-c0c0-4082-b125-cca53aefda85">

Creating AWS AMI Using Packer: Now let’s see how to create an AMI using the Packer template.

   ```
       {
         "variables": {
           "aws_access_key": "",
           "aws_secret_key": ""
         },
         "builders": [
           {
             "type": "amazon-ebs",
             "access_key": "{{user `aws_access_key`}}",
             "secret_key": "{{user `aws_secret_key`}}",
             "region": "ap-south-1",
             "source_ami": "ami-0f5ee92e2d63afc18",
             "instance_type": "t2.micro",
             "ssh_username": "{{user `ssh_username`}}",
             "ami_name": "packer-jenkins {{timestamp}}",
       	  "tags":{
       		"Name": "packer_jenkins - {{timestamp}}"
       	  }
           }
         ],
         "provisioners": [
           {
             "type": "shell",
             "script": "provisioners/jenkins.sh" 
           }
         ]
       }
```

Variables:

- This section defines two variables, aws_access_key and aws_secret_key. These variables are used to authenticate with AWS services. However, in the provided code snippet, the values for these variables are left empty, and they are expected to be filled in when using Packer.
Builders: This section defines the builder configuration, which specifies how Packer will create the AMI. In this case, it's using the "amazon-ebs" builder type, which is used for creating Amazon EBS-backed AMIs.

- access_key and secret_key: These fields use the values of the aws_access_key and aws_secret_key variables provided by the user to authenticate Packer with AWS.

- region: Specifies the AWS region where the AMI will be created.

- source_ami: The ID of the source AMI that will be used as a base for creating the new AMI.

- instance_type: The EC2 instance type to use while creating the temporary instance for provisioning and building.

- ssh_username: The SSH username that Packer will use to connect to the instance during the provisioning process.

- ami_name: The name for the new AMI that will be created. It includes the string "packer-jenkins" and a timestamp placeholder to make the name unique.

- tags: Additional tags that will be applied to the new AMI. In this code, a "Name" tag is set using a combination of "packer_jenkins" and a timestamp placeholder.

**Provisioners:** 
- This section defines how the instance created by Packer will be provisioned. In this code, a "shell" provisioner is used, which indicates that a shell script will be run on the instance.

**script:** 
- The path to the shell script that will be executed on the instance for provisioning. The script file is located at "provisioners/jenkins.sh".

```
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

```
This script is written in Bash to automate the installation and configuration of Jenkins along with installing some plugins
```
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
```
The shebang (#!/bin/bash) indicates that the script should be executed using the Bash shell. The export DEBIAN_FRONTEND=noninteractive line sets an environment variable to prevent any interactive prompts from the Debian package manager (apt-get) during installation.

```
sudo apt-get update -y
# ... (curl and echo commands to add Jenkins repository)
sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-11-jre
sudo apt-get install -y jenkins
```
This section updates the package repositories, adds the Jenkins repository, updates again, and then installs necessary packages including the OpenJDK 11 runtime and Jenkins.

```
sudo systemctl start jenkins
sudo systemctl enable jenkins
sleep 30
```
These commands start the Jenkins service and enable it to start automatically on system boot. A short pause to allow Jenkins to fully start.

```
JENKINS_PASSWORD=$(sudo cat $JENKINS_PASSWORD_FILE)
echo "Jenkins initial admin password: $JENKINS_PASSWORD"
```
This section retrieves and displays the initial admin password required to unlock and set up Jenkins. The password is stored in a file located at /var/lib/jenkins/secrets/initialAdminPassword.
```
wget http://localhost:8080/jnlpJars/jenkins-cli.jar
```
Downloads the Jenkins CLI JAR file, which allows command-line interaction with the Jenkins instance.
```
PLUGINS=("Git" "Jira")
for PLUGIN in "${PLUGINS[@]}"; do
  java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASSWORD" install-plugin "$PLUGIN"
done
```
This section installs Jenkins plugins listed in the PLUGINS array. It uses the Jenkins CLI to install each plugin using the provided Jenkins URL and admin user credentials.
```
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASSWORD" safe-restart
```
After installing the plugins, the script performs a safe restart of the Jenkins service to ensure that the newly installed plugins are properly activated.

To build the AMI through above the script by using the below Packer command:

         packer build <file_name>
The packer build command is used to initiate the build process of an image using a Packer template. The Packer template is a JSON or HCL file that defines the configuration for building the image. Above is an example of how we would use the packer build command. If we have a Packer template named template.json, and this template is located in the same directory where you're running the command. Then the commmand will be

```
packer build template.json
```
template.json is the name of your Packer template file. Packer will read this template and follow the instructions specified in the code, and create the image according to the defined configuration.

Once the build started, the packer will launch the new instance and create the image according to the defined configuration like installing the Jenkins with mentioned plugins.

<img width="1324" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/4e45f2d6-9a4e-48cc-b944-39e0c26edf67">


Once the Image is created, then the instance will be terminated automatically.

<img width="897" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/937cf36c-e929-445c-86e3-6a4ad1335543">


we can check the created AMI in the AMI section in AWS Console. like below

<img width="1676" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/5c0ce7f7-34d9-4fa8-8d2c-4202facf0f8c">


Then we launch the instance by using our created AMI. then we can see our jenkins running in our instance through ssh by using the below command.
```
systemctl status jenkins
```

<img width="1724" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/3074d47a-2c1a-4b77-b322-b265768f7d5e">

We can check the plugin installation in Jenkins in the installed plugin section.

<img width="1571" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/e25b8e94-a56f-4e59-921e-c61d01bcf893">

<img width="1545" alt="image" src="https://github.com/prakashajumisa/Prakash-Jumisa/assets/141750020/184b06f2-ac1a-48b0-b223-6ef533037a21">
