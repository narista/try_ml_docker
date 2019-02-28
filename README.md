I am writing this article to share the solution as I faced an issue when I tried to build minimum docker image that had Python and OpenCV to run a model of machine learning. This issue only happens if you use minimum linux image like ```python:3.6.8-slim-stretch```. You will not face this issue if you use full docker image like ```python:3.7.2-stretch```. However, I think every docker users want to use smaller size of image when they build their own docker images for the validation or production use.

# Issue

I tried to run the following simple python program in the docker container. I installed the necessary libraries with pip and then it shows the version number of each imported library.

```Python
import keras
import tensorflow
import numpy
import PIL
import cv2

print('keras:', keras.__version__)
print('tensorflow:', tensorflow.__version__)
print('numpy:', numpy.__version__)
print('pillow:', PIL.__version__)
print('cv2:', cv2.__version__)
```

I got following error that one of the dependencies that opencv-python using is not found.

```shell
Traceback (most recent call last):
  File "version.py", line 5, in <module>
    import cv2
  File "/usr/local/lib/python3.6/site-packages/cv2/__init__.py", line 3, in <module>
    from .cv2 import *
ImportError: libgthread-2.0.so.0: cannot open shared object file: No such file or directory
```

# Solution

This error message means ```pip install opencv-python``` itself worked fine but Python could not find a dependency. I googled with the key word "docker pip opencv" but almost all article say "Let's write a script in the DockerFile to download source code and then compile it". I really disappointed.

I was confused about the issue as I could install and run the program that uses OpenCV in my Mac only using pip to insatll. However, I found OpenCV is a native library and the opencv-python is just a wrapper.

Therefore, I thought I could resolve the dependency error if I installed the native OpenCV library first, and then install the opencv-python library by pip. I finally resolve this issue after I wrote the following DockerFile to install OpenCV library via apt-get.

```DockerFile
# Replace this line to use python official image as a base.
FROM python:3.6.8-slim-stretch

LABEL Name=try_ml_docker Version=0.0.1
EXPOSE 50000

# Add the following line to get native library of OpenCV.
RUN apt-get update && apt-get install -y libopencv-dev

WORKDIR /app
# Replace this line to copy requirements.txt inside the docker image.
ADD ./requirements.txt /app

RUN python3 -m pip install -r requirements.txt
CMD ["python3", "-m", "try_ml_docker"]
```

I wrote the following lines in the requirements.txt. We need to use the following version of keras and tensorflow if we use coremltools version 2.0 since it heavily depends on the version of keras and tensorflow. We can use any version for any other libraries.

```text
coremltools==2.0
keras==2.1.6
tensorflow==1.5.0
numpy
pillow
opencv-python
```

# Tips

I would like to share the sorce code and the dataset between the container and VS Code project directory on the host. That is why I use "-v" option in the docker run command, and set it to ¥`pwd¥`to get the absolute path to the current directory.

```shell
$ docker run -v `pwd`:/app -it -d try_ml_docker:latest /bin/bash
```

[Written in Japanese](README_ja.md)