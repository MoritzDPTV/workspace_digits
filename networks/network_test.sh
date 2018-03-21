#!/bin/sh


## Config

# Path to your network model files
network=$PWD/Network01

# Name of your the caffemodel snapshot
caffemodel=snapshot_iter_1337.caffemodel

# Analysis option (1 for object classification, 2 for detection, 3 for segmentation)
opt=1

# Mode that shall be used (1 for console (using image), 2 for camera)
mode=1

# Image that shall be classified (only used for mode=1)
image=$PWD/keyboard_0.jpg

# Output image with result (only used for mode=1)
output=$PWD/output_0.jpg


# Object classification
if [ $opt -eq 1 ]
then
	# Image analysis
	if [ $mode -eq 1 ]
	then
		# Loads the the model in the imagenet-console
		cd /home/ubuntu/inference/build/aarch64/bin
		./imagenet-console $image $output \
		--prototxt=$network/deploy.prototxt \
		--model=$network/$caffemodel \
		--labels=$network/labels.txt \
		--input_blob=data \
		--output_blob=softmax

		# Shows the image
		eog $output

	# Camera analysis
	elif [ $mode -eq 2 ]
	then
		# Loads the the model in the imagenet-camera
		cd /home/ubuntu/inference/build/aarch64/bin
		./imagenet-camera \
		--prototxt=$network/deploy.prototxt \
		--model=$network/$caffemodel \
		--labels=$network/labels.txt \
		--input_blob=data \
		--output_blob=softmax

	# Case chosen mode doesn't exist
	else
		echo "Choose a valid mode."
	fi

# Object detection
elif [ $opt -eq 2 ]
then

# Writes a new 'deploy.prototxt' editing the layers to avoid compatibility issues
sed -n -e :a -e '1,12!{P;N;D;};N;ba' $network/deploy.prototxt > $network/deploy.prototxt_new

	# Image analysis
	if [ $mode -eq 1 ]
	then
		# Loads the the model in the detectnet-console
		cd /home/ubuntu/inference/build/aarch64/bin
		./detectnet-console $image $output \
		--prototxt=$network/deploy.prototxt_new \
		--model=$network/$caffemodel \
		--input_blob=data \
		--output_cvg=coverage \
		--output_bbox=bboxes

		# Shows the image
		eog $output

	# Camera analysis
	elif [ $mode -eq 2 ]
	then
		# Loads the the model in the detectnet-camera
		cd /home/ubuntu/inference/build/aarch64/bin
		./detectnet-camera \
		--prototxt=$network/deploy.prototxt_new \
		--model=$network/$caffemodel \
		--input_blob=data \
		--output_cvg=coverage \
		--output_bbox=bboxes

	# Case chosen mode doesn't exist
	else
		echo "Choose a valid mode."
	fi

# Object segmentation
elif [ $opt -eq 3 ]
then

# Writes a new 'deploy.prototxt' editing the layers to avoid compatibility issues
sed -n -e :a -e '1,30!{P;N;D;};N;ba' $network/deploy.prototxt > $network/deploy.prototxt_new
sed -i 's/    pad: 100/    pad: 0/' $network/deploy.prototxt_new

	# Image analysis
	if [ $mode -eq 1 ]
	then
		# Loads the the model in the segnet-console
		cd /home/ubuntu/inference/build/aarch64/bin
		./segnet-console $image $output \
		--prototxt=$network/deploy.prototxt_new \
		--model=$network/$caffemodel \
		--labels=$network/fpv-labels.txt \
		--colors=$network/fpv-training-colors.txt \
		--input_blob=data \
		--output_blob=score_fr

		# Shows the image
		eog $output

	# Camera analysis
	elif [ $mode -eq 2 ]
	then
		# Loads the the model in the segnet-camera
		cd /home/ubuntu/inference/build/aarch64/bin
		./segnet-camera \
		--prototxt=$network/deploy.prototxt_new \
		--model=$network/$caffemodel \
		--labels=$network/fpv-labels.txt \
		--colors=$network/fpv-training-colors.txt \
		--input_blob=data \
		--output_blob=score_fr

	# Case chosen mode doesn't exist
	else
		echo "Choose a valid mode."
	fi

# Case chosen option doesn't exist
else
	echo "Choose a valid option."
fi
