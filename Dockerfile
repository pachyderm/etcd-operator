FROM golang:1.14 AS build

WORKDIR /etcd-operator
COPY go.mod go.sum /etcd-operator/
RUN go mod download

COPY . /etcd-operator/

ARG version="unknown"
ARG git_sha="0000000000000000000000000000000000000000"

RUN CGO_ENABLED=0 go install -ldflags "-X github.com/coreos/etcd-operator/version.Version=$version -X github.com/coreos/etcd-operator/version.GitSHA=$git_sha" ./cmd/backup-operator ./cmd/restore-operator ./cmd/operator

FROM gcr.io/distroless/static-debian10
ENV PATH="/usr/local/bin"
WORKDIR /
COPY --from=build /go/bin/backup-operator /usr/local/bin/etcd-backup-operator
COPY --from=build /go/bin/restore-operator /usr/local/bin/etcd-restore-operator
COPY --from=build /go/bin/operator /usr/local/bin/etcd-operator
