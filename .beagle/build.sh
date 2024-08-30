# /bin/bash

set -ex

BUILD_VERSION="${BUILD_VERSION:-v3.15.3}"

export GO111MODULE=on
export CGO_ENABLED=0

GIT_COMMIT=$(git rev-parse HEAD)
GIT_SHA=$(git rev-parse --short HEAD)

# Define constants based on the client-go version
K8S_MODULES_VER=$(go list -f '{{.Version}}' -m k8s.io/client-go | sed 's/[v]//g')

# 分离主版本号和次版本号
IFS='.' read -ra K8S_MODULES_VER_PARTS <<<"${K8S_MODULES_VER}"

K8S_MODULES_MAJOR_VER=$((K8S_MODULES_VER_PARTS[0] + 1))
K8S_MODULES_MINOR_VER="${K8S_MODULES_VER_PARTS[1]}"

# 将 ldflags 参数构建为一个变量
LDFLAGS=(
  "-w -s"
  "-X helm.sh/helm/v3/internal/version.metadata=unreleased"
  "-X helm.sh/helm/v3/internal/version.gitCommit=${GIT_COMMIT}"
  "-X helm.sh/helm/v3/internal/version.gitTreeState=dirty"
  "-X helm.sh/helm/v3/pkg/lint/rules.k8sVersionMajor=${K8S_MODULES_MAJOR_VER}"
  "-X helm.sh/helm/v3/pkg/lint/rules.k8sVersionMinor=${K8S_MODULES_MINOR_VER}"
  "-X helm.sh/helm/v3/pkg/chartutil.k8sVersionMajor=${K8S_MODULES_MAJOR_VER}"
  "-X helm.sh/helm/v3/pkg/chartutil.k8sVersionMinor=${K8S_MODULES_MINOR_VER}"
)

export GOARCH=amd64
go build -o ./bin/helm-$GOARCH -ldflags "${LDFLAGS[*]}" ./cmd/helm

export GOARCH=arm64
go build -o ./bin/helm-$GOARCH -ldflags "${LDFLAGS[*]}" ./cmd/helm
