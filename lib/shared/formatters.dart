import 'package:meu_app/data/enums/regularity.dart';

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String regularityLabel(Regularity regularity) {
  switch (regularity) {
    case Regularity.single:
      return 'Uma vez';
    case Regularity.daily:
      return 'Diária';
    case Regularity.weekly:
      return 'Semanal';
    case Regularity.monthly:
      return 'Mensal';
    case Regularity.annual:
      return 'Anual';
  }
}
