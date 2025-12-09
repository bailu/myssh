#!/usr/bin/env bash
#
# 快捷 ssh 登录工具
# - 读取原生 ~/.ssh/config（或通过 MYSSH_CONFIG 指定）
# - 列出 Host / HostName / 注释，支持模糊筛选
# - 若安装了 fzf 优先用模糊选择，否则用序号选择
# - 仅当 Host 唯一匹配时自动登录
#
set -euo pipefail

DATA_FILE="${MYSSH_CONFIG:-$HOME/.ssh/config}"

if [[ ! -r "$DATA_FILE" ]]; then
  echo "找不到可读的 ssh config：$DATA_FILE" >&2
  exit 1
fi

# 解析 ssh config：输出 "Host|HostName|Comment"
parse_output="$(awk '
  /^#/ { last_comment=$0; next }
  $1=="Host" && NF>=2 { host=$2; comment=last_comment; last_comment=""; next }
  $1=="HostName" { if (host!="") { print host "|" $2 "|" comment; host=""; comment="" } }
' "$DATA_FILE")"

ROWS=()
while IFS= read -r line; do
  ROWS+=("$line")
done <<<"$parse_output"

if [[ ${#ROWS[@]} -eq 0 ]]; then
  echo "未在 $DATA_FILE 中找到任何 Host/HostName 配置" >&2
  exit 1
fi

HOSTS=()
HOSTNAMES=()
COMMENTS=()
for row in "${ROWS[@]}"; do
  IFS="|" read -r h hn c <<<"$row"
  HOSTS+=("$h")
  HOSTNAMES+=("$hn")
  COMMENTS+=("${c### }")
done

# 可选的关键词筛选
FILTER="${1-}"
MATCH_INDEX=()
if [[ -n "$FILTER" ]]; then
  lf_filter="$(echo "$FILTER" | tr "[:upper:]" "[:lower:]")"
  for i in "${!HOSTS[@]}"; do
    hlf="$(echo "${HOSTS[$i]}${HOSTNAMES[$i]}" | tr "[:upper:]" "[:lower:]")"
    if [[ "$hlf" == *"$lf_filter"* ]]; then
      MATCH_INDEX+=("$i")
    fi
  done
else
  for i in "${!HOSTS[@]}"; do MATCH_INDEX+=("$i"); done
fi

if [[ ${#MATCH_INDEX[@]} -eq 0 ]]; then
  echo "没有匹配到主机（关键词：$FILTER）" >&2
  exit 1
fi

# 唯一匹配时自动登录
if [[ ${#MATCH_INDEX[@]} -eq 1 ]]; then
  idx=${MATCH_INDEX[0]}
  echo "正在进入 ${HOSTS[$idx]}（${HOSTNAMES[$idx]}）"
  exec ssh "${HOSTS[$idx]}"
fi

render_list() {
  printf "可选主机（总计 %d，关键词：%s）:\n" "${#MATCH_INDEX[@]}" "${FILTER:-<无>}"
  for pos in "${!MATCH_INDEX[@]}"; do
    i=${MATCH_INDEX[$pos]}
    printf "%2d) %-22s %-22s %s\n" "$pos" "${HOSTNAMES[$i]}" "${HOSTS[$i]}" "${COMMENTS[$i]}"
  done
}

# fzf 优先（上下左右/回车直接选中）
if command -v fzf >/dev/null 2>&1; then
  selection_line=$(for pos in "${!MATCH_INDEX[@]}"; do
    i=${MATCH_INDEX[$pos]}
    printf "%s\t%s\t%s\t%s\n" "$pos" "${HOSTNAMES[$i]}" "${HOSTS[$i]}" "${COMMENTS[$i]}"
  done | fzf --with-nth=2,3,4 --prompt="选择主机> " --ansi --no-sort)
  if [[ -z "$selection_line" ]]; then
    echo "已取消选择"
    exit 1
  fi
  select_idx=${selection_line%%$'\t'*}
else
  render_list
  while true; do
    read -rp "请输入需要登录的序号(q 退出)： " select_idx
    if [[ "$select_idx" == "q" ]]; then exit 0; fi
    if [[ "$select_idx" =~ ^[0-9]+$ ]] && (( select_idx < ${#MATCH_INDEX[@]} )); then
      break
    fi
    echo "无效序号，请重试。"
  done
fi

real_idx=${MATCH_INDEX[$select_idx]}
echo "正在进入 ${HOSTS[$real_idx]}（${HOSTNAMES[$real_idx]}）"
exec ssh "${HOSTS[$real_idx]}"
