import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String name;
  final TextEditingController variable;
  final bool multiline;
  final bool isNumeric;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final int? maxLength;

  final bool obscureText;
  final bool isEmail;

  const CustomTextField({
    super.key,
    required this.icon,
    required this.name,
    required this.variable,
    this.multiline = false,
    this.isNumeric = false,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.isEmail = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType = widget.keyboardType ??
        (widget.isEmail
            ? TextInputType.emailAddress
            : widget.isNumeric
                ? const TextInputType.numberWithOptions(decimal: true)
                : (widget.multiline
                    ? TextInputType.multiline
                    : TextInputType.text));

    return TextField(
      controller: widget.variable,
      maxLines: widget.multiline ? 4 : 1,
      keyboardType: effectiveKeyboardType,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      obscureText: widget.obscureText ? _obscure : false,
      inputFormatters: widget.isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))]
          : (widget.maxLength != null
              ? [LengthLimitingTextInputFormatter(widget.maxLength)]
              : null),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, size: 20),
        labelText: widget.name,

        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,

        counterText: widget.maxLength != null ? '' : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}