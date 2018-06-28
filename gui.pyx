'''
Gecko v1.2
'''
import tkinter as tk
from tkinter import *
from tkinter import ttk
from guiC import *


LARGE_FONT = ("Verdana",12)


class GeckoApp(tk.Tk):

	def __init__(self,*args,**kwargs):

		tk.Tk.__init__(self,*args,**kwargs)
		container = tk.Frame(self)

		container.pack(side="top",fill="both",expand = True)

		container.grid_rowconfigure(0, weight=1)
		container.grid_columnconfigure(0, weight=1)

		self.frames = {}

		frame = StartPage(container,self)

		self.frames[StartPage] = frame

		frame.grid(row=0,column=0,sticky="nswe")

		self.show_frame(StartPage)

	def show_frame(self,cont):
		frame = self.frames[cont]
		frame.tkraise()

class StartPage(tk.Frame):

	def __init__(self, parent, controller):
		tk.Frame.__init__(self,parent)
		label = ttk.Label(self, text="Gecko Application", font=LARGE_FONT)
		label.grid(row=0,column=1,columnspan=2,pady=10,padx=35)
		self.text = Text(self,font=LARGE_FONT,width=30, height=10)
		self.text.grid(row=1,column=0,padx=45,pady=(5,25),columnspan=4)#columnspan=4
		buttonClear = ttk.Button(self, text="Clear",command=self.clear)#, font=LARGE_FONT
		buttonCheck = ttk.Button(self, text="Check", command=self.check)
		buttonCheck.grid(row=2,column=1,padx=5,pady=1)
		buttonClear.grid(row=2,column=2,padx=5,pady=1)
	def check(self):
		_input = self.text.get("1.0",END)
		report= run(_input)
		self.clear()
		__input = 'Results in the "Result" Folder.' + '\n\n' + report
		self.text.insert(INSERT, __input)
		print(_input)
	def clear(self):
		self.text.delete('1.0',END)



app = GeckoApp()
app.title("GECKO v1.2")
app.wm_iconbitmap('gecko2.ico')
app.geometry("400x350") #You want the size of the app to be 500x500
app.resizable(0, 0) #Don't allow resizing in the x or y direction
app.mainloop()