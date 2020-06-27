FROM hashicorp/terraform:0.12.26

RUN apk add ansible \
    && apk add curl

WORKDIR /home/paperspace/gradient-processing-ps-cloud

ADD . ./

RUN pwd
RUN ls -la /home/paperspace/gradient-processing-ps-cloud/bin

ENTRYPOINT sh bin/run
