import 'dart:io';
import 'package:cotizadeprisa/app/providers/app_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class LogoButton extends StatelessWidget {
  const LogoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final logoPath = provider.logoPath;
    final tienelogo = logoPath != null && File(logoPath).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logo de la empresa',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final ok = await provider.seleccionarLogo();
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo seleccionar la imagen'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(
                width: tienelogo ? 2 : 1.5,
                color: tienelogo
                    ? const Color(0xFF6DB1B1)
                    : Theme.of(context).shadowColor,
              ),
              borderRadius: BorderRadius.circular(16),
              color: tienelogo
                  ? const Color(0xFF6DB1B1).withOpacity(0.06)
                  : Colors.transparent,
            ),
            child: tienelogo
                ? Row(
                    children: [
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(logoPath),
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Logo cargado',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D8F8F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Toca para cambiar',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        onPressed: () async {
                          final confirmar = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text('¿Eliminar logo?'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirmar == true && context.mounted) {
                            await provider.eliminarLogo();
                          }
                        },
                        child: const Icon(LucideIcons.trash2,
                            size: 18, color: Colors.red),
                      ),
                    ],
                  )
                : Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.imagePlus,
                            size: 20, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Text(
                          'Agregar Logo',
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
