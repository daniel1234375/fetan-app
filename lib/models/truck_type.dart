enum TruckCategory {
  isuzu,
  sinoTruck,
  fishCargo,
}

class TruckType {
  final TruckCategory category;
  final String name;
  final double baseFare;
  final double ratePerKm;
  final String description;
  final String assetPath;

  const TruckType({
    required this.category,
    required this.name,
    required this.baseFare,
    required this.ratePerKm,
    required this.description,
    required this.assetPath,
  });

  double calculateFare(double distanceKm) {
    return baseFare + (ratePerKm * distanceKm);
  }

  static List<TruckType> get list => const [
        TruckType(
          category: TruckCategory.isuzu,
          name: 'Isuzu',
          baseFare: 200.0,
          ratePerKm: 20.0,
          description: 'Ideal for medium cargo and urban deliveries.',
          assetPath: 'assets/images/isuzu.png',
        ),
        TruckType(
          category: TruckCategory.sinoTruck,
          name: 'Sino Truck',
          baseFare: 225.0,
          ratePerKm: 25.0,
          description: 'Heavy duty truck for large scale cargo transportation.',
          assetPath: 'assets/images/sino_truck.png',
        ),
        TruckType(
          category: TruckCategory.fishCargo,
          name: 'Fish Cargo Truck',
          baseFare: 200.0,
          ratePerKm: 25.0,
          description: 'Specialized refrigerated cargo for fresh products.',
          assetPath: 'assets/images/fish_cargo.png',
        ),
      ];
}
