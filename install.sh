#!/bin/bash
# macOS 终端智能代理切换工具 - 安装脚本
# https://github.com/Halloljl/mac-proxy-switcher

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROXY_HOST="127.0.0.1"
PROXY_HTTP_PORT="7890"
PROXY_SOCKS_PORT="7891"
CONFIG_FILE="$HOME/.zshrc"
BACKUP_FILE=""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  🦀 macOS 终端智能代理切换工具${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# 检测登录 shell（新终端用哪个 shell，就写哪个配置文件）
if [ "$(uname)" = "Darwin" ]; then
    LOGIN_SHELL=$(dscl . -read /Users/$(whoami) UserShell 2>/dev/null | awk '{print $2}')
else
    LOGIN_SHELL="${SHELL:-$0}"
fi

case "$LOGIN_SHELL" in
    *zsh*)
        SHELL_TYPE="zsh"
        CONFIG_FILE="$HOME/.zshrc"
        ;;
    *bash*)
        SHELL_TYPE="bash"
        CONFIG_FILE="$HOME/.bashrc"
        ;;
    *)
        echo -e "${YELLOW}⚠️  未检测到 zsh 或 bash，默认使用 zsh 配置${NC}"
        SHELL_TYPE="zsh"
        CONFIG_FILE="$HOME/.zshrc"
        ;;
esac

echo -e "${BLUE}📝 检测到登录 Shell: ${SHELL_TYPE}${NC}"
echo -e "${BLUE}📝 配置文件: ${CONFIG_FILE}${NC}\n"

# 备份原有配置
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}💾 备份原有配置到: ${BACKUP_FILE}${NC}"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# 检测是否已安装，已安装则清理旧配置
if grep -q "# === mac-proxy-switcher ===" "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  检测到已有安装，将更新配置...${NC}\n"
    sed -i.tmp '/# === mac-proxy-switcher ===/,/# === \/mac-proxy-switcher ===/d' "$CONFIG_FILE"
    rm -f "${CONFIG_FILE}.tmp"
fi

# 写入配置
echo -e "${GREEN}📝 写入配置到 ${CONFIG_FILE}...${NC}\n"

cat >> "$CONFIG_FILE" << 'EOF'

# === mac-proxy-switcher ===
# macOS 终端智能代理切换工具
# 项目地址: https://github.com/Halloljl/mac-proxy-switcher

# 配置参数（可根据需要修改）
PROXY_HOST="127.0.0.1"
PROXY_HTTP_PORT="7890"
PROXY_SOCKS_PORT="7891"

# 自动检测并设置代理
auto_set_proxy() {
    if nc -z "$PROXY_HOST" "$PROXY_HTTP_PORT" 2>/dev/null; then
        export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export no_proxy="localhost,127.0.0.1,::1,*.local"
        # SOCKS5 代理（供特殊工具使用）
        export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
        # 大写版本（某些工具需要）
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        export NO_PROXY="$no_proxy"
        export ALL_PROXY="$all_proxy"
        echo "✅ [proxy-switcher] 代理已自动开启 (http://${PROXY_HOST}:${PROXY_HTTP_PORT})"
    else
        unset http_proxy https_proxy all_proxy no_proxy
        unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
    fi
}

# 手动强制开启代理
proxy() {
    export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
    export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
    export no_proxy="localhost,127.0.0.1,::1,*.local"
    export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export NO_PROXY="$no_proxy"
    export ALL_PROXY="$all_proxy"
    echo "✅ [proxy-switcher] 代理已强制开启"
}

# 手动强制关闭代理
noproxy() {
    unset http_proxy https_proxy all_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
    echo "❌ [proxy-switcher] 代理已强制关闭"
}

# 刷新代理状态（重新检测）
proxy-refresh() {
    echo "🔄 [proxy-switcher] 重新检测代理状态..."
    auto_set_proxy
}

# 查看当前代理状态
proxy-status() {
    if [ -n "$http_proxy" ]; then
        echo "📡 [proxy-switcher] 当前代理状态: 已开启"
        echo "   http_proxy:  $http_proxy"
        echo "   https_proxy: $https_proxy"
        echo "   all_proxy:   $all_proxy"
    else
        echo "📡 [proxy-switcher] 当前代理状态: 已关闭"
    fi
}

# 测试代理是否生效
proxy-test() {
    echo "🌐 [proxy-switcher] 测试代理连通性..."
    if [ -n "$http_proxy" ]; then
        echo "   使用代理: $http_proxy"
        curl -s --max-time 5 https://ip.sb || echo "   ⚠️  连接失败"
        echo ""
    else
        echo "   ⚠️  代理未开启，请先运行 'proxy' 或 'proxy-refresh'"
    fi
}

# 显示帮助信息
proxy-help() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🦀 macOS 终端智能代理切换工具"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  proxy          - 强制开启代理"
    echo "  noproxy        - 强制关闭代理"
    echo "  proxy-refresh  - 重新检测并自动设置"
    echo "  proxy-status   - 查看当前代理状态"
    echo "  proxy-test     - 测试代理连通性"
    echo "  proxy-help     - 显示此帮助信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  💡 提示: 每次打开新终端会自动检测 Clash 状态"
    echo "  🔧 配置: 修改 PROXY_HOST/PORT 变量来自定义端口"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 自动运行检测（每次打开终端）
auto_set_proxy

# === /mac-proxy-switcher ===
EOF

echo -e "${GREEN}✅ 配置写入完成！${NC}\n"

# 检查 nc 命令
if ! command -v nc &> /dev/null; then
    echo -e "${YELLOW}⚠️  未检测到 'nc' (netcat) 命令${NC}"
    echo -e "${YELLOW}   自动检测功能可能无法工作，请安装 netcat:${NC}"
    echo -e "${BLUE}   brew install netcat${NC}\n"
fi

# 加载新配置
echo -e "${BLUE}🔄 加载新配置...${NC}"
# shellcheck source=/dev/null
source "$CONFIG_FILE" || true

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ 安装成功！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${BLUE}📚 可用命令:${NC}"
echo -e "  ${GREEN}proxy${NC}         - 强制开启代理"
echo -e "  ${GREEN}noproxy${NC}       - 强制关闭代理"
echo -e "  ${GREEN}proxy-refresh${NC} - 重新检测自动设置"
echo -e "  ${GREEN}proxy-status${NC}  - 查看当前状态"
echo -e "  ${GREEN}proxy-test${NC}    - 测试代理连通性"
echo -e "  ${GREEN}proxy-help${NC}    - 显示帮助信息\n"

echo -e "${YELLOW}💡 提示:${NC}"
echo -e "  • 每次打开新终端会自动检测 Clash 状态"
echo -e "  • 如需修改代理端口，编辑 ${CONFIG_FILE} 中的 PROXY_HTTP_PORT 变量"
echo -e "  • 备份文件已保存至: ${BACKUP_FILE}"
echo -e "  • 在当前终端执行 ${BLUE}source ${CONFIG_FILE}${NC} 立即启用命令\n"

# 询问是否测试
if [ -t 0 ]; then
    read -p "是否立即测试代理连通性？(y/n): " -n 1 -r
echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        proxy-test
    fi
else
    echo -e "${BLUE}💡 提示: 运行 'proxy-test' 可测试代理连通性${NC}"
fi

echo -e "\n${GREEN}🎉 安装完成！享受智能代理切换吧~${NC}\n"
