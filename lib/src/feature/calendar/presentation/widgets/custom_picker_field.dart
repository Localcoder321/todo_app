import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';

class CustomPickerField extends StatelessWidget {
  final String label;
  final String title;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;

  const CustomPickerField({
    super.key,
    required this.title,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.black)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$label: $value'),
                if (icon != null) Icon(icon, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
