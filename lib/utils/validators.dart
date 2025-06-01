class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu e-mail';
    }
    
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, informe um e-mail válido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe sua senha';
    }
    
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe $fieldName';
    }
    
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu CPF';
    }
    
    final cpf = value.replaceAll(RegExp(r'\D'), '');
    
    if (cpf.length != 11) {
      return 'CPF inválido';
    }
    
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return 'CPF inválido';
    }
    
    // Implementar validação completa de CPF se necessário
    
    return null;
  }
}
