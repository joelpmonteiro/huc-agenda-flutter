import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consultaStatus.model.dart';

class ConstantsConsulta {

  ConstantsConsulta();

  final int STATUS_PENDENTE = 0;

  final int STATUS_AGENDADO = 1;

  final int STATUS_CANCELADO = 2;

  final int STATUS_EM_ANDAMENTO = 3;

  final int STATUS_FINALIZADO = 4;

  final int STATUS_REAGENDADO = 5;

  final List<ConsultaStatus> statusList = [
    new ConsultaStatus(valor: 0, descricao: 'Pendente'),
    new ConsultaStatus(valor: 1, descricao: 'Agendado'),
    new ConsultaStatus(valor: 2, descricao: 'Cancelado'),
    new ConsultaStatus(valor: 3, descricao: 'Em Andamento'),
    new ConsultaStatus(valor: 4, descricao: 'Finalizado'),
    new ConsultaStatus(valor: 5, descricao: 'Reagendado')
  ];

}