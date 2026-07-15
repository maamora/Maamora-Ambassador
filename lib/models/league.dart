// Distinct from Tier (models/tier.dart): Tier is a lifetime points
// threshold, League is a relative cohort ranking with promotion/demotion.
enum League { bronze, silver, gold, platinum }

extension LeagueInfo on League {
  String get label {
    switch (this) {
      case League.bronze:
        return 'Bronze';
      case League.silver:
        return 'Silver';
      case League.gold:
        return 'Gold';
      case League.platinum:
        return 'Platinum';
    }
  }

  // null if already top league (Platinum).
  League? get next {
    switch (this) {
      case League.bronze:
        return League.silver;
      case League.silver:
        return League.gold;
      case League.gold:
        return League.platinum;
      case League.platinum:
        return null;
    }
  }

  // null if already bottom league (Bronze).
  League? get previous {
    switch (this) {
      case League.bronze:
        return null;
      case League.silver:
        return League.bronze;
      case League.gold:
        return League.silver;
      case League.platinum:
        return League.gold;
    }
  }
}
