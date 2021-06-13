#!/bin/bash

repo_base_dir="/data/repos/centos/7/"
repo_mirror="mirror.liquidtelecom.com/centos/7/"

rsync -avSHP --delete rsync://"$repo_mirror" "$repos_base_dir"

# wget -P $repos_base_dir wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official

