/// Kuruş cinsinden bir tutarı "45,50 TL" gibi okunabilir bir TL string'ine
/// çevirir. Negatif değerler için başına "-" koyar (mutlak değeri gösterir).
String formatKurusAsTl(int kurus) {
  final isNegative = kurus < 0;
  final abs = kurus.abs();
  final lira = abs ~/ 100;
  final kurusPart = (abs % 100).toString().padLeft(2, '0');
  return '${isNegative ? '-' : ''}$lira,$kurusPart TL';
}
