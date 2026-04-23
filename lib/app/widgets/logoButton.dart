import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoButton extends StatefulWidget {
  const LogoButton({super.key});

  @override
  State<LogoButton> createState() => _LogoButtonState();
}

class _LogoButtonState extends State<LogoButton> {
  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por implementar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.7, color: Theme.of(context).shadowColor),
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(12),
        onPressed: _pickImage,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(60, 60),
        child: Text(
          "Agregar Logo",
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
