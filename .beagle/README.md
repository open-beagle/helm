# helm

<!-- https://github.com/helm/helm -->

```bash
git remote add upstream git@github.com:helm/helm.git
git fetch upstream
git merge v3.11.1
```

## build

```bash
# devops-go-arch
docker run -it --rm \
-w /go/src/helm.sh/helm/v3 \
-v $PWD/:/go/src/helm.sh/helm/v3 \
-e CI_WORKSPACE=/go/src/helm.sh/helm/v3 \
-e PLUGIN_BINARY=helm \
-e PLUGIN_MAIN=cmd/helm \
registry.cn-qingdao.aliyuncs.com/wod/devops-go-arch:1.19-alpine

# tgz
docker run -it --rm \
-w /go/src/helm.sh/helm/v3 \
-v $PWD/:/go/src/helm.sh/helm/v3 \
-e CI_WORKSPACE=/go/src/helm.sh/helm/v3 \
registry.cn-qingdao.aliyuncs.com/wod/alpine:3 \
ash -c ' \
cd dist && \
mkdir -p linux-amd64 linux-arm64 linux-ppc64le linux-mips64le && \
mv helm-linux-amd64 linux-amd64/helm && \
tar czvf helm-v3.11.1-linux-amd64.tar.gz linux-amd64 && \
mv helm-linux-arm64 linux-arm64/helm && \
tar czvf helm-v3.11.1-linux-arm64.tar.gz linux-arm64 && \
mv helm-linux-ppc64le linux-ppc64le/helm && \
tar czvf helm-v3.11.1-linux-ppc64le.tar.gz linux-ppc64le
'

# devops-docker
docker run -it --rm \
-w /go/src/helm.sh/helm/v3 \
-v $PWD/:/go/src/helm.sh/helm/v3 \
-e CI_WORKSPACE=/go/src/helm.sh/helm/v3 \
-e PLUGIN_BASE=registry.cn-qingdao.aliyuncs.com/wod/alpine:3 \
-e PLUGIN_DOCKERFILE=.beagle/dockerfile \
-e PLUGIN_REPO=wod/helm \
-e PLUGIN_VERSION='v3.11.1' \
-e PLUGIN_ARGS='TARGETOS=linux,TARGETARCH=amd64' \
-e PLUGIN_REGISTRY=registry.cn-qingdao.aliyuncs.com \
-e REGISTRY_USER=<REGISTRY_USER> \
-e REGISTRY_PASSWORD=<REGISTRY_PASSWORD> \
-v /var/run/docker.sock:/var/run/docker.sock \
registry.cn-qingdao.aliyuncs.com/wod/devops-docker:1.0

# test
docker run -it --rm \
-w /go/src/helm.sh/helm/v3 \
-v $PWD/:/go/src/helm.sh/helm/v3 \
-e CI_WORKSPACE=/go/src/helm.sh/helm/v3 \
registry.cn-qingdao.aliyuncs.com/wod/alpine:3.14 \
ash -c '
./dist/helm-linux-amd64 version
'

docker run -it --rm \
-w /go/src/helm.sh/helm/v3 \
-v $PWD/:/go/src/helm.sh/helm/v3 \
-e CI_WORKSPACE=/go/src/helm.sh/helm/v3 \
registry.cn-qingdao.aliyuncs.com/wod/debian:bullseye \
bash -c '
./dist/helm-linux-amd64 version
'
```

## cache

```bash
# 构建缓存-->推送缓存至服务器
docker run --rm \
  -e PLUGIN_REBUILD=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="helm" \
  -e PLUGIN_MOUNT="./.git,./vendor" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0

# 读取缓存-->将缓存从服务器拉取到本地
docker run --rm \
  -e PLUGIN_RESTORE=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="helm" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0
```
