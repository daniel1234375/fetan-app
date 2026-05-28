class Driver {
  final String name;
  final String photoUrl;
  final String phoneNumber;
  final String licensePlate;
  final double rating;

  const Driver({
    required this.name,
    required this.photoUrl,
    required this.phoneNumber,
    required this.licensePlate,
    required this.rating,
  });

  static Driver get mockDriver => const Driver(
        name: 'Dawit Abebe',
        photoUrl: 'assets/images/driver_photo.jpg',
        phoneNumber: '+251911234567',
        licensePlate: 'AA-3-B78921',
        rating: 4.8,
      );
}
