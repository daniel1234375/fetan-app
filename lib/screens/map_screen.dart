import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/booking_provider.dart';
import '../theme/fetan_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isMatching = true;

  @override
  void initState() {
    super.initState();
    // Simulate driver matching for 2 seconds for a premium UX feel
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isMatching = false;
        });
      }
    });
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch dialer for $phoneNumber';
      }
    } catch (e) {
      if (mounted) {
        // Fallback simulated call overlay if native call fails
        showDialog(
          context: context,
          builder: (context) => _SimulatedCallDialog(phoneNumber: phoneNumber),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<BookingProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    if (_isMatching) {
      return Scaffold(
        body: Container(
          color: FetanTheme.darkBackground,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(FetanTheme.primaryOrange),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Matching a nearby driver...',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculating fares for ${booking.selectedTruck.name}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Live Map Custom Painter Canvas
          Positioned.fill(
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                return CustomPaint(
                  painter: MapPainter(
                    progress: provider.driverProgress,
                    selectedTruckType: provider.selectedTruck.name,
                  ),
                );
              },
            ),
          ),

          // Glassmorphic status/header overlay
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: FetanTheme.cardColor,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      booking.cancelBooking();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: FetanTheme.cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation, color: FetanTheme.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'En Route to destination',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Driver Information Card & Call Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: FetanTheme.cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ride Progress indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.driverProgress >= 1.0 ? 'Driver Arrived' : 'Driver is coming',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: booking.driverProgress >= 1.0 ? FetanTheme.accentAmber : Colors.white,
                        ),
                      ),
                      Text(
                        'Fare: ${booking.estimatedFare.toInt()} ETB',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: FetanTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: booking.driverProgress,
                      backgroundColor: FetanTheme.inputFieldColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(FetanTheme.primaryOrange),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Driver Details Row
                  Row(
                    children: [
                      // Driver Photo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: FetanTheme.primaryOrange, width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/driver_photo.jpg'),
                            fit: BoxFit.cover,
                            // Fallback if asset photo is missing
                            onError: null,
                          ),
                        ),
                        // Fallback design if image is missing
                        child: ClipOval(
                          child: Container(
                            color: FetanTheme.inputFieldColor,
                            child: const Icon(Icons.person, color: FetanTheme.textSecondary, size: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name & Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.driver.name,
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: FetanTheme.accentAmber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  booking.driver.rating.toString(),
                                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // License Plate & Vehicle Model
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: FetanTheme.inputFieldColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.driver.licensePlate,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.selectedTruck.name,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Call Action Button
                  ElevatedButton.icon(
                    onPressed: () => _makeCall(booking.driver.phoneNumber),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text('Call Driver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Premium emerald green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Map UI Rendering
class MapPainter extends CustomPainter {
  final double progress;
  final String selectedTruckType;

  MapPainter({required this.progress, required this.selectedTruckType});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFF16161B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF23232A)
      ..strokeWidth = 1.0;

    // Draw Map Grids
    double gridSize = 40.0;
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += gridSize) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // Define route path (Bezier curve layout)
    final routePaint = Paint()
      ..color = FetanTheme.primaryOrange.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final activeRoutePaint = Paint()
      ..color = FetanTheme.primaryOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final p1 = Offset(size.width * 0.15, size.height * 0.7); // Driver Start
    final controlPoint1 = Offset(size.width * 0.4, size.height * 0.75);
    final controlPoint2 = Offset(size.width * 0.3, size.height * 0.35);
    final p2 = Offset(size.width * 0.75, size.height * 0.25); // Destination

    final Path path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);

    canvas.drawPath(path, routePaint);

    // Compute driver position coordinate along the path
    final pathMetrics = path.computeMetrics();
    Offset driverCoord = p1;
    double rotationAngle = 0.0;
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final length = metric.length;
      final currentDistance = length * progress;
      
      final tangent = metric.getTangentForOffset(currentDistance);
      if (tangent != null) {
        driverCoord = tangent.position;
        rotationAngle = -tangent.angle; // Direction angle
      }

      // Draw active path traversed
      final activePath = Path();
      activePath.moveTo(p1.dx, p1.dy);
      // Constructing trace using metric segments
      final extractedPath = metric.extractPath(0, currentDistance);
      canvas.drawPath(extractedPath, activeRoutePaint);
    }

    // Draw End Location Marker (User Location)
    final destinationPaint = Paint()
      ..color = FetanTheme.primaryOrange
      ..style = PaintingStyle.fill;
    
    final destinationOuterPaint = Paint()
      ..color = FetanTheme.primaryOrange.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(p2, 20.0, destinationOuterPaint);
    canvas.drawCircle(p2, 10.0, destinationPaint);
    canvas.drawCircle(p2, 4.0, Paint()..color = Colors.white);

    // Draw Start Location Marker (Driver Depot)
    final startPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p1, 8.0, startPaint);
    canvas.drawCircle(p1, 3.0, Paint()..color = Colors.white);

    // Draw Driver Truck Marker
    canvas.save();
    canvas.translate(driverCoord.dx, driverCoord.dy);
    canvas.rotate(-rotationAngle); // Align with path

    // Draw vehicle shape representing a commercial truck
    final truckBasePaint = Paint()..color = Colors.white;
    final truckCargoPaint = Paint()..color = FetanTheme.primaryOrange;

    // Draw Cargo bed
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-15, -8, 20, 16),
          const Radius.circular(3),
        ),
        truckCargoPaint);
    // Draw Cabin
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, -7, 10, 14),
          const Radius.circular(2),
        ),
        truckBasePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.selectedTruckType != selectedTruckType;
  }
}

// Simulated calling Overlay
class _SimulatedCallDialog extends StatefulWidget {
  final String phoneNumber;
  const _SimulatedCallDialog({required this.phoneNumber});

  @override
  State<_SimulatedCallDialog> createState() => _SimulatedCallDialogState();
}

class _SimulatedCallDialogState extends State<_SimulatedCallDialog> {
  int _seconds = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _speakerOn = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int sec) {
    final minutes = (sec ~/ 60).toString().padLeft(2, '0');
    final seconds = (sec % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Avatar
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.emeraldAccent, width: 3),
                color: FetanTheme.inputFieldColor,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              'Calling Driver...',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.phoneNumber,
              style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              _formatTime(_seconds),
              style: GoogleFonts.outfit(
                fontSize: 20,
                color: Colors.emeraldAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Call Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallIconButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'Muted' : 'Mute',
                  isActive: _isMuted,
                  onPressed: () => setState(() => _isMuted = !_isMuted),
                ),
                _CallIconButton(
                  icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                  label: 'Speaker',
                  isActive: _speakerOn,
                  onPressed: () => setState(() => _speakerOn = !_speakerOn),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // End Call Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.call_end, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _CallIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _CallIconButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: isActive ? Colors.white : Colors.white10,
          child: IconButton(
            icon: Icon(icon, color: isActive ? const Color(0xFF0F172A) : Colors.white, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
