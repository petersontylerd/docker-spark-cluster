# debian & java base image
FROM openjdk:8-stretch

### debian packages
RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    bash \
    nano \
    net-tools \
    software-properties-common \
    ssh \
    tar \
    tree \
    wget
RUN apt-get clean

### spark
# set spark version
ENV SPARK_VERSION="2.4.3"

# install Spark
RUN wget https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz
RUN mkdir -p /usr/local/spark-${SPARK_VERSION}
RUN tar -zxf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C /usr/local/spark-${SPARK_VERSION}/
RUN rm spark-${SPARK_VERSION}-bin-hadoop2.7.tgz

# set spark home directory and add Spark command to PATH for ease of use
ENV SPARK_HOME="/usr/local/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7"
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# RUN cp conf/log4j.properties.template conf/log4j.properties

### python
RUN apt-get install -y python3 python3-pip

# set default Python 3.5
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# additional packages
RUN pip3 install --upgrade pip setuptools
WORKDIR /requirements/
COPY requirements.txt /requirements
RUN pip3 install -r requirements.txt

# set up ipython shell to start up with pyspark
ENV PYSPARK_DRIVER_PYTHON=ipython

# reset working directory
WORKDIR $SPARK_HOME