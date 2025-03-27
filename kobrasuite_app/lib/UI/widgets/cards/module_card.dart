import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModuleCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ModuleCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levelImages = {
      0: 'assets/images/tent.svg',
      1: 'assets/images/house1.svg',
      2: 'assets/images/house2.svg'
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          levelImages[data['level']] ?? levelImages[0]!,
          width: 48,
          height: 48,
        ),
        title: Text(
          data['name'],
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Population: ${data['population']}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
            Text(
              'Streak: ${data['streak']}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
            Text(
              'XP: ${data['experience']}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
            Text(
              'Currency: ${data['currency']}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}