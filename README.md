now only support ubuntu 16.04

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
