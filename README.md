# 🦀 macOS 终端智能代理切换工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-Sonoma%2B-success)](https://www.apple.com/macos)

一键安装，自动检测 Clash 状态，让你彻底告别手动配置代理的烦恼。

## ✨ 特性

- 🤖 **智能检测**：打开终端自动检测 Clash 是否运行
- 🔄 **手动切换**：需要时一键开启/关闭
- 🎯 **零配置**：开箱即用，默认适配 Clash 端口
- 📦 **轻量级**：纯 Shell 实现，无依赖（除系统自带 `nc`）
- 🎨 **友好提示**：彩色输出，清晰的状态反馈

## 🚀 快速安装

### 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/Halloljl/mac-proxy-switcher/main/install.sh | bash
```

### 手动安装

```bash
git clone https://github.com/Halloljl/mac-proxy-switcher.git
cd mac-proxy-switcher
chmod +x install.sh
./install.sh
```

## 📖 使用指南

### 基础命令

| 命令 | 说明 |
|---|---|
| `proxy` | 强制开启代理 |
| `noproxy` | 强制关闭代理 |
| `proxy-refresh` | 重新检测并自动设置 |
| `proxy-status` | 查看当前代理状态 |
| `proxy-test` | 测试代理连通性 |
| `proxy-help` | 显示帮助信息 |

### 自动化工作流

1. **打开终端**：自动检测 Clash → 自动开启/关闭代理
2. **手动干预**：运行 `noproxy` 临时关闭，运行 `proxy` 重新开启
3. **切换后重新检测**：Clash 重启后，运行 `proxy-refresh`

### 配置自定义端口

编辑 `~/.zshrc`，修改以下变量：

```bash
PROXY_HOST="127.0.0.1"     # 代理主机地址
PROXY_HTTP_PORT="7890"     # HTTP 代理端口（Clash 默认）
PROXY_SOCKS_PORT="7891"    # SOCKS5 代理端口（Clash 默认）
```

## 🗑️ 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/Halloljl/mac-proxy-switcher/main/uninstall.sh | bash
```

或

```bash
cd mac-proxy-switcher
./uninstall.sh
```

## ❓ 常见问题

### Q: 为什么用 HTTP 代理而不是 SOCKS5？

A: HTTP 代理兼容性更好，`brew`、`git`、`npm` 等工具对 HTTP 代理支持最完善。

### Q: 自动检测不工作怎么办？

A: 确保已安装 `netcat`：`brew install netcat`

### Q: 修改配置后如何生效？

A: 执行 `source ~/.zshrc` 或重新打开终端。

### Q: 支持其他代理软件吗？

A: 支持！修改 `PROXY_HTTP_PORT` 为你的代理软件端口即可（如 Surge 的 6152）。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎 Issue 和 PR！
