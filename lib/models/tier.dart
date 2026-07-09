enum Tier { bronze, silver, gold, platinum }

extension TierInfo on Tier {
  String get label {
    switch (this) {
      case Tier.bronze:
        return 'Bronze';
      case Tier.silver:
        return 'Silver';
      case Tier.gold:
        return 'Gold';
      case Tier.platinum:
        return 'Platinum';
    }
  }

  int get minPoints {
    switch (this) {
      case Tier.bronze:
        return 0;
      case Tier.silver:
        return 500;
      case Tier.gold:
        return 1500;
      case Tier.platinum:
        return 4000;
    }
  }

  static Tier fromPoints(int points) {
    if (points >= Tier.platinum.minPoints) return Tier.platinum;
    if (points >= Tier.gold.minPoints) return Tier.gold;
    if (points >= Tier.silver.minPoints) return Tier.silver;
    return Tier.bronze;
  }

  Tier? get next {
    switch (this) {
      case Tier.bronze:
        return Tier.silver;
      case Tier.silver:
        return Tier.gold;
      case Tier.gold:
        return Tier.platinum;
      case Tier.platinum:
        return null;
    }
  }
}
