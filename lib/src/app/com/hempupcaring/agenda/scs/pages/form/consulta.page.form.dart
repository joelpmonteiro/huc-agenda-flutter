import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consulta.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/list/consulta.page.list.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/scs/constantsConsulta.dart';
import 'package:flutter/material.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart'
    as medicoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/services/consulta.service.dart'
    as consultaService;
import 'dart:convert';

class ConsultaPageForm extends StatefulWidget {
  String clienteId;
  String medicoId;
  bool isNovoRegistro;
  ConsultaModel consulta;

  Function function;
  ConsultaPageForm(this.clienteId, this.medicoId, this.isNovoRegistro,
      this.consulta, this.function);

  @override
  ConsultaPageFormState createState() => ConsultaPageFormState(
      this.clienteId, this.medicoId, this.isNovoRegistro, this.consulta);
}

class ConsultaPageFormState extends State<ConsultaPageForm> {
  String clienteId;
  String medicoId;
  bool isNovoRegistro;
  ConsultaModel consulta;

  ConsultaPageFormState(
      this.clienteId, this.medicoId, this.isNovoRegistro, this.consulta);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final clienteDropdownState = GlobalKey<FormFieldState>();
  final medicoDropdownState = GlobalKey<FormFieldState>();
  final statusDropdownState = GlobalKey<FormFieldState>();
  final txtIdCtrl = new TextEditingController();
  bool isStatusDisabled = false;
  bool isMedicoDisabled = false;
  bool isClienteDisabled = false;
  bool hasValue = false;
  List<DropdownMenuItem> medicoOptionList = [];
  List<DropdownMenuItem> clienteOptionList = [];
  List<DropdownMenuItem> statusOptionList = ConstantsConsulta()
      .statusList
      .map((status) =>
          DropdownMenuItem(child: Text(status.descricao), value: status.valor))
      .toList();
  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final txtDataCtrl = new TextEditingController();
  var _data = "";
  var _timeMaskFormatter = new MaskTextInputFormatter(
      mask: '##:##', filter: {"#": RegExp(r'[0-9]')});
  final txtHorarioCtrl = new TextEditingController();
  var _horario = "";
  final txtObservacaoCtrl = new TextEditingController();

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

      if (this.isNovoRegistro) {
        this.statusDropdownState.currentState.didChange(0);
      } else {
        this.statusDropdownState.currentState.didChange(this.consulta.status);

        this.txtDataCtrl.text = dataUtil.montarData(
            this.consulta.dataHoraMarcada.day,
            this.consulta.dataHoraMarcada.month,
            this.consulta.dataHoraMarcada.year,
            "dd/MM/yyyy");

        this.txtHorarioCtrl.text = dataUtil.montarHorario(
            this.consulta.dataHoraMarcada.hour,
            this.consulta.dataHoraMarcada.minute,
            "hh:mm");

        this.txtObservacaoCtrl.text = this.consulta.observacao;
      }
      this.isStatusDisabled = true;

