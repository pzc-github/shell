#!/bin/bash

# 获取压缩包
MYSQL_PACKAGE="$1"
BACKUP_DIR="/root/data/tmp/tmp_mysql"

rollback() {
    echo "执行回退操作============================================"

    # 删除已安装的mysql目录
    rm -rf /usr/local/mysql

    # 删除数据文件，避免初始化数据库时出错  路径为/etc/my.cnf中的datadir
    rm -rf /data/mysql

    # 将备份的文件移回到原处
    mv "$BACKUP_DIR/$MYSQL_PACKAGE" /root/data

    # 删除备份文件夹
    rm -rf "$BACKUP_DIR"

    # 删除用户组和用户
    userdel mysql
    groupdel mysql

    # 删除修改的配置文件
    sudo rm -f /etc/my.cnf

    # 如果服务已经启动，停止服务
    service mysql stop

    # 撤销开放的端口
    firewall-cmd --permanent --remove-port=3306/tcp
    firewall-cmd --reload

    # 移除软链接
    rm -f /usr/bin/mysql

    echo "回退操作完成"
    exit 0
}


install_mysql(){
    if [ -z "$MYSQL_PACKAGE" ]; then
        echo "Error: 需要传入压缩包"
        exit 1
    fi

    echo "开始安装 MySQL================================="

    # 备份压缩包，用于后续回退
    cp $MYSQL_PACKAGE $BACKUP_DIR

    # 解压
    tar -zxvf $MYSQL_PACKAGE

    # 解压后的文件夹
    MYSQL_DIR=$(basename "$MYSQL_PACKAGE" .tar.gz)
    echo "解压后的文件名: $MYSQL_DIR"

    # 解压后的文件夹移动到指定位置
    mv "$MYSQL_DIR" /usr/local/mysql

    # 创建用户组
    groupadd mysql
    useradd -r -g mysql mysql
    mkdir -p  /data/mysql
    chown mysql:mysql -R /data/mysql

    # 修改配置文件
    sudo echo "" > /etc/my.cnf
    # 文件路径
    config_file="/etc/my.cnf"

    # 要添加的命令列表
    new_commands=(
        [mysqld]

        bind-address=0.0.0.0
        port=3306
        user=mysql
        basedir=/usr/local/mysql
        datadir=/data/mysql
        socket=/tmp/mysql.sock
        log-error=/data/mysql/mysql.err
        pid-file=/data/mysql/mysql.pid
        #character config
        character_set_server=utf8mb4
        symbolic-links=0
        explicit_defaults_for_timestamp=true
        lower_case_table_names=1
        max_connections=1024
        sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
        innodb_read_io_threads=32
        innodb_write_io_threads=32
        thread_cache_size=512
        innodb_buffer_pool_size=4949672960
        query_cache_type=1
        query_cache_size=1073741824
        default-time-zone=+08:00
    )

    # 检查文件是否包含相同的命令，如果没有才添加，避免重复执行此脚本时添加多条相同命令
    for command in "${new_commands[@]}"; do
        if grep -q "^$command" "$config_file"; then
            echo "Command '$command' already exists in the file. No modification needed."
        else
            # 追加命令到文件末尾
            echo "$command" | sudo tee -a "$config_file"
            echo "Command '$command' added to the file."
        fi
    done

    # 初始化数据库
    cd /usr/local/mysql/bin/
    if ./mysqld --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql/ --datadir=/data/mysql/ --user=mysql --initialize; then
        echo "MySQL 数据库初始化成功"
    else
        echo "Error: MySQL 数据库初始化失败"
        # 执行回退操作
        set +e
        rollback
    fi
    mysql_err="/data/mysql/mysql.err"
    # 使用grep和正则表达式截取临时密码
    temp_password=$(grep -oP 'A temporary password is generated for root@localhost: \K(.*)' "$mysql_err")

    cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
    service mysql start # 开启mysql服务

    ./mysql -uroot -p"$temp_password" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456'; USE mysql; UPDATE user SET Host='%' WHERE User='root'; FLUSH PRIVILEGES;" 2> /dev/null

    # 开放端口
    firewall-cmd --permanent --add-port=3306/tcp
    firewall-cmd --reload

    # 软链接，使得不用在mysql目录下就能使用mysql命令
    ln -s /usr/local/mysql/bin/mysql  /usr/bin

    echo "MYSQL安装结束================================="
}

set -x # 开启调试模式，便于定位出错的位置
set -e  # 设置脚本在发生错误时立即退出

trap 'rollback' ERR  # 捕捉错误并执行回退函数

# 检查第二个参数是否为空：
    # 不为空则说明是回退模式，为空则说明是安装模式
if [ "$2" = "rollback"  ]; then
    set +e  # 无论有无出错，执行完所有回退步骤
    rollback # 回退模式
else
    install_mysql # 安装MySQL
fi

set +x  # 关闭调试模式

