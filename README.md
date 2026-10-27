# 陈奇 · 在线简历

产品经理 / 解决方案顾问 · 制造业研发数字化 · BOM / PLM

单页静态站点，无构建依赖，直接由 GitHub Pages 托管。

- `index.html` — 在线简历（响应式，支持深色模式与 A4 打印）
- `陈奇-产品经理-简历.pdf` — 两页 PDF 版
- `陈奇-产品经理-简历.docx` — 可编辑 Word 版

## 本地预览

```bash
python -m http.server 8080
# 打开 http://localhost:8080
```

## 修改内容

直接用编辑器改 `index.html` 里的文本，然后重新生成 PDF：

```bash
chrome --headless=new --no-pdf-header-footer \
  --print-to-pdf="陈奇-产品经理-简历.pdf" index.html
```

打印样式在 `@media print` 段，两页版式已调好，改动文字后请确认仍是 2 页。