      if (this.clienteId != null) {
        this.findOneClienteByCurrentCliente().then((value) => {
              this.isClienteDisabled = true,
              this
                  .findAllMedicoRelacionadoByCurrentClienteId()
                  .then((value) => {
                        Navigator.pop(context),
                        if (!this.isNovoRegistro || (this.isNovoRegistro && this.consulta != null && this.consulta.horario != null && this.consulta.horario.medico != null)) {

                          for (DropdownMenuItem opcao in medicoOptionList) {
                            if (opcao.value == this.consulta.horario.medico.id) {
                              this.hasValue = true
                            }
                          },

                          if (this.hasValue) {
                            this.medicoDropdownState.currentState.didChange(this.consulta.horario.medico.id),
                            this.isMedicoDisabled = true
                          }
                        },
                    })
            });
      } else {
        this.findOneMedicoByCurrentMedico().then((value) => {
              this.isMedicoDisabled = true,
              this.findAllClienteRelacionadoByCurrentMedicoId().then((value) => {
                
                Navigator.pop(context),
                if ((!this.isNovoRegistro || (this.isNovoRegistro && this.consulta != null && this.consulta.cliente != null))) {

                    for (DropdownMenuItem opcao in clienteOptionList) {
                      if (opcao.value == this.consulta.cliente.id) {
                        this.hasValue = true
                      }
                    },

                    if (this.hasValue) {
                      this.clienteDropdownState.currentState.didChange(this.consulta.cliente.id),
                      this.isClienteDisabled = true
                    }
                },
              })
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: formKey,
      child: Column(
        children: [
          Visibility(
            visible: false,
            child: TextFormField(
              controller: txtIdCtrl,
              readOnly: true,
            ),
          ),
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
              onChanged: !this.isMedicoDisabled
                  ? (newValue) {
                      setState(() {});
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Campo médico é obrigatório';
                }
                return null;
              }),
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
              onChanged: !this.isClienteDisabled
                  ? (newValue) {
                      setState(() {});
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Campo cliente é obrigatório';
                }
                return null;
              }),
          Column(
            children: [
              TextFormField(
                controller: txtDataCtrl,
                decoration: InputDecoration(
                  labelText: 'Data',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF486832),
                    ),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: (!this.isNovoRegistro && this.consulta.dataHoraMarcada.isAfter(DateTime.now())) ? this.consulta.dataHoraMarcada : DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1,
                                  DateTime.now().month, DateTime.now().day))
                          .then((_date) {
                        setState(() {
                          _data = dataUtil.montarData(
                              _date.day, _date.month, _date.year, "dd/MM/yyyy");
                          txtDataCtrl.text = _data;
                        });
                      });
                    },
                  ),
                ),
                inputFormatters: [_dateMaskFormatter],
                keyboardType: TextInputType.number,
                readOnly: true,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo data é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: txtHorarioCtrl,
                decoration: InputDecoration(
                  labelText: 'Horário',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.access_time,
                      color: Color(0xFF486832),
                    ),
                    onPressed: () {
                      showTimePicker(
                        context: context,
                        initialTime: !this.isNovoRegistro ? TimeOfDay.fromDateTime(consulta.dataHoraMarcada) : TimeOfDay.now(),
                      ).then((_time) {
                        setState(() {
                          _horario = dataUtil.montarHorario(
                              _time.hour, _time.minute, "hh:mm");
                          txtHorarioCtrl.text = _horario;
                        });
                      });
                    },
                  ),
                ),
                inputFormatters: [_timeMaskFormatter],
                keyboardType: TextInputType.number,
                readOnly: true,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo horário é obrigatório';
                  }
                  return null;
                },
              )
            ],
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
            onChanged: !this.isStatusDisabled
                ? (newValue) {
                    changeStatus(newValue);
                  }
                : null,
            validator: (value) {
              if (value == null) {
                return 'Campo status é obrigatório';
              }
              return null;
            },
          ),
          TextFormField(
            controller: txtObservacaoCtrl,
            decoration: InputDecoration(labelText: 'Observação'),
            maxLines: 2,
            keyboardType: TextInputType.multiline,
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
        ],
      ),
    ));
  }

  changeStatus(newValue) {
    setState(() {});
  }

  void _openLoadingDialog(BuildContext context) {
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

  void salvar() {
    var errorObj;
    var errorMsg;

    if (formKey.currentState.validate()) {
      _openLoadingDialog(this.context);

      var consultaToSave = {
        'id': null,
        'medico': {'id': medicoDropdownState.currentState.value},
        'cliente': {'id': clienteDropdownState.currentState.value},
        'dataMarcada': txtDataCtrl.text.split("/")[2] +
            "-" +
            txtDataCtrl.text.split("/")[1] +
            "-" +
            txtDataCtrl.text.split("/")[0],
        'horarioMarcado': txtHorarioCtrl.text + ':00',
        'status': statusDropdownState.currentState.value,
        'observacao': txtObservacaoCtrl.text
      };

      if (this.isNovoRegistro) {
        consultaService
            .save(consultaToSave)
            .then((value) => {
                  Navigator.pop(this.context),
                  Navigator.pop(this.context),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ConsultaPageList(),
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
      } else {
        consultaToSave['id'] = this.consulta.id;

        consultaService
            .remarcar(consultaToSave)
            .then((value) => {
                  Navigator.pop(this.context),
                  Navigator.pop(this.context),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ConsultaPageList(),
                    ),
                  ),
                })
            .catchError((error) => {
                  errorObj = error = json.decode(error.body),
                  errorMsg =
                      utf8.decode(errorObj['message'].toString().codeUnits),
                  Navigator.pop(this.context),
                  Navigator.pop(this.context),
                  widget.function(this.context, errorMsg)
                });
      }
    }
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

  Future<void> findAllClienteRelacionadoByCurrentMedicoId() async {
    var response = await clienteService.findAllRelacionadoByCurrentMedicoId();

    setState(() {
      clienteOptionList = response
          .map((cliente) => DropdownMenuItem(
              child: Text(cliente.usuario.nome), value: cliente.id))
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
}
