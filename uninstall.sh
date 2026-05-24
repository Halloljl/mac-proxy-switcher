#!/bin/bash
# macOS 终端智能代理切换工具 - 卸载脚本
# https://github.com/Halloljl/mac-proxy-switcher

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🗑️  卸载 macOS 终端代理切换工具...${NC}\n"

# 清理指定配置文件中的代理配置（支持新旧两种格式）
clean_config() {
    local config_file="$1"
    [ ! -f "$config_file" ] && return

    # 先检测是否有需要清理的内容
    if ! grep -q "# === mac-proxy-switcher ===" "$config_file" 2>/dev/null && \
       ! grep -q "auto_set_proxy()" "$config_file" 2>/dev/null; then
        return
    fi

    # 备份
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_file" "$backup_file"
    echo -e "${GREEN}💾 已备份 ${config_file} 到: ${backup_file}${NC}"

    # 新版格式（带 marker 注释）
    if grep -q "# === mac-proxy-switcher ===" "$config_file" 2>/dev/null; then
        sed -i.tmp '/# === mac-proxy-switcher ===/,/# === \/mac-proxy-switcher ===/d' "$config_file"
        rm -f "${config_file}.tmp"
        echo -e "${GREEN}✅ 已从 ${config_file} 中移除代理切换工具配置${NC}"
        return
    fi

    # 旧版格式（# 智能代理 → auto_set_proxy）
    local start_line end_line
    start_line=$(grep -n "智能代理" "$config_file" | head -1 | cut -d: -f1)
    end_line=$(grep -n "^auto_set_proxy$" "$config_file" | tail -1 | cut -d: -f1)

    if [ -n "$start_line" ] && [ -n "$end_line" ] && [ "$end_line" -ge "$start_line" ]; then
        # 包含尾部空行
        local total_lines
        total_lines=$(wc -l < "$config_file")
        while [ "$end_line" -lt "$total_lines" ]; do
            local next_line=$((end_line + 1))
            local next_content
            next_content=$(sed -n "${next_line}p" "$config_file")
            if [ -z "$next_content" ]; then
                end_line=$next_line
            else
                break
            fi
        done
        sed -i.tmp "${start_line},${end_line}d" "$config_file"
        rm -f "${config_file}.tmp"
        echo -e "${GREEN}✅ 已从 ${config_file} 中移除旧版代理配置${NC}"
    fi
}

clean_config "$HOME/.zshrc"
clean_config "$HOME/.bashrc"
clean_config "$HOME/.bash_profile"

echo -e "\n${GREEN}🎉 卸载完成！${NC}"
