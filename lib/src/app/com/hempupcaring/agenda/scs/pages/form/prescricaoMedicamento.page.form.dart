import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamento.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/list/prescricaoMedicamento.page.list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/services/prescricaoMedicamento.service.dart'
    as prescricaoMedicamentoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/constants/prescricaoMedicamento.constants.dart';

class PrescricaoMedicamentoPageForm extends StatefulWidget {
  @override
  PrescricaoMedicamentoPageFormState createState() =>
      PrescricaoMedicamentoPageFormState(
          this.prescricaoMedicamento, this.isNovoRegistro);

  Function function;
  PrescricaoMedicamentoModel prescricaoMedicamento;
  bool isNovoRegistro;

  PrescricaoMedicamentoPageForm(
      this.isNovoRegistro, this.prescricaoMedicamento);
}

class PrescricaoMedicamentoPageFormState
    extends State<PrescricaoMedicamentoPageForm> {
  PrescricaoMedicamentoModel prescricaoMedicamento;
  bool isNovoRegistro;
  bool hasValue = false;
  final formKey = GlobalKey<FormState>();
  final clienteDropdownState = GlobalKey<FormFieldState>();
  final txtIdCtrl = new TextEditingController();
  final txtStatusCtrl = new TextEditingController();
  final txtDataHoraSolicitacaoCtrl = new TextEditingController();
  List<DropdownMenuItem> clienteOptionList = [];
  final txtNomeCtrl = new TextEditingController();
  final txtDescricaoCtrl = new TextEditingController();

  PrescricaoMedicamentoPageFormState(
      this.prescricaoMedicamento, this.isNovoRegistro);

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
            if (!this.isNovoRegistro) {
              this.txtIdCtrl.text = this.prescricaoMedicamento.id,
              this.txtStatusCtrl.text = this.prescricaoMedicamento.status.toString(),
              this.txtDataHoraSolicitacaoCtrl.text = this.prescricaoMedicamento.dataHoraSolicitacao.toLocal().toString(),
              this.txtNomeCtrl.text = this.prescricaoMedicamento.nome,
              this.txtDescricaoCtrl.text = this.prescricaoMedicamento.descricao,

              for (DropdownMenuItem opcao in clienteOptionList) {
                if (opcao.value == this.prescricaoMedicamento.cliente.id) {
                  this.hasValue = true
                }
              },

              if (this.hasValue) {
                this.clienteDropdownState.currentState.didChange(this.prescricaoMedicamento.cliente.id)
              }
            },
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
            key: formKey,
            child: Column(children: [
              Visibility(
                visible: false,
                child: TextFormField(
                  controller: txtIdCtrl,
                  readOnly: true,
                ),
              ),
              Visibility(
                visible: false,
                child: TextFormField(
                  controller: txtStatusCtrl,
                  readOnly: true,
                ),
              ),
              Visibility(
                visible: false,
                child: TextFormField(
                  controller: txtDataHoraSolicitacaoCtrl,
                  readOnly: true,
                ),
              ),
              TextFormField(
                controller: txtNomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome Medicamento',
                ),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo nome medicamento é obrigatório';
                  }
                  return null;
                },
                enabled: this.isNovoRegistro,
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
                  onChanged: this.isNovoRegistro ? (newValue) {
                    setState(() {});
                  } : null,
                  validator: (value) {
                    if (value == null) {
                      return 'Campo cliente é obrigatório';
                    }
                    return null;
                  }),
              TextFormField(
                controller: txtDescricaoCtrl,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo descrição é obrigatório';
                  }
                  return null;
                },
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
                    salvar();
                  },
                  child: Text(
                    "Salvar",
                  ),
                ),
              ])
            ])));
  }

  Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();
    var errorObj;
    var errorMsg;

    if (formKey.currentState.validate()) {
      openLoadingDialog(this.context);

      PrescricaoMedicamentoModel prescricaoMedicamento =
          new PrescricaoMedicamentoModel();
      prescricaoMedicamento.id =
          (txtIdCtrl.text != null || txtIdCtrl.text.isNotEmpty)
              ? txtIdCtrl.text
              : null;
      prescricaoMedicamento.nome = txtNomeCtrl.text;
      prescricaoMedicamento.cliente = new ClienteModel();
      prescricaoMedicamento.cliente.id =
          clienteDropdownState.currentState.value;
      prescricaoMedicamento.descricao = txtDescricaoCtrl.text;
      prescricaoMedicamento.medico = new MedicoModel();
      prescricaoMedicamento.medico.id = prefs.getString('medico_id');
      prescricaoMedicamento.status =
          (txtStatusCtrl.text != null && txtStatusCtrl.text.isNotEmpty)
              ? int.parse(txtStatusCtrl.text)
              : PrescricaoMedicamentoConstants.STATUS_SOLICITADO;
      prescricaoMedicamento.dataHoraSolicitacao = (txtDataHoraSolicitacaoCtrl.text != null && txtDataHoraSolicitacaoCtrl.text.isNotEmpty) ? DateTime.parse(txtDataHoraSolicitacaoCtrl.text) : null;

      prescricaoMedicamentoService
          .save(prescricaoMedicamento)
          .then((value) => {
                Navigator.pop(this.context),
                Navigator.pop(this.context),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PrescricaoMedicamentoPageList(),
                  ),
                ),
              })
          .catchError((error) => {
                errorObj = error = json.decode(error.body),
                errorMsg =
                    utf8.decode(errorObj['message'].toString().codeUnits),
                Navigator.pop(this.context),
                widget.function(this.context, errorMsg)
              });
    }
  }

  void openLoadingDialog(BuildContext context) {
    showDialog(
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
