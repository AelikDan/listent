import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/musica_controller.dart';
import '../models/playlist_model.dart';
import '../models/musica_model.dart';
import '../models/usuario_model.dart';
import 'buscar_musica_view.dart';

// Tela de detalhe: mostra colaboradores e as músicas de uma playlist (RF09)
class PlaylistDetalheView extends StatelessWidget {
  final String playlistId;

  const PlaylistDetalheView({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final uid = AuthController().usuarioAtual!.uid;
    final playlistController = PlaylistController();
    final musicaController = MusicaController();

    return StreamBuilder<PlaylistModel>(
      stream: playlistController.streamPlaylist(playlistId),
      builder: (context, snapshotPlaylist) {
        if (!snapshotPlaylist.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final playlist = snapshotPlaylist.data!;
        final souDono = playlist.ownerId == uid;
        final possoEditar = playlist.podeEditar(uid);

        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.nome),
            actions: [
              if (souDono)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Convidar colaborador',
                  onPressed: () => _mostrarDialogoConvidar(context, playlistController),
                ),
              if (souDono)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir playlist',
                  onPressed: () => _confirmarExclusao(context, playlistController),
                ),
            ],
          ),
          body: Column(
            children: [
              _CabecalhoColaboradores(
                playlist: playlist,
                souDono: souDono,
                controller: playlistController,
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<MusicaModel>>(
                  stream: musicaController.streamMusicas(playlistId),
                  builder: (context, snapshotMusicas) {
                    final musicas = snapshotMusicas.data ?? [];

                    if (musicas.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma música ainda', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      itemCount: musicas.length,
                      itemBuilder: (context, index) {
                        final musica = musicas[index];
                        return ListTile(
                          leading: musica.capaUrl.isNotEmpty
                              ? Image.network(musica.capaUrl, width: 48, height: 48, fit: BoxFit.cover)
                              : const Icon(Icons.music_note),
                          title: Text(musica.nome),
                          subtitle: Text(musica.artista),
                          trailing: possoEditar
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      musicaController.removerMusica(playlistId, musica.id),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: possoEditar
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuscarMusicaView(playlistId: playlistId),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  void _mostrarDialogoConvidar(BuildContext context, PlaylistController controller) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar colaborador'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'E-mail do amigo'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              final erro = await controller.convidarColaboradorPorEmail(
                playlistId,
                emailController.text,
              );

              navigator.pop();
              if (erro != null) {
                messenger.showSnackBar(SnackBar(content: Text(erro)));
              }
            },
            child: const Text('Convidar'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, PlaylistController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir playlist'),
        content: const Text('Essa ação não pode ser desfeita. Quer mesmo excluir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await controller.excluirPlaylist(playlistId);
              navigator.pop();
              navigator.pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// Mostra a lista de colaboradores e deixa o dono remover alguém (RF04)
class _CabecalhoColaboradores extends StatelessWidget {
  final PlaylistModel playlist;
  final bool souDono;
  final PlaylistController controller;

  const _CabecalhoColaboradores({
    required this.playlist,
    required this.souDono,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (playlist.collaborators.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Nenhum colaborador ainda', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: playlist.collaborators.map((uidColaborador) {
          return FutureBuilder<UsuarioModel>(
            future: controller.buscarUsuarioPorUid(uidColaborador),
            builder: (context, snapshot) {
              final nome = snapshot.data?.nomeParaExibir ?? '...';
              return Chip(
                label: Text(nome),
                onDeleted: souDono
                    ? () => controller.removerColaborador(playlist.id, uidColaborador)
                    : null,
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
