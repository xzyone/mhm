# mhm

`mhm` 是一个面向 systemd Linux 的 Mihomo 命令行管理脚本，用于安装、升级、配置、运行和卸载 Mihomo。

当前脚本版本：`v1.2.0`

## 主要功能

- 自动识别 CPU 架构并下载 Mihomo 最新稳定版
- 支持直连 GitHub、GitHub 镜像前缀和 HTTP/SOCKS 网络代理
- 交互设置配置目录、Mixed 端口、控制 API 地址及端口和 API Secret
- 自动创建 `mihomo.service`，注册开机自启
- 保留已有 `config.yaml`，修改前自动备份
- 升级失败时自动回滚 Mihomo 二进制
- 支持服务启停、状态查看、实时日志和配置检查
- 支持 x86_64、ARM64、ARMv7、386、RISC-V、S390x 和 LoongArch64

## 快速安装

### 直接从 GitHub 下载

```bash
curl -fsSL https://raw.githubusercontent.com/xzyone/mhm/main/mhm -o /tmp/mhm
sudo install -m 0755 /tmp/mhm /usr/local/bin/mhm
rm -f /tmp/mhm
sudo mhm
```

### 通过 GitHub 镜像下载 mhm

不同镜像服务的地址格式可能不同。对于支持“原始 URL 前缀”方式的镜像，可使用：

```bash
MIRROR=https://your-github-mirror.example
curl -fsSL "$MIRROR/https://raw.githubusercontent.com/xzyone/mhm/main/mhm" -o /tmp/mhm
sudo install -m 0755 /tmp/mhm /usr/local/bin/mhm
rm -f /tmp/mhm
sudo mhm
```

### 通过本地 HTTP/SOCKS 代理下载 mhm

推荐使用 `socks5h://`，让域名也通过代理解析：

```bash
curl --proxy socks5h://127.0.0.1:12222 \
  -fsSL https://raw.githubusercontent.com/xzyone/mhm/main/mhm \
  -o /tmp/mhm
sudo install -m 0755 /tmp/mhm /usr/local/bin/mhm
rm -f /tmp/mhm
sudo mhm
```

> `mhm` 的安装和设置过程依赖 `/dev/tty` 进行交互输入，因此不建议直接使用 `curl | bash`。

## 使用方法

不带参数运行会打开互动菜单：

```bash
sudo mhm
```

常用命令：

| 命令 | 说明 |
| --- | --- |
| `sudo mhm install` | 安装或重新安装 Mihomo |
| `sudo mhm upgrade` | 升级 Mihomo |
| `sudo mhm configure` | 修改下载方式、端口、配置目录和 Secret |
| `sudo mhm download` | 单独设置 GitHub 下载方式 |
| `sudo mhm proxy` | `download` 的兼容别名 |
| `sudo mhm start` | 启动 Mihomo |
| `sudo mhm stop` | 停止 Mihomo |
| `sudo mhm restart` | 重启 Mihomo |
| `sudo mhm status` | 查看版本、服务状态和连接信息 |
| `sudo mhm logs` | 查看实时日志 |
| `sudo mhm test` | 检查当前 Mihomo 配置 |
| `sudo mhm uninstall` | 互动卸载 Mihomo |
| `sudo mhm uninstall --yes` | 卸载并保留配置目录 |
| `sudo mhm uninstall --purge --yes` | 卸载并删除配置目录 |
| `mhm --version` | 查看 mhm 版本 |

## GitHub 下载方式

运行：

```bash
sudo mhm download
```

可以选择以下三种方式：

```text
1. 直连 GitHub
2. GitHub 镜像前缀
3. HTTP/SOCKS 网络代理
```

设置会保存在 `/etc/mhm.conf`，以后执行 `mhm install` 或 `mhm upgrade` 时自动使用。

### 1. 直连 GitHub

Mihomo Release 文件直接从 GitHub 下载，不改写地址，也不经过额外代理。

### 2. GitHub 镜像前缀

适用于支持以下地址格式的镜像服务：

```text
https://镜像地址/https://github.com/MetaCubeX/mihomo/releases/download/...
```

设置时输入镜像根地址即可，例如：

```text
https://your-github-mirror.example
```

`mhm` 会自动把原始 GitHub 下载地址拼接到镜像前缀后面。

### 3. HTTP/SOCKS 网络代理

适用于本机或局域网内运行的代理服务。下载地址保持为原始 GitHub 地址，由 `curl` 通过代理连接。

常见示例：

```text
http://127.0.0.1:7890
socks5://127.0.0.1:12222
socks5h://127.0.0.1:12222
```

推荐使用：

```text
socks5h://127.0.0.1:12222
```

`socks5://` 通常由本机解析域名，`socks5h://` 会将域名解析交给代理，更适合本机存在 DNS 污染或无法解析 GitHub 的情况。

## 临时指定下载方式

环境变量只对当前命令生效，并优先于 `/etc/mhm.conf` 中保存的设置。

### 临时使用 GitHub 镜像

```bash
sudo MIHOMO_GITHUB_MIRROR=https://your-github-mirror.example mhm upgrade
```

### 临时使用 HTTP/SOCKS 代理

```bash
sudo MIHOMO_DOWNLOAD_PROXY=socks5h://127.0.0.1:12222 mhm upgrade
```

### 临时指定 Mihomo 版本

```bash
sudo MIHOMO_VERSION=vX.Y.Z mhm upgrade
```

不设置 `MIHOMO_VERSION` 时，脚本会查询 `MetaCubeX/mihomo` 的最新稳定版。

