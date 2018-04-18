import numpy as np
import cv2
import os



## Config

# Name of the category and its future directory
directory_name = 'test'

# Name of the directory where all the cotegories shall be safed in
main_directory = 'train'



# Formats the images by cutting of its ends to have it square
def format_images():
	global directory_name
	pic_num = 1
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			image = cv2.imread(os.path.join(main_directory+'/'+directory_name, img), 1)
			h, w = image.shape[:2]
			cut_borders = round(0.5 * (w - h))
			roi = image[0:h, cut_borders:(w - cut_borders)]
			cv2.imwrite(os.path.join(main_directory+'/'+directory_name, 'formated'+str(pic_num)+'.jpg'), roi)
			os.remove(os.path.join(main_directory+'/'+directory_name, img))
			pic_num += 1


# Resizes the images
def resize_images():
	global directory_name
	pic_num = 1
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			image = cv2.imread(os.path.join(main_directory+'/'+directory_name, img), 1)
			resized = cv2.resize(image, (256, 256), interpolation=cv2.INTER_AREA)
			cv2.imwrite(os.path.join(main_directory+'/'+directory_name, 'resized'+str(pic_num)+'.jpg'), resized)
			os.remove(os.path.join(main_directory+'/'+directory_name, img))
			pic_num += 1


# Predefinition of the gamma function
def gamma_configuration(image, gamma=1.0):
   invGamma = 1.0 / gamma
   table = np.array([((i / 255.0) ** invGamma) * 255
      for i in np.arange(0, 256)]).astype("uint8")

   return cv2.LUT(image, table)


# Creates a darker and a brighter version of the images
def light_images():
	global directory_name, img_height, img_width
	pic_num = 1
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			original = cv2.imread(os.path.join(main_directory+'/'+directory_name, img), 1)
			gamma_bright = 2.5
			brightened = gamma_configuration(original, gamma=gamma_bright)
			cv2.imwrite(os.path.join(main_directory+'/'+directory_name, 'brightened'+str(pic_num)+'.jpg'), brightened)
			gamma_dark = 0.4
			darkened = gamma_configuration(original, gamma=gamma_dark)
			cv2.imwrite(os.path.join(main_directory+'/'+directory_name, 'darkened'+str(pic_num)+'.jpg'), darkened)
			pic_num += 1


# Mirrors the images
def mirror_images():
	global directory_name
	pic_num = 1
	for file_type in [main_directory+'/'+directory_name]:
		for img in os.listdir(file_type):
			image = cv2.imread(os.path.join(main_directory+'/'+directory_name, img), 1)
			mirrored = cv2.flip(image, 1)
			cv2.imwrite(os.path.join(main_directory+'/'+directory_name, 'mirrored'+str(pic_num)+'.jpg'), mirrored)
			pic_num += 1


# Renames the images for a proper order
def rename_images():
	global directory_name
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



rename_images()
format_images()
resize_images()
light_images()
mirror_images()
rename_images()
