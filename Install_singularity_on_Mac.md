## Installation of Singularity on Mac OS

Although Mac OS is largery similar to Linux, it's yet not completely the same. Unfortunately, Singularity can't be run natively (i.e. system-wide)  on Mac OS and requires virtual machine with Linux on it. So, let's install the virtual machine!

### Step 1: Installation of Vagrant (aka Virtual machine)
In order to install Vagrant on your Mac, you need Homebrew. If you already have it, great! One less step to do. If not, install it like this (in terminal):
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
Next, Vagrant can be installed via Homebrew using the following commands (in terminal):
```
brew cask install virtualbox
brew cask install vagrant 
brew cask install vagrant-manager
```

### Step 2: Set up Vagrant
Open a terminal, navigate to the folder there you'd like your virtual machine to be, i.e. Desktop, Documents, bin. etc and create a directory for your Vagrant VM called vm-singularity

```
mkdir vm-singularity
cd vm-singularity
```

If you have already created and used this folder for another VM, you will need to destroy the VM and delete the Vagrantfile.
```
vagrant destroy
rm Vagrantfile
```

Now, initialize your virtual machine. It will already have singularity v3.9 installed:

```
vagrant init sylabs/singularity-ce-3.9-ubuntu-bionic64 --box-version 20211116.0.0
```

### Step 3: Start your VM and finally get to Singularity!
To start your virtual machine, type:
```
vagrant up
```
You should see something like this on your screen:
```
==> vagrant: A new version of Vagrant is available: 2.2.19 (installed version: 2.2.18)!
==> vagrant: To upgrade visit: https://www.vagrantup.com/downloads.html

Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'sylabs/singularity-ce-3.9-ubuntu-bionic64'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'sylabs/singularity-ce-3.9-ubuntu-bionic64' version '20211116.0.0' is up to date...
==> default: Setting the name of the VM: singularity-vm_default_1644230488942_19987
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: 
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default: 
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
==> default: Mounting shared folders...
    default: /vagrant => /Users/maria/bin/singularity-vm
```

**IMPORTANT NOTE: you obviosly don't need to repeat steps 1 and 2 every time you want to use your VM + Singularity.However, your VM + Singularity can only be accessed in the vm-singularity folder you've just created, so you ALWAYS need to `cd vm-singularity` before launching vagrant**

Currently the virtual machine is running in the backgrond, just like a cluster, so we need to `ssh` into it:
```
vagrant ssh
```

That's it! You're inside your virtual machine with singularity installed! You should see something similar to:
```
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-156-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
New release '20.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

vagrant@vagrant:~$ 
```
on your screen. `vagrant@vagrant` indicates that you're inside your VM. Now you can work on your Singularity project.

### Step 4: finisning your work and cleaning up.

VM does take quite a chunk of your computer resources to run, so let's stop it and free resources:
```
vagrant destroy
```

### Helpful note: how to get files in and out your VM:
Since VM is running like a cluster, then we can copy files in and out via `scp`:

To copy files in:
```
scp -P 2222 your_file vagrant@127.0.0.1:.
```

To copy files out:
```
scp -P 2222 vagrant@127.0.0.1:/PATH/filename .
```

Both times it will ask for the password and it's **vagrant**. Please note, that `scp` in the example above uses port 2222 and address 127.0.0.1. It can be different for your computer. To check, which one it is for your computer, bring your VM up and run `ssh-config`:
```
vagrant up
vagrant ssh-config
```

Possible output is:
```
Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/maria/bin/singularity-vm/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```
You need HostName and Port.

### Sources:
1. [Sylabs](https://sylabs.io/guides/3.0/user-guide/installation.html#install-on-windows-or-mac)
2. [Vagrant](https://app.vagrantup.com/sylabs/boxes/singularity-ce-3.9-ubuntu-bionic64)
3. [Stackoverflow](https://stackoverflow.com/questions/16704059/easiest-way-to-copy-a-single-file-from-host-to-vagrant-guest)
