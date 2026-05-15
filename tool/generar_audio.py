"""Genera MP3s con Edge TTS (voz neural) para todas las frases de la app."""
import asyncio
import os
import edge_tts

VOZ = "es-CR-MariaNeural"  # Femenina, Costa Rica, cálida y natural
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")

LETRAS = [
    ("a", "A. Árbol"),
    ("b", "B. Banana"),
    ("c", "C. Cachorro"),
    ("d", "D. Dulce"),
    ("e", "E. Elefante"),
    ("f", "F. Fresa"),
    ("g", "G. Gato"),
    ("h", "H. Helado"),
    ("i", "I. Iguana"),
    ("j", "J. Jirafa"),
    ("k", "K. Koala"),
    ("l", "L. León"),
    ("m", "M. Manzana"),
    ("n", "N. Nube"),
    ("nn", "Ñ. Ñandú"),
    ("o", "O. Oso"),
    ("p", "P. Pizza"),
    ("q", "Q. Queso"),
    ("r", "R. Ratón"),
    ("s", "S. Sol"),
    ("t", "T. Tigre"),
    ("u", "U. Uva"),
    ("v", "V. Vaca"),
    ("w", "W. Wifi"),
    ("x", "X. Xilófono"),
    ("y", "Y. Yate"),
    ("z", "Z. Zorro"),
]

NUMEROS = [
    ("1", "Uno"),
    ("2", "Dos"),
    ("3", "Tres"),
    ("4", "Cuatro"),
    ("5", "Cinco"),
    ("6", "Seis"),
    ("7", "Siete"),
    ("8", "Ocho"),
    ("9", "Nueve"),
    ("10", "Diez"),
]

COLORES = [
    ("rojo", "Rojo"),
    ("azul", "Azul"),
    ("verde", "Verde"),
    ("amarillo", "Amarillo"),
    ("naranja", "Naranja"),
    ("morado", "Morado"),
    ("rosa", "Rosa"),
    ("negro", "Negro"),
    ("blanco", "Blanco"),
    ("cafe", "Café"),
]

FORMAS = [
    ("circulo", "Círculo"),
    ("cuadrado", "Cuadrado"),
    ("triangulo", "Triángulo"),
    ("estrella", "Estrella"),
    ("corazon", "Corazón"),
    ("rombo", "Rombo"),
    ("rectangulo", "Rectángulo"),
    ("ovalo", "Óvalo"),
]

ANIMALES = [
    ("perro", "Perro"),
    ("gato", "Gato"),
    ("raton", "Ratón"),
    ("conejo", "Conejo"),
    ("zorro", "Zorro"),
    ("oso", "Oso"),
    ("panda", "Panda"),
    ("leon", "León"),
    ("tigre", "Tigre"),
    ("elefante", "Elefante"),
    ("jirafa", "Jirafa"),
    ("koala", "Koala"),
    ("vaca", "Vaca"),
    ("pollito", "Pollito"),
    ("mariposa", "Mariposa"),
    ("pez", "Pez"),
    ("pajaro", "Pájaro"),
    ("abeja", "Abeja"),
]

DONDE_ESTA = [
    ("perro", "¿Dónde está el perro?"),
    ("gato", "¿Dónde está el gato?"),
    ("conejo", "¿Dónde está el conejo?"),
    ("zorro", "¿Dónde está el zorro?"),
    ("oso", "¿Dónde está el oso?"),
    ("leon", "¿Dónde está el león?"),
    ("elefante", "¿Dónde está el elefante?"),
    ("mariposa", "¿Dónde está la mariposa?"),
    ("manzana", "¿Dónde está la manzana?"),
    ("banana", "¿Dónde está la banana?"),
    ("fresa", "¿Dónde está la fresa?"),
    ("pelota", "¿Dónde está la pelota?"),
    ("sol", "¿Dónde está el sol?"),
    ("luna", "¿Dónde está la luna?"),
    ("estrella", "¿Dónde está la estrella?"),
    ("flor", "¿Dónde está la flor?"),
    ("carro", "¿Dónde está el carro?"),
    ("avion", "¿Dónde está el avión?"),
]

FRASES = {
    "instr_colores": "Toca un color para escucharlo.",
    "instr_formas": "Toca una forma para escucharla.",
    "instr_animales": "Toca un animal para escucharlo.",
    "instr_donde_esta": "Escucha y toca el dibujo correcto.",
    "lo_encontraste": "¡Lo encontraste!",
    "instr_trazar": "Desliza el dedo sobre la letra.",
    "muy_bien": "¡Muy bien!",
    "muy_bien_largo": "¡Excelente! ¡Lo lograste!",
    "intentalo_otra_vez": "Inténtalo otra vez.",
    "hola": "¡Hola! ¿Vamos a jugar?",
    "instr_letras_aprender": "Toca una letra para escucharla.",
    "instr_numeros_aprender": "Toca un número para escucharlo.",
    "instr_contar": "¿Cuántos hay? Arrastra el número correcto.",
    "instr_memoria": "Encuentra las parejas.",
    "instr_logica": "¿Cuál es diferente? Arrástralo a la papelera.",
    "instr_lectura": "¿Con qué letra empieza?",
    "instr_clasificar": "Coloca cada cosa en su caja.",
    "instr_sombras": "Encuentra la sombra de cada dibujo.",
    "instr_pintar": "Pinta lo que tú quieras.",
}


async def generar(texto: str, salida: str):
    if os.path.exists(salida):
        return
    com = edge_tts.Communicate(
        text=texto,
        voice=VOZ,
        rate="-10%",
        pitch="+0Hz",
    )
    await com.save(salida)
    print(f"OK  {os.path.basename(salida)} <- {texto!r}")


async def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    tareas = []
    for clave, texto in LETRAS:
        tareas.append(generar(texto, os.path.join(OUT_DIR, f"letra_{clave}.mp3")))
    for clave, texto in NUMEROS:
        tareas.append(
            generar(f"{clave}. {texto}", os.path.join(OUT_DIR, f"numero_{clave}.mp3"))
        )
    for clave, texto in COLORES:
        tareas.append(generar(texto, os.path.join(OUT_DIR, f"color_{clave}.mp3")))
    for clave, texto in FORMAS:
        tareas.append(generar(texto, os.path.join(OUT_DIR, f"forma_{clave}.mp3")))
    for clave, texto in ANIMALES:
        tareas.append(generar(texto, os.path.join(OUT_DIR, f"animal_{clave}.mp3")))
    for clave, texto in DONDE_ESTA:
        tareas.append(
            generar(texto, os.path.join(OUT_DIR, f"donde_{clave}.mp3"))
        )
    for clave, texto in FRASES.items():
        tareas.append(generar(texto, os.path.join(OUT_DIR, f"{clave}.mp3")))
    await asyncio.gather(*tareas)
    archivos = os.listdir(OUT_DIR)
    total = sum(os.path.getsize(os.path.join(OUT_DIR, f)) for f in archivos)
    print(f"\nGenerados: {len(archivos)} archivos, {total/1024:.1f} KB total")


if __name__ == "__main__":
    asyncio.run(main())
