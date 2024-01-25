# Readme

1. 建立工作目录和备份目录

2. 新建并切换到data目录作为工作目录

   ```
   mkdir /root/data
   cd /root/data
   ```

3. 新建备份目录

   ```
   mkdir /root/data/tmp
   ```

4. 由于每个安装包解压后的名称不太一样，不容易统一，所以执行每个脚本对应的参数会不一样，有些是压缩包，有些是解压后的文件夹，请对应如下文档。

> 说明：
>
> * 传入一个参数为安装脚本：`./xxx.sh [param1]`
>
> * 在其后再加一个参数`rollback`，则回退到安装前的系统状态：`./xxx.sh [param1] rollback`



### mysql脚本

1. 安装mysql：

   1. 上传install_mysql.sh和mysql安装包（.tar.gz）

      执行脚本进行安装（先赋予文件操作权限：如`chmod 777 install_mysql.sh`）
   
      ```
      ./install_mysql.sh [param1] 
   ```
   
   * param1为安装包的名称
      * 例  `./install_mysql.sh mysql-5.7.34-linux-glibc2.12-x86_64.tar.gz`

   2. 登录：(默认修改初始密码为123456)

      ```
      mysql -uroot -p123456
      ```

2. 回退模式：

   在`/root/data`工作目录下执行脚本

   ```
   ./install_mysql.sh [param1] rollback
   ```
   
   * param1为安装包名称，param2为rollback
   * 例： `./install_mysql.sh mysql-5.7.34-linux-glibc2.12-x86_64.tar.gz rollback`
   
3. 常见问题：

   1. 执行脚本进行回退时显示：<img src="https://pzc-yun.oss-cn-heyuan.aliyuncs.com/typora-img/image-20240123104552886.png" alt="image-20240123104552886" style="zoom:67%;" />

      则先将此进程杀死: `kill -9 7358`，再重新执行脚本进行回退

   2. 重复执行脚本进行安装时，提示`group`已存在，则执行rollback进行回退，再解决步骤`1`中出现的问题

   3. 初始化数据库时会有停顿，多等几秒

      ![image-20240123104810583](https://pzc-yun.oss-cn-heyuan.aliyuncs.com/typora-img/image-20240123104810583.png)

   4. 默认开启的是调试模式，会显示所有的命令及其执行结果，便于定位出错位置，但执行较慢，可在脚本中手动注释掉`set -x`和`set +x`以关闭



### redis脚本

1. 切换到工作目录：

   ```
   cd /root/data
   ```

2. 上传redis安装包和install_redis.sh安装脚本

3. 安装：

   ```
   ./install_redis.sh [param1] 
   ```

   * `param1`：压缩包名称
   * 例：`./install_redis.sh redis-5.0.7.tar.gz`

4. 回退：

   ```
   ./install_redis.sh [param1] rollback
   ```

   * 例：`./install_redis.sh redis-5.0.7.tar.gz rollback`



### nginx脚本

1. 切换到工作目录：

   ```
   cd /root/data
   ```

2. 上传nginx安装包和install_nginx.sh安装脚本

3. 安装：

   ```
   ./install_nginx.sh [param1] 
   ```

   * `param1`：压缩包名称
   * 例：`./install_nginx.sh nginx-1.18.0.tar.gz`

4. 回退：

   ```
   ./install_nginx.sh [param1] rollback
   ```

   * 例：`./install_nginx.sh nginx-1.18.0.tar.gz rollback`



### nacos脚本

1. 切换到工作目录：

   ```
   cd /root/data
   ```

2. 上传nacos安装包和install_nacos.sh安装脚本
  
3.  解压nacos安装包

4. 安装：

   ```
   ./install_nacos.sh [param1] 
   ```

   * `param1`：压缩包解压后的名称
   * 例：`./install_nacos.sh nacos-server-2.1.1.tar.gz`

5. 回退：

   ```
   ./install_nacos.sh [param1] rollback
   ```

   * 例：`./install_nacos.sh nacos-server-2.1.1.tar.gz rollback`



### jdk脚本

1. 切换到工作目录：

   ```
   cd /root/data
   ```

2. 上传jdk安装包和install_jdk.sh安装脚本

3. 解压压缩包

   如：`tar -zxvf jdk-8u261-linux-x64.tar.gz`，得到jdk1.8.0_261

4. 安装：

   ```
   ./install_jdk.sh [param1] 
   ```

   * `param1`：解压后的文件夹名称
   * 例：`./install_jdk.sh jdk1.8.0_261`

5. 回退：

   ```
   ./install_jdk.sh [param1] rollback
   ```

   * 例：`./install_jdk.sh jdk1.8.0_261 rollback`









