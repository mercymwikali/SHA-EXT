from pathlib import Path
import re
import zlib


ROOT = Path(__file__).resolve().parents[1]
MD = ROOT / "docs" / "SHA_HLD.md"
PDF = ROOT / "docs" / "SHA_HLD.pdf"


def pdf_escape(text: str) -> str:
    return text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def sanitize(text: str) -> str:
    replacements = {
        "–": "-",
        "—": "-",
        "“": '"',
        "”": '"',
        "’": "'",
        "≤": "<=",
        "≥": ">=",
        "→": "->",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text.encode("latin-1", "replace").decode("latin-1")


def md_to_lines(md: str):
    lines = []
    in_code = False
    for raw in md.splitlines():
        line = raw.rstrip()
        if line.startswith("```"):
            in_code = not in_code
            lines.append("")
            continue
        if in_code:
            lines.append(("mono", line))
            continue
        if not line:
            lines.append("")
            continue
        if line.startswith("# "):
            lines.append(("h1", line[2:]))
        elif line.startswith("## "):
            lines.append(("h2", line[3:]))
        elif line.startswith("### "):
            lines.append(("h3", line[4:]))
        elif line.startswith("- "):
            lines.append(("body", "• " + line[2:]))
        elif re.match(r"^\d+\. ", line):
            lines.append(("body", line))
        elif line.startswith("|"):
            clean = "  ".join(part.strip() for part in line.strip("|").split("|"))
            if set(clean.replace(" ", "")) <= {"-", ":"}:
                continue
            lines.append(("mono", clean))
        else:
            lines.append(("body", line))
    return lines


def wrap_text(text: str, max_chars: int):
    words = text.split(" ")
    out, current = [], ""
    for word in words:
        if not current:
            current = word
        elif len(current) + 1 + len(word) <= max_chars:
            current += " " + word
        else:
            out.append(current)
            current = word
    if current:
        out.append(current)
    return out or [""]


def paginate(items):
    pages = []
    current = []
    y = 770
    for kind_item in items:
        if kind_item == "":
            y -= 10
            current.append(("space", ""))
            continue
        kind, text = kind_item
        font_size = {"h1": 20, "h2": 15, "h3": 12, "mono": 8, "body": 10}[kind]
        leading = {"h1": 26, "h2": 21, "h3": 16, "mono": 11, "body": 13}[kind]
        max_chars = {"h1": 44, "h2": 58, "h3": 72, "mono": 96, "body": 88}[kind]
        wrapped = wrap_text(sanitize(text), max_chars)
        for idx, part in enumerate(wrapped):
            if y < 55:
                pages.append(current)
                current = []
                y = 770
            current.append((kind, part, font_size, leading))
            y -= leading
        if kind in {"h1", "h2"}:
            y -= 4
    if current:
        pages.append(current)
    return pages


def build_pdf(pages):
    objects = []

    def add(obj: bytes):
        objects.append(obj)
        return len(objects)

    font_helv = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    font_bold = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>")
    font_mono = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>")
    page_refs = []
    content_refs = []

    for page_no, page in enumerate(pages, start=1):
        y = 770
        stream_lines = ["BT"]
        for item in page:
            if item[0] == "space":
                y -= 10
                continue
            kind, text, size, leading = item
            font = "/F2" if kind in {"h1", "h2", "h3"} else "/F3" if kind == "mono" else "/F1"
            x = 42 if kind != "mono" else 36
            stream_lines.append(f"{font} {size} Tf")
            stream_lines.append(f"1 0 0 1 {x} {y} Tm ({pdf_escape(text)}) Tj")
            y -= leading
        stream_lines.append("/F1 8 Tf")
        stream_lines.append(f"1 0 0 1 270 28 Tm (Page {page_no}) Tj")
        stream_lines.append("ET")
        raw = "\n".join(stream_lines).encode("latin-1", "replace")
        compressed = zlib.compress(raw)
        content_refs.append(add(b"<< /Length %d /Filter /FlateDecode >>\nstream\n" % len(compressed) + compressed + b"\nendstream"))
        page_refs.append(None)

    pages_ref_placeholder = 0
    for i, content_ref in enumerate(content_refs):
        page_refs[i] = add(
            f"<< /Type /Page /Parent {{PAGES}} 0 R /MediaBox [0 0 612 792] "
            f"/Resources << /Font << /F1 {font_helv} 0 R /F2 {font_bold} 0 R /F3 {font_mono} 0 R >> >> "
            f"/Contents {content_ref} 0 R >>".encode("ascii")
        )

    kids = " ".join(f"{ref} 0 R" for ref in page_refs)
    pages_obj = f"<< /Type /Pages /Kids [{kids}] /Count {len(page_refs)} >>".encode("ascii")
    pages_ref = add(pages_obj)
    catalog_ref = add(f"<< /Type /Catalog /Pages {pages_ref} 0 R >>".encode("ascii"))

    for idx, obj in enumerate(objects):
        objects[idx] = obj.replace(b"{PAGES}", str(pages_ref).encode("ascii"))

    output = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for i, obj in enumerate(objects, start=1):
        offsets.append(len(output))
        output += f"{i} 0 obj\n".encode("ascii") + obj + b"\nendobj\n"
    xref = len(output)
    output += f"xref\n0 {len(objects)+1}\n".encode("ascii")
    output += b"0000000000 65535 f \n"
    for off in offsets[1:]:
        output += f"{off:010d} 00000 n \n".encode("ascii")
    output += (
        f"trailer\n<< /Size {len(objects)+1} /Root {catalog_ref} 0 R >>\n"
        f"startxref\n{xref}\n%%EOF\n"
    ).encode("ascii")
    PDF.write_bytes(output)


if __name__ == "__main__":
    text = MD.read_text(encoding="utf-8")
    pages = paginate(md_to_lines(text))
    build_pdf(pages)
    print(PDF)

