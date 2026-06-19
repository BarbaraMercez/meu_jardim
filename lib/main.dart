import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'telas/tela_verificacao.dart';
import 'banco_dados/db_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DBSeeder.inicializar();

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Jardim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TelaVerificacao(),
    );
  }
}
