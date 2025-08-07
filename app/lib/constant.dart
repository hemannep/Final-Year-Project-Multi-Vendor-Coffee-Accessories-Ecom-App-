import 'package:flutter/material.dart';

const String ipAddress = "192.168.1.97";

// Colors
const Color primaryColor = Color(0xFFF8F9FA); // Soft White  
const Color secondaryColor =Color(0xFFC5CBD6); // Light Mist Gray  
const Color accentColor = Color(0xFFD4AF37); // Elegant Gold  
const Color textColor = Color(0xFF2C2C2C); // Deep Charcoal  
const Color textSecondaryColor = Color(0xFF6C757D); // Muted Gray  
const Color borderColor = Color(0xFFD4AF37); // Elegant Gold Border 
const Color boxColor = Color.fromARGB(255, 210, 216, 223); // Light Mist Gray Box 



// Gradients
const LinearGradient gradientBackground = LinearGradient(
  colors: [primaryColor, primaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Button Styles
final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: accentColor,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25),
  ),
  textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
);

// Box Decorations
final BoxDecoration cardDecoration = BoxDecoration(
  color: secondaryColor,
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ],
);

final BoxDecoration totalAmountBoxDecoration = BoxDecoration(
  color: primaryColor,
  border: Border.all(color: borderColor, width: 2),
  borderRadius: BorderRadius.circular(25),
);

// Text Styles
const TextStyle headlineTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: textColor,
);

const TextStyle subTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: textSecondaryColor,
);

const TextStyle priceTextStyle = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: accentColor,
);

const TextStyle buttonTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);
