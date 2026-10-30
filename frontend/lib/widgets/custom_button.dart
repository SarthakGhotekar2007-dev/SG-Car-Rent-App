import 'package:flutter/material.dart';
import '../const/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.cardColor : AppColors.primaryColor,
          foregroundColor: isSecondary ? AppColors.primaryText : Colors.white,
          disabledBackgroundColor: isSecondary
              ? AppColors.cardColor.withValues(alpha: 0.5)
              : AppColors.primaryColor.withValues(alpha: 0.5),
          side: isSecondary
              ? BorderSide(color: AppColors.borderColor, width: 1.2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isSecondary ? 0 : 3,
          shadowColor: isSecondary
              ? Colors.transparent
              : AppColors.primaryColor.withValues(alpha: 0.4),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: isSecondary ? AppColors.primaryText : Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: isSecondary ? AppColors.primaryText : Colors.white,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: isSecondary ? AppColors.primaryText : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
