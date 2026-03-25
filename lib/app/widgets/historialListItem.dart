import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:flutter/material.dart';

class HistorialListItem extends StatelessWidget {
  final Cotizacion cot;
  final VoidCallback onTap;

  const HistorialListItem({required this.cot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5D9D9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      cot.id.substring(cot.id.length - 3),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cot.titulo,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cot.cliente}  ·  ${cot.fecha}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF919191), fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(cot.total, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6DB1B1).withAlpha((0.15 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cot.estatus.displayName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D8F8F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF919191)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}