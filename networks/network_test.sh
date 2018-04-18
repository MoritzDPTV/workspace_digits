#!/bin/sh



## Config

# Path to the executables of the jetson_inference project
path=/home/nvidia/inference/build/aarch64/bin

# Path to your network model files
network=$PWD/network01

# Name of your the caffemodel snapshot
caffemodel=snapshot_iter_1337.caffemodel

# Analysis option (1 for object classification, 2 for detection, 3 for segmentation)
opt=1

# Mode that shall be used (1 for console (using image), 2 for camera)
mode=2

# Option to define whether the 'deploy.prototxt' file shall be edited or not (1 to edit it, 2 to keep it original)
edit=1

# Image that shall be classified (only used for mode=1)
image=$PWD/image_samples/keyboard_0.jpg

# Output image with result (only used for mode=1)
output=$PWD/image_samples/output_0.jpg



# Object classification
if [ $opt -eq 1 ]
then
	# Image analysis
	if [ $mode -eq 1 ]
	then
		# Loads the the model in the imagenet-console
		cd $path
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
		cd $path
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
	# Edits the 'deploy.prototxt' file and uses the edited version to run the model
	if [ $edit -eq 1 ]
	then
		# Writes a new 'deploy.prototxt' editing the layers to avoid compatibility issues
		sed -n -e :a -e '1,12!{P;N;D;};N;ba' $network/deploy.prototxt > $network/deploy.prototxt_new

		deploy_prototxt=deploy.prototxt_new

	# Uses the original 'deploy.prototxt' file
	elif [ $edit -eq 2 ]
	then
		deploy_prototxt=deploy.prototxt

	# Case chosen mode doesn't exist
	else
		echo "Choose a valid mode."
	fi


	# Image analysis
	if [ $mode -eq 1 ]
	then
		# Loads the the model in the detectnet-console
		cd $path
		./detectnet-console $image $output \
		--prototxt=$network/$deploy_prototxt \
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
		cd $path
		./detectnet-camera \
		--prototxt=$network/$deploy_prototxt \
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
	# Edits the 'deploy.prototxt' file and uses the edited version to run the model
	if [ $edit -eq 1 ]
	then
		# Writes a new 'deploy.prototxt' editing the layers to avoid compatibility issues
		sed -n -e :a -e '1,30!{P;N;D;};N;ba' $network/deploy.prototxt > $network/deploy.prototxt_new
		sed -i 's/    pad: 100/    pad: 0/' $network/deploy.prototxt_new

		deploy_prototxt=deploy.prototxt_new

	# Uses the original 'deploy.prototxt' file
	elif [ $edit -eq 2 ]
	then
		deploy_prototxt=deploy.prototxt

	# Case chosen mode doesn't exist
	else
		echo "Choose a valid mode."
	fi


	# Image analysis
	if [ $mode -eq 1 ]
	then
		# Loads the the model in the segnet-console
		cd $path
		./segnet-console $image $output \
		--prototxt=$network/$deploy_prototxt \
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
		cd $path
		./segnet-camera \
		--prototxt=$network/$deploy_prototxt \
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
