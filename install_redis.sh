#!/bin/bash

REDIS_PACKAGE="$1"
BACKUP_DIR="/root/data/tmp/tmp_redis"

install_redis() {

    echo "开始安装 Redis================================="

    # 安装依赖
    yum install -y gcc-c++
    rpm -q gcc

    # 备份
    cp "$REDIS_PACKAGE" $BACKUP_DIR

    # 解压 Redis
    tar -zxvf "$REDIS_PACKAGE"
    REDIS_DIR=$(basename "$REDIS_PACKAGE" .tar.gz)
    

    # 编译安装
    cd /usr/local/redis
    make
    make PREFIX=/usr/local/redis install
    ls /usr/local/redis/bin

    # 创建配置文件目录
    mkdir -p /usr/local/redis/etc
    cp redis.conf /usr/local/redis/etc

    # 修改文件内容
    redis_conf="/usr/local/redis/etc/redis.conf"
    sed -i 's/daemonize no/daemonize yes/' "$redis_conf"
    sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' "$redis_conf"

    # 防火墙配置
    firewall-cmd --query-port=6379/tcp || firewall-cmd --permanent --add-port=6379/tcp
    firewall-cmd --reload

    # 启动 Redis 服务端
    /usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf

    # 查看进程
    ps -ef | grep redis

    # 启动客户端
    /usr/local/redis/bin/redis-cli

    echo "Redis 安装结束================================="
}

rollback_redis() {
    echo "执行 Redis 安装回退操作============================================"

    # 停止 Redis 服务
    pkill redis-server

    # 删除已安装的 Redis 目录
    rm -rf /usr/local/redis

    # 删除备份文件夹
    rm -rf "$BACKUP_DIR"

    # 恢复备份文件
    mv "$BACKUP_DIR/$REDIS_PACKAGE" "/root/data"

    # 恢复防火墙配置
    firewall-cmd --permanent --remove-port=6379/tcp
    firewall-cmd --reload

    echo "Redis 安装回退操作完成"
    exit 0
}

set -x

# 在此处添加回退逻辑
# 如果需要回退，执行：./install_redis.sh redis-5.0.7.tar.gz rollback
if [ "$2" = "rollback" ]; then
    rollback_redis
fi

if [ -z "$REDIS_PACKAGE" ]; then
    echo "Error: 请传入 Redis 压缩包"
    exit 1
fi

install_redis

set +x
