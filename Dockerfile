FROM registry.cn-beijing.aliyuncs.com/kubebase/golang-builder:latest as builder
RUN mkdir -p /go/src/github.com/annprog
COPY . /go/src/github.com/annprog/mailer
WORKDIR /go/src/github.com/annprog/mailer
RUN go build -ldflags "-s -w" -o /go/bin/mailer


FROM alpine:3.8
COPY --from=builder /go/bin/mailer /
COPY init.sh /
CMD ["sh", "/init.sh"]
