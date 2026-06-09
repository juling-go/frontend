import 'package:flutter/material.dart';

BoxDecoration card3D({BorderRadius? radius, Border? border}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF272727), Color(0xFF171717)],
    ),
    borderRadius: radius ?? BorderRadius.circular(16),
    border: border,
    boxShadow: [
      const BoxShadow(
        color: Color(0xFF3D3D3D),
        blurRadius: 5,
        offset: Offset(-2, -2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.6),
        blurRadius: 14,
        offset: const Offset(5, 7),
      ),
    ],
  );
}

BoxDecoration headerDecoration() {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF232323), Color(0xFF161616)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.55),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
      const BoxShadow(
        color: Color(0xFF3A3A3A),
        blurRadius: 4,
        offset: Offset(-1, -1),
      ),
    ],
  );
}

Widget raised3DButton({
  required Widget child,
  required Color shadowColor,
  required Color faceColor,
  required BorderRadius borderRadius,
  EdgeInsets? padding,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: shadowColor,
        borderRadius: borderRadius,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    ),
  );
}
