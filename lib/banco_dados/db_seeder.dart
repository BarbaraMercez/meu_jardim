import 'db_helper.dart';

class DBSeeder {
  static Future<void> inicializar() async {
    final db = DBHelper();
    final boxU = await db.getBox(DBHelper.boxUsuarios);
    final boxP = await db.getBox(DBHelper.boxPlantas);
    final boxH = await db.getBox(DBHelper.boxHistorico);

    if (boxU.isEmpty) {
      final uMap = <String, dynamic>{
        'nome': 'Admin',
        'email': 'admin@teste.com',
        'senha': '123',
      };
      final uKey = await boxU.add(uMap);
      uMap['id'] = uKey;
      await boxU.put(uKey, uMap);

      if (boxP.isEmpty) {
        final hoje = DateTime.now();

        final p1 = <String, dynamic>{
          'usuario_id': uKey,
          'nome': 'Samambaia Americana',
          'especie': 'Nephrolepis exaltata',
          'ultima_rega': hoje.toIso8601String(),
          'intervalo_dias': 3,
        };
        final k1 = await boxP.add(p1);
        p1['id'] = k1;
        await boxP.put(k1, p1);

        final p2 = <String, dynamic>{
          'usuario_id': uKey,
          'nome': 'Cacto Mandacaru',
          'especie': 'Cereus jamacaru',
          'ultima_rega': hoje
              .subtract(const Duration(days: 15))
              .toIso8601String(),
          'intervalo_dias': 15,
        };
        final k2 = await boxP.add(p2);
        p2['id'] = k2;
        await boxP.put(k2, p2);

        final p3 = <String, dynamic>{
          'usuario_id': uKey,
          'nome': 'Espada-de-São-Jorge',
          'especie': 'Sansevieria trifasciata',
          'ultima_rega': hoje
              .subtract(const Duration(days: 20))
              .toIso8601String(),
          'intervalo_dias': 7,
        };
        final k3 = await boxP.add(p3);
        p3['id'] = k3;
        await boxP.put(k3, p3);

        if (boxH.isEmpty) {
          final r6DiasAtras = hoje
              .subtract(const Duration(days: 6))
              .toIso8601String();
          final r3DiasAtras = hoje
              .subtract(const Duration(days: 3))
              .toIso8601String();
          final r20DiasAtras = hoje
              .subtract(const Duration(days: 20))
              .toIso8601String();
          final r15DiasAtras = hoje
              .subtract(const Duration(days: 15))
              .toIso8601String();
          final r14DiasAtras = hoje
              .subtract(const Duration(days: 14))
              .toIso8601String();
          final r7DiasAtras = hoje
              .subtract(const Duration(days: 7))
              .toIso8601String();

          final h1 = {
            'planta_id': k1,
            'data_hora': r6DiasAtras,
            'acao': '💧 Rega confirmada',
            'data_anterior': r6DiasAtras,
          };
          final kh1 = await boxH.add(h1);
          h1['id'] = kh1;
          await boxH.put(kh1, h1);

          final h2 = {
            'planta_id': k1,
            'data_hora': r3DiasAtras,
            'acao': '💧 Rega confirmada',
            'data_anterior': r6DiasAtras,
          };
          final kh2 = await boxH.add(h2);
          h2['id'] = kh2;
          await boxH.put(kh2, h2);

          final h3 = {
            'planta_id': k2,
            'data_hora': r15DiasAtras,
            'acao': '💧 Rega confirmada',
            'data_anterior': r15DiasAtras,
          };
          final kh3 = await boxH.add(h3);
          h3['id'] = kh3;
          await boxH.put(kh3, h3);

          final h4 = {
            'planta_id': k3,
            'data_hora': r14DiasAtras,
            'acao': '💧 Rega confirmada',
            'data_anterior': r20DiasAtras,
          };
          final kh4 = await boxH.add(h4);
          h4['id'] = kh4;
          await boxH.put(kh4, h4);

          final h5 = {
            'planta_id': k3,
            'data_hora': r7DiasAtras,
            'acao': '💧 Rega confirmada',
            'data_anterior': r14DiasAtras,
          };
          final kh5 = await boxH.add(h5);
          h5['id'] = kh5;
          await boxH.put(kh5, h5);
        }
      }
    }
  }
}
