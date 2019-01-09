IMAGENAME ?= $(shell pwd |awk -F'/' '{print $$NF}')
REGISTRY ?= registry.cn-beijing.aliyuncs.com/kubebase
TAG ?= $(shell git rev-parse --short HEAD)
IMAGE = $(REGISTRY)/$(IMAGENAME)
 
APP ?= $(shell pwd |awk -F'/' '{print $$NF}')

# 判断本地是否允许此容器，用于调试
exists ?= $(shell docker ps -a |grep $(APP) &>/dev/null && echo "yes" || echo "no")
PORT ?= 8080
 
PWD =$(shell pwd)
 
# k8s预定义的APP_CONFIG_PATH环境变量默认值为/run/secret/appconfig
APP_CONFIG_PATH ?= /run/secret/appconfig
 
all: build-docker push
 
build:
	go install
build-docker:
	docker build -t $(IMAGE):latest .
	docker tag $(IMAGE):latest $(IMAGE):$(TAG)
 
push:
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):latest
 
# 本地调试
debug: build-docker run
 
# 本地运行容器，需要先判断容器是否存在
run:
	echo $(exists)
ifeq ($(exists), yes)
	docker stop $(APP);docker rm $(APP)
endif
	docker run --name $(APP) -d -p $(PORT):3311 -v $(PWD)/cfg.example.json:$(APP_CONFIG_PATH)/cfg --env APP_CONFIG_PATH=$(APP_CONFIG_PATH) $(IMAGE):$(TAG)
