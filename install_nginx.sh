#!/bin/bash

NGINX_PACKAGE="$1"
BACKUP_DIR="/root/data/tmp/tmp_nginx"

rollback_nginx() {
    echo "执行 Nginx 安装回退操作============================================"

    # 删除已安装的 Nginx 目录
    rm -rf /usr/local/nginx

    # 将备份的文件移回到原处
    mv "$BACKUP_DIR/$NGINX_PACKAGE" /root/data

    # 删除备份文件夹
    rm -rf "$BACKUP_DIR"

    # 恢复防火墙配置
    firewall-cmd --permanent --remove-port=80/tcp
    firewall-cmd --reload

    echo "Nginx 安装回退操作完成"
    exit 0
}

install_nginx(){
    echo "开始安装nginx================================="

    # 备份压缩包文件
    mkdir "$BACKUP_DIR"
    cp  "$NGINX_PACKAGE" "$BACKUP_DIR"
    # 解压
    tar -zxvf $NGINX_PACKAGE
    # 解析获取解压后的文件名
    NGINX_DIR=$(basename "$NGINX_PACKAGE" .tar.gz)

    # 安装nginx
    mv /root/data/"$NGINX_DIR" /usr/local/nginx
    cd /usr/local/nginx
    ./configure --prefix=/usr/local/"$NGINX_DIR" --with-http_ssl_module --with-http_stub_status_module

    yum install pcre-devel zlib zlib-devel openssl openssl-devel
    make
    make install

    # 防火墙配置
    firewall-cmd --query-port=80/tcp || firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --reload


    ls /usr/local
    cd /usr/local/"$NGINX_DIR"/sbin
    ./nginx

    echo "nginx安装结束================================="


}

set -x

if [ "$2" = "rollback" ]; then
    rollback_nginx
fi

if [ -z "$NGINX_PACKAGE" ]; then
    echo "Error: 请传入 nginx 压缩包"
    exit 1
fi
install_nginx

set +x
