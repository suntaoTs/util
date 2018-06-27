#!/usr/bin/python

# -*- coding: utf-8 -*-

import requests
import sys


delete_argument = " ip taskid|delall"

def deleteTask(taskID, ip):
    url = "http://" + ip + "/Task/DeleteTask?ProjectID=1000"
    params = {
        "taskID": taskID
    }
    headers = {'ContentType': 'application/json'}
    r = requests.post(url, headers=headers, json=params)
    response = eval(r.content.decode("utf-8"))
    print(response)

def deleteAllTasks(ip):
    url = "http://" + ip + "/Task/QueryResource?ProjectID=1000"
    headers = {'ContentType': 'application/json'}
    r = requests.get(url, headers=headers)
    response = eval(r.content.decode("utf-8"))
    if response.has_key('taskIds'):
        print(response['taskIds'])
        for taskId in response['taskIds']:
            deleteTask(taskId, ip)
    else:
        print("no taskids")

# def delete(taskid):
#     url = "http://172.20.2.199:80/Task/DeleteTask"

#     headers = {'ContentType': 'application/json'}
#     param = {
#         "taskID": taskid
#     }
#     rsp = requests.post(url, headers=headers, json=param)
#     print(rsp.content)

def Usage():
    str = "argument error:\nUsage: python " + sys.argv[0] + delete_argument
    print (str)
    return

def main():
    if len(sys.argv) <  3 :
        Usage()
        sys.exit(0)

    ip = sys.argv[1]

    if sys.argv[2] == 'delall':
        deleteAllTasks(ip)
    elif sys.argv[2] == 'taskid':
        deleteTask(sys.argv[1], ip)

if __name__ == '__main__':
    main()

