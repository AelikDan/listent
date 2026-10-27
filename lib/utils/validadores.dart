// Pequenas funções de validação usadas nos formulários
class Validadores {
  static String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o e-mail';
    if (!valor.contains('@')) return 'E-mail inválido';
    return null;
  }

  static String? validarSenha(String? valor) {
    if (valor == null || valor.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  static String? validarObrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }
}
