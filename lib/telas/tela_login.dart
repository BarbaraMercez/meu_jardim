import 'package:flutter/material.dart';
import '../banco_dados/db_helper.dart';
import '../models/usuario.dart';
import 'tela_cadastro.dart';
import 'tela_principal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _EstadoTelaLogin();
}

class _EstadoTelaLogin extends State<TelaLogin> {
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  bool _senhaOculta = true;

  void _navegarParaCadastro() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animacao, animacaoSecundaria) =>
            const TelaCadastro(),
        transitionsBuilder: (context, animacao, animacaoSecundaria, child) {
          return FadeTransition(opacity: animacao, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  InputDecoration _decoracaoCampo(
    String rotulo,
    IconData icone, {
    Widget? sufixo,
  }) {
    return InputDecoration(
      labelText: rotulo,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icone, color: Colors.green),
      suffixIcon: sufixo,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.green.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(color: Colors.green, width: 2.5),
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'icone_planta',
                child: Icon(Icons.eco, size: 100, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                'Meu Jardim',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _controladorEmail,
                decoration: _decoracaoCampo('E-mail', Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controladorSenha,
                obscureText: _senhaOculta,
                decoration: _decoracaoCampo(
                  'Senha',
                  Icons.lock,
                  sufixo: IconButton(
                    icon: Icon(
                      _senhaOculta ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green.shade700,
                    ),
                    onPressed: () =>
                        setState(() => _senhaOculta = !_senhaOculta),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () async {
                    String email = _controladorEmail.text.trim();
                    String senha = _controladorSenha.text.trim();

                    if (email.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, preencha todos os campos.'),
                        ),
                      );
                      return;
                    }

                    final regexEmail = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!regexEmail.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, insira um e-mail válido.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    Usuario? usuarioLogado = await DBHelper().loginUsuario(
                      email,
                      senha,
                    );

                    if (usuarioLogado != null) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setInt('usuarioId', usuarioLogado.id!);
                      await prefs.setString('usuarioNome', usuarioLogado.nome);

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TelaPrincipal(
                              usuarioId: usuarioLogado.id!,
                              usuarioNome: usuarioLogado.nome,
                            ),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('E-mail ou senha incorretos.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _navegarParaCadastro,
                child: Text.rich(
                  TextSpan(
                    text: 'Não tem uma conta? ',
                    style: TextStyle(color: Colors.grey[700]),
                    children: const [
                      TextSpan(
                        text: 'Cadastre-se aqui',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
