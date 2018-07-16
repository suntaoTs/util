静态比对系统 docker 环境
===

# aim

* 统一编译环境
# content

## image-pipeline编译环境

1. 第一种方式
```
cd build
sudo ./docker-build.sh
```
2. 第二种方式

```
sudo docker save -o iva-image-pipeline.tar iva-image-pipeline-build:0.0.1
  -o --output=      Write to an file, instead of STDOUT 输出到的文件

sudo docker load -i iva-image-pipeline.tar
  -i --input=       Read from a tar archive file, instead of STDIN 加载的tar文件
```
启动示例

```
sudo docker run  --net=host --privileged -it --rm -v $PWD:/data iva-image-pipeline-build:0.0.1 /bin/bash
```
* --runtime=nvidia: for cuda
* --net=host: 网络穿透
* --privileged: 获取加密狗等信息
* --rm: 退出容器时，删除容器
* -it: 交互终端
* -v $PWD:/data: 挂载当前目录（一般是工程目录）


...
