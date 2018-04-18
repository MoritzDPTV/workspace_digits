import urllib.request
import numpy as np
import cv2
import os



## Config

# Name of the category and its future directory
directory_name = 'keyboard'

# Name of the directory where all the cotegories shall be safed in
main_directory = 'train'

# Where the number of the picture names starts counting from
pic_num = 1

# Size of the downloaded images
img_height = 256
img_width = 256

# Color of the downloaded images (0 for grayscale, 1 for original colors)
img_flag = 1

# Download source (0 to download from url, 1 to download from file)
urls_source = 0

# Image-net url with urls (only used for urls_source = 0)
urls_url = 'http://image-net.org/api/text/imagenet.synset.geturls?wnid=n03614007'

# File with urls (only used for urls_source = 1)
urls_file = 'urls.txt'



# Downloads and converts all images from links from the link or the file
def store_images():
	global pic_num, img_flag, img_height, img_width, urls_source, directory_name

	# Checks which download source to use and grabs the links
	if urls_source == 0:
		images_urls = urllib.request.urlopen(urls_url).read().decode()
	else:
		UrlListFile = open(urls_file)
		images_urls = UrlListFile.read()
		UrlListFile.close()

	# Creates folders for the work environment
	if not os.path.exists(main_directory):
		os.makedirs(main_directory)
	if not os.path.exists(main_directory+'/'+directory_name):
		os.makedirs(main_directory+'/'+directory_name)

	# Processes the links
	for i in images_urls.split('\n'):
		try:
			print(i)
			urllib.request.urlretrieve(i, os.path.join(main_directory+'/'+directory_name, "{:04}".format(pic_num)+".jpg"))
			statinfo = os.stat(os.path.join(main_directory+'/'+directory_name, "{:04}".format(pic_num)+".jpg"))

			if statinfo.st_size > 140:
				img = cv2.imread(os.path.join(main_directory+'/'+directory_name, "{:04}".format(pic_num)+".jpg"), img_flag)
				img.shape
				resized_image = cv2.resize(img, (img_height, img_width))
				cv2.imwrite(os.path.join(main_directory+'/'+directory_name, "{:04}".format(pic_num)+".jpg"), resized_image)
				pic_num += 1

			else:
				print('Invalid link skipped.')

		# For the case the image caused an error, it will be removed if it exists as file
		except:
			try:
				os.remove(os.path.join(main_directory+'/'+directory_name, "{:04}".format(pic_num)+".jpg"))
			except:
				pass

			print('Invalid link skipped.')


# Finds and deletes images you don't want in the dataset, which you have to copy once in the folder invalids
def delete_invalids():
	global directory_name
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			for invalid in os.listdir('invalids'):
				try:
					current_image_path = str(file_type)+'/'+str(img)
					question = cv2.imread(current_image_path)
					invalid = cv2.imread('invalids/'+str(invalid))
					if invalid.shape == question.shape and not(np.bitwise_xor(invalid,question).any()):
						os.remove(current_image_path)
						print('Invalid image '+current_image_path+' deleted.')

				except:
					pass


# Renames the images for a proper order
def rename_images():
	global pic_num, directory_name
	pic_num = 1

	# Renames the images and includes the term 'temp' to the name - to avoid overwriting
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			os.rename(str(file_type)+'/'+str(img), str(file_type)+'/'+"{:04}".format(pic_num)+"temp"+".jpg")
			pic_num += 1

	# Renames the files back to 4 digits only
	pic_num = 1
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			os.rename(str(file_type)+'/'+str(img), str(file_type)+'/'+"{:04}".format(pic_num)+".jpg")
			pic_num += 1


# Creates texts files listing the images with their paths, and labels
def create_textfiles():
	global directory_name

	# Full path to the directory a Python file is contained in
	dir_path = os.path.dirname(os.path.realpath(__file__))

	# Images path and their label text file
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			current_image_path = str(file_type)+'/'+str(img)
			line = dir_path+'/'+current_image_path+' '+directory_name+' '+'\n'
			with open(os.path.join(main_directory+'/','train.txt'), 'a') as txt:
				txt.write(line)

	# Lable text file
	line = directory_name+'\n'
	with open(os.path.join(main_directory+'/','labels.txt'), 'a') as txt:
		txt.write(line)



store_images()
delete_invalids()
rename_images()
#create_textfiles()
