import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/relacaoClienteMedicoFilter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/mensagem.page.form.dart';
import 'package:agenda/widgets/expansion-panel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/relacaoClienteMedico.service.dart'
    as relacaoClienteMedicoService;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicoSemRelacaoClienteMedicoPage extends StatefulWidget {
  @override
  _MedicoSemRelacaoClienteMedicoState createState() =>
      _MedicoSemRelacaoClienteMedicoState();
}

class _MedicoSemRelacaoClienteMedicoState
    extends State<MedicoSemRelacaoClienteMedicoPage> {
  List<CustomExpansionPanel> clientePainelExpansivoList = [];
  final filtroFormKey = GlobalKey<FormState>();

  final txtNomeCtrl = new TextEditingController();
  final txtCpfCtrl = new TextEditingController();
  final txtSexoCtrl = new TextEditingController();
  final txtDataNascInicioCtrl = new TextEditingController();
  final txtDataNascFimCtrl = new TextEditingController();

  var _genero = null;
  var _dataNascimento = "";

  DateTime _dateTime;

  var _cpfMaskFormatter = new MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

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

    findAllByMedicoId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
          title: Text('Clientes',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          actions: <Widget>[
            IconButton(
              iconSize: 40,
              icon: Icon(
                Icons.filter_alt,
              ),
              tooltip: 'Filtrar',
              onPressed: () {
                setState(() {
                  this._openRelacaoClienteMedicoFilter(context);
                });
              },
            ),
          ]),
      body: Container(
        child: ListView.builder(
          itemCount: clientePainelExpansivoList.length,
          itemBuilder: (BuildContext context, int index) {
            return ExpansionPanelList(
              animationDuration: Duration(milliseconds: 1000),
              dividerColor: Colors.red,
              elevation: 1,
              children: [
                ExpansionPanel(
                  body: Container(
                      padding: EdgeInsets.all(10),
                      child: clientePainelExpansivoList[index].body),
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: clientePainelExpansivoList[index].header,
                    );
                  },
                  isExpanded: clientePainelExpansivoList[index].expanded,
                )
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  clientePainelExpansivoList[index].expanded =
                      !clientePainelExpansivoList[index].expanded;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> findAllByMedicoId() async {
    CustomExpansionPanel clientePainelExpansivo;
    final prefs = await SharedPreferences.getInstance();

    clienteService
        .findAllNaoRelacionadoByCurrentMedicoId()
        .then((clienteList) => {
              this.setState(() {
                for (var i = 0; i < clienteList.length; i++) {
                  clientePainelExpansivo = CustomExpansionPanel(
                      false,
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: clienteList[i].usuario.foto != null
                                ? Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: MemoryImage(
                                              clienteList[i].usuario.foto),
                                        )),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              'assets/user_default.png'),
                                        )),
                                  ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(clienteList[i].usuario.nome,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text('CPF: ' + clienteList[i].usuario.cpf),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                                'Celular: ' + clienteList[i].usuario.celular),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text('Data Nasc.: ' +
                                dataUtil.montarData(
                                    DateTime.parse(clienteList[i]
                                            .usuario
                                            .dataNascimento)
                                        .day,
                                    DateTime.parse(clienteList[i]
                                            .usuario
                                            .dataNascimento)
                                        .month,
                                    DateTime.parse(clienteList[i]
                                            .usuario
                                            .dataNascimento)
                                        .year,
                                    "dd/MM/yyyy")),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child:
                                Text('Sexo: ' + clienteList[i].usuario.genero),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chat_outlined,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Chat',
                                onPressed: () {
                                  setState(() {
                                    this.openConfirmarChat(
                                        context,
                                        clienteList[i].id,
                                        prefs.getString("medico_id"),
                                        clienteList[i].usuario.nome);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.person_add,
                                  color: Colors.green,
                                ),
                                tooltip: 'Novo Vínculo',
                                onPressed: () {
                                  setState(() {
                                    this._openRelacaoClienteMedicoConfirmAdd(
                                        context,
                                        clienteList[i].usuario.nome,
                                        clienteList[i].id);
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ));
                  clientePainelExpansivoList.add(clientePainelExpansivo);
                }
                Navigator.pop(context);
              }),
            });
  }

  void openConfirmarChat(BuildContext context, String clienteId,
      String medicoId, String usuarioNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Chat"),
            content: Container(
              child:
                  Text('Deseja realmente conversar com ' + usuarioNome + '?'),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MensagemPageForm(clienteId, medicoId),
                    ),
                  );
                },
                child: Text(
                  "Conversar",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  void _openRelacaoClienteMedicoConfirmAdd(
      BuildContext context, String nome, String clienteId) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Adicionar"),
            content: Container(
              child: Text('Deseja realmente adicionar vínculo com o cliente ' +
                  nome +
                  '?'),
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
                  relacaoClienteMedicoService
                      .createByCurrentMedicoId(clienteId)
                      .then((value) => {
                            Navigator.of(context).pop(),
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    MedicoSemRelacaoClienteMedicoPage(),
                              ),
                            ),
                          });
                },
                child: Text(
                  "Adicionar",
                  //style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRelacaoClienteMedicoFilter(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Filtrar"),
            content: Container(
              child: Form(
                key: filtroFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: txtNomeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: txtCpfCtrl,
                        decoration: InputDecoration(
                          labelText: 'CPF',
                        ),
                        inputFormatters: [_cpfMaskFormatter],
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Color(0xFF486832),
                          ),
                          iconSize: 24,
                          elevation: 16,
                          hint: Text('Gênero'),
                          onChanged: (String newValue) {
                            setState(() {
                              _genero = newValue;
                            });
                          },
                          items: <String>['Masculino', 'Feminino']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: txtDataNascInicioCtrl,
                        decoration: InputDecoration(
                          labelText: 'Data de Nasc. Início',
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: Color(0xFF486832),
                            ),
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: txtDataNascInicioCtrl
                                              .text.isNotEmpty
                                          ? DateTime.parse(txtDataNascInicioCtrl
                                                  .text
                                                  .split("/")[2] +
                                              "-" +
                                              txtDataNascInicioCtrl.text
                                                  .split("/")[1] +
                                              "-" +
                                              txtDataNascInicioCtrl.text
                                                  .split("/")[0])
                                          : DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now())
                                  .then((_date) {
                                setState(() {
                                  _dateTime = _date;
                                  _dataNascimento = dataUtil.montarData(
                                      _dateTime.day,
                                      _dateTime.month,
                                      _dateTime.year,
                                      "dd/MM/yyyy");
                                  txtDataNascInicioCtrl.text = _dataNascimento;
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
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: txtDataNascFimCtrl,
                        decoration: InputDecoration(
                          labelText: 'Data de Nasc. Fim',
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: Color(0xFF486832),
                            ),
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate:
                                          txtDataNascFimCtrl.text.isNotEmpty
                                              ? DateTime.parse(
                                                  txtDataNascFimCtrl.text
                                                          .split("/")[2] +
                                                      "-" +
                                                      txtDataNascFimCtrl.text
                                                          .split("/")[1] +
                                                      "-" +
                                                      txtDataNascFimCtrl.text
                                                          .split("/")[0])
                                              : DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now())
                                  .then((_date) {
                                setState(() {
                                  _dateTime = _date;
                                  _dataNascimento = dataUtil.montarData(
                                      _dateTime.day,
                                      _dateTime.month,
                                      _dateTime.year,
                                      "dd/MM/yyyy");
                                  txtDataNascFimCtrl.text = _dataNascimento;
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
                  this._openLoadingDialog(context);

                  RelacaoClienteMedicoFilter relacaoClienteMedicoFilter =
                      new RelacaoClienteMedicoFilter();
                  relacaoClienteMedicoFilter.usuarioNome =
                      this.txtNomeCtrl.text;
                  relacaoClienteMedicoFilter.usuarioCpf = this.txtCpfCtrl.text;
                  relacaoClienteMedicoFilter.usuarioGenero = _genero;

                  if (this.txtDataNascInicioCtrl.text != null &&
                      this.txtDataNascInicioCtrl.text.isNotEmpty)
                    relacaoClienteMedicoFilter.usuarioDataNascInicio =
                        dataUtil.formatarDataToJson(
                            this.txtDataNascInicioCtrl.text, "dd/MM/yyyy");
                  else
                    relacaoClienteMedicoFilter.usuarioDataNascInicio = null;

                  if (this.txtDataNascFimCtrl.text != null &&
                      this.txtDataNascFimCtrl.text.isNotEmpty)
                    relacaoClienteMedicoFilter.usuarioDataNascFim =
                        dataUtil.formatarDataToJson(
                            this.txtDataNascFimCtrl.text, "dd/MM/yyyy");
                  else
                    relacaoClienteMedicoFilter.usuarioDataNascFim = null;

                  findAllByFilterWithOutMedicoId(relacaoClienteMedicoFilter);
                },
                child: Text(
                  "Filtrar",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> findAllByFilterWithOutMedicoId(
      RelacaoClienteMedicoFilter relacaoClienteMedicoFilter) async {
    CustomExpansionPanel clientePainelExpansivo;
    final prefs = await SharedPreferences.getInstance();

    relacaoClienteMedicoService
        .findAllByFilterWithOutRelacaoMedicoId(relacaoClienteMedicoFilter)
        .then((clienteList) => {
              this.setState(() {
                clientePainelExpansivoList.clear();

                for (var i = 0; i < clienteList.length; i++) {
                  clientePainelExpansivo = CustomExpansionPanel(
                      false,
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: clienteList[i].usuario.foto != null
                                ? Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: MemoryImage(
                                              clienteList[i].usuario.foto),
                                        )),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              'assets/user_default.png'),
                                        )),
                                  ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(clienteList[i].usuario.nome,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text('CPF: ' + clienteList[i].usuario.cpf),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                                'Celular: ' + clienteList[i].usuario.celular),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text('Data Nasc.: ' +
                                dataUtil.montarData(
                                    DateTime.parse(clienteList[i]
                                            .usuario
                                            .dataNascimento)
                                        .day,
                                    DateTime.parse(clienteList[i]
                                            .usuario
                                            .dataNascimento)
                                        .month,
                                    DateTime.parse(clienteList[i]
                                            .usuario
                                            .dataNascimento)
                                        .year,
                                    "dd/MM/yyyy")),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child:
                                Text('Sexo: ' + clienteList[i].usuario.genero),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chat_outlined,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Chat',
                                onPressed: () {
                                  setState(() {
                                    this.openConfirmarChat(
                                        context,
                                        clienteList[i].id,
                                        prefs.getString("medico_id"),
                                        clienteList[i].usuario.nome);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.person_add,
                                  color: Colors.green,
                                ),
                                tooltip: 'Novo Vínculo',
                                onPressed: () {
                                  setState(() {
                                    this._openRelacaoClienteMedicoConfirmAdd(
                                        context,
                                        clienteList[i].usuario.nome,
                                        clienteList[i].id);
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ));
                  clientePainelExpansivoList.add(clientePainelExpansivo);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              }),
            });
  }
}
