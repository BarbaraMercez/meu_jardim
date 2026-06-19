import 'package:flutter/material.dart';
import '../banco_dados/db_helper.dart';
import '../models/planta.dart';
import '../models/usuario.dart';
import 'tela_formulario_planta.dart';
import 'tela_detalhes_planta.dart';
import 'tela_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaPrincipal extends StatefulWidget {
  final int usuarioId;
  final String usuarioNome;

  const TelaPrincipal({
    super.key,
    required this.usuarioId,
    required this.usuarioNome,
  });

  @override
  State<TelaPrincipal> createState() => _EstadoTelaPrincipal();
}

class _EstadoTelaPrincipal extends State<TelaPrincipal> {
  int _indiceAtual = 0;

  List<Planta> _minhasPlantas = [];
  bool _carregando = true;
  late String _nomeExibicao;
  String _filtroStatusSelecionado = 'Todas';
  String _termoPesquisa = '';
  final _controladorPesquisa = TextEditingController();
  int _paginaAtual = 1;
  final int _itensPorPagina = 5;

  final _controladorNomePerfil = TextEditingController();
  final _controladorEmailPerfil = TextEditingController();
  final _controladorSenhaPerfil = TextEditingController();
  bool _senhaOculta = true;

  @override
  void initState() {
    super.initState();
    _nomeExibicao = widget.usuarioNome;
    _atualizarListaEDadosUsuario();
  }

  @override
  void dispose() {
    _controladorPesquisa.dispose();
    _controladorNomePerfil.dispose();
    _controladorEmailPerfil.dispose();
    _controladorSenhaPerfil.dispose();
    super.dispose();
  }

