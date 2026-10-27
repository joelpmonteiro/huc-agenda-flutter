class ConstantRelacaoClienteMedico {
  ConstantRelacaoClienteMedico();

  final int ALVO_CLIENTE = 0;

  final int ALVO_MEDICO = 1;

  int getAlvoCliente() {
    return this.ALVO_CLIENTE;
  }

  int getAlvoMedico() {
    return this.ALVO_MEDICO;
  }

}