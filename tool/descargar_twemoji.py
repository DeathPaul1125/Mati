"""Descarga set Twemoji (colorido, estilo WhatsApp/Twitter) en paralelo a OpenMoji.
   Usa los mismos emojis que el script de OpenMoji."""
import os
import urllib.request
import sys

sys.path.insert(0, os.path.dirname(__file__))
from descargar_openmoji import EMOJIS

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "twemoji")
BASE_URL = "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg"


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    descargados = 0
    fallidos = []
    for emoji, code in EMOJIS.items():
        # Twemoji usa lowercase
        nombre = code.lower()
        out_path = os.path.join(OUT_DIR, f"{nombre}.svg")
        if os.path.exists(out_path):
            descargados += 1
            continue
        url = f"{BASE_URL}/{nombre}.svg"
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
            with open(out_path, "wb") as f:
                f.write(data)
            descargados += 1
            print(f"OK  {emoji} -> {nombre}.svg ({len(data)} bytes)")
        except Exception as e:
            fallidos.append((emoji, code, str(e)))
            print(f"ERR {emoji} ({code}): {e}")

    print(f"\nDescargados: {descargados}/{len(EMOJIS)}")
    if fallidos:
        print("Fallidos:")
        for e, c, err in fallidos:
            print(f"  {e} {c}: {err}")


if __name__ == "__main__":
    main()
