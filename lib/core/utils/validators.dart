String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'El correo electrónico es requerido';
  }

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Ingrese un correo electrónico válido';
  }

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'La contraseña es requerida';
  }

  if (value.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }

  return null;
}

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName es requerido';
  }
  return null;
}

String? validateNumber(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName es requerido';
  }

  final number = double.tryParse(value);
  if (number == null) {
    return '$fieldName debe ser un número válido';
  }

  if (number < 0) {
    return '$fieldName debe ser mayor a 0';
  }

  return null;
}
