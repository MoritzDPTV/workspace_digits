# Workspace for DNNs
This workspace serves to download and organize images for example from *image-net.org* or *cocodataset.org* to build and extend a dataset needed to train DNN models. If you are planning to use DIGITS, I recommend to follow [this guide](https://github.com/dusty-nv/jetson-inference).

## Build a workspace
As we will have to download many images and datasets of images and the Jetsons memory is limited, this workspace rather should be placed on another device such as your host computer. If you are planning then to build the models and its datasets on the Jetson, you can just copy the image source folder of interest to it.


To get started, first download a raw example of the workspace, which includes all the scripts:

```sh
$ cd ~/
$ git clone https://github.com/MoritzDPTV/workspace_dnn.git
```


Note: To keep things simple all parameters that can or have to be configured can be found at the beginning of each script.



### ImageNet
To train a model **for object classification**, we need a bunch of images. Therefore websites like 'image-net.org' are giving us a hand. This website for example provides hundreds and thousands of images hierarchically organized consisting of nodes for all the different categories of objects it supplies images of.

With the 'images\_download.py' script you can download images of your desired category, either from a text files which contains the links of the images or from an url containing these links. The images then will be downloaded, resized, filtered, renamed and saved in an appropriate directory. Sometimes it happens, that links aren't valid anymore and are showing an image saying this. These kind of images you don't wish to have in your dataset, wherefore you can copy an example of these invalid images into the folder 'invalids', which you will find in the same directory as the script, and run the script again with the 'store\_images( )' function commented.

To run the script go into the 'images\_dataset' directory, modify the scripts beginning and execute it:

```sh
$ cd ~/workspace_digits/imagenet
$ python3 imagenet_download.py
```


Besides this script to download images, you will find another script with the name 'data\_augmentation.py' in the same directory, which you can use to extend your dataset. This script will first rename your images to ensure there will be no overwriting, then format them by cutting of their ends to have them square, resize them to your desired size, apply two gamma operations to create an additional bright and a dark version of each image, mirror all those images and then rename them once again.

As before, to run this script modify the script's beginning and execute it:

```sh
$ cd ~/workspace_dnn/images_dataset
$ nano data_augmentation.py
$ python3 data_augmentation.py

```



### COCO
'COCO' is a large image dataset designed **for object detection and segmentation**. As well it provides hundreds and thousands of images, though organized in a different way as image-net.org: here the image dataset has a corresponding annotation dataset.
A format called 'KITTI' often is used for object detection data, for example by DIGITS, which is why the source images must be organized in a certain way. This format requires label text files corresponding to each single image. Jon Barker wrote a script called 'coco2kitti.py' which converts COCO annotation files to KITTI format bounding box label files.


To use this script we need the COCO API library to be installed:

```sh
$ cd ~/
$ git clone https://github.com/cocodataset/cocoapi.git
$ cd cocoapi/PythonAPI
$ make -j"$(nproc)"
$ sudo make install
$ sudo python setup.py install
$ cd ~/
$ sudo rm -r cocoapi
```


Furthermore the script uses the COCO dataset of the images and its annotations which must be downloaded from 'cocodataset.org'. We will use the dataset of 2017:

```sh
$ cd ~/workspace_dnn/coco_dataset
$ wget images.cocodataset.org/annotations/annotations_trainval2017.zip
$ unzip annotations_trainval2017.zip
$ rm annotations_trainval2017.zip
$ mkdir images
$ cd images
$ wget images.cocodataset.org/zips/train2017.zip
$ wget images.cocodataset.org/zips/val2017.zip
$ unzip train2017.zip
$ rm train2017.zip
$ unzip val2017.zip
$ rm val2017.zip
```

In total the datasets will require about 21GB of memory.


Now we can use the 'coco\_download.sh' script which will modify and run the coco2kitti.py script, save the label files it gathered in an appropriate directory and copy the corresponding images out of the dataset as well to the appropriate directory.

To run this script, modify the scripts beginning and execute it. Enter therefore:

```sh
$ cd ~/workspace_dnn/coco_dataset
$ nano coco_download.sh
$ ./coco_download.sh
```



### Network
The directory 'networks' is supposed to be used to store your trained DNN models. Besides this you will find there a script called 'network\_test.sh'. This you can use to test your in DIGITS trained DNN models using the jetson-inference runtime library. In the beginning of its code, as always, you can define some parameters, such as which kind of network you want to use, which of your DNN models shall be included and weather you want to use the console to analyse an image or the camera to deploy live inference. You can also go into the original directory of the jetson-inference to run the consoles and enter everything by hand, but for a fast workflow this script is useful and can be modified and launched by entering:

```sh
$ cd ~/workspace_dnn/networks
$ nano network_test.sh
$ ./network_test.sh
```

Note: Using the option for object detection or segmentation will require an editing of the 'deploy.prototxt' file from your DNN, as this is needed for compatibility. Therefore in the script an option to do this automatically is included. In case you use it, an edited version of the file will be created and then used to launch the DNN.
