#!/usr/bin/env bash
# 一键发布到 GitHub Pages
# 用法： ./deploy.sh "改动说明"
set -euo pipefail

cd "$(dirname "$0")"

MSG="${1:-update: 更新简历内容}"

# 1. 重新生成 PDF（需要 Chrome）
# 注意：Chrome 不认 Git Bash 的 /c/... 路径，必须转成 Windows 路径，否则静默失败
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
PDF="陈奇-产品经理-简历.pdf"
if [ -x "$CHROME" ]; then
  echo "→ 重新生成 PDF ..."
  WIN_HTML="$(cygpath -w "$(pwd)/index.html")"
  WIN_PDF="$(cygpath -w "$(pwd)/$PDF")"
  rm -f "$PDF"
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
    --virtual-time-budget=7000 \
    --print-to-pdf="$WIN_PDF" \
    "file:///$WIN_HTML" 2>&1 | grep -i "written\|error" || true
  if [ ! -f "$PDF" ]; then
    echo "✗ PDF 生成失败，中止发布（避免旧文件带着敏感内容上线）"
    exit 1
  fi
else
  echo "✗ 未找到 Chrome，无法重新生成 PDF，中止发布"
  exit 1
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
