#!/usr/bin/env bash
# 一键发布到 GitHub Pages
# 用法： ./deploy.sh "改动说明"
set -euo pipefail

cd "$(dirname "$0")"

MSG="${1:-update: 更新简历内容}"

# 1. 重新生成 PDF（Playwright 内置 Chromium）
# 历史：原用 Chrome --print-to-pdf，Chrome 升到 158 后在本机会静默崩溃，改为 make_pdf.py
PDF="陈奇-产品经理-简历.pdf"
echo "→ 重新生成 PDF ..."
rm -f "$PDF"
if command -v python >/dev/null 2>&1; then
  python make_pdf.py || true
fi
if [ ! -f "$PDF" ]; then
  echo "✗ PDF 生成失败，中止发布（避免旧文件带着敏感内容上线）"
  echo "  修复：python -m pip install playwright && python -m playwright install chromium"
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
