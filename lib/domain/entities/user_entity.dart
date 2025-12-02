import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrador';
  bool get isSeller =>
      role.toLowerCase() == 'seller' || role.toLowerCase() == 'vendedor';

  @override
  List<Object?> get props => [id, email, name, role, createdAt];
}
