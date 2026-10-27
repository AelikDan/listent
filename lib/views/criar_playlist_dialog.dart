import 'package:flutter/material.dart';
import '../controllers/playlist_controller.dart';

// Dialog simples pra criar uma playlist nova (RF02)
Future<void> mostrarDialogoCriarPlaylist(BuildContext context, String uid) async {
  final controller = TextEditingController();
  final playlistController = PlaylistController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nova playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nome da playlist'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.trim().isEmpty) return;
            await playlistController.criarPlaylist(controller.text, uid);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Criar'),
        ),
      ],
    ),
  );
}
