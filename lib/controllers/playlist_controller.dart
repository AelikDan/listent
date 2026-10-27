import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playlist_model.dart';
import '../models/usuario_model.dart';

// Aqui ficam as operações relacionadas a playlists:
// criar, listar, convidar/remover colaborador e excluir
class PlaylistController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _playlists => _db.collection('playlists');

  // Lista em tempo real as playlists onde o usuário é dono OU colaborador (RF08)
  // Usa Filter.or porque o Firestore não deixa combinar "ownerId == uid" com
  // "collaborators contém uid" numa query normal
  Stream<List<PlaylistModel>> streamPlaylistsDoUsuario(String uid) {
    return _playlists
        .where(Filter.or(
          Filter('ownerId', isEqualTo: uid),
          Filter('collaborators', arrayContains: uid),
        ))
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PlaylistModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  // Detalhe de uma playlist em tempo real (RF09, RNF02)
  Stream<PlaylistModel> streamPlaylist(String playlistId) {
    return _playlists.doc(playlistId).snapshots().map(
        (doc) => PlaylistModel.fromMap(doc.id, doc.data() as Map<String, dynamic>));
  }

  // Cria uma nova playlist com o usuário atual como dono (RF02)
  Future<String> criarPlaylist(String nome, String ownerId) async {
    final doc = await _playlists.add({
      'nome': nome.trim(),
      'ownerId': ownerId,
      'collaborators': <String>[],
      'criadaEm': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Convida um colaborador buscando o UID dele pelo e-mail (RF03)
  // Retorna uma mensagem de erro, ou null se deu tudo certo
  Future<String?> convidarColaboradorPorEmail(
      String playlistId, String emailDigitado) async {
    final emailBusca = emailDigitado.trim().toLowerCase();

    if (emailBusca.isEmpty) return 'Digite um e-mail';

    final resultado = await _db
        .collection('users')
        .where('email', isEqualTo: emailBusca)
        .limit(1)
        .get();

    if (resultado.docs.isEmpty) {
      return 'Nenhum usuário encontrado com esse e-mail';
    }

    final uidConvidado = resultado.docs.first.id;

    await _playlists.doc(playlistId).update({
      'collaborators': FieldValue.arrayUnion([uidConvidado]),
    });

    return null;
  }

  // Remove um colaborador da playlist (RF04)
  Future<void> removerColaborador(String playlistId, String uidColaborador) async {
    await _playlists.doc(playlistId).update({
      'collaborators': FieldValue.arrayRemove([uidColaborador]),
    });
  }

  // Exclui a playlist inteira - só o dono deve poder chamar isso (RF10)
  Future<void> excluirPlaylist(String playlistId) async {
    await _playlists.doc(playlistId).delete();
  }

  // Busca os dados de um usuário a partir do uid, pra mostrar o nome dele na tela
  Future<UsuarioModel> buscarUsuarioPorUid(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UsuarioModel.fromMap(uid, doc.data() ?? {});
  }
}
