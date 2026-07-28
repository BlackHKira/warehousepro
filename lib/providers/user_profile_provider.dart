import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRole { staff, accountant, admin }

class UserProfileState {
  final String name;
  final String email;
  final AppRole role;
  final String rawRole;

  UserProfileState({
    required this.name,
    required this.email,
    required this.role,
    required this.rawRole,
  });

  bool get isAdmin => role == AppRole.admin;
  bool get isAccountant => role == AppRole.accountant;
}

final userProfileProvider = StateProvider<UserProfileState?>((ref) => null);
