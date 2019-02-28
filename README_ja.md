機械学習モデルの実行環境用にDockerイメージを作ろうとして、OpenCVのインストールにハマってしまい丸1日を費やしたので、同じことで悩む人が少しでも減ることを願ってシェアします。この問題は```python:3.6.8-slim-stretch```のような最小イメージをベースにして作成する際に発生します。```python:3.7.2-stretch```のようなフルサイズのイメージをベースにする場合は発生しませんが、多くのユーザーはできるだけ小さなDockerイメージを検証用や本番用の環境として作ろうとするものと考えられます。

# 問題点

PythonオフィシャルのDockerイメージに、機械学習に必要なライブラリをpipでインストールして起動し、必要ライブラリをインポートしてバージョン情報を表示するだけの下記プログラムを実行します。

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

すると、下記のOpenCVが依存しているネイティブ・ライブラリが見つからないというエラーがimportの時点で発生します。

```shell
Traceback (most recent call last):
  File "version.py", line 5, in <module>
    import cv2
  File "/usr/local/lib/python3.6/site-packages/cv2/__init__.py", line 3, in <module>
    from .cv2 import *
ImportError: libgthread-2.0.so.0: cannot open shared object file: No such file or directory
```

# 解決策

このエラーは、opencv-python自体はpipでインストールされておりcv2は見つかったものの、依存関係にある外部ライブラリが見つからないというエラーになります。「docker pip opencv」などをキーワードに対処方法をググってみると、大半はOpenCVのソースからコンパイルするスクリプトをDockerFileに書こうという記述ばかりが並びちょっと凹みます。

Macでは、pipでOpenCVがインストールできてPythonから使えていたので、余計に混乱しましたがちょっと冷静になって考えてみると、元々OpenCVはネイティブライブラリでありopencv-pythonはそれに皮を被せただけのラッパーに過ぎないと気づきました。

だったら、apt-getで元々のネイティブライブラリをインストールすれば、依存関係のエラーは解消できるはずと考えてDockerFileを以下のようにしてイメージを作成してみたところエラーは解消されました。

```DockerFile
# Replace this line to use python official image as a base.
FROM python:3.6.8-slim-stretch

LABEL Name=try_ml_docker Version=0.0.1
EXPOSE 50000

# Add the following line to get native library of OpenCV.
RUN apt-get update && apt-get -y libopencv-dev 

WORKDIR /app
# Replace this line to copy requirements.txt inside the docker image.
ADD ./requirements.txt /app

RUN python3 -m pip install -r requirements.txt
CMD ["python3", "-m", "try_ml_docker"]
```

requirements.txtには以下の内容を記載します。coremltoolsはkerasとtensorflowのバージョンに著しく依存するので、coremltools2.0を利用する場合はkerasとtensorflowは下記バージョンに指定します。その他のpythonライブラリは最新版を利用します。

```text
coremltools==2.0
keras==2.1.6
tensorflow==1.5.0
numpy
pillow
opencv-python
```

# Tips

ソースコードはVS Code上のものをホストとコンテナの間で共有したいのでカレント・ディレクトリを共有するようにコンテナを実行します。-vパラメーターで渡すのは絶対パスなので、\`pwd\`コマンドでカレントディレクトリの絶対パスを取得して渡しています。pwdコマンドをくくっているのはバッククォートですので気をつけてください。

```shell
$ docker run -v `pwd`:/app -it -d try_ml_docker:latest /bin/bash
```

[英語版](README.md)

