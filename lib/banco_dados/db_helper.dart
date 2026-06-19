import 'package:hive_flutter/hive_flutter.dart';
import '../models/usuario.dart';
import '../models/planta.dart';

class DBHelper {
  static final DBHelper _instancia = DBHelper._interno();
  factory DBHelper() => _instancia;
  DBHelper._interno();

  static const String boxUsuarios = 'usuarios_box';
  static const String boxPlantas = 'plantas_box';
  static const String boxHistorico = 'historico_box';

  Future<Box> getBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  // --- GESTÃO DE USUÁRIOS ---

  // Registrar um novo usuário
  Future<int> cadastrarUsuario(Usuario usuario) async {
    final box = await getBox(boxUsuarios);
    final map = usuario.toMap();
    final key = await box.add(map);
    map['id'] = key;
    await box.put(key, map);
    return key;
  }

  // Autenticação
  Future<Usuario?> loginUsuario(String email, String senha) async {
    final box = await getBox(boxUsuarios);
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data);
        if (map['email'] == email && map['senha'] == senha) {
          map['id'] = key;
          return Usuario.fromMap(map);
        }
      }
    }
    return null;
  }

  // Atualizar Usuário
  Future<int> atualizarUsuario(Usuario usuario) async {
    if (usuario.id == null) return 0;
    final box = await getBox(boxUsuarios);
    final map = usuario.toMap();
    map['id'] = usuario.id;
    await box.put(usuario.id, map);
    return 1;
  }

  // Busca os dados de um usuário específico
  Future<Usuario?> buscarUsuarioPorId(int id) async {
    final box = await getBox(boxUsuarios);
    final data = box.get(id);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map['id'] = id;
      return Usuario.fromMap(map);
    }
    return null;
  }

  // --- GESTÃO DE PLANTAS ---

  // Registra uma nova planta associada a um usuário específico
  Future<int> cadastrarPlanta(Planta planta) async {
    final box = await getBox(boxPlantas);
    final map = planta.toMap();
    final key = await box.add(map);
    map['id'] = key;
    await box.put(key, map);
    await box.flush();
    return key;
  }

  // Retorna a lista de todas as plantas cadastradas pelo usuário
  Future<List<Planta>> listarPlantasDoUsuario(int usuarioId) async {
    final box = await getBox(boxPlantas);
    List<Planta> lista = [];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data);
        if (map['usuario_id'] == usuarioId) {
          map['id'] = key;
          lista.add(Planta.fromMap(map));
        }
      }
    }
    return lista;
  }

  // Busca os detalhes de uma planta específica através do seu ID
  Future<Planta?> buscarPlantaPorId(int id) async {
    final box = await getBox(boxPlantas);
    final data = box.get(id);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map['id'] = id;
      return Planta.fromMap(map);
    }
    return null;
  }

  // Atualiza os dados de uma planta existente
  Future<int> atualizarPlanta(Planta planta) async {
    final box = await getBox(boxPlantas);
    final map = planta.toMap();
    map['id'] = planta.id;
    await box.put(planta.id, map);
    await box.flush();
    return 1;
  }

  // Remove uma planta e deleta todo o seu histórico de regas
  Future<int> excluirPlanta(int plantaId) async {
    final box = await getBox(boxPlantas);
    await box.delete(plantaId);

    final boxH = await getBox(boxHistorico);
    final chavesParaApagar = [];
    for (var key in boxH.keys) {
      final item = boxH.get(key);
      if (item != null && item['planta_id'] == plantaId) {
        chavesParaApagar.add(key);
      }
    }

    await boxH.deleteAll(chavesParaApagar);
    return 1;
  }

  // --- HISTÓRICO E REGAS ---

  // Registra que a planta foi regada hoje salvando o evento na linha do tempo
  Future<void> registrarRegaHoje(int plantaId) async {
    final boxP = await getBox(boxPlantas);
    final boxH = await getBox(boxHistorico);
    final dataHora = DateTime.now().toIso8601String();

    final dataP = boxP.get(plantaId);
    String dataAnterior = dataHora;

    if (dataP != null) {
      final mapP = Map<String, dynamic>.from(dataP);
      dataAnterior = mapP['ultima_rega'] ?? dataHora;
      mapP['ultima_rega'] = dataHora;
      await boxP.put(plantaId, mapP);
    }

    final hMap = {
      'planta_id': plantaId,
      'data_hora': dataHora,
      'acao': '💧 Rega confirmada',
      'data_anterior': dataAnterior,
    };
    final hKey = await boxH.add(hMap);
    hMap['id'] = hKey;
    await boxH.put(hKey, hMap);
  }

  // Retorna todo o histórico de cuidados de uma planta do mais recente ao mais antigo
  Future<List<Map<String, dynamic>>> buscarHistoricoPlanta(int plantaId) async {
    final boxH = await getBox(boxHistorico);
    List<Map<String, dynamic>> lista = [];
    for (var key in boxH.keys) {
      final data = boxH.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data);
        if (map['planta_id'] == plantaId) {
          map['id'] = key;
          lista.add(map);
        }
      }
    }
    lista.sort(
      (a, b) => b['data_hora'].toString().compareTo(a['data_hora'].toString()),
    );
    return lista;
  }

  // Apaga um registro específico do histórico e recalcula a última rega da planta
  Future<void> excluirHistoricoRega(int historicoId, int plantaId) async {
    final boxP = await getBox(boxPlantas);
    final boxH = await getBox(boxHistorico);

    final todosRegistros = await buscarHistoricoPlanta(plantaId);
    bool apagandoMaisRecente = false;
    if (todosRegistros.isNotEmpty &&
        todosRegistros.first['id'] == historicoId) {
      apagandoMaisRecente = true;
    }

    final registroApagado = boxH.get(historicoId);
    String? dataMemoria;
    if (registroApagado != null) {
      final mapH = Map<String, dynamic>.from(registroApagado);
      dataMemoria = mapH['data_anterior'];
    }

    await boxH.delete(historicoId);
    if (apagandoMaisRecente) {
      final dataP = boxP.get(plantaId);
      if (dataP != null) {
        final mapP = Map<String, dynamic>.from(dataP);
        if (dataMemoria != null) {
          mapP['ultima_rega'] = dataMemoria;
        } else {
          int intervalo = mapP['intervalo_dias'] ?? 1;
          mapP['ultima_rega'] = DateTime.now()
              .subtract(Duration(days: intervalo))
              .toIso8601String();
        }
        await boxP.put(plantaId, mapP);
      }
    }
  }

  // Reverte o regsitro de "Regada Hoje"
  Future<void> reverterRegaHoje(int plantaId) async {
    final restante = await buscarHistoricoPlanta(plantaId);

    if (restante.isNotEmpty) {
      int historicoId = restante.first['id'];
      await excluirHistoricoRega(historicoId, plantaId);
    } else {
      final boxP = await getBox(boxPlantas);
      final dataP = boxP.get(plantaId);

      if (dataP != null) {
        final mapP = Map<String, dynamic>.from(dataP);
        int intervalo = mapP['intervalo_dias'] ?? 1;
        mapP['ultima_rega'] = DateTime.now()
            .subtract(Duration(days: intervalo))
            .toIso8601String();
        await boxP.put(plantaId, mapP);
      }
    }
  }
}
