import 'package:flutter/material.dart';
import '../banco_dados/db_helper.dart';
import '../models/planta.dart';

class TelaDetalhesPlanta extends StatefulWidget {
  final int plantaId;
  final int usuarioId;

  const TelaDetalhesPlanta({
    super.key,
    required this.plantaId,
    required this.usuarioId,
  });

  @override
  State<TelaDetalhesPlanta> createState() => _EstadoTelaDetalhesPlanta();
}

class _EstadoTelaDetalhesPlanta extends State<TelaDetalhesPlanta> {
  Planta? _planta;
  List<Map<String, dynamic>> _historico = [];
  bool _carregando = true;

  final _controladorNome = TextEditingController();
  final _controladorEspecie = TextEditingController();
  final _controladorDiasCustom = TextEditingController();

  int _intervaloSelecionado = 1;
  bool _teveAlteracao = false;
  String? _mensagemErro;

  int _paginaAtualHistorico = 1;
  final int _itensPorPaginaHistorico = 5;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final planta = await DBHelper().buscarPlantaPorId(widget.plantaId);
    final historico = await DBHelper().buscarHistoricoPlanta(widget.plantaId);
    if (mounted) {
      setState(() {
        _planta = planta;
        _historico = historico;
        _carregando = false;

        if (!_teveAlteracao && planta != null) {
          _controladorNome.text = planta.nome;
          _controladorEspecie.text = planta.especie;

          if ([1, 2, 3, 7, 15].contains(planta.intervaloDias)) {
            _intervaloSelecionado = planta.intervaloDias;
          } else {
            _intervaloSelecionado = -1;
            _controladorDiasCustom.text = planta.intervaloDias.toString();
          }
        }
      });
    }
  }

  void _marcarAlteracao() {
    if (!_teveAlteracao) setState(() => _teveAlteracao = true);
  }

  Future<void> _salvarAlteracoes() async {
    setState(() => _mensagemErro = null);

    if (_controladorNome.text.isEmpty) {
      setState(() => _mensagemErro = 'A planta precisa ter um nome.');
      return;
    }

    int intervalo = _intervaloSelecionado;
    if (_intervaloSelecionado == -1) {
      intervalo = int.tryParse(_controladorDiasCustom.text) ?? 0;
      if (intervalo <= 0) {
        setState(() => _mensagemErro = 'Insira um número válido de dias.');
        return;
      }
    }

    Planta plantaAtualizada = Planta(
      id: _planta!.id,
      usuarioId: _planta!.usuarioId,
      nome: _controladorNome.text.trim(),
      especie: _controladorEspecie.text.trim(),
      intervaloDias: intervalo,
      ultimaRega: _planta!.ultimaRega,
    );

    await DBHelper().atualizarPlanta(plantaAtualizada);
    await DBHelper().buscarPlantaPorId(_planta!.id!);

    setState(() {
      _planta = plantaAtualizada;
      _teveAlteracao = false;
    });

    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alterações salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmarExclusaoPlanta() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Remover Planta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${_planta!.nome}" do seu jardim?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () async {
              await DBHelper().excluirPlanta(_planta!.id!);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Planta removida com sucesso!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatarDataHora(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
  }

  Widget _construirBoletimSaude(ThemeData tema) {
    final hoje = DateTime.now();
    final dataAtual = DateTime(hoje.year, hoje.month, hoje.day);
    final dataRega = DateTime(
      _planta!.ultimaRega.year,
      _planta!.ultimaRega.month,
      _planta!.ultimaRega.day,
    );

    final diasPassados = dataAtual.difference(dataRega).inDays;
    final intervalo = _planta!.intervaloDias;
    final diasRestantes = intervalo - diasPassados;

    double nivelHidratacao = 1.0 - (diasPassados / intervalo);
    if (nivelHidratacao < 0) nivelHidratacao = 0.0;
    if (nivelHidratacao > 1) nivelHidratacao = 1.0;

    String diagnostico;
    Color corSaude;
    IconData iconeStatus;

    if (diasRestantes == intervalo || diasRestantes > 1) {
      diagnostico =
          'A planta está perfeitamente hidratada. O ritmo de rega está ótimo!';
      corSaude = Colors.green;
      iconeStatus = Icons.sentiment_very_satisfied;
    } else if (diasRestantes == 1 && intervalo > 1) {
      diagnostico =
          'A reserva de água está quase no fim. Prepare-se para regar amanhã.';
      corSaude = Colors.orange;
      iconeStatus = Icons.sentiment_neutral;
    } else if (diasRestantes == 0) {
      diagnostico =
          'É dia de rega! A terra já consumiu a água. Mantenha a hidratação em dia hoje.';
      corSaude = Colors.amber.shade700;
      iconeStatus = Icons.water_drop_outlined;
    } else {
      int diasAtraso = diasPassados - intervalo;
      diagnostico =
          'Alerta Crítico: Planta desidratada! A rega está atrasada em $diasAtraso dia(s). Regue imediatamente!';
      corSaude = Colors.red;
      iconeStatus = Icons.sentiment_very_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corSaude.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corSaude.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: corSaude),
              const SizedBox(width: 8),
              Text(
                'Boletim de Saúde',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: corSaude,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.opacity, size: 16, color: Colors.blue.shade300),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: nivelHidratacao,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    color: corSaude,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(nivelHidratacao * 100).toInt()}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: corSaude),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconeStatus, color: corSaude),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  diagnostico,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracaoInputClean(String dica, IconData icone) {
    return InputDecoration(
      hintText: dica,
      prefixIcon: Icon(icone, color: Colors.green.shade600, size: 20),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
      ),
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    if (_carregando || _planta == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hoje = DateTime.now();
    final foiRegadaHoje =
        _planta!.ultimaRega.year == hoje.year &&
        _planta!.ultimaRega.month == hoje.month &&
        _planta!.ultimaRega.day == hoje.day;

    int totalPaginasHist = (_historico.length / _itensPorPaginaHistorico)
        .ceil();
    if (totalPaginasHist == 0) totalPaginasHist = 1;
    if (_paginaAtualHistorico > totalPaginasHist)
      _paginaAtualHistorico = totalPaginasHist;

    int startIdx = (_paginaAtualHistorico - 1) * _itensPorPaginaHistorico;
    int endIdx = startIdx + _itensPorPaginaHistorico;
    if (endIdx > _historico.length) endIdx = _historico.length;

    final historicoPaginado = _historico.isNotEmpty
        ? _historico.sublist(startIdx, endIdx)
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _planta!.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: _confirmarExclusaoPlanta,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _construirBoletimSaude(tema),
              const SizedBox(height: 24),

              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    maintainState: true,
                    iconColor: Colors.green.shade700,
                    collapsedIconColor: Colors.grey.shade500,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_note,
                        color: Colors.green.shade700,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Editar Dados da Planta',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_mensagemErro != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _mensagemErro!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 8),
                          const Text(
                            'Nome da Planta',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controladorNome,
                            decoration: _decoracaoInputClean(
                              'Ex: Samambaia da Sala',
                              Icons.local_florist_outlined,
                            ),
                            onChanged: (_) => _marcarAlteracao(),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Espécie',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controladorEspecie,
                            decoration: _decoracaoInputClean(
                              'Ex: Nephrolepis exaltata (Opcional)',
                              Icons.science_outlined,
                            ),
                            onChanged: (_) => _marcarAlteracao(),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Frequência de Rega',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                  {'label': 'Todo dia', 'dias': 1},
                                  {'label': 'A cada 2 dias', 'dias': 2},
                                  {'label': 'A cada 3 dias', 'dias': 3},
                                  {'label': 'Semanal', 'dias': 7},
                                  {'label': 'Quinzenal', 'dias': 15},
                                  {'label': 'Personalizado...', 'dias': -1},
                                ].map((opcao) {
                                  int dias = opcao['dias'] as int;
                                  bool selecionado =
                                      _intervaloSelecionado == dias;
                                  return FilterChip(
                                    label: Text(opcao['label'] as String),
                                    selected: selecionado,
                                    onSelected: (bool valor) {
                                      setState(
                                        () => _intervaloSelecionado = dias,
                                      );
                                      _marcarAlteracao();
                                    },
                                    showCheckmark: false,
                                    backgroundColor: Colors.transparent,
                                    selectedColor: Colors.blue.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: selecionado
                                            ? Colors.blue.shade200
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: selecionado
                                          ? Colors.blue.shade700
                                          : Colors.black87,
                                      fontWeight: selecionado
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  );
                                }).toList(),
                          ),

                          if (_intervaloSelecionado == -1) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Quantidade de dias personalizada',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _controladorDiasCustom,
                              keyboardType: TextInputType.number,
                              decoration: _decoracaoInputClean(
                                'Insira a quantidade de dias',
                                Icons.edit_calendar_outlined,
                              ),
                              onChanged: (_) => _marcarAlteracao(),
                            ),
                          ],

                          if (_teveAlteracao) ...[
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.save_outlined, size: 22),
                                label: const Text(
                                  'Salvar Alterações',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _salvarAlteracoes,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Icon(Icons.history, color: Colors.green.shade900),
                  const SizedBox(width: 8),
                  Text(
                    'Histórico de Cuidados',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _historico.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Nenhuma rega registrada ainda.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historicoPaginado.length,
                      itemBuilder: (context, index) {
                        final item = historicoPaginado[index];
                        final data = DateTime.parse(item['data_hora']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.water_drop,
                                    color: Colors.blue.shade500,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['acao'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatarDataHora(data),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  onPressed: () async {
                                    await DBHelper().excluirHistoricoRega(
                                      item['id'],
                                      widget.plantaId,
                                    );
                                    _carregarDados();
                                  },
                                  style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(40, 40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              if (totalPaginasHist > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.chevron_left, size: 18),
                        onPressed: _paginaAtualHistorico > 1
                            ? () => setState(() => _paginaAtualHistorico--)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_paginaAtualHistorico / $totalPaginasHist',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.chevron_right, size: 18),
                        onPressed: _paginaAtualHistorico < totalPaginasHist
                            ? () => setState(() => _paginaAtualHistorico++)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: foiRegadaHoje
            ? ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'Regada Hoje (Desfazer)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await DBHelper().reverterRegaHoje(_planta!.id!);
                  _carregarDados();
                },
              )
            : ElevatedButton.icon(
                icon: const Icon(Icons.water_drop),
                label: const Text(
                  'Registrar Rega Agora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await DBHelper().registrarRegaHoje(_planta!.id!);
                  _carregarDados();
                },
              ),
      ),
    );
  }
}
