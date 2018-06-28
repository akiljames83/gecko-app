'''
Gecko v1.2
'''
import os
import time
import PyPDF2 as pdf
import re
pdf_files, folder_tups, fraud_list, fraud_accounts,zip_list = [], [], [], [], []
global_zip_files,clean_zip,saved = [], [], []

# Import File Check Functions
cpdef str h
cdef int val
def strip(str text):
	global zip_list, h,val
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
	val = 0
	h = ""

cdef int file_fraud_count
cpdef str n_file 
cpdef str text
cdef int i
cdef int occurences
def scrape(int index,str query_a,str query_b):
	global folder_tups,fraud_count,fraud_list,file_fraud_count,n_file,text,i,occurences
	file_fraud_count = 0

	n_file = pdf_files[index] #name of file and the number
	doc_tups = [n_file,query_a[2:]]
	file = open(n_file, 'rb')
	pdfobj = pdf.PdfFileReader(file)
	i = 0
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

cpdef str q_list
cpdef str q
cdef int num_of_nums = 0
cdef float t1
cdef int fraud_count = 0
cdef float t2
cpdef str __in 
cpdef str _in
cpdef int list_length
cpdef int counter = 0
def run(str _input):
	global q_list,q,pdf_files, folder_tups, fraud_list, fraud_accounts, zip_list, global_zip_files, clean_zip, saved, fraud_count, num_of_nums,i,t1,fraud_count,t2, __in, _in, counter, list_length
	q_list = str(_input)
	q = q_list.replace('(',"").replace(')'," ").replace("\n","").replace("-","")
	q_list_formatted = q.split(",")
	num_of_nums = len(q_list_formatted)
	i = 0
	delete_list = []
	for i in range(len(q_list_formatted)):
		if len(q_list_formatted[i]) < 11:
			delete_list.append(i)
			continue
		if len(q_list_formatted[i]) != 11:
			counter = 0
			while(len(q_list_formatted[i]) != 11):
				if q_list_formatted[i][0] == " ":
					q_list_formatted[i]=q_list_formatted[i][1:]
				elif q_list_formatted[i][-1] == " ":
					q_list_formatted[i]=q_list_formatted[i][:-1]
				if len(q_list_formatted[i]) == 11:
					break
				counter += 1
				if counter > 4:
					delete_list.append(i)
					counter = 0
					break
	list_length = len(delete_list) - 1
	if list_length+1 >0:
		for i in range(list_length+1):
			del q_list_formatted[list_length-i]
	# all_nums = q_list_formatted.split(",")
	query = []
	print(q_list_formatted)
	if len(q_list_formatted) == 0:
		return "Invalid input."
	for each in q_list_formatted:
		query.append(['am'+each,'pm'+each])
	t1 = time.time() # time check
	try:
		os.chdir("PDF_files") # enter directory
	except FileNotFoundError:
		return "'PDF_files' not in current working directory."

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
	#cdef int i
	for each in zip_list:
		if each[0] not in str(clean_zip):
			clean_zip.append(each)
			saved.append(each[0])
		elif each[0] in str(clean_zip):
			c = []
			b = (str(clean_zip).replace("[","").replace("]","")).split(", ")[0::2]
			index = saved.index(each[0]) # get clean zip at index
			clean_zip[index][1] += each[1]

	clean_zip_organized = sorted(clean_zip,key=lambda l:l[1])

	# print first 5 in clean_zip_organized, append first 10 to seperate text doc, include try except statement
	os.chdir("..")
	if (not os.path.isdir('Results')):
		os.mkdir('Results')
	os.chdir('Results')
	t2 = time.time()
	time_elapsed = round(t2 - t1,2)
	i=0
	for i in range(1): # summary for each number
		with open("Job_recap_clone{}.txt".format(i+1),"w") as t:
			for folder_tup in folder_tups:
				_in = "Document {}: ".format(folder_tups.index(folder_tup)+1) + str(folder_tup) +'\n'
				t.write(_in)
			__in = "The following files are fraudulent: " + str(fraud_accounts)
			t.write(__in)

	# adjust zip numbers
	i=0
	for i in range(5):
		clean_zip[i][1] = int(clean_zip[i][1]/num_of_nums)

	# summary for the num counts
	with open("number_summary.txt","w") as t:

		_in = str((clean_zip[0]))
		_in+='\n' + str(clean_zip[1]) + '\n' + str(clean_zip[2]) + '\n' + str(clean_zip[3]) + '\n' + str(clean_zip[4])
		t.write(_in)

	return 'Results in the "Result" Folder.' + '\n\n' + 'Time elapsed: {} seconds.'.format(time_elapsed)