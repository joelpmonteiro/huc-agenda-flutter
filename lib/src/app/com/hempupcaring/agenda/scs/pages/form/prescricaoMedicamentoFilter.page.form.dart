import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamento.filter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamentoStatus.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/scs/constantsPrescricaoMedicamento.dart';
import 'package:flutter/material.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrescricaoMedicamentoFilterPageForm extends StatefulWidget {
  Function function;
  PrescricaoMedicamentoFilterPageForm(this.function);

  @override
  _PrescricaoMedicamentoFilterPageFormState createState() =>
      _PrescricaoMedicamentoFilterPageFormState();
}

class _PrescricaoMedicamentoFilterPageFormState
    extends State<PrescricaoMedicamentoFilterPageForm> {
  List<DropdownMenuItem> clienteOptionList = [];
  final formKey = GlobalKey<FormState>();
  final clienteDropdownState = GlobalKey<FormFieldState>();
  final txtNomeCtrl = new TextEditingController();
  final txtDataInicioCtrl = new TextEditingController();
  final txtDataFimCtrl = new TextEditingController();
  var _data = "";
  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final statusDropdownState = GlobalKey<FormFieldState>();
  List<DropdownMenuItem> statusOptionList = new ConstantsPrescricaoMedicamento()
      .statusList
      .map<DropdownMenuItem<int>>(
          (PrescricaoMedicamentoStatus prescricaoMedicamentoStatus) {
    return DropdownMenuItem<int>(
      value: prescricaoMedicamentoStatus.valor,
      child: Text(prescricaoMedicamentoStatus.descricao),
    );
  }).toList();

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

      this.findAllClienteRelacionadoByCurrentMedicoId().then((value) => {
            Navigator.pop(context),
          });
    });
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
                hint: Text('Cliente'),
                key: clienteDropdownState,
                items: this.clienteOptionList,
                onChanged: (newValue) {
                  setState(() {});
                },
              ),
              TextFormField(
                controller: txtNomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome Medicamento',
                ),
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
                                      firstDate: DateTime(
                                          DateTime.now().year - 1,
                                          DateTime.now().month,
                                          DateTime.now().day),
                                      lastDate: DateTime(
                                          DateTime.now().year + 1,
                                          DateTime.now().month,
                                          DateTime.now().day))
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
                                      firstDate: DateTime(
                                          DateTime.now().year - 1,
                                          DateTime.now().month,
                                          DateTime.now().day),
                                      lastDate: DateTime(
                                          DateTime.now().year + 1,
                                          DateTime.now().month,
                                          DateTime.now().day))
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
                  onChanged: (newValue) {
                    setState(() {});
                  }),
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
          )),
    );
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

  Future<void> filtrar() async {
    final prefs = await SharedPreferences.getInstance();

    PrescricaoMedicamentoFilter prescricaoMedicamentoFilter =
        new PrescricaoMedicamentoFilter();
    prescricaoMedicamentoFilter.medico = new MedicoModel();
    prescricaoMedicamentoFilter.medico.id = prefs.getString('medico_id');

    prescricaoMedicamentoFilter.cliente = new ClienteModel();
    prescricaoMedicamentoFilter.cliente.id =
        clienteDropdownState.currentState.value;

    prescricaoMedicamentoFilter.nome = txtNomeCtrl.text;
    if (txtDataInicioCtrl.text != null &&
        txtDataInicioCtrl.text.trim().isNotEmpty)
      prescricaoMedicamentoFilter.dataInicio = DateTime.parse(
          txtDataInicioCtrl.text.split("/")[2] +
              "-" +
              txtDataInicioCtrl.text.split("/")[1] +
              "-" +
              txtDataInicioCtrl.text.split("/")[0]);

    if (txtDataFimCtrl.text != null && txtDataFimCtrl.text.trim().isNotEmpty)
      prescricaoMedicamentoFilter.dataFim = DateTime.parse(
          txtDataFimCtrl.text.split("/")[2] +
              "-" +
              txtDataFimCtrl.text.split("/")[1] +
              "-" +
              txtDataFimCtrl.text.split("/")[0]);

    prescricaoMedicamentoFilter.status = statusDropdownState.currentState.value;

    Navigator.pop(context);
    widget.function(prescricaoMedicamentoFilter);
  }
}
