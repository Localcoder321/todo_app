import 'package:flutter/material.dart';
import 'package:todo_app/src/core/constants/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String placeholder;
  final int maxLines;
  final Widget? suffixIcon;
  final bool required;

  const CustomInputField({
    super.key,
    required this.title,
    required this.controller,
    required this.placeholder,
    this.maxLines = 1,
    this.suffixIcon,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.black)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (v) =>
                required && (v == null || v.trim().isEmpty) ? 'Required' : null,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
