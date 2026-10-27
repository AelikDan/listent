import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/playlist_controller.dart';
import '../models/playlist_model.dart';
import 'criar_playlist_dialog.dart';
import 'playlist_detalhe_view.dart';

// Tela principal: lista as playlists onde o usuário é dono ou colaborador (RF08)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();
    final playlistController = PlaylistController();
    final uid = auth.usuarioAtual!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: StreamBuilder<List<PlaylistModel>>(
        stream: playlistController.streamPlaylistsDoUsuario(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final playlists = snapshot.data ?? [];

          if (playlists.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não tem nenhuma playlist.\nToque no + pra criar a primeira.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final souDono = playlist.ownerId == uid;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.nome),
                  subtitle: Text(souDono ? 'Você é o dono' : 'Você é colaborador'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetalheView(playlistId: playlist.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarDialogoCriarPlaylist(context, uid),
        child: const Icon(Icons.add),
      ),
    );
  }
}
