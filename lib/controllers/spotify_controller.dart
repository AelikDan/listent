import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/spotify_config.dart';

// Resultado de uma busca, antes de virar uma música salva na playlist
class ResultadoSpotify {
  final String spotifyId;
  final String nome;
  final String artista;
  final String capaUrl;

  ResultadoSpotify({
    required this.spotifyId,
    required this.nome,
    required this.artista,
    required this.capaUrl,
  });
}

// Aqui ficam as chamadas pra API do Spotify, usadas na busca de músicas (RF05)
//
// o ideal é fazer essa autenticação passando por um servidor
// (ex: Cloud Function), pra não expor o client secret dentro do app. Aqui a chamada é feita direto do app só pra
// simplificar - antes de publicar de verdade, mova a função _pegarToken pra
// um backend.
class SpotifyController {
  String? _token;
  DateTime? _tokenExpiraEm;

  // Pega (ou renova) o token de acesso usando o fluxo Client Credentials
  Future<String> _pegarToken() async {
    final tokenAindaValido = _token != null &&
        _tokenExpiraEm != null &&
        DateTime.now().isBefore(_tokenExpiraEm!);

    if (tokenAindaValido) return _token!;

    final credenciais = base64Encode(
      utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'),
    );

    final resposta = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credenciais',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (resposta.statusCode != 200) {
      throw Exception('Não foi possível autenticar com o Spotify');
    }

    final dados = jsonDecode(resposta.body);
    _token = dados['access_token'];
    _tokenExpiraEm =
        DateTime.now().add(Duration(seconds: dados['expires_in'] - 30));

    return _token!;
  }

  // Busca músicas pelo termo digitado (RF05)
  Future<List<ResultadoSpotify>> buscarMusicas(String termo) async {
    if (termo.trim().isEmpty) return [];

    final token = await _pegarToken();

    final resposta = await http.get(
      Uri.parse(
        'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(termo)}&type=track&limit=15',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resposta.statusCode != 200) {
      // Falha na busca não pode travar o app, só avisa o usuário (RNF05)
      throw Exception('Erro ao buscar músicas, tente novamente');
    }

    final dados = jsonDecode(resposta.body);
    final faixas = dados['tracks']['items'] as List;

    return faixas.map((faixa) {
      final capas = faixa['album']['images'] as List;
      return ResultadoSpotify(
        spotifyId: faixa['id'],
        nome: faixa['name'],
        artista: (faixa['artists'] as List).map((a) => a['name']).join(', '),
        capaUrl: capas.isNotEmpty ? capas.first['url'] : '',
      );
    }).toList();
  }
}
