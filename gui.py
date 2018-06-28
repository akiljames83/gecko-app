'''
Gecko v1.2
'''
import tkinter as tk
from tkinter import *
from tkinter import ttk
import os
import time
import PyPDF2 as pdf
import re
pdf_files, folder_tups, fraud_list, fraud_accounts,zip_list = [], [], [], [], []
global_zip_files,clean_zip,saved = [], [], []
fraud_count, num_of_nums = 0, 0

LARGE_FONT = ("Verdana",12)

def cleared():
	print("Cleared...")

# Import File Check Functions
def strip(text):
	global zip_list
	phone_nums_stripped, phone_nums_unique =[], []

	phone_nums = re.findall(r'\w\d{3}\s\d{3}\D\d{4}\w',text)
	for e in phone_nums:
		h = e[1:-1]
		phone_nums_stripped.append(h)

	for i in phone_nums_stripped:
		if i not in phone_nums_unique:
			phone_nums_unique.append(i)
	
	for el in phone_nums_unique:
		val = phone_nums_stripped.count(el)
		zip_list.append(([el,val]))

def scrape(index,query_a,query_b):
	global folder_tups,fraud_count,fraud_list
	file_fraud_count = 0

	n_file = pdf_files[index] #name of file and the number
	doc_tups = [n_file,query_a[2:]]
	file = open(n_file, 'rb')
	pdfobj = pdf.PdfFileReader(file)

	for i in range(pdfobj.getNumPages()):
		text = pdfobj.getPage(i).extractText()
		strip(text) 
		occurences = (text.count(query_a)+text.count(query_b))
		fraud_count += occurences
		file_fraud_count += occurences

		#  Page Num ; Num Occurences in Page
		tup = ("Page: {}".format(i+1),
			"Num Occurences: {}".format(occurences))
		doc_tups.append(tup) # adds occurences per page

	folder_tups.append(doc_tups)
	file.close()
	if (file_fraud_count>1):
			fraud_list.append('Triggered')
			fraud_accounts.append(n_file)

def run(_input):
	q_list = str(_input)
	print("Started")
	global pdf_files, folder_tups, fraud_list, fraud_accounts, zip_list, global_zip_files, clean_zip, saved, fraud_count, num_of_nums
	q = q_list.replace('(',"").replace(')'," ").replace("\n","").replace("-","")
	q_list_formatted = q.split(",")
	num_of_nums = len(q_list_formatted)
	for i in range(len(q_list_formatted)):
		print(len(q_list_formatted[i]))
		if len(q_list_formatted[i]) != 11:
			print("'",q_list_formatted[i], "'")
			while(len(q_list_formatted[i]) != 11):
				print(q_list_formatted[i],".")
				if q_list_formatted[i][0] == " ":
					print("here")
					q_list_formatted[i]=q_list_formatted[i][1:]
					print("In loop ",q_list_formatted[i])
				elif q_list_formatted[i][-1] == " ":
					print("elif")
					q_list_formatted[i]=q_list_formatted[i][:-1]
					print("In loop ",q_list_formatted[i])
				if len(q_list_formatted[i]) == 11:
					break
			print(q_list_formatted[i])
		if len(q_list_formatted[i]) < 11:
			del q_list_formatted[i]
	# all_nums = q_list_formatted.split(",")
	query = []
	for each in q_list_formatted:
		query.append(['am'+each,'pm'+each])
	print(query)
	t1 = time.time() # time check
	os.chdir("PDF_files") # enter directory

	# Setup number for pdf files to scrape
	pdf_files, folder_tups, fraud_list, fraud_accounts,zip_list = [], [], [], [], []
	fraud_count = 0
	contents = os.listdir()
	for content in contents:
		if content[-4:] == '.pdf':
			pdf_files.append(content)

	# Looping over data
	global_zip_files = []
	for i in range(len(pdf_files)): 
		for j in range(len(query)):
			query_a, query_b = query[j][0], query[j][1]
			scrape(i,query_a,query_b)
		

	# Clean up stripped data:
	clean_zip = []
	saved = []
	for i in zip_list:
		if i[0] not in str(clean_zip):
			clean_zip.append(i)
			saved.append(i[0])
		elif i[0] in str(clean_zip):
			c = []
			b = (str(clean_zip).replace("[","").replace("]","")).split(", ")[0::2]
			index = saved.index(i[0]) # get clean zip at index
			clean_zip[index][1] += i[1]

	clean_zip_organized = sorted(clean_zip,key=lambda l:l[1])

	# print first 5 in clean_zip_organized, append first 10 to seperate text doc, include try except statement
	os.chdir("..")
	if (not os.path.isdir('Results')):
		os.mkdir('Results')
	os.chdir('Results')
	t2 = time.time()
	time_elapsed = round(t2 - t1,2)
	for i in range(1): # summary for each number
		with open("Job_recap_clone{}.txt".format(i+1),"w") as t:
			for folder_tup in folder_tups:
				_in = "Document {}: ".format(folder_tups.index(folder_tup)+1) + str(folder_tup) +'\n'
				t.write(_in)
			__in = "The following files are fraudulent: " + str(fraud_accounts)
			t.write(__in)

	# adjust zip numbers
	for i in range(5):
		clean_zip[i][1] = int(clean_zip[i][1]/num_of_nums)

	# summary for the num counts
	with open("number_summary.txt","w") as t:

		_in = str((clean_zip[0]))
		_in+='\n' + str(clean_zip[1]) + '\n' + str(clean_zip[2]) + '\n' + str(clean_zip[3]) + '\n' + str(clean_zip[4])
		t.write(_in)
		# maybe include try except for IndexError:, not likely though cause not many calling less than 5

	return "Time elapsed: {} seconds.".format(time_elapsed)
# Define Class for Gecko Application
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
		#buttonClear.pack(pady=10,padx=10)
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