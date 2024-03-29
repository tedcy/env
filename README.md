now only support ubuntu 16.04

```
docker pull ubuntu:16.04

mount_dirs="-v /data/xxx:/root"

docker run -it --privileged --cap-add sys_ptrace $mount_dirs -w /root --ulimit nofile=1024 -m 40G -p 9497:22 -e LANG=zh_CN.UTF-8 -e LC_ALL=C --name $dockername  ubuntu:16.04

apt update && apt-get install -y git lrzsz ssh && git clone https://github.com/tedcy/env

echo "PermitRootLogin yes" > /etc/ssh/sshd_config && /etc/init.d/ssh restart && passwd

#other machine
scp -P 9497 vim_download.tar.gz root@x.x.x.x:/root/env/ 
```

## 1 install

* run install.sh to install
* run set_shell.sh to set shell color

## 2 usage

### 2.1 completion

* https://github.com/Valloric/YouCompleteMe

ycm is the base of completion

```
cmake:
cmake $CODE_FOLDER
bear make

make:
bear make
```

if have any question, read "C-family Semantic Completion" of ycm README to know how to support cmake and make

* https://github.com/Sarcasm/compdb

compdb is a extention of support cpp header files completion

```
compdb -p . list > tmp_compile_commands.json
mv tmp_compile_commands.json compile_commands.json
```

## 3 TODO

* add bear make script to create json in /tmp folder
* modify ycm_extra_conf.py to find the json file in /tmp folder
* modify ycm_extra_conf.py to know the g++ version
