# mhm

`mhm` 是一个面向 systemd Linux 的 Mihomo 命令行管理脚本，用于安装、升级、配置、运行和卸载 Mihomo。

## 功能

- 自动识别 CPU 架构并下载 Mihomo 最新稳定版
- 支持指定 Mihomo 版本，并持久保存 GitHub 下载代理
- 交互设置 GitHub 下载代理、Mixed 代理端口、控制 API 地址及端口、配置目录和 API Secret
- 自动创建并启用 `mihomo.service`
- 保留已有 `config.yaml`，修改前自动备份
- 升级或重启失败时自动回滚二进制、配置和 systemd 服务
- 支持 MetaCubeXD 等浏览器面板连接控制 API
- 支持安装、升级、配置、启停、状态、日志、配置检查和卸载

## 安装 mhm

```bash
curl -fsSL https://raw.githubusercontent.com/xzyone/mhm/main/mhm -o /tmp/mhm
sudo install -m 0755 /tmp/mhm /usr/local/bin/mhm
rm -f /tmp/mhm
sudo mhm
```

也可以下载后手动运行：

```bash
chmod +x mhm
sudo ./mhm
```

> 交互安装依赖 `/dev/tty`，因此不建议直接使用 `curl | bash`。

## 常用命令

```bash
sudo mhm                    # 打开互动菜单
sudo mhm install            # 安装或重新安装 Mihomo
sudo mhm upgrade            # 升级 Mihomo
sudo mhm configure          # 修改下载代理、端口、配置目录和 API Secret
sudo mhm proxy              # 单独设置或清除 GitHub 下载代理
sudo mhm start              # 启动服务
sudo mhm stop               # 停止服务
sudo mhm restart            # 重启服务
sudo mhm status             # 查看版本、服务状态和连接信息
sudo mhm logs               # 查看实时日志
sudo mhm test               # 检查当前配置
sudo mhm uninstall          # 卸载 Mihomo，互动选择是否删除配置
sudo mhm uninstall --yes    # 自动确认卸载并保留配置
sudo mhm uninstall --purge --yes
                            # 自动卸载并删除配置目录
mhm --version               # 查看 mhm 版本
```

## 默认路径和端口

| 项目 | 默认值 |
| --- | --- |
| Mihomo 二进制 | `/usr/local/bin/mihomo` |
| mhm 命令 | `/usr/local/bin/mhm` |
| 配置目录 | `/etc/mihomo` |
| 配置文件 | `/etc/mihomo/config.yaml` |
| mhm 状态文件 | `/etc/mhm.conf` |
| systemd 服务 | `/etc/systemd/system/mihomo.service` |
| Mixed 端口 | `7890` |
| 控制 API | `0.0.0.0:9090` |

## 指定 Mihomo 版本

```bash
sudo MIHOMO_VERSION=v1.19.29 mhm install
sudo MIHOMO_VERSION=v1.19.29 mhm upgrade
```

不设置 `MIHOMO_VERSION` 时，脚本会查询 `MetaCubeX/mihomo` 的最新稳定版。

## 使用 GitHub 下载代理

下载代理可以作为持久设置保存到 `/etc/mhm.conf`：

```bash
sudo mhm proxy
```

按提示输入代理地址，例如：

```text
https://gh-proxy.example
```

之后执行 `mhm install` 或 `mhm upgrade` 时会自动使用该代理。输入 `none`、`off`、`clear` 或 `-` 可以清除设置并恢复直连。

安装流程会在下载 Mihomo 之前先询问代理地址，因此首次安装时也可以直接使用 GitHub 下载代理。

仍然可以通过环境变量临时覆盖已保存的设置：

```bash
sudo MIHOMO_GITHUB_PROXY=https://another-proxy.example mhm upgrade
```

环境变量只对当前命令生效，优先级高于 `/etc/mhm.conf` 中保存的代理。代理地址会作为 GitHub Release 原始下载链接的前缀。

## 配置处理

首次安装且配置目录中没有 `config.yaml` 时，`mhm` 会生成一份最小配置，默认全部直连。已有配置不会被整体覆盖，脚本只更新以下顶层字段：

```yaml
mixed-port: 7890
external-controller: '0.0.0.0:9090'
secret: 'your-secret'
```

修改已有配置前会生成时间戳备份：

```text
/etc/mihomo/config.yaml.bak.YYYYMMDD-HHMMSS
```

## MetaCubeXD

安装完成后，在 MetaCubeXD 中填写：

- 后端地址：`http://服务器IP:控制端口`
- Secret：安装时设置或自动生成的 API Secret

若控制 API 监听 `0.0.0.0` 或 `[::]`，请不要把控制端口直接暴露到公网。建议通过防火墙限制来源地址，或仅在可信局域网内使用。

## 删除 mhm 命令

`mhm uninstall` 默认只卸载 Mihomo，不删除管理脚本本身。确认不再使用后，可执行：

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

## 要求

- 使用 systemd 的 Linux 发行版
- root 权限
- `curl`
- `gzip`、`awk`、`sed`、`grep`、`install` 等常用系统工具

## 免责声明

本项目是第三方管理脚本，与 MetaCubeX 官方无隶属关系。Mihomo 本体及其许可证以 `MetaCubeX/mihomo` 项目为准。
