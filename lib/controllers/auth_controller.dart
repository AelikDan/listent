import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Aqui ficam as operações de autenticação (login, cadastro, logout)
class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fica de olho se o usuário está logado ou não, usado pra trocar de tela
  Stream<User?> get streamUsuario => _auth.authStateChanges();

  User? get usuarioAtual => _auth.currentUser;

  // Cria a conta e também salva os dados em users/{uid}, necessário pro
  // convite por e-mail funcionar depois
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    final uid = credencial.user!.uid;

    await _db.collection('users').doc(uid).set({
      'email': email.trim().toLowerCase(),
      'displayName': nome.trim(),
    });

    await credencial.user!.updateDisplayName(nome.trim());
  }

  Future<void> login({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
