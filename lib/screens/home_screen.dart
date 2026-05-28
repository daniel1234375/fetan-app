import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/booking_provider.dart';
import '../models/truck_type.dart';
import '../theme/fetan_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _destinationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Synchronize controller text with provider destination
    final provider = Provider.of<BookingProvider>(context, listen: false);
    _destinationController.text = provider.destination;
    _destinationController.addListener(() {
      provider.updateDestination(_destinationController.text);
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  // Predefined popular hubs in Addis Ababa for autocomplete chips
  final List<String> _popularDestinations = const [
    'Bole Airport',
    'Mercato',
    'Piazza',
    'Kaliti Cargo Terminal',
    'Gotera Interchange'
  ];

  void _onOrderNow() {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = Provider.of<BookingProvider>(context, listen: false);
    provider.startBooking();
    Navigator.pushNamed(context, '/map');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FETAN',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.black,
            letterSpacing: 2,
            color: FetanTheme.primaryOrange,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: FetanTheme.textSecondary),
            onPressed: () {
              Provider.of<BookingProvider>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Select Vehicle Type',
                  style: textTheme.titleLarge,
                ),
              ),

              // Vehicle Cards list
              Expanded(
                child: Consumer<BookingProvider>(
                  builder: (context, provider, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: TruckType.list.length,
                      itemBuilder: (context, index) {
                        final truck = TruckType.list[index];
                        final isSelected = provider.selectedTruck.category == truck.category;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            onTap: () => provider.selectTruck(truck),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? FetanTheme.primaryOrange.withOpacity(0.08)
                                    : FetanTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? FetanTheme.primaryOrange
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: FetanTheme.primaryOrange.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                              ),
                              child: Row(
                                children: [
                                  // Truck Icon Representation
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? FetanTheme.primaryOrange
                                          : FetanTheme.inputFieldColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.local_shipping_rounded,
                                      color: isSelected ? Colors.white : FetanTheme.primaryOrange,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  // Details Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          truck.name,
                                          style: textTheme.titleLarge?.copyWith(
                                            color: isSelected ? FetanTheme.primaryOrange : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          truck.description,
                                          style: textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        // Pricing Display
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? FetanTheme.primaryOrange.withOpacity(0.12)
                                                : FetanTheme.inputFieldColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Base starts at ${truck.baseFare.toInt()} ETB + ${truck.ratePerKm.toInt()} ETB/km',
                                            style: GoogleFonts.outfit(
                                              color: isSelected ? FetanTheme.accentAmber : Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Check indicator
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: FetanTheme.primaryOrange,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Destination input and Booking Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                decoration: const BoxDecoration(
                  color: FetanTheme.cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 16,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Suggestions Section
                    Text(
                      'Popular Locations',
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _popularDestinations.map((dest) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(
                                dest,
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                              backgroundColor: FetanTheme.inputFieldColor,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onPressed: () {
                                _destinationController.text = dest;
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Destination Search Input
                    TextFormField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        hintText: 'Where to? (Enter Destination)',
                        prefixIcon: Icon(Icons.location_on_outlined, color: FetanTheme.primaryOrange),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a cargo delivery destination';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Order Now Button
                    ElevatedButton(
                      onPressed: _onOrderNow,
                      child: const Text('Order Now'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
