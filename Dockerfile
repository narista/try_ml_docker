# Python support can be specified down to the minor or micro version
# (e.g. 3.6 or 3.6.3).
# OS Support also exists for jessie & stretch (slim and full).
# See https://hub.docker.com/r/library/python/ for all supported Python
# tags from Docker Hub.

# Replace this line as follows.
FROM python:3.6.8-slim-stretch

# If you prefer miniconda:
#FROM continuumio/miniconda3

LABEL Name=try_ml_docker Version=0.0.1
EXPOSE 50000

# Add the following line
RUN apt-get update && apt-get install -y libopencv-dev

WORKDIR /app
# Replace this line as follows.
ADD ./requirements.txt /app

# Using pip:
RUN python3 -m pip install -r requirements.txt
CMD ["python3", "-m", "try_ml_docker"]

# Using pipenv:
#RUN python3 -m pip install pipenv
#RUN pipenv install --ignore-pipfile
#CMD ["pipenv", "run", "python3", "-m", "try_ml_docker"]

# Using miniconda (make sure to replace 'myenv' w/ your environment name):
#RUN conda env create -f environment.yml
#CMD /bin/bash -c "source activate myenv && python3 -m try_ml_docker"
