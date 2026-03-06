class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;

  const UserProfile({required this.id, this.name, this.email, this.photoUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ photoUrl.hashCode;
}
