import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamentoStatus.model.dart';

class ConstantsPrescricaoMedicamento {

  ConstantsPrescricaoMedicamento();

  final int STATUS_SOLICITADO = 0;

  final int STATUS_APROVADO = 1;

  final int STATUS_REPROVADO = 2;

  final List<PrescricaoMedicamentoStatus> statusList = [
    new PrescricaoMedicamentoStatus(valor: 0, descricao: 'Solicitado'),
    new PrescricaoMedicamentoStatus(valor: 1, descricao: 'Aprovado'),
    new PrescricaoMedicamentoStatus(valor: 2, descricao: 'Reprovado')
  ];

}