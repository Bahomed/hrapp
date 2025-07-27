import 'package:flutter/material.dart';

class SaudiRiyalDisplay extends StatelessWidget {
  final double? amount;
  final TextStyle style;
  final int decimalPlaces;
  final String? customText;

  const SaudiRiyalDisplay({
    super.key,
    this.amount,
    this.style = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    this.decimalPlaces = 2,
    this.customText,
  }) : assert(amount != null || customText != null, 'Either amount or customText must be provided');

  @override
  Widget build(BuildContext context) {
    if (customText != null) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: customText!,
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
    
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: amount!.toStringAsFixed(decimalPlaces),
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