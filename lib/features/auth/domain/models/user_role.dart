/// App roles stored on each user document in Firestore (`users/{uid}.role`).
enum UserRole {
  member,
  admin;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.member,
    );
  }
}