为了兼容 `v1.1.0`，旧变量 `MIHOMO_GITHUB_PROXY` 仍然可用：

- 值以 SOCKS 协议开头时，按网络代理处理
- 值以 HTTP 或 HTTPS 开头时，按 GitHub 镜像前缀处理

新配置建议使用含义更明确的 `MIHOMO_GITHUB_MIRROR` 和 `MIHOMO_DOWNLOAD_PROXY`。

## 安装时的互动设置

安装或执行 `sudo mhm configure` 时，可以设置：

| 设置 | 默认值 | 说明 |
| --- | --- | --- |
| 配置目录 | `/etc/mihomo` | Mihomo 配置及运行目录 |
| Mixed 端口 | `7890` | 同时提供 HTTP 和 SOCKS 代理 |
| 控制 API 地址 | `0.0.0.0` | Mihomo External Controller 监听地址 |
| 控制 API 端口 | `9090` | 面板及 API 使用的端口 |
| API Secret | 自动生成 | External Controller 访问密码 |
| GitHub 下载方式 | 直连 | 可改为镜像前缀或网络代理 |

## 配置文件处理

首次安装且配置目录中没有 `config.yaml` 时，`mhm` 会生成一份最小可运行配置，默认全部直连。

如果已有 `config.yaml`，脚本不会整体覆盖节点、代理组和规则，只会更新以下顶层字段：

```yaml
mixed-port: 7890
external-controller: '0.0.0.0:9090'
secret: 'your-secret'
```

如果原配置中没有 `external-controller-cors`，脚本还会补充面板跨域访问设置。

修改配置前会创建时间戳备份：

```text
/etc/mihomo/config.yaml.bak.YYYYMMDD-HHMMSS
```

可以使用以下命令检查配置：

```bash
sudo mhm test
```

## systemd 服务

安装完成后，Mihomo 会注册为：

```text
mihomo.service
```

服务默认开机自启，常见操作：

```bash
sudo systemctl status mihomo
sudo systemctl restart mihomo
journalctl -u mihomo -n 100 -f
```

也可以直接使用对应的 `mhm` 命令。

## MetaCubeXD 等控制面板

在面板中填写：

```text
后端地址：http://服务器IP:控制端口
Secret：安装时设置或自动生成的 API Secret
```

例如：

```text
http://192.168.1.10:9090
```

如果控制 API 监听 `0.0.0.0` 或 `[::]`，不要把控制端口直接暴露到公网。建议通过防火墙限制来源地址，或者只允许可信局域网访问。

## 默认路径

| 项目 | 默认路径 |
| --- | --- |
| mhm 命令 | `/usr/local/bin/mhm` |
| Mihomo 二进制 | `/usr/local/bin/mihomo` |
| Mihomo 配置目录 | `/etc/mihomo` |
| Mihomo 配置文件 | `/etc/mihomo/config.yaml` |
| mhm 状态文件 | `/etc/mhm.conf` |
| systemd 服务文件 | `/etc/systemd/system/mihomo.service` |

`/etc/mhm.conf` 中包含 API Secret 和下载设置，脚本会将其权限设置为 `600`。

## 升级 mhm 本身

`mhm upgrade` 升级的是 Mihomo，不会升级管理脚本本身。更新 `mhm` 可重新执行安装命令：

```bash
curl -fsSL https://raw.githubusercontent.com/xzyone/mhm/main/mhm -o /tmp/mhm
sudo install -m 0755 /tmp/mhm /usr/local/bin/mhm
rm -f /tmp/mhm
mhm --version
```

需要通过本地代理时：

```bash
curl --proxy socks5h://127.0.0.1:12222 \
  -fsSL https://raw.githubusercontent.com/xzyone/mhm/main/mhm \
  -o /tmp/mhm
sudo install -m 0755 /tmp/mhm /usr/local/bin/mhm
```

## 卸载

卸载 Mihomo并保留配置：

```bash
sudo mhm uninstall --yes
```

完全卸载 Mihomo 并删除配置目录：

```bash
sudo mhm uninstall --purge --yes
```

`mhm uninstall` 默认不会删除管理脚本自身。确认不再需要后，可执行：

```bash
sudo rm -f /usr/local/bin/mhm
```

## 支持的架构

- x86_64 / amd64
- arm64 / aarch64
- armv7
- i386 / i686
- riscv64
- s390x
- loongarch64

## 系统要求

- 使用 systemd 的 Linux 发行版
- root 权限
- `curl`
- `gzip`
- `awk`、`sed`、`grep`、`install` 等常用系统工具

缺少 `curl` 或 `gzip` 时，脚本会尝试通过系统包管理器自动安装。

## 常见排查

查看服务状态：

```bash
sudo mhm status
```

检查配置：

```bash
sudo mhm test
```

查看实时日志：

```bash
sudo mhm logs
```

下载失败时，可先检查本地代理是否监听：

```bash
curl --proxy socks5h://127.0.0.1:12222 -I https://github.com
```

也可以临时指定一个确定存在的 Mihomo 版本，以区分“GitHub API 查询失败”和“Release 文件下载失败”：

```bash
sudo MIHOMO_VERSION=vX.Y.Z \
  MIHOMO_DOWNLOAD_PROXY=socks5h://127.0.0.1:12222 \
  mhm upgrade
```

## 免责声明

本项目是第三方管理脚本，与 MetaCubeX 官方无隶属关系。Mihomo 本体及其许可证以 `MetaCubeX/mihomo` 项目为准。
