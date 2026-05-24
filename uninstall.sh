#!/bin/bash
# macOS 终端智能代理切换工具 - 卸载脚本
# https://github.com/Halloljl/mac-proxy-switcher

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🗑️  卸载 macOS 终端代理切换工具...${NC}\n"

# 清理指定配置文件中的代理切换工具配置（支持新旧两种格式）
clean_config() {
    local config_file="$1"
    [ ! -f "$config_file" ] && return

    # 用 Python 检测并移除代理配置块（兼容新旧格式）
    python3 -c "
import sys
path = '$config_file'
with open(path) as f:
    lines = f.readlines()

# 检测是否有代理切换工具配置
has_new = any('# === mac-proxy-switcher ===' in l for l in lines)
has_old = any('auto_set_proxy()' in l for l in lines)
if not has_new and not has_old:
    sys.exit(0)

# 定位并移除配置块
if has_new:
    start = next(i for i, l in enumerate(lines) if '# === mac-proxy-switcher ===' in l)
    end = next(i for i, l in enumerate(lines) if '# === /mac-proxy-switcher ===' in l)
else:
    start = next(i for i, l in enumerate(lines) if '智能代理' in l)
    end = next(i for i, l in enumerate(lines) if l.strip() == 'auto_set_proxy' and i > start)

# 包含尾部空行
while end + 1 < len(lines) and lines[end + 1].strip() == '':
    end += 1

new_lines = lines[:start] + lines[end+1:]
import shutil
shutil.copy2(path, path + '.backup.' + __import__('datetime').datetime.now().strftime('%Y%m%d_%H%M%S'))
with open(path, 'w') as f:
    f.writelines(new_lines)
print('cleaned')
" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 已清理 ${config_file} 中的代理切换工具配置${NC}"
    fi
}

clean_config "$HOME/.zshrc"
clean_config "$HOME/.bashrc"
clean_config "$HOME/.bash_profile"

echo -e "\n${GREEN}🎉 卸载完成！${NC}"
