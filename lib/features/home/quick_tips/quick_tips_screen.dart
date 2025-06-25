import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class QuickTipsScreen extends StatelessWidget {
  const QuickTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Quick Tips & Tricks',
          style: TextStyle(
            color: blacktext,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blacktext),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TipCard(
            title: 'Packing Smart',
            tips: [
              'Roll your clothes instead of folding to save space',
              'Use packing cubes to organize your belongings',
              'Pack versatile clothing items that can be mixed and matched',
              'Keep important documents in a waterproof pouch',
            ],
            icon: Icons.luggage,
          ),
          SizedBox(height: 16),
          _TipCard(
            title: 'Airport Hacks',
            tips: [
              'Download offline maps before your trip',
              'Take photos of important documents as backup',
              'Use airport lounges for comfortable waiting',
              'Keep a power bank for your devices',
            ],
            icon: Icons.flight,
          ),
          SizedBox(height: 16),
          _TipCard(
            title: 'Money Saving Tips',
            tips: [
              'Book flights during off-peak seasons',
              'Use local transportation instead of taxis',
              'Eat where locals eat for authentic and cheaper food',
              'Look for free walking tours in cities',
            ],
            icon: Icons.savings,
          ),
          SizedBox(height: 16),
          _TipCard(
            title: 'Safety Tips',
            tips: [
              'Keep a copy of your passport in a safe place',
              'Share your itinerary with family or friends',
              'Use a money belt for important documents',
              'Research local emergency numbers before traveling',
            ],
            icon: Icons.security,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final List<String> tips;
  final IconData icon;

  const _TipCard({required this.title, required this.tips, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blacktext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 14, color: blacktext),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
