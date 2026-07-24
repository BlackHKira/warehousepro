class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? fcmToken;
  final DateTime? lastActive;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'Thủ kho',
    this.status = 'Hoạt động',
    this.fcmToken,
    this.lastActive,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) => UserProfile(
    id: id,
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    role: map['role'] as String? ?? 'Thủ kho',
    status: map['status'] as String? ?? 'Hoạt động',
    fcmToken: map['fcmToken'] as String?,
    lastActive: map['lastActive'] != null ? (map['lastActive'] as dynamic).toDate() as DateTime? : null,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'status': status,
    'fcmToken': fcmToken,
    'lastActive': lastActive,
  };

  UserProfile copyWith({
    String? name,
    String? phone,
    String? role,
    String? status,
    String? fcmToken,
    DateTime? lastActive,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    email: email,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    status: status ?? this.status,
    fcmToken: fcmToken ?? this.fcmToken,
    lastActive: lastActive ?? this.lastActive,
  );
}
