"""Descarga los SVGs de OpenMoji para todos los emojis usados en la app."""
import os
import urllib.request

EMOJIS = {
    # Frutas
    "🍎": "1F34E", "🍌": "1F34C", "🍇": "1F347", "🍓": "1F353",
    "🍊": "1F34A", "🍉": "1F349", "🍒": "1F352", "🥝": "1F95D",

    # Animales
    "🐶": "1F436", "🐱": "1F431", "🐭": "1F42D", "🐹": "1F439",
    "🐰": "1F430", "🦊": "1F98A", "🐻": "1F43B", "🐼": "1F43C",
    "🦁": "1F981", "🐯": "1F42F", "🐠": "1F420", "🐝": "1F41D",
    "🐘": "1F418", "🦋": "1F98B", "🐀": "1F400",

    # Vehículos
    "🚗": "1F697", "🚌": "1F68C", "🚜": "1F69C", "🚲": "1F6B2",
    "✈️": "2708", "🚂": "1F682", "🛵": "1F6F5", "⛵": "26F5",

    # Comida
    "🍔": "1F354", "🍕": "1F355", "🌮": "1F32E", "🍣": "1F363",
    "🍩": "1F369", "🍪": "1F36A", "🍫": "1F36B", "🥪": "1F96A",
    "🍦": "1F366",

    # Ropa
    "👕": "1F455", "👖": "1F456", "👗": "1F457", "🧦": "1F9E6",
    "👟": "1F45F", "🧢": "1F9E2", "🧤": "1F9E4", "🧥": "1F9E5",

    # Instrumentos
    "🎸": "1F3B8", "🥁": "1F941", "🎹": "1F3B9", "🎺": "1F3BA",
    "🎻": "1F3BB", "🪕": "1FA95", "🪗": "1FA97", "🎷": "1F3B7",

    # Naturaleza y objetos
    "🌳": "1F333", "🌸": "1F338", "🌹": "1F339", "🌺": "1F33A",
    "🌵": "1F335", "🌞": "1F31E", "🌙": "1F319", "⭐": "2B50",
    "🎈": "1F388", "🏠": "1F3E0",

    # Menú y UI
    "🔢": "1F522", "🧠": "1F9E0", "🧩": "1F9E9", "📚": "1F4DA",
    "🎨": "1F3A8", "📦": "1F4E6", "👤": "1F464", "🧺": "1F9FA",
    "🧳": "1F9F3", "🗑": "1F5D1", "🎉": "1F389", "💭": "1F4AD",
    "✨": "2728", "💫": "1F4AB", "🌟": "1F31F",

    # Bebé / aprendizaje
    "🍰": "1F370",

    # Animales adicionales
    "🦒": "1F992", "🐨": "1F428", "🐮": "1F42E", "🐥": "1F425",
    "🐦": "1F426", "🐟": "1F41F",

    # Avatares premium para la tienda
    "🦓": "1F993", "🐢": "1F422", "🐙": "1F419", "🐲": "1F432",
    "🦄": "1F984", "🦖": "1F996", "🦩": "1F9A9", "🐳": "1F433",
    "🦘": "1F998", "🦔": "1F994",

    # Faltantes para Aprender Letras y otros
    "🦎": "1F98E", "☁": "2601", "🦤": "1F9A4", "🧀": "1F9C0",
    "📶": "1F4F6", "🎵": "1F3B5", "🎷": "1F3B7",
    "➕": "2795", "➖": "2796",
}

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "openmoji")
BASE_URL = "https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/color/svg"


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    descargados = 0
    fallidos = []
    for emoji, code in EMOJIS.items():
        out_path = os.path.join(OUT_DIR, f"{code}.svg")
        if os.path.exists(out_path):
            descargados += 1
            continue
        url = f"{BASE_URL}/{code}.svg"
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
            with open(out_path, "wb") as f:
                f.write(data)
            descargados += 1
            print(f"OK  {emoji} -> {code}.svg ({len(data)} bytes)")
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
