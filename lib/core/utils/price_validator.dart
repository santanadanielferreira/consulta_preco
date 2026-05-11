class PriceValidator {
  static void ensureValid(double preco) {
    if (preco <= 0) {
      throw const FormatException('Preco deve ser maior que zero.');
    }
  }
}
