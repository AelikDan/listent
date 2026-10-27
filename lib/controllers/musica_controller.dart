import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musica_model.dart';

// Aqui ficam as operações relacionadas às músicas dentro de uma playlist
class MusicaController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _musicasDaPlaylist(String playlistId) {
    return _db.collection('playlists').doc(playlistId).collection('musicas');
  }

  // Lista em tempo real as músicas de uma playlist (RNF02)
  Stream<List<MusicaModel>> streamMusicas(String playlistId) {
    return _musicasDaPlaylist(playlistId).snapshots().map((snap) => snap.docs
        .map((d) => MusicaModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  // Adiciona uma música escolhida na busca do Spotify (RF06)
  // Guarda também quem adicionou, pra manter o histórico (RNF07)
  Future<void> adicionarMusica({
    required String playlistId,
    required String spotifyId,
    required String nome,
    required String artista,
    required String capaUrl,
    required String uidQuemAdicionou,
  }) async {
    await _musicasDaPlaylist(playlistId).add({
      'nome': nome,
      'artista': artista,
      'capaUrl': capaUrl,
      'spotifyId': spotifyId,
      'addedBy': uidQuemAdicionou,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove uma música da playlist (RF07)
  Future<void> removerMusica(String playlistId, String musicaId) async {
    await _musicasDaPlaylist(playlistId).doc(musicaId).delete();
  }
}
