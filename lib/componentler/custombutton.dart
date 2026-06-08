import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final EdgeInsets? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading || isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
