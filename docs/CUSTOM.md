# 使用Docker创建环境

**源码细节正在调试，暂未开放，欢迎邮件沟通 [zzudongxiang@163.com](mailto:zzudongxiang@163.com)**

**源码细节正在调试，暂未开放，欢迎邮件沟通 [zzudongxiang@163.com](mailto:zzudongxiang@163.com)**

**源码细节正在调试，暂未开放，欢迎邮件沟通 [zzudongxiang@163.com](mailto:zzudongxiang@163.com)**

> 注意该流程仅供参考，仅作为开发者自用的脚本记录

## 1. 创建容器

- 创建Docker容器

```bash
docker run -it --ipc=host --name astrasim \
    -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v ~/.ssh/authorized_keys:/root/.ssh/authorized_keys.host \
    -v /etc/localtime:/etc/localtime \
    -v ~/workdir:/workdir \
    --workdir=/workdir \
    -p 223:22 \
    ubuntu:20.04 /bin/bash
```

- 复制已认证的公钥信息

```bash
cat /root/.ssh/authorized_keys.host > /root/.ssh/authorized_keys
```

## 2. 安装依赖

- apt-get依赖安装

```bash
apt update
apt upgrade -y
apt install -y gcc g++ make cmake mpich nano git git-lfs python3 python3-pip openssh-server sudo libboost-dev libboost-program-options-dev libprotobuf-dev protobuf-compiler autoconf automake unzip pciutils gfortran net-tools iproute2 zlib1g zlib1g-dev libsqlite3-dev libssl-dev libtool libffi-dev libblas-dev libblas3
```

- nano /etc/ssh/sshd_config

```txt
Port 22
PermitRootLogin yes
PubkeyAuthentication yes
ClientAliveInterval 30
ClientAliveCountMax 10
```

- 启动ssh服务

```bash
service ssh start
```

## 3. 创建用户

```bash
adduser astrasim # passwd: 123456
```

- nano /etc/sudoers

```bash
astrasim ALL=(ALL:ALL) ALL
```

- 切换用户

```bash
su astrasim
```

- 安装pip依赖

```bash
pip install --upgrade pip
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple protobuf==3.6.1 pydot pandas matplotlib seaborn
```

- 添加ssh-key

```bash
sudo cp /root/.ssh/id_rsa /home/astrasim/.ssh/id_rsa
sudo cat /root/.ssh/authorized_keys.host > /home/astrasim/.ssh/authorized_keys
```

## 4. 下载仓库并更新内容

```bash
git submodule update --init --recursive
```

