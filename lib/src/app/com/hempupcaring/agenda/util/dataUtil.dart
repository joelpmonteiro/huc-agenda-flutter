
montarHorario(int hora, int minuto, String formato) {
  var horaConvertido = hora.toString();
  var minutoConvertido = minuto.toString();
  var horarioMontado;

  if (horaConvertido.length == 1) {
    horaConvertido = "0" + horaConvertido;
  }

  if (minutoConvertido.length == 1) {
    minutoConvertido = "0" + minutoConvertido;
  }

  if (formato == "hh:mm") {
    horarioMontado = horaConvertido + ":" + minutoConvertido;
  }

  return horarioMontado;
}

montarData(int dia, int mes, int ano, String formato) {
  var _diaConvertido = dia.toString();
  var _mesConvertido = mes.toString();
  var _anoConvertido = ano.toString();
  var _dataMontada;

  if (_diaConvertido.length == 1) {
    _diaConvertido = "0" + _diaConvertido;
  }

  if (_mesConvertido.length == 1) {
    _mesConvertido = "0" + _mesConvertido;
  }

  if (formato == "dd/MM/yyyy") {
    _dataMontada = _diaConvertido + "/" + _mesConvertido + "/" + _anoConvertido;
  }
  else if (formato == "yyyy-MM-dd") {
    _dataMontada = _anoConvertido + "-" + _mesConvertido + "-" + _diaConvertido;
  }

  return _dataMontada;
}

formatarDataToJson(String data, String formato) {
  var dia;
  var mes;
  var ano;
  var dataFormatada;

  if (formato == "dd/MM/yyyy") {
    dia = data.split("/")[0];
    mes = data.split("/")[1];
    ano = data.split("/")[2];
  }

  dataFormatada = ano + "-" + mes + "-" + dia;

  return dataFormatada;
}