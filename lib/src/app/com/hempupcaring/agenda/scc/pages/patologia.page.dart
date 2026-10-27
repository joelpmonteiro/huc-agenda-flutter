import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/clientePatologiaModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/patologiaModel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/patologia.service.dart'
    as patologiaService;
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/clientePatologia.service.dart'
    as clientePatologiaService;
import 'package:shared_preferences/shared_preferences.dart';

class PatologiaPage extends StatefulWidget {
  @override
  _PatologiaPageState createState() => _PatologiaPageState();
}

class _PatologiaPageState extends State<PatologiaPage> {
  final patologiaFormKey = GlobalKey<FormState>();
  List<dynamic> patologiaListItems = [];
  List<dynamic> patologiaListSelectedItems = [];

  dynamic obj;

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

    findAllPatologia().then((value) => {
          clientePatologiaService
              .findAllByCurrentClienteId()
              .then((clientePatologiaList) => {
                    for (int i = 0; i < clientePatologiaList.length; i++)
                      {
                        setState(() {
                          patologiaListSelectedItems
                              .add(clientePatologiaList[i].patologia.id);
                        })
                      },
                    Navigator.pop(context),
                  }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Patologias',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Container(
          child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: patologiaFormKey,
              child: Column(
                children: [
                  MultiSelect(
                    titleText: 'Patologias',
                    hintText: 'Selecione uma ou mais',
                    dataSource: patologiaListItems,
                    valueField: 'id',
                    textField: 'nome',
                    searchBoxHintText: 'Pesquisar ...',
                    cancelButtonText: 'Cancelar',
                    saveButtonText: 'Confirmar',
                    selectedOptionsInfoText:
                        'Itens selecionados (toque para remover)',
                    initialValue: patologiaListSelectedItems,
                    onSaved: (value) {
                      patologiaListSelectedItems = value;
                      if (value == null) patologiaListSelectedItems = [];
                    },
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    this._openLoadingDialog(context, 'Salvando, aguarde ...');
                    setState(() {
                      atualizarPatologias(context);
                    });
                  },
                  child: Text(
                    "Salvar",
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Future<void> findAllPatologia() async {
    var response = await patologiaService.findAll();

    for (int i = 0; i < response.length; i++) {
      dynamic obj = {'id': response[i].id, 'nome': response[i].nome};

      setState(() {
        patologiaListItems.add(obj);
      });
    }
  }

  void _openLoadingDialog(BuildContext context, String msg) {
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
                new Text(msg),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> atualizarPatologias(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final FormState form = patologiaFormKey.currentState;

    if (form.validate()) {
      form.save();

      ClienteModel cliente = new ClienteModel();
      cliente.id = prefs.getString('cliente_id');

      List<ClientePatologiaModel> clientePatologiaList = [];

      for (int i = 0; i < patologiaListSelectedItems.length; i++) {
        PatologiaModel patologia = new PatologiaModel();
        patologia.id = patologiaListSelectedItems[i];

        ClientePatologiaModel clientePatologia = new ClientePatologiaModel();
        clientePatologia.cliente = cliente;
        clientePatologia.patologia = patologia;

        clientePatologiaList.add(clientePatologia);
      }

      clientePatologiaService
          .save(clientePatologiaList)
          .then((value) => {Navigator.pop(context)});
    } else {
      Navigator.pop(context);
    }
  }
}
