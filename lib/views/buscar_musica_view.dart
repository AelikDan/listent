import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/musica_controller.dart';
import '../controllers/spotify_controller.dart';

// Tela de busca de músicas no Spotify pra adicionar na playlist (RF05, RF06)
class BuscarMusicaView extends StatefulWidget {
  final String playlistId;

  const BuscarMusicaView({super.key, required this.playlistId});

  @override
  State<BuscarMusicaView> createState() => _BuscarMusicaViewState();
}

class _BuscarMusicaViewState extends State<BuscarMusicaView> {
  final _spotify = SpotifyController();
  final _musicaController = MusicaController();
  final _buscaController = TextEditingController();

  List<ResultadoSpotify> _resultados = [];
  bool _carregando = false;
  String? _erro;

  Future<void> _buscar() async {
    final termo = _buscaController.text;
    if (termo.trim().isEmpty) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultados = await _spotify.buscarMusicas(termo);
      setState(() => _resultados = resultados);
    } catch (e) {
      // Falha na API não pode travar o app, só mostra um aviso (RNF05)
      setState(() => _erro = 'Não foi possível buscar agora, tente de novo');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _adicionar(ResultadoSpotify resultado) async {
    final uid = AuthController().usuarioAtual!.uid;
    final messenger = ScaffoldMessenger.of(context);

    await _musicaController.adicionarMusica(
      playlistId: widget.playlistId,
      spotifyId: resultado.spotifyId,
      nome: resultado.nome,
      artista: resultado.artista,
      capaUrl: resultado.capaUrl,
      uidQuemAdicionou: uid,
    );

    messenger.showSnackBar(
      SnackBar(content: Text('"${resultado.nome}" adicionada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar música')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    decoration: const InputDecoration(hintText: 'Nome da música ou artista'),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
              ],
            ),
          ),
          if (_carregando) const CircularProgressIndicator(),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_erro!, style: const TextStyle(color: Colors.redAccent)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final resultado = _resultados[index];
                return ListTile(
                  leading: resultado.capaUrl.isNotEmpty
                      ? Image.network(resultado.capaUrl, width: 48, height: 48, fit: BoxFit.cover)
                      : const Icon(Icons.music_note),
                  title: Text(resultado.nome),
                  subtitle: Text(resultado.artista),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _adicionar(resultado),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
