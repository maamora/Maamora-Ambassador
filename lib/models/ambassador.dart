class Ambassador {
  final String id;
  final String name;
  final String email;
  final String referralCode;
  final int points;

  const Ambassador({
    required this.id,
    required this.name,
    required this.email,
    required this.referralCode,
    this.points = 0,
  });

  Ambassador copyWith({int? points}) {
    return Ambassador(
      id: id,
      name: name,
      email: email,
      referralCode: referralCode,
      points: points ?? this.points,
    );
  }
}
