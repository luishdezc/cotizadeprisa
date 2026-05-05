import 'package:cotizadeprisa/app/models/cotizacion.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class HistorialListItem extends StatelessWidget {
  final Cotizacion cot;
  final VoidCallback onTap;

  const HistorialListItem({super.key, required this.cot, required this.onTap});

  Color get _statusColor {
    switch (cot.estatus) {
      case EstadoCotizacion.facturada: return const Color(0xFF3D8F8F);
      case EstadoCotizacion.aceptada:  return Colors.green;
      case EstadoCotizacion.rechazada: return Colors.red;
      case EstadoCotizacion.enviada:   return Colors.blue;
      case EstadoCotizacion.borrador:  return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color  = _statusColor;
    final suffix = cot.id.length >= 3
        ? cot.id.substring(cot.id.length - 3)
        : cot.id;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38, height: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: cot.estatus == EstadoCotizacion.facturada
                    ? Icon(LucideIcons.badgeCheck, size: 18, color: color)
                    : Text(suffix,
                        style: TextStyle(color: color, fontSize: 12,
                            fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cot.titulo.isNotEmpty ? cot.titulo : cot.asunto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cot.clienteNombre.isNotEmpty
                        ? '${cot.clienteNombre}  ·  ${cot.fecha}'
                        : cot.fecha,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF919191), fontFamily: 'Inter'),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(cot.totalFormateado,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.25), width: 0.8),
                  ),
                  child: Text(
                    cot.estatus.displayName,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF919191)),
          ],
        ),
      ),
    );
  }
}