  Future<void> _atualizarListaEDadosUsuario() async {
    try {
      final plantas = await DBHelper().listarPlantasDoUsuario(widget.usuarioId);

      plantas.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      final usuario = await DBHelper().buscarUsuarioPorId(widget.usuarioId);

      if (mounted) {
        setState(() {
          _minhasPlantas = plantas;
          if (usuario != null) {
            _nomeExibicao = usuario.nome;
            if (_controladorNomePerfil.text.isEmpty) {
              _controladorNomePerfil.text = usuario.nome;
              _controladorEmailPerfil.text = usuario.email;
              _controladorSenhaPerfil.text = usuario.senha;
            }
          }
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Planta> get _plantasFiltradas {
    return _minhasPlantas.where((planta) {
      final correspondeTexto =
          planta.nome.toLowerCase().contains(_termoPesquisa.toLowerCase()) ||
          planta.especie.toLowerCase().contains(_termoPesquisa.toLowerCase());
      if (!correspondeTexto) return false;
      switch (_filtroStatusSelecionado) {
        case 'Atrasadas':
          return planta.diasRestantes < 0;
        case 'Regar Hoje':
          return planta.diasRestantes == 0;
        case 'Em dia':
          return planta.diasRestantes > 0;
        default:
          return true;
      }
    }).toList();
  }

  Widget _construirVisaoJardim(ThemeData tema) {
    final listagemFiltrada = _plantasFiltradas;

    int totalPaginas = (listagemFiltrada.length / _itensPorPagina).ceil();
    if (totalPaginas == 0) totalPaginas = 1;
    final paginaAtual = _paginaAtual > totalPaginas
        ? totalPaginas
        : _paginaAtual;

    int startIndex = (paginaAtual - 1) * _itensPorPagina;
    int endIndex = startIndex + _itensPorPagina;
    if (endIndex > listagemFiltrada.length) endIndex = listagemFiltrada.length;

    final plantasPaginadas = listagemFiltrada.isNotEmpty
        ? listagemFiltrada.sublist(startIndex, endIndex)
        : <Planta>[];

    int total = _minhasPlantas.length;
    int atrasadas = _minhasPlantas.where((p) => p.diasRestantes < 0).length;
    int hoje = _minhasPlantas.where((p) => p.diasRestantes == 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _itemDashboard(
                'No Jardim',
                '$total',
                Colors.green.shade600,
                Icons.yard_outlined,
              ),
              const SizedBox(width: 12),
              _itemDashboard(
                'Regar Hoje',
                '$hoje',
                hoje > 0 ? Colors.amber.shade600 : Colors.grey.shade400,
                Icons.water_drop_outlined,
              ),
              const SizedBox(width: 12),
              _itemDashboard(
                'Atrasadas',
                '$atrasadas',
                atrasadas > 0 ? Colors.red.shade600 : Colors.grey.shade400,
                Icons.warning_amber_rounded,
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _controladorPesquisa,
            onChanged: (valor) => setState(() {
              _termoPesquisa = valor;
              _paginaAtual = 1;
            }),
            decoration: InputDecoration(
              hintText: 'Pesquisar no jardim...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              suffixIcon: _termoPesquisa.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _controladorPesquisa.clear();
                        _termoPesquisa = '';
                        _paginaAtual = 1;
                      }),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.green.shade600, width: 2),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final recarregar = await showDialog<bool>(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: TelaFormularioPlanta(usuarioId: widget.usuarioId),
                  ),
                ),
              );
              if (recarregar == true) _atualizarListaEDadosUsuario();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_circle_outline, size: 22),
            label: const Text(
              'Adicionar Nova Planta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: ['Todas', 'Atrasadas', 'Regar Hoje', 'Em dia'].map((
              statusChip,
            ) {
              final selecionado = _filtroStatusSelecionado == statusChip;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(statusChip),
                  selected: selecionado,
                  onSelected: (bool valor) => setState(() {
                    _filtroStatusSelecionado = statusChip;
                    _paginaAtual = 1;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selecionado
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: Colors.green.shade50,
                  labelStyle: TextStyle(
                    color: selecionado
                        ? Colors.green.shade800
                        : Colors.grey.shade600,
                    fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: listagemFiltrada.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma planta encontrada.',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: plantasPaginadas.length + 1,
                  itemBuilder: (context, index) {
                    if (index == plantasPaginadas.length)
                      return _construirControlesDePaginacao(
                        totalPaginas,
                        paginaAtual,
                      );

                    final planta = plantasPaginadas[index];
                    final dias = planta.diasRestantes;

                    final hoje = DateTime.now();
                    final foiRegadaHoje =
                        planta.ultimaRega.year == hoje.year &&
                        planta.ultimaRega.month == hoje.month &&
                        planta.ultimaRega.day == hoje.day;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaDetalhesPlanta(
                                plantaId: planta.id!,
                                usuarioId: widget.usuarioId,
                              ),
                            ),
                          );
                          _atualizarListaEDadosUsuario();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_florist_outlined,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      planta.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      planta.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: dias < 0
                                            ? Colors.red.shade600
                                            : Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: foiRegadaHoje
                                    ? 'Desfazer rega'
                                    : 'Registrar rega',
                                icon: Icon(
                                  foiRegadaHoje
                                      ? Icons.water_drop
                                      : Icons.water_drop_outlined,
                                  color: foiRegadaHoje
                                      ? Colors.blue.shade500
                                      : Colors.grey.shade400,
                                  size: 26,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: foiRegadaHoje
                                      ? Colors.blue.shade50
                                      : Colors.transparent,
                                  shape: const CircleBorder(),
                                ),
                                onPressed: () async {
                                  if (foiRegadaHoje) {
                                    await DBHelper().reverterRegaHoje(
                                      planta.id!,
                                    );
                                  } else {
                                    await DBHelper().registrarRegaHoje(
                                      planta.id!,
                                    );
                                  }
                                  _atualizarListaEDadosUsuario();
                                },
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade300,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _construirVisaoPerfil(ThemeData tema) {
    int total = _minhasPlantas.length;
    int emDia = _minhasPlantas.where((p) => p.diasRestantes > 0).length;
    int regarHoje = _minhasPlantas.where((p) => p.diasRestantes == 0).length;
    int atrasadas = _minhasPlantas.where((p) => p.diasRestantes < 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green.shade50,
              child: Icon(Icons.person, size: 45, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _controladorNomePerfil,
            decoration: _decoracaoCampoPerfil(
              'Nome Completo',
              Icons.person_outline,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _controladorEmailPerfil,
            decoration: _decoracaoCampoPerfil('E-mail', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _controladorSenhaPerfil,
            obscureText: _senhaOculta,
            decoration: _decoracaoCampoPerfil(
              'Alterar Senha',
              Icons.lock_outline,
              sufixo: IconButton(
                icon: Icon(
                  _senhaOculta ? Icons.visibility_off : Icons.visibility,
                  color: Colors.green.shade700,
                ),
                onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
              ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text(
              'Salvar Alterações',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              String nome = _controladorNomePerfil.text.trim();
              String email = _controladorEmailPerfil.text.trim();
              String senha = _controladorSenhaPerfil.text.trim();

              if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nenhum campo pode ficar em branco.'),
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
              await _atualizarListaEDadosUsuario();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil atualizado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),

          Container(
            margin: const EdgeInsets.only(top: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insert_chart_outlined,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Desempenho do Jardim',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _linhaRelatorio(
                  'Plantas Registradas',
                  '$total',
                  Icons.grass_outlined,
                ),
                const SizedBox(height: 12),
                _linhaRelatorio(
                  'Status: Em Dia',
                  '$emDia',
                  Icons.check_circle_outline,
                  cor: Colors.green.shade600,
                ),
                const SizedBox(height: 12),
                _linhaRelatorio(
                  'Status: Regar Hoje',
                  '$regarHoje',
                  Icons.water_drop_outlined,
                  cor: Colors.amber.shade600,
                ),
                const SizedBox(height: 12),
                _linhaRelatorio(
                  'Status: Atrasadas',
                  '$atrasadas',
                  Icons.warning_amber_rounded,
                  cor: Colors.red.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemDashboard(
    String titulo,
    String valor,
    Color corDestaque,
    IconData icone,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: corDestaque, size: 26),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirControlesDePaginacao(int totalPaginas, int paginaAtual) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_left),
            onPressed: paginaAtual > 1
                ? () => setState(() => _paginaAtual--)
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Página $paginaAtual de $totalPaginas',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 16),
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_right),
            onPressed: paginaAtual < totalPaginas
                ? () => setState(() => _paginaAtual++)
                : null,
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracaoCampoPerfil(
    String rotulo,
    IconData icone, {
    Widget? sufixo,
  }) {
    return InputDecoration(
      labelText: rotulo,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icone, color: Colors.green.shade600),
      suffixIcon: sufixo,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.green.shade600, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
            Icon(icone, size: 20, color: cor ?? Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 15,
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
      appBar: AppBar(
        title: Text(
          _indiceAtual == 0 ? 'Jardim de $_nomeExibicao' : 'Meu Perfil',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaLogin()),
                );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: _indiceAtual,
                children: [
                  _construirVisaoJardim(tema),
                  _construirVisaoPerfil(tema),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceAtual,
          onTap: (int index) => setState(() => _indiceAtual = index),
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.yard_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.yard),
              ),
              label: 'Jardim',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
