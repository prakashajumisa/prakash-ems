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
