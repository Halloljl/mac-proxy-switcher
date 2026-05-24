#!/bin/bash
# macOS 终端智能代理切换工具 - 卸载脚本
# https://github.com/Halloljl/mac-proxy-switcher

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="$HOME/.zshrc"

echo -e "${YELLOW}🗑️  卸载 macOS 终端代理切换工具...${NC}\n"

if [ -f "$CONFIG_FILE" ]; then
    # 备份
    BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}💾 已备份配置到: ${BACKUP_FILE}${NC}"

    # 移除配置块
    sed -i.tmp '/# === mac-proxy-switcher ===/,/# === \/mac-proxy-switcher ===/d' "$CONFIG_FILE"
    rm -f "${CONFIG_FILE}.tmp"

    echo -e "${GREEN}✅ 已从 ${CONFIG_FILE} 中移除代理切换工具配置${NC}"
else
    echo -e "${YELLOW}⚠️  未找到配置文件 ${CONFIG_FILE}${NC}"
fi

echo -e "\n${GREEN}🎉 卸载完成！${NC}"
