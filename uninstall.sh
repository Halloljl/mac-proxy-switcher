#!/bin/bash
# macOS 终端智能代理切换工具 - 卸载脚本
# https://github.com/Halloljl/mac-proxy-switcher

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🗑️  卸载 macOS 终端代理切换工具...${NC}\n"

# 检测当前 shell 并清理对应的配置文件
clean_config() {
    local config_file="$1"
    if [ ! -f "$config_file" ]; then
        return
    fi
    if ! grep -q "# === mac-proxy-switcher ===" "$config_file" 2>/dev/null; then
        return
    fi

    # 备份
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_file" "$backup_file"
    echo -e "${GREEN}💾 已备份 ${config_file} 到: ${backup_file}${NC}"

    # 移除配置块
    sed -i.tmp '/# === mac-proxy-switcher ===/,/# === \/mac-proxy-switcher ===/d' "$config_file"
    rm -f "${config_file}.tmp"

    echo -e "${GREEN}✅ 已从 ${config_file} 中移除代理切换工具配置${NC}"
}

clean_config "$HOME/.zshrc"
clean_config "$HOME/.bashrc"
clean_config "$HOME/.bash_profile"

echo -e "\n${GREEN}🎉 卸载完成！${NC}"
