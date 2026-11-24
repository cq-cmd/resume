# -*- coding: utf-8 -*-
"""把 index.html 渲染成简历 PDF。

用途：deploy.sh 的 PDF 生成步骤。
历史：原先用 Chrome 命令行 --print-to-pdf，Chrome 升到 158 后在该环境下静默崩溃
（生成 Crashpad 转储、无输出），改由 Playwright 内置 Chromium 渲染。

依赖：python -m pip install playwright && python -m playwright install chromium
"""
import pathlib
import sys

from playwright.sync_api import sync_playwright

ROOT = pathlib.Path(__file__).resolve().parent
SRC = ROOT / "index.html"
OUT = ROOT / "陈奇-产品经理-简历.pdf"


def main() -> int:
    if not SRC.exists():
        print(f"✗ 找不到 {SRC}")
        return 1

    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--disable-gpu"])
        page = browser.new_page(viewport={"width": 1000, "height": 1400})
        page.emulate_media(media="print")
        page.goto(SRC.as_uri(), wait_until="load")
        page.wait_for_timeout(1200)
        # 滚动进场动画会让元素初始 opacity:0，强制置为可见，否则会印出空白
        page.evaluate("document.querySelectorAll('.reveal').forEach(e=>e.classList.add('in'))")
        page.wait_for_timeout(300)
        page.pdf(
            path=str(OUT),
            print_background=True,
            prefer_css_page_size=True,
            margin={"top": "0", "bottom": "0", "left": "0", "right": "0"},
        )
        browser.close()

    size = OUT.stat().st_size
    print(f"✓ {OUT.name}  {size / 1024:.0f} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
