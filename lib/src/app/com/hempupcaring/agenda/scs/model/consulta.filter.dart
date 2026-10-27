import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';

class ConsultaFilter {

  ClienteModel cliente;
  MedicoModel medico;
  DateTime dataInicio;
  DateTime dataFim;
  int status; 

  ConsultaFilter({this.cliente, this.medico, this.dataInicio, this.dataFim, this.status});

  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente,
      'medico': medico != null ? medico : null,
      'dataInicio': dataInicio != null ? dataInicio.toString().split(" ")[0] : '',
      'dataFim': dataFim != null ? dataFim.toString().split(" ")[0] : '',
      'status': status
    };
  }

}