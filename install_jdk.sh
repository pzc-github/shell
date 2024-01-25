#!/bin/bash

# 设置全局变量
JDK_DIR="$1"
BACKUP_DIR="/root/data/tmp/tmp_jdk"
ROLLBACK="$2"

# 回退函数
rollback() {
    echo "执行 JDK 安装回退操作============================================"

    # 删除已安装的 JDK 目录
    rm -rf /usr/local/java

    # 将备份的文件移回到原处
    mv "$BACKUP_DIR/$JDK_DIR" /root/data

    # 删除备份文件夹
    rm -rf "$BACKUP_DIR"

    # 恢复修改的配置文件
    config_file="/etc/profile"
    prefixes=("export JAVA_HOME" "export JRE_HOME" "export CLASSPATH" "export JAVA_PATH" "export PATH")

    # 使用 sed 删除以指定字符串开头的行
    for prefix in "${prefixes[@]}"; do
        sudo sed -i "/^$prefix/d" "$config_file"
    done


    # 刷新环境变量
    source /etc/profile

    echo "JDK 安装回退操作完成"
    exit 0
}

# 安装 JDK 函数
install_jdk() {
    echo "开始安装 JDK================================="

    # 创建备份文件夹
    mkdir -p "$BACKUP_DIR"
    cp -r $JDK_DIR $BACKUP_DIR

    # 移动到指定位置
    mv "$JDK_DIR" /usr/local/java/


    # 修改配置文件
    config_file="/etc/profile"
    declarations=(
        "export JAVA_HOME=/usr/local/java"
        "export JRE_HOME=\${JAVA_HOME}/jre"
        "export CLASSPATH=\$:CLASSPATH:\${JAVA_HOME}/lib/"
        "export JAVA_PATH=\${JAVA_HOME}/bin:\${JRE_HOME}/bin"
        "export PATH=\$PATH:\${JAVA_PATH}"
    )

    for declaration in "${declarations[@]}"; do
        if ! grep -q "$declaration" "$config_file"; then
            echo "$declaration" | sudo tee -a "$config_file"
        fi
    done


    # 刷新环境变量
    source /etc/profile

    java -version

    echo "JDK 安装完成================================="
}

# 设置错误处理和回退
set -x
set -e

# 检查参数是否为空
if [ -z "$JDK_DIR" ]; then
    echo "Error: 需要传入 JDK 压缩包"
    exit 1
fi

# 检查第二个参数是否为空：
    # 不为空则说明是回退模式，为空则说明是安装模式
if [ "$2" = "rollback" ]; then
    set +e  # 无论有无出错，执行完所有回退步骤
    rollback  # 回退模式
else
    install_jdk # 安装jdk
fi


set +x



                                                                     