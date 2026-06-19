import 'package:flutter/material.dart';
import '../banco_dados/db_helper.dart';
import '../models/usuario.dart';
import '../models/planta.dart';

class TelaPerfil extends StatefulWidget {
  final int usuarioId;

  const TelaPerfil({super.key, required this.usuarioId});

  @override
  State<TelaPerfil> createState() => _EstadoTelaPerfil();
}

class _EstadoTelaPerfil extends State<TelaPerfil> {
  final _controladorNome = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();

  bool _carregando = true;
  bool _senhaOculta = true;

  List<Planta> _minhasPlantas = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfilERelatorio();
  }

  Future<void> _carregarDadosPerfilERelatorio() async {
    Usuario? usuario = await DBHelper().buscarUsuarioPorId(widget.usuarioId);
    List<Planta> plantas = await DBHelper().listarPlantasDoUsuario(
      widget.usuarioId,
    );

    if (usuario != null && mounted) {
      setState(() {
        _controladorNome.text = usuario.nome;
        _controladorEmail.text = usuario.email;
        _controladorSenha.text = usuario.senha;
        _minhasPlantas = plantas;
        _carregando = false;
      });
    }
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
    );
  }

  Widget _construirRelatorio(ThemeData tema) {
    int total = _minhasPlantas.length;
    int emDia = _minhasPlantas.where((p) => p.diasRestantes > 0).length;
    int regarHoje = _minhasPlantas.where((p) => p.diasRestantes == 0).length;
    int atrasadas = _minhasPlantas.where((p) => p.diasRestantes < 0).length;

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insert_chart_outlined, color: Colors.green.shade800),
              const SizedBox(width: 8),
              Text(
                'Relatório do seu Jardim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _linhaRelatorio('Plantas Cadastradas', '$total', Icons.grass),
          const SizedBox(height: 12),
          _linhaRelatorio(
            'Status: Em Dia',
            '$emDia',
            Icons.check_circle_outline,
            cor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _linhaRelatorio(
            'Status: Regar Hoje',
            '$regarHoje',
            Icons.water_drop_outlined,
            cor: Colors.amber.shade700,
          ),
          const SizedBox(height: 12),
          _linhaRelatorio(
            'Status: Atrasadas',
            '$atrasadas',
            Icons.warning_amber_rounded,
            cor: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _linhaRelatorio(
    String titulo,
    String valor,
    IconData icone, {
    Color? cor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icone, size: 20, color: cor ?? Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: cor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Meu Perfil'), centerTitle: true),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green.shade50,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _controladorNome,
                    decoration: _decoracaoCampo(
                      'Nome Completo',
                      Icons.person_outline,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _controladorEmail,
                    decoration: _decoracaoCampo('E-mail', Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _controladorSenha,
                    obscureText: _senhaOculta,
                    decoration: _decoracaoCampo(
                      'Alterar Senha',
                      Icons.lock_outline,
                      sufixo: IconButton(
                        icon: Icon(
                          _senhaOculta
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.green.shade700,
                        ),
                        onPressed: () =>
                            setState(() => _senhaOculta = !_senhaOculta),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Salvar Alterações',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      String nome = _controladorNome.text.trim();
                      String email = _controladorEmail.text.trim();
                      String senha = _controladorSenha.text.trim();

                      if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nenhum campo pode ficar em branco.'),
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

                      Usuario usuarioAtualizado = Usuario(
                        id: widget.usuarioId,
                        nome: nome,
                        email: email,
                        senha: senha,
                      );
                      await DBHelper().atualizarUsuario(usuarioAtualizado);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil atualizado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    },
                  ),

                  _construirRelatorio(tema),
                ],
              ),
            ),
    );
  }
}
