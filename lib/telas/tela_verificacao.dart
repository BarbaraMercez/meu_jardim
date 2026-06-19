import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_login.dart';
import 'tela_principal.dart';

class TelaVerificacao extends StatefulWidget {
  const TelaVerificacao({super.key});

  @override
  State<TelaVerificacao> createState() => _EstadoTelaVerificacao();
}

class _EstadoTelaVerificacao extends State<TelaVerificacao> {
  @override
  void initState() {
    super.initState();
    _verificarLogin();
  }

  Future<void> _verificarLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? usuarioId = prefs.getInt('usuarioId');
    String? usuarioNome = prefs.getString('usuarioNome');

    await Future.delayed(const Duration(milliseconds: 500));

    if (usuarioId != null && usuarioNome != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TelaPrincipal(usuarioId: usuarioId, usuarioNome: usuarioNome),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaLogin()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 80, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
