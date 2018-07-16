## 概述

对`refelucca v1.0`进行重构，主要目标在于`架构`和`性能`，具体在以下几个方面进行改动：

1.  改进架构，便于扩充维护，彻底摆脱`felucca`的架构问题
1.  删除`felucca`留下的无用代码
1.  加强机器资源利用，提高任务执行并发性
1.  解决入库缓慢问题，提高任务入库量

## 架构方案

1.  全局设置模块：集中用户输入参数与日志logger设置
1.  库管理模块：
    1.  子模块划分
    1.  加快入库速度
1.  任务管理模块：
    1.  将任务相关数据抽象为`class task`
    1.  优化任务下发策略，缩短测试时间
    1.  子模块划分
1.  分析模块：
    1.  子模块划分

## 进度

* [ ]  重构
    * [x]  configure：
        * [x]  日志模块集中管理
    * [ ]  database：
        * [x]  解决`felucca`遗留的全局变量问题
        * [ ]  测试多线程大批量入库
        * [x]  子模块划分：
            * [x]  dbDelete.py
            * [x]  dbHandler.py
            * [x]  dbPreprocess.py
            * [x]  dbCreate.py
            * [x]  dbGet.py
    * [ ]  task：
        * [x]  任务数据抽象
        * [x]  解决`felucca`遗留的全局变量问题
        * [ ]  任务下发策略优化
        * [x]  子模块划分：
            * [x]  taskDelete.py
            * [x]  taskHandler.py
            * [x]  taskPreprocess.py
            * [x]  taskCreate.py
            * [x]  taskGet.py
            * [x]  taskMonitor.py
    * [ ]  analyze：
        * [x]  解决`felucca`遗留的全局变量问题
        * [ ]  子模块划分：TODO
    * [ ]  将`asset`集成在四大模块中
* [ ]  移除无用代码
* [ ]  使用`pipreqs`自动生成`requirements.txt`

## 参与者

Assignee： @yeluyang 

Reviewer： @ruanjiabin @gaobin @suntao 

* [ ] test
* [x] test2:
    * [ ] test3
        * [ ] test4
1. test:
    1. test:
        1. test:
            1. test:
            2. test:
                1. test:
                1. test
                1. test:
                