class Dificultad {
  final int edad;
  const Dificultad(this.edad);

  factory Dificultad.deEdad(int edad) => Dificultad(edad);

  bool get esPreescolar => edad <= 4;
  bool get esBasica => edad >= 5 && edad <= 6;
  bool get esAvanzada => edad >= 7;

  int get matMin => 1;
  int get matMax => esPreescolar ? 5 : (esBasica ? 10 : 15);
  int get matOpciones => esPreescolar ? 2 : 3;

  int get memoriaParejas => esPreescolar ? 3 : (esBasica ? 6 : 8);
  int get memoriaColumnas => esPreescolar ? 3 : 4;

  int get logicaOpciones => esPreescolar ? 4 : 6;

  int get clasificarCajas => esPreescolar ? 2 : (esBasica ? 3 : 4);
  int get clasificarItemsPorCaja => esPreescolar ? 2 : 3;

  int get sombrasItems => esPreescolar ? 2 : (esBasica ? 3 : 4);

  int get lecturaOpciones => esPreescolar ? 2 : 3;

  String get etiqueta {
    if (esPreescolar) return 'Preescolar';
    if (esBasica) return 'Básico';
    return 'Avanzado';
  }
}
