#!/usr/bin/env bash
# 一键发布到 GitHub Pages
# 用法： ./deploy.sh "改动说明"
set -euo pipefail

cd "$(dirname "$0")"

MSG="${1:-update: 更新简历内容}"

# 1. 重新生成 PDF（需要 Chrome；不存在则跳过，保留已有 PDF）
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
if [ -x "$CHROME" ]; then
  echo "→ 重新生成 PDF ..."
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
    --virtual-time-budget=6000 \
    --print-to-pdf="陈奇-产品经理-简历.pdf" \
    "file://$(pwd)/index.html" >/dev/null 2>&1
else
  echo "! 未找到 Chrome，跳过 PDF 生成"
fi

# 2. 提交
git add -A
if git diff --cached --quiet; then
  echo "= 没有改动需要提交"
else
  git commit -m "$MSG"
fi

# 3. 同时推送 main 与 gh-pages（Pages 从 gh-pages 发布）
echo "→ 推送 main ..."
git push origin main
echo "→ 同步 gh-pages ..."
git push origin main:gh-pages --force

echo "✓ 完成： https://cq-cmd.github.io/resume/"
