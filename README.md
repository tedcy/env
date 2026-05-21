# env 使用说明

## 组件说明

本仓库主要维护两类环境：

- 顶层 `install.sh`：安装完整 Vim / YouCompleteMe / Python / Bear / gperftools 开发环境。
- `clang_make/`：维护独立的 clang 编译辅助脚本和 C++14/C++17/C++20 工具链。

这两套流程的支持系统不同，使用前需要分开看。

## 顶层 install.sh

### 支持环境

`install.sh` 当前按 Ubuntu 20.04 和 Ubuntu 24.04 维护。

- Ubuntu 20.04：已在 Docker 干净容器中跑通，`install.rc=0`。
- Ubuntu 24.04：已在 Docker 干净容器中跑通，`install.rc=0`。
- Ubuntu 16.04：不再维护。

实测结果：

- Python：`Python 3.8.12`
- Vim：`VIM - Vi IMproved 8.2`
- Bear：Ubuntu 20.04 为 `bear 2.4.3`，Ubuntu 24.04 为 `bear 3.1.3`。
- gperftools：使用系统仓库 `google-perftools`。

已知问题：

- `vim +GoInstallBinaries` 会提示 `go executable not found`，但不影响脚本继续执行。

### Docker 环境

推荐使用 Ubuntu 20.04 或 Ubuntu 24.04：

```bash
docker pull ubuntu:20.04
# 或
docker pull ubuntu:24.04

mount_dirs="-v /data/xxx:/root"

docker run -it --privileged --cap-add sys_ptrace $mount_dirs -w /root --ulimit nofile=1024 -m 40G -p 9497:22 -e LANG=zh_CN.UTF-8 -e LC_ALL=C --name $dockername ubuntu:24.04
```

容器内初始化。注意必须用非交互模式，否则 `tzdata` / `debconf` 可能卡住：

```bash
apt update
DEBIAN_FRONTEND=noninteractive apt-get install -y sudo software-properties-common git lrzsz ssh
git clone https://github.com/tedcy/env /root/env
```

`install.sh` 推荐配合离线包使用：

```bash
scp -P 9497 vim_download.tar.gz root@x.x.x.x:/root/env/
```

运行安装：

```bash
cd /root/env
./install.sh
```

安装结束后设置 shell：

```bash
cd /root/env
./bash/set_shell.sh
```

如需开启 SSH：

```bash
echo "PermitRootLogin yes" > /etc/ssh/sshd_config
/etc/init.d/ssh restart
passwd
```

## clang_make

### 支持环境

`clang_make` 当前支持情况：

- Ubuntu 24.04：支持 C++14、C++17、C++20。
- Ubuntu 20.04：支持 C++14、C++17、C++20。
- Ubuntu 16.04：不支持。

`clang_make` 会根据最终生效的 `-std` / `--std` 自动选择对应工具链：

- C++14：`clang_make/cxx14/bin/clang++`
- C++17：`clang_make/cxx17/bin/clang++`
- C++20：`clang_make/cxx20/bin/clang++`

如果当前系统 glibc 版本不满足对应工具链要求，脚本会提前退出并打印明确错误。

### 安装

安装全部 clang_make 工具链：

```bash
cd /root/env/clang_make
./install_all.sh
```

也可以只安装某个标准对应的工具链：

```bash
cd /root/env/clang_make
./cxx14/install.sh
./cxx17/install.sh
./cxx20/install.sh
```

### 使用

在需要编译的项目目录执行：

```bash
/root/env/clang_make/clang-make.sh
```

生成 `compile_commands.json`：

```bash
/root/env/clang_make/clang-make.sh bear
```

只查看前 N 行编译输出：

```bash
/root/env/clang_make/clang-make.sh h80
```

`clang_make` 会先通过 `make -n -B` 判断最终编译命令里的最后一个 `-std` / `--std`，再自动选择 C++14、C++17 或 C++20 对应的 clang。

## 代码补全

YouCompleteMe 是 C/C++ 补全基础：

https://github.com/Valloric/YouCompleteMe

cmake 项目：

```bash
cmake $CODE_FOLDER
bear make
```

make 项目：

```bash
bear make
```

如需了解 C/C++ 语义补全的完整配置方式，参考 YouCompleteMe README 里的 `C-family Semantic Completion`。

`compdb` 用于扩展头文件补全支持：

https://github.com/Sarcasm/compdb

```bash
compdb -p . list > tmp_compile_commands.json
mv tmp_compile_commands.json compile_commands.json
```

## TODO

- 增加 bear make 脚本，把 json 生成到 `/tmp`。
- 修改 `ycm_extra_conf.py`，支持从 `/tmp` 查找 json。
- 修改 `ycm_extra_conf.py`，识别 g++ 版本。
