#!/usr/bin/env python3

age = input("name: \n")
print(type(age))
age = int(age)
print(type(age))
if age < 100 :
    print(age)
else:
    print("too old")

a = ord('测')
print(a)
b = chr(33)
print(b)

a = '中文'.encode()
print(a)
print(a.decode())

print('hi %s , you have %d' %('suntao', 10000))

classmates = ['sun', 'aks', 'sts']
print(classmates[-1], classmates[-2])
classmates.pop()

c = ('sdfkj', 'sfkj', ';afkjds')
print(c)
print(c.__sizeof__(), len(c))

c = list(range(100))
sum = 0
for i in c:
    sum = sum + i
print(sum)



from tkinter import *
import tkinter.messagebox as messagebox

class Application(Frame):
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.pack()
        self.createWidgets()

    def createWidgets(self):
        self.nameInput = Entry(self)
        self.nameInput.pack()
        self.alertButton = Button(self, text='Hello', command=self.hello)
        self.alertButton.pack()

    def hello(self):
        name = self.nameInput.get() or 'world'
        messagebox.showinfo('Message', 'Hello, %s' % name)

app = Application()
# 设置窗口标题:
app.master.title('Hello World')
# 主消息循环:
app.mainloop()