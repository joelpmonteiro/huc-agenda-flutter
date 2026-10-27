class HorarioConstants {

  static final String DIA_SEMANA_DOMINGO = "Domingo";
  static final String DIA_SEMANA_SEGUNDA_FEIRA = "Segunda-Feira";
  static final String DIA_SEMANA_TERCA_FEIRA = "Terça-Feira";
  static final String DIA_SEMANA_QUARTA_FEIRA = "Quarta-Feira";
  static final String DIA_SEMANA_QUINTA_FEIRA = "Quinta-Feira";
  static final String DIA_SEMANA_SEXTA_FEIRA = "Sexta-Feira";
  static final String DIA_SEMANA_SABADO = "Sabado";

  static getDiaSemanaIndex(String diaSemana) {

    if (diaSemana == DIA_SEMANA_DOMINGO)
      return 7;
    else if (diaSemana == DIA_SEMANA_SEGUNDA_FEIRA)
      return 1;
    else if (diaSemana == DIA_SEMANA_TERCA_FEIRA)
      return 2;
    else if (diaSemana == DIA_SEMANA_QUARTA_FEIRA)
      return 3;
    else if (diaSemana == DIA_SEMANA_QUINTA_FEIRA)
      return 4;
    else if (diaSemana == DIA_SEMANA_SEXTA_FEIRA)
      return 5;
    else if (diaSemana == DIA_SEMANA_SABADO)
      return 6;
    else
      return -1;

  }

  static getDiaSemana(int diaSemanaIndex) {

    if (diaSemanaIndex == 7)
      return DIA_SEMANA_DOMINGO;
    else if (diaSemanaIndex == 1)
      return DIA_SEMANA_SEGUNDA_FEIRA;
    else if (diaSemanaIndex == 2)
      return DIA_SEMANA_TERCA_FEIRA;
    else if (diaSemanaIndex == 3)
      return DIA_SEMANA_QUARTA_FEIRA;
    else if (diaSemanaIndex == 4)
      return DIA_SEMANA_QUINTA_FEIRA;
    else if (diaSemanaIndex == 5)
      return DIA_SEMANA_SEXTA_FEIRA;
    else if (diaSemanaIndex == 6)
      return DIA_SEMANA_SABADO;

  }

}