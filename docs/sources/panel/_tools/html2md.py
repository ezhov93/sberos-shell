#!/usr/bin/env python3
"""Конвертер вики-страницы (Confluence HTTrack HTML) в markdown-черновик.

Выдаёт структурированный MD с:
  * декодированными HTML-entity (html.unescape);
  * заголовками h1-h6;
  * таблицами (требования FT_/UI_) — ячейками по строкам;
  * параграфами и списками как текст;
  * изображениями-скринами как ![alt](screenshots/<basename>).

Назначение — подготовить читаемый черновик для последующей ручной (агентной)
перефразировки. Исходный HTML не изменяется.
"""
import html as html_lib
import re
import sys
from bs4 import BeautifulSoup, NavigableString, Tag

SCREENSHOT_DIR = "screenshots"


def clean_text(node):
    """Рекурсивно собрать текст с элемента, декодируя entity и сохраняя переносы."""
    if isinstance(node, NavigableString):
        return html_lib.unescape(str(node)).strip()
    return "".join(clean_text(c) for c in node.children).strip()


def img_markup(node):
    """Вернуть markdown-разметку для <img>, ссылаясь на скрин по имени файла."""
    src = node.get("src", "") or ""
    alt = clean_text(node) or node.get("alt", "") or ""
    # Берём только имя файла (basename) — скрины сложены в converted/screenshots/
    fname = src.split("/")[-1]
    caption = alt.split("/")[-1]
    caption = re.sub(r"\s+", " ", caption).strip()
    return f"![{caption}]({SCREENSHOT_DIR}/{fname})"


def emit_text(node, out, indent_list=False):
    """Обойти контейнер node и выписать текст/списки/картинки в out (list[str])."""
    for child in node.children:
        if isinstance(child, NavigableString):
            t = html_lib.unescape(str(child)).strip()
            if t:
                out.append(t)
            continue
        if not isinstance(child, Tag):
            continue
        name = child.name.lower()
        if name == "img":
            out.append(img_markup(child))
        elif name in ("p", "div", "br"):
            if child.name == "br":
                out.append("")
            else:
                emit_text(child, out)
        elif name in ("ul", "ol"):
            for li in child.find_all("li", recursive=False):
                inner = []
                emit_text(li, inner)
                txt = " ".join(inner).strip()
                if txt:
                    out.append(("- " if child.name == "ul" else "1. ") + txt)
        elif name in ("strong", "b"):
            inner = []
            emit_text(child, inner)
            t = " ".join(inner).strip()
            if t:
                out.append(f"**{t}**")
        elif name in ("em", "i"):
            inner = []
            emit_text(child, inner)
            t = " ".join(inner).strip()
            if t:
                out.append(f"*{t}*")
        elif name in ("table", "tbody", "thead", "tfoot", "tr", "td", "th") \
                or re.fullmatch(r"h[1-6]", name):
            # Таблицы обрабатываются отдельно в convert_table; заголовки в этих
            # контейнерах не ожидаются — пропускаем
            continue
        else:
            emit_text(child, out)


def convert_table(table):
    """Вернуть список строк markdown-таблицы + списка строк требований."""
    rows = []
    for tr in table.find_all("tr", recursive=True):
        cells = []
        for cell in tr.find_all(["td", "th"], recursive=False):
            out = []
            emit_text(cell, out)
            # схлопнуть повторные пустые строки
            lines = [l for l in out if l.strip()]
            cells.append(" ".join(lines).strip())
        if cells and any(c for c in cells):
            rows.append(cells)
    return rows


def count_images(node):
    return sum(1 for _ in node.find_all("img"))


def main(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        soup = BeautifulSoup(f.read(), "lxml")

    body = soup.find("body") or soup
    out = []

    def walk(node):
        for child in node.children:
            if isinstance(child, NavigableString):
                continue
            if not isinstance(child, Tag):
                continue
            name = child.name.lower()
            if name in ("script", "style", "head", "link", "meta"):
                continue
            if name == "img":
                src = (child.get("src") or "").lower()
                if "jira.sberbank.ru" in src or "viewavatar" in src:
                    continue  # служебная иконка статуса задачи Jira — не скрин
                out.append(img_markup(child))
            elif re.fullmatch(r"h[1-6]", name):
                txt = clean_text(child)
                if not txt:
                    continue
                level = int(name[1])
                out.append("\n" + "#" * level + " " + txt)
            elif name == "table":
                walk_table(child)
            elif name in ("div", "blockquote", "section", "article", "body", "main"):
                walk(child)
            elif name in ("p", "ul", "ol", "pre"):
                frag = []
                emit_text(child, frag)
                lines = [l for l in frag if l.strip()]
                if lines:
                    out.append("\n".join(lines).strip())
            elif name in ("strong", "b", "em", "i", "span", "a", "code", "font"):
                txt = clean_text(child)
                if txt:
                    out.append(txt)
            else:
                walk(child)

    def walk_table(table):
        rows = convert_table(table)
        if not rows:
            return
        out.append("")
        # первая строка — шапка (Индекс|Статус|Требование|Трассировка|Автор) или контент
        out.append(" | ".join(rows[0]))
        out.append("---")
        for r in rows[1:]:
            out.append(" | ".join(r))
        out.append("")

    walk(body)

    text = "\n".join(out)
    # чистим множественные пустые строки
    text = re.sub(r"\n{3,}", "\n\n", text)
    print(text)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: html2md.py <file.html>")
    main(sys.argv[1])