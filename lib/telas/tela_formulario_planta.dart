import 'package:flutter/material.dart';
import '../models/planta.dart';
import '../banco_dados/db_helper.dart';

class TelaFormularioPlanta extends StatefulWidget {
  final int usuarioId;
  final Planta? plantaExistente;

  const TelaFormularioPlanta({
    super.key,
    required this.usuarioId,
    this.plantaExistente,
  });

  @override
  State<TelaFormularioPlanta> createState() => _EstadoTelaFormularioPlanta();
}

class _EstadoTelaFormularioPlanta extends State<TelaFormularioPlanta> {
  final _controladorNome = TextEditingController();
  final _controladorEspecie = TextEditingController();
  final _controladorDiasCustom = TextEditingController();

  int _intervaloSelecionado = 1;
  DateTime _dataUltimaRega = DateTime.now();
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    if (widget.plantaExistente != null) {
      _controladorNome.text = widget.plantaExistente!.nome;
      _controladorEspecie.text = widget.plantaExistente!.especie;
      _dataUltimaRega = widget.plantaExistente!.ultimaRega;

      if ([1, 2, 3, 7, 15].contains(widget.plantaExistente!.intervaloDias)) {
        _intervaloSelecionado = widget.plantaExistente!.intervaloDias;
      } else {
        _intervaloSelecionado = -1;
        _controladorDiasCustom.text = widget.plantaExistente!.intervaloDias
            .toString();
      }
    }
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorEspecie.dispose();
    _controladorDiasCustom.dispose();
    super.dispose();
  }

  InputDecoration _decoracaoCampo(String rotulo, IconData icone) {
    return InputDecoration(
      labelText: rotulo,
      prefixIcon: Icon(icone, color: Colors.green.shade600),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.green.shade600, width: 2),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.plantaExistente == null
                      ? 'Nova Planta'
                      : 'Editar Planta',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade400),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controladorNome,
              decoration: _decoracaoCampo(
                'Nome da Planta (Ex: Samambaia)',
                Icons.local_florist_outlined,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controladorEspecie,
              decoration: _decoracaoCampo(
                'Espécie (Opcional)',
                Icons.science_outlined,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: const Text(
                  'Última rega',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "${_dataUltimaRega.day.toString().padLeft(2, '0')}/${_dataUltimaRega.month.toString().padLeft(2, '0')}/${_dataUltimaRega.year}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dataUltimaRega,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _dataUltimaRega = d);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Frequência de Rega',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                    bool selecionado = _intervaloSelecionado == dias;
                    return FilterChip(
                      label: Text(opcao['label'] as String),
                      selected: selecionado,
                      onSelected: (bool valor) =>
                          setState(() => _intervaloSelecionado = dias),
                      showCheckmark: false,
                      backgroundColor: Colors.grey.shade50,
                      selectedColor: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selecionado
                              ? Colors.blue.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: selecionado
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                        fontWeight: selecionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),
            if (_intervaloSelecionado == -1) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _controladorDiasCustom,
                keyboardType: TextInputType.number,
                decoration: _decoracaoCampo(
                  'A cada quantos dias?',
                  Icons.edit_calendar_outlined,
                ),
              ),
            ],
            const SizedBox(height: 32),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                setState(() => _mensagemErro = null);

                if (_controladorNome.text.isEmpty) {
                  setState(
                    () =>
                        _mensagemErro = 'Por favor, dê um nome para a planta.',
                  );
                  return;
                }

                int intervalo = _intervaloSelecionado;
                if (_intervaloSelecionado == -1) {
                  intervalo = int.tryParse(_controladorDiasCustom.text) ?? 0;
                  if (intervalo <= 0) {
                    setState(
                      () => _mensagemErro = 'Insira um número válido de dias.',
                    );
                    return;
                  }
                }

                Planta novaPlanta = Planta(
                  id: widget.plantaExistente?.id,
                  usuarioId: widget.usuarioId,
                  nome: _controladorNome.text.trim(),
                  especie: _controladorEspecie.text.trim(),
                  intervaloDias: intervalo,
                  ultimaRega: _dataUltimaRega,
                );

                if (widget.plantaExistente == null) {
                  await DBHelper().cadastrarPlanta(novaPlanta);
                } else {
                  await DBHelper().atualizarPlanta(novaPlanta);
                }

                if (mounted) Navigator.pop(context, true);
              },
              child: const Text(
                'Salvar Planta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
