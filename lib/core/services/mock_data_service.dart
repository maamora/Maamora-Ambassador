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

  static final List<Ambassador> mockLeaderboard = [
    Ambassador(id: 'a1', name: 'Yasmine B.', email: '', referralCode: 'YASB01', points: 5200),
    Ambassador(id: 'a2', name: 'Omar T.', email: '', referralCode: 'OMRT02', points: 3100),
    mockCurrentAmbassador,
    Ambassador(id: 'a4', name: 'Amine L.', email: '', referralCode: 'AMNL04', points: 900),
    Ambassador(id: 'a5', name: 'Nadia F.', email: '', referralCode: 'NADF05', points: 320),
  ]..sort((a, b) => b.points.compareTo(a.points));
}
