# CentOS 7.9 Repository-Mirror

Steps to create a repository-mirror for CentOS 7.9 hosted on CentOS 7.9.
I intended to use this mirror for a series of virtual machines with no direct internet-access, so I used two network-interfaces, one using the default setup with NAT for internet-access, and one private, connected to a virtual lan.

## Requisites

* A complete clone is quite large (~95GB as of today), plus some GB for the system. I used a VirtualBox-VM for this install with 150GB maximum disk size.

* Install-CD. I used CentOS-7-x86_64-Everything-2009.iso

## Preparation
* Create a VM for this install. I used the values:
  * Name and Operating system
    * Name: repomirror
    * Folder: d:/vbox
    * Type: Linux
    * Version: Fedora (64-bit)
  * Memory Size
    * 1024MB (default)
  * Hard disk
    * (Create a virtual hard disk now)
    * Select: VDI
    * Select: Dynamically allocated
    * File: d:/vbox/repomirror/repomirror.vdi
    * Size: 150GB

## Installation
* Boot the virtual machine
* Select the CentOS-ISO as installation image
* In the installer, setup:
  * Minimal Software Configuration
  * Partition: btrfs, autogenerate
  * no network
  * users/password: root/*****, vm/*****
* Reboot and login

## Configure external network
* sudo -e /etc/sysconfig/network-scripts/ifcfg-enp0s3 (Could have used nmtui, if I knew earlier)
* sudo ifdown enp0s3
* sudo ifup enp0s3
* ping www.google.com

## Grab some stuff
* sudo yum install bzip2 elinks rsync screen time wget

## Install webserver
* sudo yum install epel-release
* sudo yum install nginx
* sudo systemctl enable nginx.service
* sudo systemctl start nginx.service
* sudo firewall-cmd --add-service=http --permanent
* sudo firewall-cmd --reload

## Setup repository-location
* sudo mkdir -p /data/repos/centos/7
* Create file: /etc/sync_repo_centos7.sh
* sudo chmod +x /etc/sync_repo_centos7.sh
* Might use some cron-job to update the mirror:
  * # Update mirror each wednesday at 20:00. See `man 5 crontab` for syntax.
  * sudo crontab -e
  * 00 20 * * 3 /etc/sync_repo_centos7.sh
* Manually start the sync: sudo /etc/sync_repo_centos7.sh (Depending on your and the mirror's connection, this may take some hours/days.)

## Configure the webserver
* Create file: /etc/nginx/conf.d/centos-mirror.conf
* Test configuration: sudo nginx -t
* Reload nginx: systemctl restart nginx
* Tell SELinux to allow access: chcon -Rt httpd_sys_content_t /data/repo/centos
* Add to /etc/hosts:
  * 127.0.0.1 repomirror.vmnet centos.repomirror.vmnet
* Test: elinks http://centos.repomirror.vmnet (Should show a listing with only one directory "7", mirrored files inside.)
