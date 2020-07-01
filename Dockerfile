FROM hashicorp/terraform:0.12.24

RUN apk add curl

RUN mkdir /home/paperspace
ADD ./bin/setup /home/paperspace/gradient-installer/bin/setup
RUN /home/paperspace/gradient-installer/bin/setup

ADD . /home/paperspace/gradient-installer

WORKDIR /home/paperspace/gradient-cluster
ENTRYPOINT
CMD terraform init && terraform apply
