# debian & java base image
FROM ubuntu:18.04

### ubuntu packages
RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    apt-transport-https \
    bash \
    build-essential \
    bzip2 \
    curl \
    git \
    gnupg-agent \
    htop \
    libbz2-dev \
    libffi-dev \
    libgdbm-compat-dev \
    libgdbm-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    nano \
    net-tools \
    openjdk-8-jdk \
    openjdk-8-jre \
    openssl \
    software-properties-common \
    ssh \
    tar \
    tree \
    wget \
    uuid-dev \
    zlib1g-dev
RUN apt-get clean

### Java
# add java home to path
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH ${JAVA_HOME}/bin:$PATH

### spark
# set spark version
ENV SPARK_VERSION="3.0.0"

# install Spark
RUN wget http://apache.mirrors.hoobly.com/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz
RUN mkdir -p /usr/local/spark-${SPARK_VERSION}
RUN tar -zxf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C /usr/local/spark-${SPARK_VERSION}/
RUN rm spark-${SPARK_VERSION}-bin-hadoop2.7.tgz

# set spark home directory and add Spark command to PATH for ease of use
ENV SPARK_HOME="/usr/local/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7"
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# RUN cp conf/log4j.properties.template conf/log4j.properties

### python
RUN apt-get install -y python3 python3-pip

# set default Python
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# additional packages
RUN pip3 install --upgrade pip setuptools
WORKDIR /requirements/
COPY requirements.txt /requirements
RUN pip3 install -r requirements.txt

# set up ipython shell to start up with pyspark
ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook'

### jupyter
# enable extensions
RUN jupyter contrib nbextension install --user
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable code_font_size/code_font_size
RUN jupyter nbextension enable highlight_selected_word/main
RUN jupyter nbextension enable collapsible_headings/main
RUN jupyter nbextension enable codefolding/main

# set theme
RUN jt -t monokai -f fira -fs 13 -nf ptsans -nfs 11 -N -kl -cursw 5 -cursc r -cellw 95% -T

# reset working directory
WORKDIR /workspace/