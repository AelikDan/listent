import 'package:cloud_firestore/cloud_firestore.dart';

// Representa uma música dentro de uma playlist (subcoleção playlists/{id}/musicas)
class MusicaModel {
  final String id;
  final String nome;
  final String artista;
  final String capaUrl;
  final String spotifyId;
  final String addedBy;
  final DateTime? addedAt;

  MusicaModel({
    required this.id,
    required this.nome,
    required this.artista,
    required this.capaUrl,
    required this.spotifyId,
    required this.addedBy,
    this.addedAt,
  });

  // Converte os dados vindos do Firestore pro modelo
  factory MusicaModel.fromMap(String id, Map<String, dynamic> dados) {
    return MusicaModel(
      id: id,
      nome: dados['nome'] ?? '',
      artista: dados['artista'] ?? '',
      capaUrl: dados['capaUrl'] ?? '',
      spotifyId: dados['spotifyId'] ?? '',
      addedBy: dados['addedBy'] ?? '',
      addedAt: dados['addedAt'] != null
          ? (dados['addedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
