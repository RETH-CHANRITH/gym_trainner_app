import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trainer_details_controller.dart';

class TrainerDetailsView extends GetView<TrainerDetailsController> {
  const TrainerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    const String trainerName = 'Alex Johnson';
    const String specialty = 'Strength & Conditioning';
    const double rating = 4.8;
    const int reviewCount = 32;
    const String description =
        'Alex is a certified trainer with 10+ years of experience helping clients achieve their fitness goals. Passionate about strength, nutrition, and holistic health.';
    const int age = 29;
    const double height = 1.82;

    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1C26),
        title: const Text('Trainer Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF191121),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile picture placeholder
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7A11EA), width: 3),
                    ),
                    child: const Icon(Icons.person, size: 54, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  Text(trainerName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),

                  Text(specialty,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      )),
                  const SizedBox(height: 14),

                  // Rating + Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < rating.floor()
                              ? Icons.star
                              : (i < rating ? Icons.star_half : Icons.star_border),
                          color: const Color(0xFFFFD700),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('($reviewCount reviews)',
                          style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Age + Height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _infoChip('Age: $age'),
                      const SizedBox(width: 14),
                      _infoChip('Height: ${height.toStringAsFixed(2)} m'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Certifications
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF221A2E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Certifications & Experience:',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('- Certified Personal Trainer (CPT)',
                            style: TextStyle(color: Colors.white70)),
                        Text('- 10+ years experience',
                            style: TextStyle(color: Colors.white70)),
                        Text('- Nutrition Specialist',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF221A2E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(description,
                        style: const TextStyle(color: Colors.white, fontSize: 15)),
                  ),

                  const SizedBox(height: 22),

                  // Message Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to chat
                      },
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text('Message Trainer',
                          style: TextStyle(fontSize: 17, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A11EA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Booking UI placeholder
            const _BookingSection(),

            const SizedBox(height: 30),

            // Write Review
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Write Review feature coming soon!')),
                  );
                },
                icon: const Icon(Icons.rate_review, color: Color(0xFF7A11EA)),
                label: const Text('Write a Review',
                    style: TextStyle(color: Color(0xFF7A11EA), fontSize: 16)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7A11EA)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper chip widget
  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF261933),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 15)),
    );
  }
}

// Placeholder for booking section
class _BookingSection extends StatelessWidget {
  const _BookingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1624),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Booking Section Coming Soon',
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
