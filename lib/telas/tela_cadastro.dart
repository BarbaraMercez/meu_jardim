import 'package:flutter/material.dart';
import '../banco_dados/db_helper.dart';
import '../models/usuario.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _EstadoTelaCadastro();
}

class _EstadoTelaCadastro extends State<TelaCadastro> {
  final _controladorNome = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _controladorConfirmaSenha = TextEditingController();

  bool _senhaOculta = true;
  bool _confirmaSenhaOculta = true;

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
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'icone_planta',
                child: Icon(Icons.eco, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _controladorNome,
                decoration: _decoracaoCampo('Seu Nome', Icons.person),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _controladorEmail,
                decoration: _decoracaoCampo('E-mail', Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
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
              const SizedBox(height: 15),
              TextField(
                controller: _controladorConfirmaSenha,
                obscureText: _confirmaSenhaOculta,
                decoration: _decoracaoCampo(
                  'Confirmar Senha',
                  Icons.lock_clock,
                  sufixo: IconButton(
                    icon: Icon(
                      _confirmaSenhaOculta
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.green.shade700,
                    ),
                    onPressed: () => setState(
                      () => _confirmaSenhaOculta = !_confirmaSenhaOculta,
                    ),
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
                    String nome = _controladorNome.text.trim();
                    String email = _controladorEmail.text.trim();
                    String senha = _controladorSenha.text.trim();
                    String confirmaSenha = _controladorConfirmaSenha.text
                        .trim();

                    if (nome.isEmpty ||
                        email.isEmpty ||
                        senha.isEmpty ||
                        confirmaSenha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha todos os campos!'),
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
                          content: Text('Insira um e-mail válido.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (senha != confirmaSenha) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('As senhas não coincidem!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Usuario novoUsuario = Usuario(
                      nome: nome,
                      email: email,
                      senha: senha,
                    );

                    try {
                      await DBHelper().cadastrarUsuario(novoUsuario);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bem-vindo(a), $nome! Conta criada.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Este e-mail já está em uso.'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text.rich(
                  TextSpan(
                    text: 'Já tem uma conta? ',
                    style: TextStyle(color: Colors.grey[700]),
                    children: const [
                      TextSpan(
                        text: 'Faça login aqui',
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
