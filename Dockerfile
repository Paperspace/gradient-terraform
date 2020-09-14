FROM hashicorp/terraform:0.13.2

RUN apk add ansible curl bash

RUN mkdir /home/paperspace
ADD ./bin/setup /home/paperspace/gradient-installer/bin/setup
RUN /home/paperspace/gradient-installer/bin/setup

ADD . /home/paperspace/gradient-installer

WORKDIR /home/paperspace/gradient-cluster
ENTRYPOINT
CMD terraform init && terraform apply
