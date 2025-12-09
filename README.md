# myssh
快捷 ssh 登录工具：根据原生 ssh config 列出主机，选择后快速登录。

## 安装
```bash
# 克隆或下载后，确保脚本可执行
chmod +x ~/myssh.sh
# 创建全局命令
ln -s ~/myssh.sh /usr/local/bin/myssh
```

## 使用
```bash
# 直接列出并选择
myssh

# 关键词筛选（匹配 Host/HostName，唯一匹配会自动登录）
myssh prod
myssh 10.1.2.

# 指定自定义 config
MYSSH_CONFIG=~/work/ssh/config myssh
```

- 若安装了 `fzf`，将自动进入模糊选择；否则使用序号选择。
- 列表展示：HostName / Host / 注释（取自 Host 前一行的 `# ...`）。
- 仅当找到唯一匹配时自动登录；否则提示选择。