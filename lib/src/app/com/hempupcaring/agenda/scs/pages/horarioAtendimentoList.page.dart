import 'package:flutter/material.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:agenda/widgets/expansion-panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/services/horarioAtendimento.service.dart'
    as horarioService;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/constants/horario.constants.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/horarioAtendimentoModel.dart';

class HorarioAtendimentoListPage extends StatefulWidget {
  _HorarioAtendimentoListPageState createState() =>
      _HorarioAtendimentoListPageState();
}

class _HorarioAtendimentoListPageState
    extends State<HorarioAtendimentoListPage> {
  TimeOfDay tempoObtido;
  TimeOfDay time;
  String comboDiaSemana;

  TimeOfDay inicioPrimeiroHorario;
  TimeOfDay fimPrimeiroHorario;
  TimeOfDay inicioSegundoHorario;
  TimeOfDay fimSegundoHorario;

  List<CustomExpansionPanel> horarioPainelExpansivoList = [];

  final txtInicioPrimeiroHorarioCtrl = new TextEditingController();
  final txtFimPrimeiroHorarioCtrl = new TextEditingController();
  final txtInicioSegundoHorarioCtrl = new TextEditingController();
  final txtFimSegundoHorarioCtrl = new TextEditingController();
  final txtIdCtrl = new TextEditingController();

  final _horarioAtendimentoFormKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    this.findAllHorarioByMedicoId();
  }

  List<DropdownMenuItem<String>> diaSemanaList = [
    'Domingo',
    'Segunda-Feira',
    'Terça-Feira',
    'Quarta-Feira',
    'Quinta-Feira',
    'Sexta-Feira',
    'Sabado'
  ].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  Future<TimeOfDay> timePicker(BuildContext context) async {
    time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        tempoObtido = time;
        return tempoObtido;
      });
    }
  }

  ListView List_Criteria;

  Widget build(BuildContext context) {
    List_Criteria = ListView.builder(
      itemCount: horarioPainelExpansivoList.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpansionPanelList(
          animationDuration: Duration(milliseconds: 1000),
          dividerColor: Colors.red,
          elevation: 1,
          children: [
            ExpansionPanel(
              body: Container(
                  padding: EdgeInsets.all(10),
                  child: horarioPainelExpansivoList[index].body),
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: horarioPainelExpansivoList[index].header,
                );
              },
              isExpanded: horarioPainelExpansivoList[index].expanded,
            )
          ],
          expansionCallback: (int item, bool status) {
            setState(() {
              horarioPainelExpansivoList[index].expanded =
                  !horarioPainelExpansivoList[index].expanded;
            });
          },
        );
      },
    );
    WillPopScope willPopScope = WillPopScope(
      child: Scaffold(
        drawer: NavDrawer(),
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Horário de Atendimento",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
        body: List_Criteria,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            this._openHorarioAtendimentoForm(context, null);
          },
          child: new Icon(Icons.add),
        ),
      ),
    );

    return willPopScope;
  }

  void _openHorarioAtendimentoForm(
      BuildContext context, HorarioAtendimentoModel horarioAtendimentoModel) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: horarioAtendimentoModel == null ? Text("Novo Horário") : Text("Editar Horário"),
            content: Form(
              key: _horarioAtendimentoFormKey,
              child: Column(
                children: <Widget>[
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
                    hint: Text('Dia da Semana'),
                    onChanged: (newValue) {
                      setState(() {
                        comboDiaSemana = newValue;
                      });
                    },
                    value: horarioAtendimentoModel != null
                        ? HorarioConstants.getDiaSemana(
                            horarioAtendimentoModel.diaSemana)
                        : null,
                    items: diaSemanaList,
                    validator: (value) {
                      if (comboDiaSemana == null) {
                        return 'Campo estado é obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextFormField(
                            controller: txtInicioPrimeiroHorarioCtrl,
                            onTap: () {
                              timePicker(context).then((value) => {
                                    txtInicioPrimeiroHorarioCtrl.text =
                                        tempoObtido.format(context)
                                  });
                            },
                            decoration: InputDecoration(
                              labelText: 'Das',
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Campo inicio primeiro horário é obrigatório';
                              } else if (!horarioAtendimentoValidate(
                                  txtInicioPrimeiroHorarioCtrl.text,
                                  txtFimPrimeiroHorarioCtrl.text)) {
                                return 'Horário de inicio deve vir antes do final';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextFormField(
                            controller: txtFimPrimeiroHorarioCtrl,
                            onTap: () {
                              timePicker(context).then((value) => {
                                    txtFimPrimeiroHorarioCtrl.text =
                                        tempoObtido.format(context)
                                  });
                            },
                            decoration: InputDecoration(
                              labelText: 'às',
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Campo fim primeiro horário é obrigatório';
                              } else if (!horarioAtendimentoValidate(
                                  txtInicioPrimeiroHorarioCtrl.text,
                                  txtFimPrimeiroHorarioCtrl.text)) {
                                return 'Horário de inicio deve vir antes do final';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextFormField(
                            controller: txtInicioSegundoHorarioCtrl,
                            onTap: () {
                              timePicker(context).then((value) => {
                                    txtInicioSegundoHorarioCtrl.text =
                                        tempoObtido.format(context)
                                  });
                            },
                            decoration: InputDecoration(
                              labelText: 'e das',
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Campo inicio segundo horário é obrigatório';
                              } else if (!horarioAtendimentoValidate(
                                  txtInicioSegundoHorarioCtrl.text,
                                  txtFimSegundoHorarioCtrl.text)) {
                                return 'Horário de inicio deve vir antes do final';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextFormField(
                            controller: txtFimSegundoHorarioCtrl,
                            onTap: () {
                              timePicker(context).then((value) => {
                                    txtFimSegundoHorarioCtrl.text =
                                        tempoObtido.format(context)
                                  });
                            },
                            decoration: InputDecoration(
                              labelText: 'ás',
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Campo fim segundo horário é obrigatório';
                              } else if (!horarioAtendimentoValidate(
                                  txtInicioSegundoHorarioCtrl.text,
                                  txtFimSegundoHorarioCtrl.text)) {
                                return 'Horário de inicio deve vir antes do final';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
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
                  setState(() {
                    if (_horarioAtendimentoFormKey.currentState.validate()) {
                      save();
                    }
                  });
                },
                child: Text(
                  "Salvar",
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      txtIdCtrl.text = '';
      txtInicioPrimeiroHorarioCtrl.text = '';
      txtFimPrimeiroHorarioCtrl.text = '';
      txtInicioSegundoHorarioCtrl.text = '';
      txtFimSegundoHorarioCtrl.text = '';
      comboDiaSemana = null;
    });
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

  void _openHorarioAtendimentoConfirmDelete(
      BuildContext context, String diaSemana, String id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Deletar"),
            content: Container(
              child: Text(
                  'Deseja realmente deletar o horário de ' + diaSemana + '?'),
            ),
            actions: <Widget>[
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
                  horarioService.deleteById(id).then((response) => {
                        Navigator.of(context).pop(),
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HorarioAtendimentoListPage(),
                          ),
                        ),
                      });
                },
                child: Text(
                  "Deletar",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  horarioAtendimentoValidate(String inicioHorario, String fimHorario) {
    double inicioHorarioDouble = int.parse(inicioHorario.split(":")[0]) +
        int.parse(inicioHorario.split(":")[1]) / 60.0;
    double fimHorarioDouble = int.parse(fimHorario.split(":")[0]) +
        int.parse(fimHorario.split(":")[1]) / 60.0;

    if (inicioHorarioDouble < fimHorarioDouble)
      return true;
    else
      return false;
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    Object horarioSalvo;
    var medico = {"id": prefs.getString('medico_id')};

    var horario = {
      "id": txtIdCtrl.text,
      "diaSemana": HorarioConstants.getDiaSemanaIndex(comboDiaSemana),
      "primeiroHorarioInicio": txtInicioPrimeiroHorarioCtrl.text,
      "primeiroHorarioTermino": txtFimPrimeiroHorarioCtrl.text,
      "segundoHorarioInicio": txtInicioSegundoHorarioCtrl.text,
      "segundoHorarioTermino": txtFimSegundoHorarioCtrl.text,
      "medico": medico
    };

    _openLoadingDialog(context);

    horarioService.save(horario).then((Response response) => {
          this.setState(() {
            Navigator.pop(context);

            if (response.statusCode == '500') {
              _displaySnackBar(
                  context, 'Este dia da semana já está cadastrado!');
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      HorarioAtendimentoListPage(),
                ),
              );
            }
          })
        });
  }

  _displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<Response> findAllHorarioByMedicoId() async {
    final prefs = await SharedPreferences.getInstance();
    var medicoId = prefs.getString('medico_id');
    List horarioList;
    CustomExpansionPanel horarioPainelExpansivo;

    _openLoadingDialog(context);

    horarioService.findAllByMedicoId(medicoId).then((Response response) => {
          this.setState(() {
            horarioList = response.results;
            for (var i = 0; i < response.metadata.resultSet.count; i++) {
              horarioPainelExpansivo = CustomExpansionPanel(
                  false,
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text(HorarioConstants.getDiaSemana(
                            horarioList[i]['diaSemana'])),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: <Widget>[
                            Text('Das ' +
                                horarioList[i]['primeiroHorarioInicio'] +
                                ' às ' +
                                horarioList[i]['primeiroHorarioTermino']),
                            SizedBox(
                              height: 10,
                            ),
                            Text('e das ' +
                                horarioList[i]['segundoHorarioInicio'] +
                                ' às ' +
                                horarioList[i]['segundoHorarioTermino'])
                          ],
                        ),
                        Container(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Editar',
                                onPressed: () {
                                  setState(() {
                                    HorarioAtendimentoModel
                                        horarioAtendimentoModel =
                                        HorarioAtendimentoModel();
                                    horarioAtendimentoModel.id =
                                        horarioList[i]['id'];
                                    horarioAtendimentoModel.diaSemana =
                                        horarioList[i]['diaSemana'];

                                    this.comboDiaSemana =
                                        HorarioConstants.getDiaSemana(
                                            horarioList[i]['diaSemana']);
                                    this.txtIdCtrl.text = horarioList[i]['id'];
                                    this.txtInicioPrimeiroHorarioCtrl.text =
                                        horarioList[i]['primeiroHorarioInicio']
                                            .toString()
                                            .substring(0, 5);
                                    this.txtFimPrimeiroHorarioCtrl.text =
                                        horarioList[i]['primeiroHorarioTermino']
                                            .toString()
                                            .substring(0, 5);
                                    this.txtInicioSegundoHorarioCtrl.text =
                                        horarioList[i]['segundoHorarioInicio']
                                            .toString()
                                            .substring(0, 5);
                                    this.txtFimSegundoHorarioCtrl.text =
                                        horarioList[i]['segundoHorarioTermino']
                                            .toString()
                                            .substring(0, 5);

                                    this._openHorarioAtendimentoForm(
                                        context, horarioAtendimentoModel);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Excluir',
                                onPressed: () {
                                  setState(() {
                                    this._openHorarioAtendimentoConfirmDelete(
                                        context,
                                        HorarioConstants.getDiaSemana(
                                            horarioList[i]['diaSemana']),
                                        horarioList[i]['id']);
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
              horarioPainelExpansivoList.add(horarioPainelExpansivo);
            }
            Navigator.pop(context);
          }),
        });
  }
}
