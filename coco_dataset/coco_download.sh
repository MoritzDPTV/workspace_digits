#!/bin/bash



## Config

# Name of category (can be looked up at cocodataset.org/#explore)
category=keyboard

# Directory name of the folder for train\val folders for the images and labels
# To create a directory for each category, include it in the name: 'directory=coco_$category'
directory=training

# Process option (0 process both, 1 process train, 2 process val)
opt=0

# Name of train datatype
data_train=train2017

# Name of val datatype
data_val=val2017



# Creates workspace if doesn't exist yet
mkdir $directory/train/images $directory/train/labels -p
mkdir $directory/val/images $directory/val/labels -p


# Gathers train and optional val
if [ $opt -eq 0 -o $opt -eq 1 ]
then
	echo "Gathering 'train' labels and images..."

	# Creates temporary workspace
	mkdir temp -p
	cd temp
	wget https://raw.githubusercontent.com/dusty-nv/jetson-inference/L4T-R27.1/tools/coco2kitti.py

	# Modifies the script
	sed -i "52s/.*/    dataType = '$data_train'/" coco2kitti.py
	sed -i "60s/.*/    catNms = ['$category']/" coco2kitti.py

	# Executes the script
	python coco2kitti.py

	# Copies the labels in the right directory and deletes the script folder
	cd ..
	mkdir $directory/train/labels/$category -p
	cp temp/labels/*  $directory/train/labels/$category/
	rm -r temp
	echo "Labels of '$category' have been added to train/labels/$category."

	# Copies the corresponding images in the right directory
	mkdir $directory/train/images/$category -p
	echo "Copying corresponding images..."
	for file in $directory/train/labels/$category/*
	do
		filename=$(basename $file .txt)
		new_file="$filename.jpg"
		cp images/train2017/$new_file $directory/train/images/$category/
	done
	echo "Images copied to train/images/$category."

	# Same for val if option for both taken
	if [ $opt -eq 0 ]
	then
		echo -e "\n\nGathering 'val' labels and images..."
		mkdir temp
		cd temp
		wget https://raw.githubusercontent.com/dusty-nv/jetson-inference/L4T-R27.1/tools/coco2kitti.py
		sed -i "52s/.*/    dataType = '$data_val'/" coco2kitti.py
		sed -i "60s/.*/    catNms = ['$category']/" coco2kitti.py
		python coco2kitti.py
		cd ..
		mkdir $directory/val/labels/$category -p
		cp temp/labels/*  $directory/val/labels/$category/
		rm -r temp
		echo "Labels of '$category' have been added to val/labels/$category."
		mkdir $directory/val/images/$category -p
		echo "Copying corresponding images..."
		for file in $directory/val/labels/$category/*
		do
			filename=$(basename $file .txt)
			new_file="$filename.jpg"
			cp images/val2017/$new_file $directory/val/images/$category/
		done
		echo "Images copied to val/images/$category."
	fi

# Gathers only val
elif [ $opt -eq 2 ]
then
	echo "Gathering 'val' labels and images..."
	mkdir temp -p
	cd temp
	wget https://raw.githubusercontent.com/dusty-nv/jetson-inference/L4T-R27.1/tools/coco2kitti.py
	sed -i "52s/.*/    dataType = '$data_val'/" coco2kitti.py
	sed -i "60s/.*/    catNms = ['$category']/" coco2kitti.py
	python coco2kitti.py
	cd ..
	mkdir $directory/val/labels/$category -p
	cp temp/labels/*  $directory/val/labels/$category/
	rm -r temp
	echo "Labels of '$category' have been added to val/labels/$category."
	mkdir $directory/val/images/$category -p
	echo "Copying corresponding images..."
	for file in $directory/val/labels/$category/*
	do
		filename=$(basename $file .txt)
		new_file="$filename.jpg"
		cp images/val2017/$new_file $directory/val/images/$category/
	done
	echo "Images copied to val/images/$category."

# Case chosen option doesn't exist
else
	echo "Choose a valid option."
fi
