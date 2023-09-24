FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="America/New_York"

# These libs are required by the AWS C++ SDK and should remain inside
# of any child container using this image as a base image.
ENV AWS_SDK_CPP_REQUIRED_LIBS \
  libssl-dev \
  libcurl4-openssl-dev \
  curl \
  libxml2 \
  libc-dev \
  libpulse-dev \
  ca-certificates 

# These installs are required for compiling the AWS C++ SDK. It is probable
# that any child image will also need these to compile their projects. But as
# with USEFUL_TOOLS below, could be removed from the final release build image
# to save image space.
ENV AWS_SDK_CPP_BUILD_TOOLS \
  build-essential \
  autoconf \
  g++ \
  gcc \
  make 

# If you use this container as a base image then the following
# installs can be removed from the final image to save image space.
# I install them here as they are useful during development.
ENV AWS_SDK_CPP_USEFUL_TOOLS \
  apt-utils \
  vim \
  wget \
  mysql-client \
  xz-utils \
  file \
  mlocate \
  unzip \
  git

ENV AWS_CPP_REQUIRED_LIBS \
  unixodbc \
  unixodbc-dev \
  python3-pip

RUN apt-get update \
  && apt-get install -y \
  $AWS_SDK_CPP_BUILD_TOOLS \
  $AWS_SDK_CPP_REQUIRED_LIBS \
  $AWS_SDK_CPP_USEFUL_TOOLS \
  $AWS_CPP_REQUIRED_LIBS \
  --no-install-recommends \
  # install Cmake
  && mkdir -p /tmp/build && cd /tmp/build \
  && curl -sSL https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.tar.gz > cmake-3.10.2-Linux-x86_64.tar.gz \
  && tar -v -zxf cmake-3.10.2-Linux-x86_64.tar.gz \
  && rm -f cmake-3.10.2-Linux-x86_64.tar.gz \
  && cd cmake-3.10.2-Linux-x86_64 \
  && cp -rp bin/* /usr/local/bin/ \
  && cp -rp share/* /usr/local/share/ \
  && cd / && rm -rf /tmp/build \
  # install aws cli
  && mkdir /tmp/build \
  && cd /tmp/build \
  && curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install

RUN pip3 install --upgrade setuptools
RUN pip3 install okta-awscli
# export LC_ALL=C.UTF-8
# export LANG=C.UTF-8

RUN mkdir -p /tmp/build && cd /tmp/build \
  && git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp \
  && cmake aws-sdk-cpp \ 
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=. \
  && make \
  && make install


# These commands copy your files into the specified directory in the image
# and set that as the working location
#COPY . /usr/src/myapp
#WORKDIR /usr/src/myapp
#RUN mkdir bin

#RUN apt update
#RUN apt -y install unixodbc
#RUN apt -y install unixodbc-dev
#RUN apt -y install unixodbc-dev


# This command compiles your app using GCC, adjust for your source code
#RUN make

# This command runs your application, comment out this line to compile only
#CMD ["./bin/compiler"]
LABEL Name=awscppbase Version=0.0.1
