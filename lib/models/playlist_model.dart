import 'package:cloud_firestore/cloud_firestore.dart';

// Representa uma playlist colaborativa (coleção playlists/{id})
class PlaylistModel {
  final String id;
  final String nome;
  final String ownerId;
  final List<String> collaborators;
  final DateTime? criadaEm;

  PlaylistModel({
    required this.id,
    required this.nome,
    required this.ownerId,
    required this.collaborators,
    this.criadaEm,
  });

  // Converte os dados vindos do Firestore pro modelo
  factory PlaylistModel.fromMap(String id, Map<String, dynamic> dados) {
    return PlaylistModel(
      id: id,
      nome: dados['nome'] ?? '',
      ownerId: dados['ownerId'] ?? '',
      collaborators: List<String>.from(dados['collaborators'] ?? []),
      criadaEm: dados['criadaEm'] != null
          ? (dados['criadaEm'] as Timestamp).toDate()
          : null,
    );
  }

  // Verifica se o usuário pode editar essa playlist (é o dono ou um colaborador)
  bool podeEditar(String uid) {
    return uid == ownerId || collaborators.contains(uid);
  }
}
