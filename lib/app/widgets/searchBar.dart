import 'package:flutter/material.dart';


class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.searchController,
    this.hintText = 'Buscar',
  });

  final TextEditingController searchController;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        height: 45,
        decoration: ShapeDecoration(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : const Color.fromARGB(255, 235, 235, 235),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFF919191), size: 18),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF919191),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}
