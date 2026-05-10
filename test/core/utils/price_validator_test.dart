import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/core/utils/price_validator.dart';

void main() {
  group('PriceValidator', () {
    test('deve aceitar preco valido positivo', () {
      expect(
        () => PriceValidator.ensureValid(10.50),
        returnsNormally,
      );
    });

    test('deve rejeitar preco zero', () {
      expect(
        () => PriceValidator.ensureValid(0),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve rejeitar preco negativo', () {
      expect(
        () => PriceValidator.ensureValid(-5.0),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
