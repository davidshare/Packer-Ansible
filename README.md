# AUTOMATE CP DEPLOYMENT USING PACKER & ANSIBLE

## Intro

This README contains a guide on how to setup and automate your Nodejs app deployment using Packer & Ansible.
In our last automated deployment with `bash` script, we learnt a lot of things about how to create an AWS instance, what security rules to set, how to reverse proxy how applications IP and port, how to setup our domain name etc.
However, here we would be learning about how to abstract out most of these configurations using Packer as the Amazon Machine Image builder and Ansible as the Configuration manager.

## How To Setup Packer To Build AMIs

#### Download & Install Packer

The first thing to do is to install Packer using whatever method best suits you as decribed in the Packer documentation here [Install Packer](https://www.packer.io/intro/getting-started/install.html).

#### Setup Packer Template for build config

By the Packer documentation you can use the Packer tool to either just create and build AMIs or you can us it to also make some crucial configuration settings in your AMI for example, you can configure the machine environment to mirror exactly what you want your custom `production`, `development` and `test` environment to look like.

The Packer template file is a `json` object containing `keys` like:

> Variables
> Builders
> Provisioners
> Post-processesors

Each one of these values has its own crucial role it plays when correctly configured and included in a Packer template. For example, the `Variable` makes it easier to abstract out and protect sensitive keys like `aws access keys and secret keys`. The `builders` deals with ensuring that when Packer is instructed to build a machine image, the image mimics the configuration sets out in the `Builders` section.

The `Provisioners` section allows you to setup your server OS configurations for example, if you want to do a Linux Ubuntu package update, you could do so here. If you want to clone the repository where your application is sitting, you can do that here, if you need to setup your project for deployment, you can also do the same thing here. The number of amazing things that can be done with the `Provisioners` are not really exhaustive.

> For more information on what these concepts can be used for, kindly see the Packer Documentation here
> **Build Image** [https://www.packer.io/intro/getting-started/build-image.html]()

#### Building an AMI with Packer & Deploying CP with Ansible

In this repo, there are three files that are important to the completion of the task of automating deployment without using `bash` as our `provisioner`.

1.  **packer-config.json** - Packer template
2.  **aws-cp-playbook.yml** - YAML file that contains our plays
3.  **ansible.sh** - contains command to configure the AMI before ansible process the playbook in 3 above

In the **packer-config.json** file, the `variables` section has `aws_access_key` and `aws_secret_key` declared as empty strings, this wa deliberate as it is always industry practice to not push `secret or access keys` to source control in order to give authorized access to hackers or neferious individuals who may want to use your compromise your account.
In order to get Packer to build you an AWS AMI, you would need to replace

```
"variables": {
    "aws_access_key": "",
    "aws_secret_key": ""
  },
```

with something like

```
"variables": {
  "aws_access_key": "KLJASHDJASHDLASHDKJASHD",
  "aws_secret_key": "LASJDKAJSDKJALKAHLSJFH89ASDKJASHDJKSAHF8JKS"
},
```

To get your `access and secret keys` please follow AWS documentation here [https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey]()

when you have gotten the keys, endevour to add those to the appropriate fields in the `variables` section as shown above.

Another section worthy of note is the `provisioners` section where if you look closely you would see this

```
  {
    "type": "file",
    "source": "./",
    "destination": "/tmp"
  },
  {
    "type": "shell",
    "inline": [
      "echo '******* Copy .env from /tmp/ to ~/ *********'",
      "sudo cp /tmp/.env ~/.env"
    ]
  },
```

What is basically happening here is that since the .env file contained sensitive information that cannot commited to source control, I decided to copy the file during the build and configuration process to the `/tmp/` dir and there after the file is copied from `/tmp/` dir to the `~/` dir where it is made accessible to the application.

> NOTE: So ensure that after cloning this repo, you add the necesassy .env file containing these values:

      SECRET=< JWT SECRET >
      PORT=<APP PORT NO>
      DATABASE_URL=< DATABASE URL >
      CLOUDINARY_URL=< CLOUDINARY URL >
      UPLOAD_PRESET=<CLOUDINARY UPLOAD_PRESET>
      SEED_ADMIN_PW=<ADMIN_TEST PW>
      SEED_SUPERADMIN=<PASSWORD FOR SUPERADMIN>
      SEED_ADMIN=<SEED ADMIN PW>
      SEED_USER=<SEED USER PW>
      EMAIL=<NODE_MAILER EMAIL SETUP>
      PASSWORD=<PW_FOR_EMAIL>

Also in the packer template, still under the `provisioners` section there is a

```
{
      "type": "shell",
      "script": "./ansible.sh"
    }
```

configuration option that allows packer to install ansible using the shell script **ansible.sh** during the building of this particular AMI.
Without installing Ansible in the AMI, it would be really hard to use the Ansible Playbook to complete the configuration of that AMI instance.

The `provisioners` section also has a type of `ansible-local` that allows packer to run the plays in the `Ansible Playbook` file as form of configuration management tool.

for more information on how to use Ansible Playbook, please see the ansible documentation [https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#basics]()

### Start Deployment

To start deployment follow the following steps:

1.  clone this repo
2.  create an AWS account here [https://aws.amazon.com]() if you do not have one, and if you already do skip to step 3.
3.  signin to your AWS, create and generate your `access and secret` keys following the explanation above
4.  add the keys to the `variables` section of the `packer-config.json` file

    > NOTE: please REMEMBER NOT TO PUSH YOUR VERSION OF THIS PACKER TEMPLATE TO SOURCE CONTROL WITH YOUR REAL `ACCESS AND SECRET` KEYS STILL THERE.

5.  Like it was described above, also include the .env file in the root of the repository, the .env file is already added to .gitignore
6.  in the terminal run the command `packer build packer-config.json` to begin AMI config and setup
7.  at the completion of the packer build, an artificat (AMI) should be created and ready to use.

#### To launch AMI

To launch the just build Artifact / AMI follow the following steps

1.  Log in to your AWS console and nagivate to the **EC2 Dashboard**
2.  On the left dashboard, look for **Images** section and click on the **AMIs** link to see your just created AMI.
3.  Find the AMI you created within the list of AMI if there are other AMIs, and then click the blue `launch` button at the top.
4.  launching this AMI would take you through the normal flow of how to create an AWS instance except with your own AMI as the image.
5.  on the instance config page, skip to the `Configure Security Group` page and then either create new group or use an existing group
6.  complete config by clicking the 'review and launch` button
7.  on the next page, click `launch` to create a new `key pair` or use an existing one
8.  at the end of step 7, an instance should be launched and should be visible on your instances page.
9.  At after the instance is done starting up and initialining, copy the `DNS IPv4 address` of the instance to see the application start up.

##NOTE:

> so far this configuration and deployment script does not account for setting up the nginx SSL certificate configuration.
