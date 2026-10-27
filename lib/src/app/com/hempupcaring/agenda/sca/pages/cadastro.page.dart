import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/usuario.service.dart'
    as usuarioService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart'
    as medicoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/scl/services/municipio.service.dart'
    as municipioService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/autenticacao.service.dart'
    as autenticacaoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/autenticacaoResponse.dart';
import 'package:cpfcnpj/cpfcnpj.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/list/consulta.page.list.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _stepDadosAcesso = 0;
  final _stepDadosPessoais = 1;
  final _stepDadosComplementares = 2;

  final _acessoFormKey = GlobalKey<FormState>();
  final _pessoalFormKey = GlobalKey<FormState>();
  final _complementarFormKey = GlobalKey<FormState>();
  final _cidadeDropdownKey = GlobalKey<FormFieldState>();

  bool _emailJaCadastrado;
  bool _cpfJaCadastrado;
  bool _crmJaCadastrado;

  int _currentStep = 0;

  var _cpfMaskFormatter = new MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var _celularMaskFormatter = new MaskTextInputFormatter(
      mask: '+## (##) # ####-####', filter: {"#": RegExp(r'[0-9]')});

  DateTime _dateTime;
  List<DropdownMenuItem> ufListItems = [];
  List<DropdownMenuItem> cidadeListItems = [];

  bool _isMedico = false;
  var _dataNascimento = "";
  var _genero = null;
  var _uf = null;
  var _cidade = null;
  var _termoUsoAceito = false;
  var _mostrarAvisoTermoUso = false;
  bool proximoHabilitado = true;
  bool voltarHabilitado = false;

  final txtEmailCtrl = new TextEditingController();
  final txtSenhaCtrl = new TextEditingController();
  final txtSenhaConfCtrl = new TextEditingController();
  final txtNomeCtrl = new TextEditingController();
  final txtCpfCtrl = new TextEditingController();
  final txtDataNascimentoCtrl = new TextEditingController();
  final txtCelularCtrl = new TextEditingController();
  final txtCrmCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    this.findAllUf();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Cadastro',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            body: ListView(
              children: [
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
                  steps: _cadastroSteps(),
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    setState(() {
                      this._currentStep = step;
                    });
                  },
                  onStepContinue: proximoHabilitado
                      ? () {
                          setState(() {
                            this.voltarHabilitado = true;
                            if (this._currentStep == _stepDadosAcesso &&
                                _acessoFormKey.currentState.validate()) {
                              this._currentStep++;
                            } else if (this._currentStep ==
                                    _stepDadosPessoais &&
                                _pessoalFormKey.currentState.validate()) {
                              this._currentStep++;
                              this.proximoHabilitado = false;
                            }
                          });
                        }
                      : null,
                  onStepCancel: voltarHabilitado
                      ? () {
                          setState(() {
                            this.proximoHabilitado = true;
                            if (this._currentStep == 1) {
                              this._currentStep--;
                              voltarHabilitado = false;
                            } else if (this._currentStep > 0) {
                              this._currentStep--;
                              voltarHabilitado = true;
                            }
                          });
                        }
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            save();
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
        onWillPop: _onBackButton);
  }

  List<Step> _cadastroSteps() {
    List<Step> _stepList = [
      Step(
        title: Text('Dados de Acesso'),
        content: Form(
          key: _acessoFormKey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Switch(
                    value: _isMedico,
                    activeColor: Color(0xFF486832),
                    onChanged: (bool state) {
                      setState(() {
                        _isMedico = state;
                      });
                    },
                  ),
                  Text(
                    'Cadastrar como médico',
                    style: TextStyle(color: Colors.black38),
                  ),
                ],
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
                controller: txtSenhaCtrl,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Campo senha é obrigatório';
                  } else if (value.trim().length < 6) {
                    return 'Campo senha deve ter pelo menos 6 digitos';
                  } else if (txtSenhaConfCtrl.text.trim().isNotEmpty &&
                      txtSenhaConfCtrl.text != value) {
                    return 'As senhas informadas não correspondem';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtSenhaConfCtrl,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                ),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Campo confirmar senha é obrigatório';
                  } else if (txtSenhaCtrl.text.trim().isNotEmpty &&
                      txtSenhaCtrl.text != value) {
                    return 'As senhas informadas não correspondem';
                  }
                  return null;
                },
              )
            ],
          ),
        ),
        isActive: _currentStep >= 0,
      ),
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
                              initialDate: DateTime.now(),
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
        isActive: _currentStep >= 1,
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
              Visibility(
                visible: _isMedico,
                child: TextFormField(
                  controller: txtCrmCtrl,
                  decoration: InputDecoration(labelText: 'CRM'),
                  keyboardType: TextInputType.number,
                  enabled: _isMedico,
                  onChanged: (crm) async {
                    final exists = await existsByCrm(crm);
                    setState(() => _crmJaCadastrado = exists);
                  },
                  validator: (value) {
                    if (_isMedico && value.trim().isEmpty) {
                      return 'Campo CRM é obrigatório';
                    } else if (_isMedico && _crmJaCadastrado) {
                      return 'Este CRM já esta cadastrado';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              CheckboxListTile(
                  title: InkWell(
                    child: new Text(
                      'Declaro que li e aceito os termos de uso',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline),
                    ),
                    onTap: () => {showTermoUsoDialog()},
                  ),
                  activeColor: Color(0xFF486832),
                  value: _termoUsoAceito,
                  onChanged: (newValue) {
                    setState(() {
                      _termoUsoAceito = newValue;
                    });
                  },
                  subtitle: _mostrarAvisoTermoUso
                      ? Text(
                          'É necessário aceitar os termos de uso',
                          style: TextStyle(color: Colors.red),
                        )
                      : null,
                  controlAffinity: ListTileControlAffinity.leading),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
      )
    ];
    return _stepList;
  }

  void showTermoUsoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Termos de Uso"),
            content: Text("Lorem ipsum suscipit accumsan est libero lectus justo ullamcorper, egestas curabitur a viverra nibh lectus id platea, justo suscipit nam leo cras turpis eget. venenatis ultrices integer feugiat curae id iaculis ante litora mollis, lectus gravida ut est sed in ultricies vulputate bibendum tristique, sollicitudin quam nam lorem netus sodales imperdiet cubilia. ante primis suspendisse orci cubilia tellus aptent fringilla feugiat, at porttitor volutpat lorem enim at quisque ad, a quam ullamcorper suscipit sapien libero aenean. platea auctor aliquam per sit erat tellus et lorem urna, suspendisse velit semper accumsan tincidunt aenean lacinia metus pellentesque rutrum, class semper at donec egestas turpis vestibulum habitasse." +
                "Suscipit habitasse vitae himenaeos lobortis maecenas ligula dui risus hendrerit senectus varius, netus lorem sapien ipsum proin non commodo in senectus aliquet, sapien tristique adipiscing feugiat inceptos cursus maecenas neque iaculis donec. posuere maecenas arcu nec scelerisque feugiat consequat aenean orci a, netus ullamcorper consequat sem etiam senectus euismod rhoncus primis lobortis, quisque lacinia pulvinar auctor nulla feugiat adipiscing vivamus. nisi blandit malesuada vulputate vestibulum maecenas pulvinar a, euismod potenti vel tempor facilisis ut suspendisse, class habitant orci quisque purus per. hac per porttitor cubilia enim fermentum ante ac volutpat, nibh ipsum a posuere litora lacus sociosqu torquent est, quam in adipiscing suspendisse rhoncus ut himenaeos." +
                "Molestie lacus convallis congue scelerisque inceptos cras amet iaculis, habitant donec sociosqu malesuada hac nullam sodales tempus, a ullamcorper ut duis suspendisse erat rutrum. adipiscing cubilia urna per netus mi sagittis cubilia conubia nunc quis mattis, scelerisque id ultrices diam pharetra commodo phasellus hendrerit curae dictumst. mollis habitant imperdiet per eros vulputate consectetur lacus fusce hac justo elementum habitasse senectus, duis proin vitae faucibus duis mattis proin accumsan cursus mattis netus proin, sed sem tincidunt tempor pulvinar rhoncus feugiat ultricies facilisis suspendisse sed inceptos. integer justo libero litora vitae accumsan litora habitant eu ad, elementum tempor elit aliquet lacus sit euismod." +
                "Iaculis etiam commodo tincidunt nam nunc a praesent himenaeos tempus, curabitur ultricies volutpat lobortis velit urna gravida justo hac, dui ultricies quis velit vivamus fames risus vitae. leo et lectus nisi venenatis eu consectetur porttitor auctor phasellus velit bibendum, urna auctor curae donec imperdiet praesent euismod pellentesque neque lacus consequat nulla, viverra vivamus ultrices orci sodales dictumst proin lacus cursus phasellus. porttitor hendrerit lorem quisque tincidunt tempor quis suspendisse sit duis, enim sollicitudin lorem inceptos id auctor sapien volutpat suspendisse primis, morbi feugiat accumsan felis aliquam sociosqu donec nostra. nisi habitant massa purus orci rutrum lacus vulputate commodo vivamus ultricies, arcu congue feugiat sem curabitur tristique dui ut quisque urna, luctus vel tristique mattis fermentum euismod curabitur mi felis." +
                "Curabitur aliquam tortor sapien bibendum et inceptos tempus duis felis lorem duis egestas tempus, libero pellentesque eros aliquam scelerisque sollicitudin diam ac blandit taciti ut blandit. fermentum congue ad curae euismod cubilia varius urna, ipsum aliquam tincidunt sodales dictumst nibh ultrices nostra, elementum ultricies primis consectetur rhoncus eros. phasellus sociosqu ultricies nunc ut sagittis lorem aenean sociosqu litora dictumst in, fermentum curabitur senectus condimentum laoreet aliquam scelerisque hac hendrerit lacus."),
            actions: <Widget>[
              FlatButton(
                child: Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void save() {
    if (!_complementarFormKey.currentState.validate()) {
      return;
    }

    if (!_termoUsoAceito) {
      setState(() {
        _mostrarAvisoTermoUso = true;
      });
      return;
    }

    var municipio = {"cidade": _cidade, "uf": _uf};

    var usuario = {
      "id": null,
      "nome": txtNomeCtrl.text,
      "email": txtEmailCtrl.text,
      "cpf": txtCpfCtrl.text,
      "senha": txtSenhaCtrl.text,
      "celular": txtCelularCtrl.text,
      "dataNascimento":
          dataUtil.formatarDataToJson(_dataNascimento, "dd/MM/yyyy"),
      "genero": _genero,
      "habilitado": true,
      "emailConfirmado": false,
      "municipio": municipio
    };

    this._openLoadingDialog(context);

    if (_isMedico) {
      var medico = {"id": null, "usuario": usuario, "crm": txtCrmCtrl.text};
      medicoService
          .save(medico)
          .then(
              (response) => {autenticar(txtEmailCtrl.text, txtSenhaCtrl.text)})
          .catchError((error) => {});
    } else {
      var cliente = {"id": null, "usuario": usuario, "tipo": 0};
      clienteService
          .save(cliente)
          .then(
              (response) => {autenticar(txtEmailCtrl.text, txtSenhaCtrl.text)})
          .catchError((error) => {});
    }
  }

  Future<bool> existsByEmail(email) async {
    var exists;

    await usuarioService.existsByEmail(email).then((response) => {
          exists = response.result,
        });

    return exists;
  }

  Future<bool> existsByCpf(cpf) async {
    var exists;

    await usuarioService.existsByCpf(cpf).then((response) => {
          exists = response.result,
        });

    return exists;
  }

  Future<bool> existsByCrm(crm) async {
    var exists;

    await medicoService.existsByCrm(crm).then((response) => {
          exists = response.result,
        });

    return exists;
  }

  Future<String> findAllUf() async {
    var response = await municipioService.findAllUf();

    setState(() {
      ufListItems = response
          .map((item) => DropdownMenuItem(child: Text(item), value: item))
          .toList();
    });

    return '';
  }

  Future<String> findAllCidadeByUf(uf) async {
    var response = await municipioService.findAllCidadeByUf(uf);

    setState(() {
      cidadeListItems = response
          .map((item) => DropdownMenuItem(child: Text(item), value: item))
          .toList();
    });

    return '';
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

  Future<bool> _onBackButton() {
    // Implement your logic
    return Future.value(true);
  }

  autenticar(email, senha) async {
    final prefs = await SharedPreferences.getInstance();
    var medico = null;
    var cliente = null;

    autenticacaoService.autenticar(email, senha).then((AutenticacaoResponse response) => {
              prefs.clear(),
              prefs.setString('token', response.token),
              usuarioService.getIdByEmail(email).then((Response response) => {
                prefs.setString('id', response.result),
                usuarioService.getTipoUsuario(email).then((Response response) => {
                      prefs.setString('tipo', response.result),
                      if (response.result == 'Cliente')
                        {
                          clienteService
                              .findOneByUsuarioEmail(email)
                              .then((Response response) => {
                                    cliente = response.result,
                                    prefs.setString('cliente_id', cliente['id']),
                                    Navigator.pop(context),
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ConsultaPageList(),
                                      ),
                                    ),
                                  })
                        }
                      else if (response.result == 'Medico')
                        {
                          medicoService
                              .findOneByUsuarioEmail(email)
                              .then((Response response) => {
                                    medico = response.result,
                                    prefs.setString('medico_id', medico['id']),
                                    Navigator.pop(context),
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ConsultaPageList(),
                                      ),
                                    ),
                                  })
                        }
                    }),
                })
            });
  }
}
