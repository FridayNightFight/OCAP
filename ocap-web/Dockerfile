FROM golang:1.16-alpine as builder
WORKDIR /go/pkg/ocap-web
RUN go build -a -o app .

FROM alpine:3.14
WORKDIR /usr/local/ocap-web
COPY --from=builder /go/pkg/ocap-web/app /usr/local/ocap-web/app
COPY static /usr/local/ocap-web/static
COPY template /usr/local/ocap-web/template

ENTRYPOINT ["/app"]
