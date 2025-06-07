#!/bin/bash

# 测试多架构镜像脚本
# 使用方法: ./test-multi-arch.sh [镜像标签]

set -e

# 默认镜像标签
TAG=${1:-"8.3"}
IMAGE_NAME="registry.cn-hangzhou.aliyuncs.com/llapi/laravel:${TAG}"

echo "🧪 测试多架构镜像: ${IMAGE_NAME}"
echo ""

# 检查镜像是否存在
echo "🔍 检查镜像信息..."
if docker buildx imagetools inspect ${IMAGE_NAME} > /dev/null 2>&1; then
    echo "✅ 镜像存在"
    
    # 显示支持的架构
    echo ""
    echo "🏗️  支持的架构:"
    docker buildx imagetools inspect ${IMAGE_NAME} | grep -A 10 "Manifests:" | grep "Platform:" || echo "无法获取架构信息"
    
    echo ""
    echo "📥 拉取镜像 (Docker会自动选择匹配的架构)..."
    docker pull ${IMAGE_NAME}
    
    echo ""
    echo "🔍 本地镜像架构信息:"
    docker inspect ${IMAGE_NAME} | grep -i "architecture\|platform" || echo "无法获取本地镜像架构信息"
    
    echo ""
    echo "🐘 测试PHP版本:"
    docker run --rm ${IMAGE_NAME} php -v
    
    echo ""
    echo "🖥️  测试系统架构:"
    docker run --rm ${IMAGE_NAME} uname -m
    
    echo ""
    echo "✅ 测试完成!"
    echo ""
    echo "💡 使用说明:"
    echo "   - 在Apple M2芯片Mac上会自动使用arm64架构"
    echo "   - 在阿里云Linux服务器上会自动使用amd64架构"
    echo "   - 如需强制指定架构，使用: docker run --platform linux/amd64 ..."
    
else
    echo "❌ 镜像不存在或无法访问"
    echo "💡 请先运行构建脚本或GitHub Actions工作流"
    exit 1
fi
