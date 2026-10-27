import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/relacaoClienteMedicoFilter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/mensagem.page.form.dart';
import 'package:agenda/widgets/expansion-panel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart'
    as medicoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/relacaoClienteMedico.service.dart'
    as relacaoClienteMedicoService;
import 'package:shared_preferences/shared_preferences.dart';

class ClienteSemRelacaoClienteMedicoPage extends StatefulWidget {
  @override
  _ClienteSemRelacaoClienteMedicoState createState() =>
      _ClienteSemRelacaoClienteMedicoState();
}

class _ClienteSemRelacaoClienteMedicoState
    extends State<ClienteSemRelacaoClienteMedicoPage> {
  List<CustomExpansionPanel> medicoPainelExpansivoList = [];
  final filtroFormKey = GlobalKey<FormState>();

  final txtNomeCtrl = new TextEditingController();
  final txtCrmCtrl = new TextEditingController();

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

    findAllByClienteId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
          title: Text('Médicos',
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
          itemCount: medicoPainelExpansivoList.length,
          itemBuilder: (BuildContext context, int index) {
            return ExpansionPanelList(
              animationDuration: Duration(milliseconds: 1000),
              dividerColor: Colors.red,
              elevation: 1,
              children: [
                ExpansionPanel(
                  body: Container(
                      padding: EdgeInsets.all(10),
                      child: medicoPainelExpansivoList[index].body),
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: medicoPainelExpansivoList[index].header,
                    );
                  },
                  isExpanded: medicoPainelExpansivoList[index].expanded,
                )
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  medicoPainelExpansivoList[index].expanded =
                      !medicoPainelExpansivoList[index].expanded;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> findAllByClienteId() async {
    CustomExpansionPanel medicoPainelExpansivo;
    final prefs = await SharedPreferences.getInstance();

    medicoService.findAllNaoRelacionadoByCurrentClienteId().then((medicoList) =>
        {
          this.setState(() {
            for (var i = 0; i < medicoList.length; i++) {
              medicoPainelExpansivo = CustomExpansionPanel(
                  false,
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: medicoList[i].usuario.foto != null
                            ? Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: MemoryImage(
                                          medicoList[i].usuario.foto),
                                    )),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage('assets/user_default.png'),
                                    )),
                              ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(medicoList[i].usuario.nome,
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
                        child: Text('CRM: ' + medicoList[i].crm),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 5.0),
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Column(
                          children: <Widget>[
                            Visibility(
                                visible: medicoList[i].consultorioLogradouro !=
                                        "null" &&
                                    medicoList[i].consultorioLogradouro != "" &&
                                    medicoList[i].consultorioNumero != "null" &&
                                    medicoList[i].consultorioNumero != "" &&
                                    medicoList[i].consultorioBairro != "null" &&
                                    medicoList[i].consultorioBairro != "" &&
                                    medicoList[i].consultorioCep != "null" &&
                                    medicoList[i].consultorioCep != "" &&
                                    medicoList[i].consultorioComplemento !=
                                        "null" &&
                                    medicoList[i].consultorioComplemento != "",
                                child: Text(
                                    medicoList[i].consultorioLogradouro +
                                        ', ' +
                                        medicoList[i].consultorioNumero +
                                        ' - ' +
                                        medicoList[i].consultorioBairro +
                                        ' - ' +
                                        medicoList[i].consultorioCep +
                                        ' (' +
                                        medicoList[i].consultorioComplemento +
                                        ')'))
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                              visible: medicoList[i].biografia != null,
                              child: IconButton(
                                icon: Icon(
                                  Icons.menu_book,
                                  color: Colors.black,
                                ),
                                tooltip: 'Biografia',
                                onPressed: () {
                                  setState(() {
                                    openBiografia(
                                        context, medicoList[i].biografia);
                                  });
                                },
                              )),
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
                                    prefs.getString("cliente_id"),
                                    medicoList[i].id,
                                    medicoList[i].usuario.nome);
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
                                    medicoList[i].usuario.nome,
                                    medicoList[i].id);
                              });
                            },
                          )
                        ],
                      ),
                    ],
                  ));
              medicoPainelExpansivoList.add(medicoPainelExpansivo);
            }
            Navigator.pop(context);
          }),
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

  void openBiografia(BuildContext context, String biografia) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Biografia"),
            content: Container(
              child: Text(biografia),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Voltar",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
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
              child: Text('Deseja realmente adicionar vínculo com o médico ' +
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
                      .createByCurrentClienteId(clienteId)
                      .then((value) => {
                            Navigator.of(context).pop(),
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ClienteSemRelacaoClienteMedicoPage(),
                              ),
                            ),
                          });
                },
                child: Text(
                  "Adicionar",
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
                        controller: txtCrmCtrl,
                        decoration: InputDecoration(
                          labelText: 'CRM',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    )
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
                  relacaoClienteMedicoFilter.medicoCrm = this.txtCrmCtrl.text;

                  findAllByFilterWithOutClienteId(relacaoClienteMedicoFilter);
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

  Future<void> findAllByFilterWithOutClienteId(
      RelacaoClienteMedicoFilter relacaoClienteMedicoFilter) async {
    CustomExpansionPanel medicoPainelExpansivo;
    final prefs = await SharedPreferences.getInstance();

    relacaoClienteMedicoService
        .findAllByFilterWithOutRelacaoClienteId(relacaoClienteMedicoFilter)
        .then((medicoList) => {
              this.setState(() {
                medicoPainelExpansivoList.clear();

                for (var i = 0; i < medicoList.length; i++) {
                  medicoPainelExpansivo = CustomExpansionPanel(
                      false,
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: medicoList[i].usuario.foto != null
                                ? Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: MemoryImage(
                                              medicoList[i].usuario.foto),
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
                                  Text(medicoList[i].usuario.nome,
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
                            child: Text('CRM: ' + medicoList[i].crm),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 5.0),
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              children: <Widget>[
                                Visibility(
                                    visible: medicoList[i]
                                                .consultorioLogradouro !=
                                            "null" &&
                                        medicoList[i].consultorioLogradouro !=
                                            "" &&
                                        medicoList[i].consultorioNumero !=
                                            "null" &&
                                        medicoList[i].consultorioNumero != "" &&
                                        medicoList[i].consultorioBairro !=
                                            "null" &&
                                        medicoList[i].consultorioBairro != "" &&
                                        medicoList[i].consultorioCep !=
                                            "null" &&
                                        medicoList[i].consultorioCep != "" &&
                                        medicoList[i].consultorioComplemento !=
                                            "null" &&
                                        medicoList[i].consultorioComplemento !=
                                            "",
                                    child: Text(medicoList[i]
                                            .consultorioLogradouro +
                                        ', ' +
                                        medicoList[i].consultorioNumero +
                                        ' - ' +
                                        medicoList[i].consultorioBairro +
                                        ' - ' +
                                        medicoList[i].consultorioCep +
                                        ' (' +
                                        medicoList[i].consultorioComplemento +
                                        ')'))
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                  visible: medicoList[i].biografia != null,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.menu_book,
                                      color: Colors.black,
                                    ),
                                    tooltip: 'Biografia',
                                    onPressed: () {
                                      setState(() {
                                        openBiografia(
                                            context, medicoList[i].biografia);
                                      });
                                    },
                                  )),
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
                                        prefs.getString("cliente_id"),
                                        medicoList[i].id,
                                        medicoList[i].usuario.nome);
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
                                        medicoList[i].usuario.nome,
                                        medicoList[i].id);
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ));
                  medicoPainelExpansivoList.add(medicoPainelExpansivo);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              }),
            });
  }
}
