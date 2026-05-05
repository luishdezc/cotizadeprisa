import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientSelectionButton extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final bool isSelected;
  final String? rfc;

  const ClientSelectionButton({
    super.key,
    required this.name,
    this.onTap,
    this.isSelected = false,
    this.rfc,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF6DB1B1)
        : Theme.of(context).hintColor.withOpacity(0.4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? const Color(0xFF6DB1B1).withOpacity(0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? LucideIcons.userCheck : LucideIcons.userPlus,
              size: 20,
              color: isSelected
                  ? const Color(0xFF6DB1B1)
                  : Theme.of(context).hintColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected ? 'Cliente seleccionado' : 'Seleccionar cliente',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF6DB1B1)
                          : Theme.of(context).hintColor.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF3D8F8F)
                          : Theme.of(context).hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isSelected && rfc != null)
                    Text(
                      'RFC: $rfc',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF919191)),
                    ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: isSelected
                  ? const Color(0xFF6DB1B1)
                  : Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
