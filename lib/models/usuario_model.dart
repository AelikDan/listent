// Representa um usuário do GrooveShare (guardado em users/{uid})
class UsuarioModel {
  final String uid;
  final String email;
  final String nome;

  UsuarioModel({
    required this.uid,
    required this.email,
    required this.nome,
  });

  // Converte os dados vindos do Firestore pro modelo
  factory UsuarioModel.fromMap(String uid, Map<String, dynamic> dados) {
    return UsuarioModel(
      uid: uid,
      email: dados['email'] ?? '',
      nome: dados['displayName'] ?? '',
    );
  }

  // Nome pra mostrar na tela, usa o e-mail se não tiver nome salvo
  String get nomeParaExibir => nome.isNotEmpty ? nome : email;
}
