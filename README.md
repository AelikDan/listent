# 1. GrooveShare – Discoteca Pessoal: Documentação Técnica

Oct 26, 2026 · @Daniel

## 2. Visão Geral

**Projeto:** Discoteca Pessoal ("Discotheque") para o app GrooveShare.

**Missão:** construir o recurso de **playlists colaborativas**, permitindo que um usuário crie uma playlist, adicione músicas e convide amigos para também adicionarem músicas à mesma lista.

**Desafio central:** modelar corretamente a relação **muitos-para-muitos** entre usuários e playlists (donos e colaboradores) e garantir, via regras de segurança do Firestore, que apenas pessoas autorizadas editem cada playlist.

## 3. Requisitos Funcionais (RF)

| Código | Requisito |
| --- | --- |
| RF01 | Usuário pode criar uma conta e autenticar-se (e-mail/senha). |
| RF02 | Usuário autenticado pode criar uma nova playlist. |
| RF03 | Dono da playlist pode convidar outro usuário como colaborador, informando seu e-mail. |
| RF04 | Dono da playlist pode remover um colaborador. |
| RF05 | Dono e colaboradores podem buscar músicas/álbuns via API externa (Spotify ou Last.fm). |
| RF06 | Dono e colaboradores podem adicionar músicas à playlist. |
| RF07 | Dono e colaboradores podem remover músicas da playlist. |
| RF08 | Usuário pode visualizar a lista de playlists das quais é dono ou colaborador. |
| RF09 | Usuário pode visualizar os detalhes de uma playlist (faixas, colaboradores). |
| RF10 | Apenas o dono pode excluir a playlist inteira. |

## 4. Requisitos Não Funcionais (RNF)

| Código | Requisito |
| --- | --- |
| RNF01 | Segurança: regras do Firestore devem impedir leitura/escrita por usuários não autorizados, mesmo via chamadas diretas à API. |
| RNF02 | Consistência: alterações em colaboradores ou faixas devem refletir em tempo real para todos os membros da playlist (listeners do Firestore). |
| RNF03 | Escalabilidade: a estrutura de dados deve suportar playlists com muitos colaboradores e faixas sem degradar performance de leitura. |
| RNF04 | Usabilidade: convite de colaborador deve ser simples (busca por e-mail) e dar feedback claro de sucesso/erro. |
| RNF05 | Disponibilidade: dependência da API externa (Spotify/Last.fm) não pode travar a edição da playlist — falhas de busca devem ser tratadas com mensagens de erro, sem quebrar o app. |
| RNF06 | Portabilidade: app deve rodar em pelo menos uma plataforma mobile (Android ou iOS) via Flutter. |
| RNF07 | Auditabilidade: deve ser possível identificar quem adicionou/removeu cada faixa (campo addedBy). |

## 5. Escopo do Projeto

- **API externa:** integração com a API do Spotify (ou Last.fm) para busca de álbuns e faixas, usada no fluxo de adicionar música à playlist.
- **Autenticação:** sistema de login/registro via Firebase Authentication (e-mail/senha).
- **Backend/dados:** Firestore como banco de dados, com estrutura pensada para a relação muitos-para-muitos entre usuários e playlists.
- **Colaboração:** convite de colaboradores por e-mail, com controle de quem pode editar o quê.
- **Fora do escopo (v1):** reprodução de áudio dentro do app, chat entre colaboradores, notificações push, playlists públicas/descoberta social.

## 6. Modelagem de Dados

Cada playlist tem um dono e pode ter vários colaboradores. Ao mesmo tempo, um colaborador pode participar de várias playlists diferentes — é essa combinação que forma a relação muitos-para-muitos entre usuários e playlists.

As músicas adicionadas ficam sempre vinculadas à playlist em que foram inseridas, e guardam também quem foi a pessoa que as adicionou, para manter um histórico de quem contribuiu com o quê.

## 7. Diagrama de Dados (Entidades e Relacionamentos)

&#91;embedded content: modelo de dados · relação muitos-para-muitos\]

Cada playlist sabe quem é o seu dono e guarda a lista de colaboradores autorizados; as músicas adicionadas ficam sempre amarradas à playlist a que pertencem.

## 8. Fluxo de Colaboração

&#91;embedded content: fluxo de colaboração · convite e edição conjunta\]

1. O dono cria a playlist.
2. O dono convida um amigo digitando o e-mail dele; o sistema encontra esse usuário e o adiciona como colaborador.
3. A partir daí, tanto o dono quanto qualquer colaborador pode adicionar ou remover músicas.
4. As mudanças aparecem na hora para todos que estão olhando a playlist.

## 9. Integração com API de Música

A busca de álbuns/faixas usa a **Web API do Spotify** (recomendada por ter catálogo rico e endpoint de busca simples) ou, como alternativa, a **Last.fm API**.

- A busca pode acontecer sem o usuário precisar logar no Spotify, usando apenas as credenciais do próprio aplicativo.
- Ao escolher uma música na busca, guardamos o nome, o artista, a capa do álbum e uma referência para encontrá-la de novo no catálogo.
- A chamada para a API deve passar por um servidor nosso (nunca direto do app), para não expor as credenciais.
- Resultados de busca podem ficar guardados temporariamente enquanto o usuário digita, evitando buscas repetidas.

## 10. Autenticação

- **Provedor:** Firebase Authentication, método e-mail/senha (expansível para login social depois).
- **Cadastro:** nome, e-mail e senha → cria também um documento em `users/{uid}` com `email` e `displayName`, necessário para o fluxo de convite por e-mail funcionar (buscar o UID a partir do e-mail digitado).
- **Login:** autenticação padrão do Firebase, token de sessão gerenciado pelo SDK.
- **Convite por e-mail:** como o Firestore não permite buscar por e-mail diretamente sem um índice dedicado, mantém-se o e-mail em minúsculas no documento `users` com uma query `where('email', '==', emailDigitado.toLowerCase())` para resolver o UID do convidado antes de adicioná-lo a `collaborators`.

## 11. Critérios de Avaliação Específicos

| Critério | O que é avaliado |
| --- | --- |
| Regras de Segurança | Principal ponto de avaliação. Regras complexas que garantem corretamente quem pode convidar/remover colaboradores e quem pode editar as faixas. |
| Modelagem de Dados | Estrutura eficiente e escalável para a relação muitos-para-muitos entre usuários e playlists. |
| Funcionalidade | Fluxo completo funcionando: criar playlist, convidar colaborador, adicionar/remover faixas, refletindo em tempo real. |
