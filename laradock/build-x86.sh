#!/bin/bash

# 构建x86_64架构的PHP-FPM镜像并推送到阿里云镜像仓库
# 使用方法: ./build-x86.sh [版本号]
# 注意: 推荐使用 GitHub Actions 自动构建，此脚本作为备用方案

set -e

# 默认版本号
VERSION=${1:-"8.3"}
IMAGE_NAME="registry.cn-hangzhou.aliyuncs.com/llapi/laravel"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

echo "🚀 开始构建 x86_64 架构的 PHP-FPM 镜像..."
echo "📦 镜像名称: ${FULL_IMAGE_NAME}"
echo "🐘 PHP版本: ${VERSION}"
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

# 使用传统docker build方法，指定平台
docker build \
    --platform linux/amd64 \
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
    ./php-fpm

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功!"
    echo "📤 开始推送镜像到阿里云..."
    docker push ${FULL_IMAGE_NAME}

    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 镜像推送成功!"
        echo "📦 镜像名称: ${FULL_IMAGE_NAME}"
        echo "🏗️  架构: linux/amd64 (x86_64)"
        echo ""

        # 验证推送的镜像
        echo "🔍 验证镜像信息..."
        docker inspect ${FULL_IMAGE_NAME} | grep -i arch

        echo ""
        echo "📋 使用方法:"
        echo "   docker pull ${FULL_IMAGE_NAME}"
        echo ""
        echo "💡 提示: 推荐使用 GitHub Actions 进行自动构建"
        echo "   详见: DOCKER_BUILD_README.md"
    else
        echo "❌ 镜像推送失败!"
        exit 1
    fi
else
    echo "❌ 镜像构建失败!"
    exit 1
fi

echo ""
echo "🏁 完成!"
