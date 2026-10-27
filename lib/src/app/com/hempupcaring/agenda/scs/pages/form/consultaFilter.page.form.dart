import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consulta.filter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consultaStatus.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/scs/constantsConsulta.dart';
import 'package:flutter/material.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart'
    as medicoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;

class ConsultaFilterPageForm extends StatefulWidget {
  String clienteId;
  String medicoId;

  Function function;
  ConsultaFilterPageForm(this.clienteId, this.medicoId, this.function);

  @override
  _ConsultaFilterPageFormState createState() =>
      _ConsultaFilterPageFormState(this.clienteId, this.medicoId);
}

class _ConsultaFilterPageFormState extends State<ConsultaFilterPageForm> {
  String clienteId;
  String medicoId;

  _ConsultaFilterPageFormState(this.clienteId, this.medicoId);

  final formKey = GlobalKey<FormState>();
  final clienteDropdownState = GlobalKey<FormFieldState>();
  final medicoDropdownState = GlobalKey<FormFieldState>();
  final statusDropdownState = GlobalKey<FormFieldState>();
  List<DropdownMenuItem> medicoOptionList = [];
  List<DropdownMenuItem> clienteOptionList = [];
  List<DropdownMenuItem> statusOptionList = new ConstantsConsulta()
      .statusList
      .map<DropdownMenuItem<int>>((ConsultaStatus consultaStatus) {
    return DropdownMenuItem<int>(
      value: consultaStatus.valor,
      child: Text(consultaStatus.descricao),
    );
  }).toList();

  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final txtDataInicioCtrl = new TextEditingController();
  final txtDataFimCtrl = new TextEditingController();
  var _data = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: new Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  new Padding(
                    padding:
                        EdgeInsets.only(bottom: 0, left: 0, right: 20, top: 0),
                    child: new CircularProgressIndicator(),
                  ),
                  new Text('Carregando, aguarde ...'),
                ],
              ),
            ),
          );
        },
      );
    });

    if (this.clienteId != null) {
      this.findOneClienteByCurrentCliente().then((value) => {
            this
                .findAllMedicoRelacionadoByCurrentClienteId()
                .then((value) => {Navigator.pop(context)})
          });
    } else {
      this.findOneMedicoByCurrentMedico().then((value) => {
            this
                .findAllClienteRelacionadoByCurrentMedicoId()
                .then((value) => {Navigator.pop(context)})
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: formKey,
      child: Column(
        children: [
          DropdownButtonFormField(
            icon: Icon(
              Icons.arrow_downward,
              color: Color(0xFF486832),
            ),
            iconSize: 24,
            elevation: 16,
            hint: Text('Médico'),
            key: medicoDropdownState,
            items: this.medicoOptionList,
            onChanged: (newValue) {
              setState(() {});
            },
          ),
          DropdownButtonFormField(
            icon: Icon(
              Icons.arrow_downward,
              color: Color(0xFF486832),
            ),
            iconSize: 24,
            elevation: 16,
            hint: Text('Cliente'),
            key: clienteDropdownState,
            items: this.clienteOptionList,
            onChanged: (newValue) {
              setState(() {});
            },
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    controller: txtDataInicioCtrl,
                    decoration: InputDecoration(
                      labelText: 'Inicio',
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Color(0xFF486832),
                        ),
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year - 1,
                                      DateTime.now().month, DateTime.now().day),
                                  lastDate: DateTime(DateTime.now().year + 1,
                                      DateTime.now().month, DateTime.now().day))
                              .then((_date) {
                            setState(() {
                              _data = dataUtil.montarData(_date.day,
                                  _date.month, _date.year, "dd/MM/yyyy");
                              txtDataInicioCtrl.text = _data;
                            });
                          });
                        },
                      ),
                    ),
                    inputFormatters: [_dateMaskFormatter],
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    controller: txtDataFimCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fim',
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Color(0xFF486832),
                        ),
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year - 1,
                                      DateTime.now().month, DateTime.now().day),
                                  lastDate: DateTime(DateTime.now().year + 1,
                                      DateTime.now().month, DateTime.now().day))
                              .then((_date) {
                            setState(() {
                              _data = dataUtil.montarData(_date.day,
                                  _date.month, _date.year, "dd/MM/yyyy");
                              txtDataFimCtrl.text = _data;
                            });
                          });
                        },
                      ),
                    ),
                    inputFormatters: [_dateMaskFormatter],
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField(
            icon: Icon(
              Icons.arrow_downward,
              color: Color(0xFF486832),
            ),
            iconSize: 24,
            key: statusDropdownState,
            elevation: 16,
            hint: Text('Status'),
            items: this.statusOptionList,
            onChanged: changeStatus,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                filtrar();
              },
              child: Text(
                "Filtrar",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ])
        ],
      ),
    ));
  }

  void filtrar() {
    ConsultaFilter consultaFilter = new ConsultaFilter();

    consultaFilter.cliente = new ClienteModel();
    consultaFilter.cliente.id = clienteDropdownState.currentState.value;

    consultaFilter.medico = new MedicoModel();
    consultaFilter.medico.id = medicoDropdownState.currentState.value;
    
    if (txtDataInicioCtrl.text != null &&
        txtDataInicioCtrl.text.trim().isNotEmpty)
      consultaFilter.dataInicio = DateTime.parse(
          txtDataInicioCtrl.text.split("/")[2] +
              "-" +
              txtDataInicioCtrl.text.split("/")[1] +
              "-" +
              txtDataInicioCtrl.text.split("/")[0]);
    
    if (txtDataFimCtrl.text != null && txtDataFimCtrl.text.trim().isNotEmpty)
      consultaFilter.dataFim = DateTime.parse(
          txtDataFimCtrl.text.split("/")[2] +
              "-" +
              txtDataFimCtrl.text.split("/")[1] +
              "-" +
              txtDataFimCtrl.text.split("/")[0]);

    consultaFilter.status = statusDropdownState.currentState.value;

    Navigator.pop(context);
    widget.function(consultaFilter);
  }

  void changeStatus(newValue) {
    setState(() {});
  }

  Future<void> findOneClienteByCurrentCliente() async {
    var response = await clienteService.findOneByCurrentClienteId();

    setState(() {
      clienteOptionList.add(DropdownMenuItem(
          child: Text(response.usuario.nome), value: response.id));
      this.clienteDropdownState.currentState.didChange(response.id);
    });
  }

  Future<void> findAllMedicoRelacionadoByCurrentClienteId() async {
    var response = await medicoService.findAllRelacionadoByCurrentClienteId();

    setState(() {
      medicoOptionList = response
          .map((medico) => DropdownMenuItem(
              child: Text(medico.usuario.nome), value: medico.id))
          .toList();
    });
  }

  Future<void> findOneMedicoByCurrentMedico() async {
    var response = await medicoService.getCurrent();

    setState(() {
      medicoOptionList.add(DropdownMenuItem(
          child: Text(response.usuario.nome), value: response.id));
      this.medicoDropdownState.currentState.didChange(response.id);
    });
  }

  Future<void> findAllClienteRelacionadoByCurrentMedicoId() async {
    var response = await clienteService.findAllRelacionadoByCurrentMedicoId();

    setState(() {
      clienteOptionList = response
          .map((cliente) => DropdownMenuItem(
              child: Text(cliente.usuario.nome), value: cliente.id))
          .toList();
    });
  }
}
