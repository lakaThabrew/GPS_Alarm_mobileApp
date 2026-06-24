class User {
  final String username;
  final String fullName;
  final String passwordHash; // In a real app, don't store passwords like this!

  User({
    required this.username,
    required this.fullName,
    required this.passwordHash,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'passwordHash': passwordHash,
    };
  }
}
