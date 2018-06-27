#!/usr/bin/python3
# -*- coding: utf-8 -*-

import requests
import sys
def Usage():
    print("argument error:\nUsage: " + sys.argv[0] + " filepath|rtsp")

url="http://172.20.2.199:80/Task/CreateTask?ProjectID=1000"
#url="http://127.0.0.1:8765/Task/CreateTask?ProjectID=1000"

if len(sys.argv) < 2:
    Usage()
    sys.exit(0)

file_path = sys.argv[1]

headers = {'Content-Type': 'application/json'}
params_videofile = {
        "taskType":0,
        "param": {      
        "Source": {

                "UserName" : "anonymou ",
                "DeviceIP" : "172.20.2.102",
                "DevicePort" : 80,
                "SourceType" : 0,
                "VideoFile" : file_path,
                "LoopPlay" : 1

        }, 
        "Result" : [
            {
                "Index" : 0,
                "ProtocolType" : 10,
                "URL" : "172.20.4.95:8765/receiver",
                "FilterNoImg": 1
            },
            {
                "Index" : 1,  
                "ProtocolType" : 10,
                "URL" : "172.20.4.95:8765/receiver",
                "FilterNoImg": 1 
            }
        ],
        "Private": 
        {
            "targets": [
                {"dbId":"disturb","score":0.8}
            ]
        }
    }
}
params_rtsp = {
    "taskType":0,
	    "param": {      
        "Source": {
 
	            "UserName" : "anonymous",
	    		"DeviceIP" : "172.20.2.102",
				"DevicePort" : 80,
	            "SourceType" : 2, 
	            "RtspUrl" : "rtsp://admin:admin1234@172.20.101.173:554",
	            "LoopPlay" : 1

        }, 
        "Result" : [
            {
                "Index" : 0,
                "ProtocolType" : 10,
                "URL" : "172.20.4.95:8765/receiver",
                "FilterNoImg": 1
            },
            {
                "Index" : 1,  
                "ProtocolType" : 10,
                "URL" : "172.20.4.95:8765/receiver",
                "FilterNoImg": 1 
            }
        ],
        "Private": 
        {
            "targets": [
                {"dbId":"disturb","score":0.8}
            ]
        }
    }
}
if sys.argv[1] == 'rtsp':
    params = params_rtsp
else:
    params = params_videofile
    

print(params)
r = requests.post(url, headers=headers, json=params)
response = eval(r.content.decode("utf-8"))
print(response)

# parameters={'wd':"abc"}

# #提交get请求
# P_get=requests.get(url,params=parameters)
# #提交post请求
# P_post=requests.post(url,headers=headers,data=post_data)

# import urllib
# import urllib2
# import json

# # 发起请求的url
# post_url = 'http://www.baidu.com';

# postData = {'a': 'aaa', 'b': 'bbb', 'c': 'ccc', 'd': 'ddd'}
# # json序列化
# data = json.dumps(postData)

# req = urllib2.Request(post_url)
# response = urllib2.urlopen(req, urllib.urlencode({'sku_info': data}))

# # 打印返回值
# print response.read()