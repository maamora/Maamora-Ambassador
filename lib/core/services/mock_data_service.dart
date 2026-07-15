import '../../models/models.dart';

/// SOURCE UNIQUE de données factices pour la phase "écrans statiques".
///
/// Règle d'équipe : ne dupliquez pas ces données dans vos propres écrans.
/// Si le dashboard, le leaderboard et le share screen utilisent tous le
/// même ambassadeur (mockCurrentAmbassador), tout le monde voit des
/// chiffres cohérents pendant les démos.
///
/// Quand l'intégration backend commence (semaine 4+), ce fichier sera
/// remplacé par de vrais appels API, mais la forme des données
/// (les modèles dans lib/models/) ne changera pas.
class MockDataService {
  MockDataService._();

  static final Ambassador mockCurrentAmbassador = Ambassador(
    id: 'me',
    name: 'Yassine Alami',
    email: 'yassine@example.com',
    referralCode: 'YASA042',
    points: 1250,
    league: League.gold,
  );

  static final List<Product> mockCatalog = const [
    Product(
      id: 'p1',
      name: "Huile d'argan bio 100ml",
      price: 180,
      imageUrl: '',
      pointsPerSale: 20,
    ),
    Product(
      id: 'p2',
      name: 'Coffret Maamora Découverte',
      price: 350,
      imageUrl: '',
      pointsPerSale: 40,
    ),
    Product(
      id: 'p3',
      name: 'Savon noir traditionnel',
      price: 60,
      imageUrl: '',
      pointsPerSale: 8,
    ),
    Product(
      id: 'p4',
      name: 'Ghassoul en poudre 250g',
      price: 90,
      imageUrl: '',
      pointsPerSale: 12,
    ),
  ];

  static final List<ReferralOrder> mockOrders = [
    ReferralOrder(
      id: 'o1',
      productId: 'p1',
      productName: "Huile d'argan bio 100ml",
      amount: 180,
      pointsEarned: 20,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.confirmed,
    ),
    ReferralOrder(
      id: 'o2',
      productId: 'p2',
      productName: 'Coffret Maamora Découverte',
      amount: 350,
      pointsEarned: 40,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.confirmed,
    ),
  ];

  // Sorted by points; league is not monotonic across the full list (a
  // Silver member can out-point a Gold member) — intentional, not a bug.
  static final List<Ambassador> mockLeaderboard =
      [
        // --- Platinum League (7) ---
        Ambassador(id: 'p1', name: 'Sofia Benjelloun', email: '', referralCode: 'SOFB01', points: 5200, league: League.platinum),
        Ambassador(id: 'p2', name: 'Karim Ziani', email: '', referralCode: 'KARZ02', points: 4950, league: League.platinum),
        Ambassador(id: 'p3', name: 'Leila Amrani', email: '', referralCode: 'LEIA03', points: 4700, league: League.platinum),
        Ambassador(id: 'p4', name: 'Nabil Chakib', email: '', referralCode: 'NABC04', points: 4500, league: League.platinum),
        Ambassador(id: 'p5', name: 'Widad Belhaj', email: '', referralCode: 'WIDB05', points: 4300, league: League.platinum),
        Ambassador(id: 'p6', name: 'Othmane Rifai', email: '', referralCode: 'OTHR06', points: 4100, league: League.platinum),
        Ambassador(id: 'p7', name: 'Houda Serghini', email: '', referralCode: 'HOUS07', points: 3900, league: League.platinum),

        // --- Gold League (13, ambassadeur courant inclus) ---
        Ambassador(id: 'g1', name: 'Marcus V.', email: '', referralCode: 'MARV01', points: 2200, league: League.gold),
        Ambassador(id: 'g2', name: 'Sarah J.', email: '', referralCode: 'SARJ02', points: 2050, league: League.gold),
        Ambassador(id: 'g3', name: 'Elena R.', email: '', referralCode: 'ELER03', points: 1950, league: League.gold),
        Ambassador(id: 'g4', name: 'Alex Chen', email: '', referralCode: 'ALEC04', points: 1800, league: League.gold),
        Ambassador(id: 'g5', name: 'Mia Thompson', email: '', referralCode: 'MIAT05', points: 1700, league: League.gold),
        Ambassador(id: 'g6', name: "Liam O'Neill", email: '', referralCode: 'LIAO06', points: 1550, league: League.gold),
        mockCurrentAmbassador, // rank 7/13 in Gold
        Ambassador(id: 'g8', name: 'Priya Kapoor', email: '', referralCode: 'PRIK08', points: 1100, league: League.gold),
        Ambassador(id: 'g9', name: 'Karim Haddad', email: '', referralCode: 'KARH09', points: 950, league: League.gold),
        Ambassador(id: 'g10', name: 'Fatima Zahra', email: '', referralCode: 'FATZ10', points: 800, league: League.gold),
        Ambassador(id: 'g11', name: 'Diego Alvarez', email: '', referralCode: 'DIEA11', points: 650, league: League.gold),
        Ambassador(id: 'g12', name: 'Nora Idrissi', email: '', referralCode: 'NORI12', points: 500, league: League.gold),
        Ambassador(id: 'g13', name: 'Tom Becker', email: '', referralCode: 'TOMB13', points: 350, league: League.gold),

        // --- Silver League (9) ---
        Ambassador(id: 's1', name: 'Yasmine B.', email: '', referralCode: 'YASB01', points: 1900, league: League.silver),
        Ambassador(id: 's2', name: 'Omar T.', email: '', referralCode: 'OMRT02', points: 1750, league: League.silver),
        Ambassador(id: 's3', name: 'Hafsa Idrissi', email: '', referralCode: 'HAFI03', points: 1600, league: League.silver),
        Ambassador(id: 's4', name: 'Amine L.', email: '', referralCode: 'AMNL04', points: 1450, league: League.silver),
        Ambassador(id: 's5', name: 'Nadia F.', email: '', referralCode: 'NADF05', points: 1300, league: League.silver),
        Ambassador(id: 's6', name: 'Youssef Amrani', email: '', referralCode: 'YOUA06', points: 1150, league: League.silver),
        Ambassador(id: 's7', name: 'Salma Bennis', email: '', referralCode: 'SALB07', points: 1000, league: League.silver),
        Ambassador(id: 's8', name: 'Rachid Alaoui', email: '', referralCode: 'RACA08', points: 850, league: League.silver),
        Ambassador(id: 's9', name: 'Imane Fassi', email: '', referralCode: 'IMAF09', points: 700, league: League.silver),

        // --- Bronze League (7) ---
        Ambassador(id: 'b1', name: 'Noor Habibi', email: '', referralCode: 'NOOH01', points: 900, league: League.bronze),
        Ambassador(id: 'b2', name: 'Zakaria El Idrissi', email: '', referralCode: 'ZAKE02', points: 820, league: League.bronze),
        Ambassador(id: 'b3', name: 'Lina Chraibi', email: '', referralCode: 'LINC03', points: 750, league: League.bronze),
        Ambassador(id: 'b4', name: 'Younes Berrada', email: '', referralCode: 'YOUB04', points: 680, league: League.bronze),
        Ambassador(id: 'b5', name: 'Salima Ouazzani', email: '', referralCode: 'SALO05', points: 600, league: League.bronze),
        Ambassador(id: 'b6', name: 'Bilal Sefrioui', email: '', referralCode: 'BILS06', points: 520, league: League.bronze),
        Ambassador(id: 'b7', name: 'Meryem Lahlou', email: '', referralCode: 'MERL07', points: 450, league: League.bronze),
      ]..sort((a, b) => b.points.compareTo(a.points));
}
