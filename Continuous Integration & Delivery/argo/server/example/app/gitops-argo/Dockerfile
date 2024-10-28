FROM golang:alpine AS builder
#FROM golang:latest AS builder
MAINTAINER Lookeke
ENV VERSION 1.0

WORKDIR /app

# 拷贝当前目录下可以执行文件
COPY . .

RUN unset https_proxy
RUN unset http_proxy
RUN go env -w GOPROXY=https://proxy.golang.com.cn,direct

# 里要加-tags netgo进行静态编译，否则由于alipne基础镜像缺少必要的动态库，可能会出现类似“no such file or directory"的报错
# 或者直接禁用gcc，然后进行编译
RUN mkdir -p /app/bin
# # pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/bin/ ./...

#FROM alpine:latest
FROM scratch

WORKDIR /app

# 从 builder 镜像中复制 Go 二进制文件到当前镜像中
COPY --from=builder /app/bin .

# 暴露端口
EXPOSE 4000

# 定义容器启动时运行的命令
ENTRYPOINT ["/app/test1"]
