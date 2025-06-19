import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border ?? const OutlineInputBorder(),
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        disabledBorder: disabledBorder,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
      ),
    );
  }
}
