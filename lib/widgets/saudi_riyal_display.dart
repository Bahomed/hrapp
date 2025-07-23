import 'package:flutter/material.dart';

class SaudiRiyalDisplay extends StatelessWidget {
  final double amount;
  final TextStyle style;
  final int decimalPlaces;

  const SaudiRiyalDisplay({
    super.key,
    required this.amount,
    this.style = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    this.decimalPlaces = 2,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: amount.toStringAsFixed(decimalPlaces),
            style: style,
          ),
          TextSpan(
            text: ' \uE900', // Saudi Riyal symbol
            style: TextStyle(
              fontFamily: 'saudi_riyal',
              fontSize: style.fontSize,
              fontWeight: style.fontWeight,
              color: style.color,
            ),
          ),
        ],
      ),
    );
  }
}