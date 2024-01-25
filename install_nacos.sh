#!/bin/bash

NACOS_DIR="$1"
BACKUP_DIR="/root/data/tmp/tmp_nacos"

install_nacos() {
    
    echo "开始安装 Nacos================================="

    cp -r $NACOS_DIR $BACKUP_DIR

    # 解压 Nacos
    mv "$NACOS_DIR" /usr/local/nacos

    # 启动 Nacos 服务
    cd /usr/local/nacos/bin
    sh startup.sh -m standalone

    # 防火墙配置
    firewall-cmd --permanent --add-port=8848/tcp
    firewall-cmd --reload

    echo "Nacos 安装结束================================="
}

rollback_nacos() {
    echo "执行 Nacos 安装回退操作============================================"

    # 停止 Nacos 服务
    sh /usr/local/nacos/bin/shutdown.sh

    # 删除已安装的 Nacos 目录
    rm -rf /usr/local/nacos

    # 删除备份文件夹
    rm -rf "$BACKUP_DIR"

    # 恢复备份
    mv "/$BACKUP_DIR/$NACOS_DIR" "/root/data"

    # 恢复防火墙配置
    firewall-cmd --permanent --remove-port=8848/tcp
    firewall-cmd --reload

    echo "Nacos 安装回退操作完成"
    exit 0
}

set -x

if [ "$2" = "rollback" ]; then
    rollback_nacos
fi

if [ -z "$NACOS_DIR" ]; then
    echo "Error: 请传入 Nacos 压缩包"
    exit 1
fi  

install_nacos "$NACOS_DIR"

set +x


