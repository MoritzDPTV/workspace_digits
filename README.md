# Workspace for DIGITS
This workspace serves to download and organize images from *image-net.org* and *cocodataset.org* to build and train DNN models in DIGITS v6.1.0, originally for a work with NVIDIAs Jetson TX1.
I recommend to use this workspace and to follow [this guide](https://github.com/dusty-nv/jetson-inference/tree/L4T-R27.1) to deploy deep learning.


## Build a workspace
As we will have to download many images and datasets of images and the Jetson TX1s memory is limited, this workspace rather should be placed on another device such as your host computer. If you are planning to build the DNN models and its datasets on the Jetson TX1, you can just copy the image source folder of interest to it.

To get started, first download a raw example of it, which includes the scripts:

```sh
$ cd ~/
$ git clone https://github.com/MoritzDPTV/workspace_digits.git
```

Note: To keep things simple all parameters that can or have to be configured can be found at the beginning of each script.


### ImageNet
To train a model **for object classification**, we need a bunch of images. Therefore 'ImageNet' gives us a hand. ImageNet is an image database providing hundreds and thousands of images hierarchically organized consisting of nodes for all the different categeories of objects it supplies images of.

Basically this workspace already contains what it needs to get started. Go into the *imagenet* directory, modify the scripts beginning then execute it:

```sh
$ cd ~/workspace_digits/imagenet
$ python3 imagenet_download.py
```

Images of your desired category, either from a text files links or from an url containing the links will now be downloaded, converted, resized and saved in an appropriate directory inside *imagenet/train*. This Script also contains a mirror function in case you wish to enlarge your dataset, which therefore must be uncommented at the scripts very end.


### COCO
'COCO' is a large image dataset designed **for object detection and segmentation**. As well it provides hundreds and thousands of images, though organized in a different way as ImageNet: the image dataset has a corresponding annotation dataset.

As DIGITS uses the 'KITTI' format for object detection data, the source images must be organized equally. This format requires label text files corresponding to each single image. Therefore Jon Barker wrote a script 'coco2kitti.py' which converts COCO annotation files to KITTI format bounding box label files.

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

Furthermore the script uses the dataset of the images and its annotations which must be downloaded from *cocodataset.org* in the right directories. We will use the dataset of 2017, feel free to choose another one:

```sh
$ cd workspace_digits/coco
$ wget images.cocodataset.org/annotations/annotations_trainval2017.zip
$ unzip annotations_trainval2017.zip
$ rm annotations_trainval2017.zip
$ cd images
$ wget images.cocodataset.org/zips/train2017.zip
$ wget images.cocodataset.org/zips/val2017.zip
$ unzip train2017.zip
$ rm train2017.zip
$ unzip val2017.zip
$ rm val2017.zip
```

In case the downloading takes very long, try to download it manually from your browser. This probably will safe some time. In total the datasets will require about 21GB of memory.

Now you finally can run the script, which uses the coco2kitti.py script in it:

```sh
$ cd ..
$ ./coco_download.sh
```

Your *train* and, if you chose so, your *val* directory will be found in a by the script created and by default called directory 'training'. Those you now can use to build a new object detection datasets in DIGITS.


### Network
The directory *network* is supposed to be used to store your trained DNN models from DIGITS. In addition you there will find a script called 'network_test.sh'. This you can use to test your DNN models. In the beginning of its code, as always, you can define some parameters, such as which kind of network you want to use, which of your DNN models shall be included and weather you want to use the console to analyse an image or the camera to run live inference. You can also go into the original directory of those consoles and enter everything by hand, but for a fast workflow, this script is useful and can be launched by entering:

```sh
$ cd ~/workspace_digits/networks
$ ./network_test.sh
```

Note: Using the option for object detection or segmentation will edit the *deploy.prototxt* of your model and safe it as a new file called *deploy.prototxt_new* which then will be used from the script to launch the DNN, as this is required for compatibility. That's why this step from the guide above, to edit the file by yourself, **must** be skipped.
