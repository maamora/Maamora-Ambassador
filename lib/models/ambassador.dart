import 'league.dart';

// `league` added to this shared model without team sign-off — optional,
// defaults to bronze, so existing call sites don't break.
class Ambassador {
  final String id;
  final String name;
  final String email;
  final String referralCode;
  final int points;
  final League league;

  const Ambassador({
    required this.id,
    required this.name,
    required this.email,
    required this.referralCode,
    this.points = 0,
    this.league = League.bronze,
  });

  Ambassador copyWith({int? points, League? league}) {
    return Ambassador(
      id: id,
      name: name,
      email: email,
      referralCode: referralCode,
      points: points ?? this.points,
      league: league ?? this.league,
    );
  }
}
