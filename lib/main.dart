import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'utils/tema.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase. No Android, as opções vêm do google-services.json
  await Firebase.initializeApp();

  runApp(const GrooveShareApp());
}

class GrooveShareApp extends StatelessWidget {
  const GrooveShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrooveShare',
      debugShowCheckedModeBanner: false,
      theme: Tema.dark,
      home: const TelaInicial(),
    );
  }
}

// decide se mostra a tela de login ou a home, de acordo com o estado de autenticação
class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();

    return StreamBuilder(
      stream: auth.streamUsuario,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeView();
        }

        return const LoginView();
      },
    );
  }
}
