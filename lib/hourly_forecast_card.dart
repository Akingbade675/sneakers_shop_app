import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({
    super.key,
    required this.icon,
    required this.time,
    required this.humidity,
  });

  final IconData icon;
  final String time;
  final String humidity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(humidity),
            ],
          ),
        ),
      ),
    );
  }
}
