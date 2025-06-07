# Docker 镜像自动构建说明

本项目使用 GitHub Actions 自动构建 x86_64 架构的 PHP-FPM Docker 镜像并推送到阿里云容器镜像服务。

## 🔧 配置 GitHub Secrets

在使用自动构建功能之前，需要在 GitHub 仓库中配置以下 Secrets：

### 1. 进入仓库设置
1. 打开你的 GitHub 仓库
2. 点击 `Settings` 选项卡
3. 在左侧菜单中选择 `Secrets and variables` → `Actions`

### 2. 添加必要的 Secrets
点击 `New repository secret` 按钮，添加以下两个 secrets：

#### ALIYUN_REGISTRY_USERNAME
- **名称**: `ALIYUN_REGISTRY_USERNAME`
- **值**: 你的阿里云容器镜像服务用户名
- **说明**: 通常是你的阿里云账号或者 RAM 用户名

#### ALIYUN_REGISTRY_PASSWORD
- **名称**: `ALIYUN_REGISTRY_PASSWORD`
- **值**: 你的阿里云容器镜像服务密码
- **说明**: 阿里云账号密码或者 RAM 用户的访问密钥

### 3. 获取阿里云容器镜像服务凭据

#### 方法一：使用阿里云账号（推荐用于个人项目）
1. 登录 [阿里云容器镜像服务控制台](https://cr.console.aliyun.com/)
2. 点击左侧菜单 `访问凭据`
3. 设置 Registry 登录密码
4. 用户名为你的阿里云账号，密码为刚设置的 Registry 密码

#### 方法二：使用 RAM 用户（推荐用于企业项目）
1. 创建 RAM 用户并授予容器镜像服务权限
2. 为 RAM 用户创建 AccessKey
3. 用户名为 RAM 用户名，密码为 AccessKey Secret

## 🚀 触发构建

### 自动触发
以下情况会自动触发构建：
- 推送代码到 `main` 或 `master` 分支
- 修改 `laradock/php-fpm/` 目录下的文件
- 修改 `.github/workflows/build-docker.yml` 文件

### 手动触发
1. 进入 GitHub 仓库的 `Actions` 选项卡
2. 选择 `Build and Push Docker Image` 工作流
3. 点击 `Run workflow` 按钮
4. 选择 PHP 版本（8.0-8.4）
5. 可选：自定义镜像标签
6. 点击 `Run workflow` 开始构建

## 📦 构建产物

构建成功后，镜像将推送到：
```
registry.cn-hangzhou.aliyuncs.com/llapi/laravel:[版本号]
```

例如：
- `registry.cn-hangzhou.aliyuncs.com/llapi/laravel:8.3`
- `registry.cn-hangzhou.aliyuncs.com/llapi/laravel:8.2`

## 🔍 使用构建的镜像

### 拉取镜像
```bash
docker pull registry.cn-hangzhou.aliyuncs.com/llapi/laravel:8.3
```

### 在 docker-compose.yml 中使用
```yaml
services:
  php-fpm:
    image: registry.cn-hangzhou.aliyuncs.com/llapi/laravel:8.3
    volumes:
      - ./www:/var/www
    networks:
      - backend
```

### 验证镜像架构
```bash
docker inspect registry.cn-hangzhou.aliyuncs.com/llapi/laravel:8.3 | grep -i arch
```

## ⚙️ 自定义构建配置

如需修改构建配置，编辑 `.github/workflows/build-docker.yml` 文件中的 `build-args` 部分：

```yaml
build-args: |
  LARADOCK_PHP_VERSION=${{ steps.vars.outputs.php_version }}
  INSTALL_BCMATH=true
  INSTALL_MYSQLI=true
  # 添加或修改其他扩展...
```

## 🐛 故障排除

### 构建失败
1. 检查 GitHub Secrets 是否正确配置
2. 确认阿里云容器镜像服务凭据有效
3. 查看 Actions 日志获取详细错误信息

### 推送失败
1. 确认阿里云账号有推送权限
2. 检查镜像仓库是否存在且可访问
3. 验证网络连接是否正常

### 架构问题
- 本工作流专门构建 x86_64 (linux/amd64) 架构镜像
- 如需 ARM64 支持，需要修改工作流配置

## 📝 注意事项

1. **安全性**: 请妥善保管阿里云凭据，不要在代码中硬编码
2. **费用**: 注意阿里云容器镜像服务的计费规则
3. **存储**: 定期清理不需要的镜像版本以节省存储空间
4. **权限**: 确保 RAM 用户有足够的权限进行镜像推送操作

## 🔗 相关链接

- [阿里云容器镜像服务文档](https://help.aliyun.com/product/60716.html)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Buildx 文档](https://docs.docker.com/buildx/)
- [Laradock 官方文档](https://laradock.io/)
