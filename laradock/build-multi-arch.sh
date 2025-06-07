#!/bin/bash

# 构建多架构PHP-FPM镜像并推送到阿里云镜像仓库
# 支持架构: linux/amd64 (阿里云服务器), linux/arm64 (Apple M2芯片)
# 使用方法: ./build-multi-arch.sh [版本号]
# 注意: 推荐使用 GitHub Actions 自动构建，此脚本作为备用方案

set -e

# 默认版本号
VERSION=${1:-"8.3"}
IMAGE_NAME="registry.cn-hangzhou.aliyuncs.com/llapi/laravel"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

echo "🚀 开始构建多架构 PHP-FPM 镜像..."
echo "📦 镜像名称: ${FULL_IMAGE_NAME}"
echo "🐘 PHP版本: ${VERSION}"
echo "🏗️  支持架构: linux/amd64 (阿里云服务器), linux/arm64 (Apple M2芯片)"
echo ""

# 检查是否已登录阿里云镜像仓库
echo "🔐 检查阿里云镜像仓库登录状态..."
if ! docker info | grep -q "registry.cn-hangzhou.aliyuncs.com"; then
    echo "⚠️  请先登录阿里云镜像仓库:"
    echo "   docker login registry.cn-hangzhou.aliyuncs.com"
    echo ""
    read -p "是否现在登录? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login registry.cn-hangzhou.aliyuncs.com
    else
        echo "❌ 需要登录后才能推送镜像"
        exit 1
    fi
fi

echo "🔨 开始构建镜像..."

# 检查Docker Buildx是否可用
if ! docker buildx version > /dev/null 2>&1; then
    echo "❌ Docker Buildx 不可用，无法构建多架构镜像"
    echo "💡 请升级Docker到支持buildx的版本，或使用GitHub Actions构建"
    exit 1
fi

# 创建并使用buildx builder
BUILDER_NAME="multiarch-builder"
if ! docker buildx ls | grep -q "${BUILDER_NAME}"; then
    echo "🔧 创建多架构构建器: ${BUILDER_NAME}"
    docker buildx create --name ${BUILDER_NAME} --use --bootstrap
else
    echo "🔧 使用现有构建器: ${BUILDER_NAME}"
    docker buildx use ${BUILDER_NAME}
fi

# 使用buildx构建多架构镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg LARADOCK_PHP_VERSION=${VERSION} \
    --build-arg BASE_IMAGE_TAG_PREFIX=latest \
    --build-arg CHANGE_SOURCE=false \
    --build-arg INSTALL_BCMATH=true \
    --build-arg INSTALL_MYSQLI=true \
    --build-arg INSTALL_INTL=true \
    --build-arg INSTALL_IMAGEMAGICK=true \
    --build-arg INSTALL_OPCACHE=true \
    --build-arg INSTALL_IMAGE_OPTIMIZERS=true \
    --build-arg INSTALL_PHPREDIS=true \
    --build-arg INSTALL_MEMCACHED=false \
    --build-arg INSTALL_BZ2=false \
    --build-arg INSTALL_ENCHANT=false \
    --build-arg INSTALL_GMP=false \
    --build-arg INSTALL_GNUPG=false \
    --build-arg INSTALL_XDEBUG=false \
    --build-arg INSTALL_PCOV=false \
    --build-arg INSTALL_XHPROF=false \
    --build-arg INSTALL_PHPDBG=false \
    --build-arg INSTALL_SMB=false \
    --build-arg INSTALL_IMAP=false \
    --build-arg INSTALL_MONGO=false \
    --build-arg INSTALL_AMQP=false \
    --build-arg INSTALL_CASSANDRA=false \
    --build-arg INSTALL_ZMQ=false \
    --build-arg INSTALL_GEARMAN=false \
    --build-arg INSTALL_MSSQL=false \
    --build-arg INSTALL_SSH2=false \
    --build-arg INSTALL_SOAP=false \
    --build-arg INSTALL_XSL=false \
    --build-arg INSTALL_EXIF=false \
    --build-arg INSTALL_AEROSPIKE=false \
    --build-arg INSTALL_OCI8=false \
    --build-arg INSTALL_PGSQL=false \
    --build-arg INSTALL_GHOSTSCRIPT=false \
    --build-arg INSTALL_LDAP=false \
    --build-arg INSTALL_PHALCON=false \
    --build-arg INSTALL_SWOOLE=false \
    --build-arg INSTALL_TAINT=false \
    --build-arg INSTALL_PG_CLIENT=false \
    --build-arg INSTALL_POSTGIS=false \
    --build-arg INSTALL_PCNTL=false \
    --build-arg INSTALL_CALENDAR=false \
    --build-arg INSTALL_FAKETIME=false \
    --build-arg INSTALL_IONCUBE=false \
    --build-arg INSTALL_RDKAFKA=false \
    --build-arg INSTALL_GETTEXT=false \
    --build-arg INSTALL_XMLRPC=false \
    --build-arg INSTALL_APCU=false \
    --build-arg INSTALL_CACHETOOL=false \
    --build-arg INSTALL_YAML=false \
    --build-arg INSTALL_ADDITIONAL_LOCALES=false \
    --build-arg INSTALL_MYSQL_CLIENT=false \
    --build-arg INSTALL_PING=false \
    --build-arg INSTALL_SSHPASS=false \
    --build-arg INSTALL_MAILPARSE=false \
    --build-arg INSTALL_WKHTMLTOPDF=false \
    --build-arg INSTALL_XLSWRITER=false \
    --build-arg INSTALL_PHPDECIMAL=false \
    --build-arg INSTALL_ZOOKEEPER=false \
    --build-arg INSTALL_SSDB=false \
    --build-arg INSTALL_TRADER=false \
    --build-arg INSTALL_EVENT=false \
    --build-arg INSTALL_DOCKER_CLIENT=false \
    --build-arg INSTALL_DNSUTILS=true \
    --build-arg INSTALL_POPPLER_UTILS=false \
    --tag ${FULL_IMAGE_NAME} \
    --push \
    ./php-fpm

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 多架构镜像构建并推送成功!"
    echo "📦 镜像名称: ${FULL_IMAGE_NAME}"
    echo "🏗️  支持架构: linux/amd64 (阿里云服务器), linux/arm64 (Apple M2芯片)"
    echo ""

    # 验证推送的镜像
    echo "🔍 验证镜像信息..."
    docker buildx imagetools inspect ${FULL_IMAGE_NAME}

    echo ""
    echo "📋 使用方法:"
    echo "   # 在Apple M2芯片Mac上:"
    echo "   docker pull ${FULL_IMAGE_NAME}"
    echo ""
    echo "   # 在阿里云Linux服务器上:"
    echo "   docker pull ${FULL_IMAGE_NAME}"
    echo ""
    echo "💡 提示: Docker会自动选择匹配当前平台的架构"
    echo "💡 推荐使用 GitHub Actions 进行自动构建，详见: DOCKER_BUILD_README.md"
else
    echo "❌ 镜像构建失败!"
    exit 1
fi

echo ""
echo "🏁 完成!"
