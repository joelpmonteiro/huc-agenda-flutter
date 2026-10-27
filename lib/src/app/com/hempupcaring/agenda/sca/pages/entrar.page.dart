import 'package:flutter/material.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/cadastro.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/list/consulta.page.list.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/redefinirsenha.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/autenticacaoResponse.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/autenticacao.service.dart' as autenticacaoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/usuario.service.dart' as usuarioService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart' as medicoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart' as clienteService;
import 'package:shared_preferences/shared_preferences.dart';

class EntrarPage extends StatefulWidget {
  @override
  _EntrarPageState createState() => _EntrarPageState();
}

class _EntrarPageState extends State<EntrarPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _credencialFormKey = GlobalKey<FormState>();

  final txtEmailCtrl = new TextEditingController();
  final txtSenhaCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 40,
          left: 40,
          right: 40,
        ),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 144,
              height: 144,
              child: Image.asset('assets/logo_clara_app.jpg'),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Agenda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 28,
                color: Color(0xFF486832),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _credencialFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: txtEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w400,
                        fontSize: 20
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo e-mail é obrigatório';
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: txtSenhaCtrl,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 20
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Campo senha é obrigatório';
                      }
                    },
                  ),
                  Container(
                    height: 40,
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      child: Text(
                        'Esqueci Minha Senha',
                        style: TextStyle(
                          color: Colors.black38
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => RedefinirSenhaPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Color(0xFF486832),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      )
                    ),
                    child: SizedBox.expand(
                      child: FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Entrar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        onPressed: () => {
                          setState(() {
                            if (_credencialFormKey.currentState.validate()) {
                              this.autenticar(txtEmailCtrl.text, txtSenhaCtrl.text);
                            }
                          })
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: FlatButton(
                      child: Text(
                        'Criar Conta',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => CadastroPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
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
                  padding: EdgeInsets.only(bottom: 0, left: 0, right: 20, top: 0),
                  child: new CircularProgressIndicator(),
                ),
                new Text('Carregando ... Aguarde'),
              ],
            ),
          ),
        );
      },
    );
  }

  autenticar(email, senha) async {
    final prefs = await SharedPreferences.getInstance();
    var medico = null;
    var cliente = null;

    _openLoadingDialog(context);

    autenticacaoService.autenticar(email, senha).then((AutenticacaoResponse response) => {
      prefs.clear(),
      if(response.statusCode == 200) {
        prefs.setString('token', response.token),
          usuarioService.getIdByEmail(email).then((Response response) => {
            prefs.setString('id', response.result),
            usuarioService.getTipoUsuario(email).then((Response response) => {
              prefs.setString('tipo', response.result),
              if (response.result == 'Cliente') {
                clienteService.findOneByUsuarioEmail(email).then((Response response) => {
                  cliente = response.result,
                  prefs.setString('cliente_id', cliente['id']),
                  Navigator.pop(context),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ConsultaPageList(),
                    ),
                  ),
                })
              }
              else if (response.result == 'Medico') {
                medicoService.findOneByUsuarioEmail(email).then((Response response) => {
                  medico = response.result,
                  prefs.setString('medico_id', medico['id']),
                  Navigator.pop(context),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ConsultaPageList(),
                    ),
                  ),
                })
              }
            }),
        })
      }
      else {
        _displaySnackBar(context),
        Navigator.pop(context),
      }
    });
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Usuário ou senha incorreto!'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}