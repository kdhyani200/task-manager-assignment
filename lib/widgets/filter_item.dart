import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_provider.dart';

class FilterItem extends ConsumerWidget {
  // Changed to ConsumerWidget
  const FilterItem({super.key, required this.itemName, required this.filter});

  final String itemName;
  final TaskFilter filter; // Pass the enum value here

  // Update build method slightly for a smoother feel:
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(taskFilterProvider);
    final isSelected = activeFilter == filter;

    return GestureDetector(
      onTap: () {
        ref.read(taskFilterProvider.notifier).state = filter;
      },
      child: AnimatedContainer(
        // Use AnimatedContainer instead of Container
        duration: const Duration(milliseconds: 200),
        height: MediaQuery.of(context).size.height * 0.04,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          border: Border.all(
            width: 2,
            color: isSelected
                ? Colors.black
                : Colors.black26, // Dim the border if not selected
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              itemName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
