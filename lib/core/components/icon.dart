import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class CustomIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final String? semanticLabel;
  final VoidCallback? onTap;
  const CustomIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.iconColor = AppColors.darkBlue,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: FaIcon(
          icon,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}
