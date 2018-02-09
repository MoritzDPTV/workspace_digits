import urllib.request
import numpy as np
import cv2
import os


## Config

# Name of the category and its future directory
directory_name = 'keyboard'

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
urls_url = 'http://www.image-net.org/api/text/imagenet.synset.geturls?wnid=n03085013'

# File with urls (only used for urls_source = 1)
urls_file = 'urls.txt'



# Downloads and converts all images from links from the link or the file
def store_images():
	global pic_num, img_flag, img_height, img_width, urls_source

	if urls_source == 0:
		images_urls = urllib.request.urlopen(urls_url).read().decode()
	else:
		UrlListFile = open(urls_file)
		images_urls = UrlListFile.read()
		UrlListFile.close()

	if not os.path.exists('train'):
		os.makedirs('train')

	if not os.path.exists('train/directory'):
		os.makedirs('train/directory')

	for i in images_urls.split('\n'):
		try:
			print(i)
			urllib.request.urlretrieve(i, "train/directory/"+"{:04}".format(pic_num)+".jpg")
			statinfo = os.stat("train/directory/"+"{:04}".format(pic_num)+".jpg")
			if statinfo.st_size > 140:
				img = cv2.imread("train/directory/"+"{:04}".format(pic_num)+".jpg", img_flag)
				img.shape
				resized_image = cv2.resize(img, (img_height, img_width))
				cv2.imwrite("train/directory/"+"{:04}".format(pic_num)+".jpg", resized_image)
				pic_num += 1
			else:
				print('Not a valid link.')
		except:
			try:
				os.remove("train/directory/"+"{:04}".format(pic_num)+".jpg")
			except:
				pass

			print('Not a valid link.')

	os.rename('train/directory', 'train/'+directory_name)


# Finds invalid images
def find_uglies():
	match = False
	for file_type in ['train/'+directory_name]:
		for img in os.listdir(file_type):
			for ugly in os.listdir('uglies'):
				try:
					current_image_path = str(file_type)+'/'+str(img)
					question = cv2.imread(current_image_path)
					ugly = cv2.imread('uglies/'+str(ugly))
					if ugly.shape == question.shape and not(np.bitwise_xor(ugly,question).any()):
						os.remove(current_image_path)
						print(current_image_path+' deleted.')

				except:
					pass


# Renames the images for a proper order
def rename_images():
	global pic_num
	pic_num = 1
	for file_type in ['train/'+directory_name]:
		for img in os.listdir(file_type):
			os.rename(str(file_type)+'/'+str(img), str(file_type)+'/'+"{:05}".format(pic_num)+".jpg")
			pic_num += 1

	pic_num = 1
	for file_type in ['train/'+directory_name]:
		for img in os.listdir(file_type):
			os.rename(str(file_type)+'/'+str(img), str(file_type)+'/'+"{:04}".format(pic_num)+".jpg")
			pic_num += 1


# Creates texts files listing the images with their paths, and labels (not necessary anymore)
def create_textfiles():
	# full path to the directory a Python file is contained in
	dir_path = os.path.dirname(os.path.realpath(__file__))

	for file_type in ['train/'+directory_name]:
		for img in os.listdir(file_type):
			current_image_path = str(file_type)+'/'+str(img)
			line = dir_path+'/'+current_image_path+' '+directory_name+' '+'\n'
			with open(os.path.join('train/','train.txt'), 'a') as txt:
				txt.write(line)
	line = directory_name+'\n'
	with open(os.path.join('train/','labels.txt'), 'a') as txt:
		txt.write(line)



store_images()
find_uglies()
rename_images()
#create_textfiles()
