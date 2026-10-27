import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';

class PrescricaoMedicamentoFilter {

  ClienteModel cliente;
  MedicoModel medico;
  DateTime dataInicio;
  DateTime dataFim;
  String nome;
  int status;

  PrescricaoMedicamentoFilter({this.cliente, this.medico, this.dataInicio, this.dataFim, this.nome, this.status});

  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente,
      'medico': medico != null ? medico : null,
      'dataInicio': dataInicio != null ? dataInicio.toString().split(" ")[0] : '',
      'dataFim': dataFim != null ? dataFim.toString().split(" ")[0] : '',
      'nome': nome,
      'status': status
    };
  }

}