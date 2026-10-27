import 'dart:typed_data';

import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/municipioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:cpfcnpj/cpfcnpj.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;
import 'package:agenda/src/app/com/hempupcaring/agenda/util/imageUtil.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scl/services/municipio.service.dart'
    as municipioService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/usuario.service.dart'
    as usuarioService;

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _stepDadosPessoais = 0;
  final _stepDadosComplementares = 1;

  final _pessoalFormKey = GlobalKey<FormState>();
  final _complementarFormKey = GlobalKey<FormState>();

  final _generoDropdownKey = GlobalKey<FormFieldState>();
  final _estadoDropdownKey = GlobalKey<FormFieldState>();
  final _cidadeDropdownKey = GlobalKey<FormFieldState>();

  int _currentStep = 0;

  var _cpfMaskFormatter = new MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var _celularMaskFormatter = new MaskTextInputFormatter(
      mask: '+## (##) # ####-####', filter: {"#": RegExp(r'[0-9]')});

  final txtEmailCtrl = new TextEditingController();
  final txtNomeCtrl = new TextEditingController();
  final txtCpfCtrl = new TextEditingController();
  final txtDataNascimentoCtrl = new TextEditingController();
  final txtCelularCtrl = new TextEditingController();
  bool proximoHabilitado = true;
  bool voltarHabilitado = false;

  var _dataNascimento = "";
  var _genero = null;
  var _uf = null;
  var _cidade = null;

  bool _emailJaCadastrado;
  bool _cpfJaCadastrado;

  DateTime _dateTime;
  List<DropdownMenuItem> ufListItems = [];
  List<DropdownMenuItem> cidadeListItems = [];

  DateTime dataNascUsuario;

  UsuarioModel usuario;

  Uint8List imageByte = null;

  final picker = ImagePicker();

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

    usuarioService.getCurrent().then((Response response) => {
          usuario = UsuarioModel.fromJson(response.result),
          txtNomeCtrl.text = usuario.nome,
          txtCpfCtrl.text = usuario.cpf,
          txtEmailCtrl.text = usuario.email,
          dataNascUsuario = DateTime.parse(usuario.dataNascimento),
          txtDataNascimentoCtrl.text = dataUtil.montarData(dataNascUsuario.day,
              dataNascUsuario.month, dataNascUsuario.year, "dd/MM/yyyy"),
          _generoDropdownKey.currentState.setValue(usuario.genero),
          txtCelularCtrl.text = usuario.celular,
          if (usuario.foto != null)
            {
              setState(() {
                imageByte = usuario.foto;
              }),
            },
          this.findAllUf().then((value) => {
                if (usuario.municipio != null)
                  {
                    _estadoDropdownKey.currentState
                        .setValue(usuario.municipio.uf),
                    findAllCidadeByUf(usuario.municipio.uf).then((value) => {
                          _cidadeDropdownKey.currentState
                              .setValue(usuario.municipio.cidade),
                          Navigator.pop(context),
                        })
                  }
                else
                  {
                    Navigator.pop(context),
                  }
              }),
        });

    _dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Perfil',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  imageByte != null
                      ? Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(imageByte),
                              )),
                        )
                      : Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/user_default.png'),
                              )),
                        ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: FloatingActionButton(
                      //onPressed: getImage,
                      onPressed: null,
                      tooltip: 'Pick Image',
                      child: Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
            ),
            Stepper(
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
                return Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: controlsDetails.onStepContinue,
                      child: Text(
                        "Próximo",
                      ),
                    ),
                    TextButton(
                      onPressed: controlsDetails.onStepCancel,
                      child: Text(
                        "Voltar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
              steps: _perfilSteps(),
              currentStep: _currentStep,
              onStepTapped: (step) {
                setState(() {
                  this._currentStep = step;
                });
              },
              onStepContinue: proximoHabilitado ? () {
                setState(() {
                  voltarHabilitado = true;
                  if (this._currentStep < _stepDadosComplementares) {
                    this._currentStep++;
                    proximoHabilitado = false;
                  }
                });
              } : null,
              onStepCancel: voltarHabilitado ? () {
                setState(() {
                  proximoHabilitado = true;
                  if (this._currentStep > _stepDadosPessoais) {
                    this._currentStep--;
                    voltarHabilitado = false;
                  }
                });
              } : null,
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
                        atualizarUsuario(context);
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
        ),
      ),
    );
  }

  List<Step> _perfilSteps() {
    List<Step> _stepList = [
      Step(
        title: Text('Dados Pessoais'),
        content: Form(
          key: _pessoalFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: txtNomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                ),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo nome completo é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtEmailCtrl,
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (email) async {
                  final exists = await existsByEmail(email);
                  setState(() => _emailJaCadastrado = exists);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Campo e-mail é obrigatório';
                  } else if (_emailJaCadastrado) {
                    return 'Este e-mail já esta cadastrado';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtCpfCtrl,
                decoration: InputDecoration(labelText: 'CPF'),
                inputFormatters: [_cpfMaskFormatter],
                keyboardType: TextInputType.number,
                onChanged: (cpf) async {
                  final exists = await existsByCpf(cpf);
                  setState(() => _cpfJaCadastrado = exists);
                },
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo CPF é obrigatório';
                  } else if (!CPF.isValid(value)) {
                    return 'CPF inválido';
                  } else if (_cpfJaCadastrado) {
                    return 'Este CPF já esta cadastrado';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtDataNascimentoCtrl,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF486832),
                    ),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: dataNascUsuario,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now())
                          .then((_date) {
                        setState(() {
                          _dateTime = _date;
                          _dataNascimento = dataUtil.montarData(_dateTime.day,
                              _dateTime.month, _dateTime.year, "dd/MM/yyyy");
                          txtDataNascimentoCtrl.text = _dataNascimento;
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
                    return 'Campo data de nascimento é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                key: _generoDropdownKey,
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
                validator: (value) {
                  if (_genero == null) {
                    return 'Campo gênero é obrigatório';
                  }
                  return null;
                },
                items: <String>['Masculino', 'Feminino']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ],
          ),
        ),
        isActive: _currentStep >= _stepDadosPessoais,
      ),
      Step(
        title: Text('Dados Complementares'),
        content: Form(
          key: _complementarFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: txtCelularCtrl,
                decoration: InputDecoration(labelText: 'Celular'),
                inputFormatters: [_celularMaskFormatter],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo celular é obrigatório';
                  } else if (value.trim().length != 20) {
                    return 'Formato de celular inválido';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                key: _estadoDropdownKey,
                icon: Icon(
                  Icons.arrow_downward,
                  color: Color(0xFF486832),
                ),
                iconSize: 24,
                elevation: 16,
                hint: Text('Estado'),
                items: this.ufListItems,
                onChanged: (newValue) {
                  setState(() {
                    cidadeListItems.clear();
                    _cidadeDropdownKey.currentState.reset();
                    _uf = newValue;
                    this.findAllCidadeByUf(_uf);
                  });
                },
                validator: (value) {
                  if (_uf == null) {
                    return 'Campo estado é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                key: _cidadeDropdownKey,
                icon: Icon(
                  Icons.arrow_downward,
                  color: Color(0xFF486832),
                ),
                iconSize: 24,
                elevation: 16,
                hint: Text('Cidade'),
                items: this.cidadeListItems,
                onChanged: (newValue) {
                  setState(() {
                    _cidade = newValue;
                  });
                },
                validator: (value) {
                  if (_cidade == null) {
                    return 'Campo cidade é obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep >= _stepDadosComplementares,
      )
    ];
    return _stepList;
  }

  Future<bool> _onBackButton() {
    // Implement your logic
    return Future.value(true);
  }

  Future<bool> existsByCpf(cpf) async {
    var exists;

    await usuarioService.existsByCpf(cpf).then((response) => {
          exists = response.result,
        });

    return exists;
  }

  Future<bool> existsByEmail(email) async {
    var exists;

    await usuarioService.existsByEmail(email).then((response) => {
          exists = response.result,
        });

    return exists;
  }

  Future<void> findAllUf() async {
    var response = await municipioService.findAllUf();

    setState(() {
      ufListItems = response
          .map((item) => DropdownMenuItem(child: Text(item), value: item))
          .toList();
    });
  }

  Future<void> findAllCidadeByUf(uf) async {
    var response = await municipioService.findAllCidadeByUf(uf);

    setState(() {
      cidadeListItems = response
          .map((item) => DropdownMenuItem(child: Text(item), value: item))
          .toList();
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        pickedFile.readAsBytes().then((value) => {
              setState(() {
                imageByte = ImageUtil.bytesFromBase64String(
                    ImageUtil.base64String(value));
              }),
            });
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> atualizarUsuario(BuildContext context) async {
    MunicipioModel municipio = new MunicipioModel();
    municipio.cidade = _cidadeDropdownKey.currentState.value;
    municipio.uf = _estadoDropdownKey.currentState.value;

    UsuarioModel usuario = new UsuarioModel();
    usuario.nome = txtNomeCtrl.text;
    usuario.email = txtEmailCtrl.text;
    usuario.cpf = txtCpfCtrl.text;
    usuario.celular = txtCelularCtrl.text;
    usuario.foto = imageByte;
    usuario.dataNascimento =
        dataUtil.formatarDataToJson(txtDataNascimentoCtrl.text, "dd/MM/yyyy");
    usuario.genero = _generoDropdownKey.currentState.value;
    usuario.municipio = municipio;

    await usuarioService.update(usuario);
    Navigator.pop(context);
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
}
