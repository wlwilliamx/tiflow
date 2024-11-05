FROM golang:1.23.2-alpine as builder
RUN apk add --no-cache git make bash
WORKDIR /go/src/github.com/pingcap/tiflow
COPY . .
ENV CDC_ENABLE_VENDOR=1
RUN go mod vendor
RUN make failpoint-enable
RUN make cdc
RUN make failpoint-disable

FROM ghcr.io/pingcap-qe/bases/tools-base:v1.9.2
RUN apk add --no-cache tzdata bash curl socat
COPY --from=builder /go/src/github.com/pingcap/tiflow/bin/cdc /cdc
EXPOSE 8300
CMD [ "/cdc" ]

