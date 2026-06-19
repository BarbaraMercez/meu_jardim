class Planta {
  int? id;
  int usuarioId;
  String nome;
  String especie;
  int intervaloDias;
  DateTime ultimaRega;

  Planta({
    this.id,
    required this.usuarioId,
    required this.nome,
    required this.especie,
    required this.intervaloDias,
    required this.ultimaRega,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      'especie': especie,
      'intervalo_dias': intervaloDias,
      'ultima_rega': ultimaRega.toIso8601String(),
    };
  }

  factory Planta.fromMap(Map<String, dynamic> map) {
    return Planta(
      id: map['id'],
      usuarioId: map['usuario_id'] ?? 0,
      nome: map['nome'] ?? map['nome_popular'] ?? 'Planta Sem Nome',
      especie: map['especie'] ?? '',
      intervaloDias: map['intervalo_dias'] ?? 1,
      ultimaRega: map['ultima_rega'] != null
          ? DateTime.tryParse(map['ultima_rega'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  int get diasRestantes {
    final hoje = DateTime.now();
    final dataAtual = DateTime(hoje.year, hoje.month, hoje.day);
    final dataRega = DateTime(
      ultimaRega.year,
      ultimaRega.month,
      ultimaRega.day,
    );

    final diasPassados = dataAtual.difference(dataRega).inDays;
    return intervaloDias - diasPassados;
  }

  String get status {
    if (diasRestantes > 0) return 'Em dia';
    if (diasRestantes == 0) return 'Regar Hoje';
    return 'Atrasada';
  }
}
