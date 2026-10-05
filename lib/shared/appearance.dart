import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppPalette { standard, monochrome }

enum CalendarPeriod { week, twoWeeks, month }

abstract interface class PreferenceStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class DevicePreferenceStore implements PreferenceStore {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}

class AppearanceController extends ChangeNotifier {
  AppearanceController(this.store);

  final PreferenceStore store;
  AppPalette palette = AppPalette.standard;
  Brightness brightness = Brightness.light;
  CalendarPeriod period = CalendarPeriod.week;
  Future<void> _pendingWrite = Future<void>.value();

  Future<void> load() async {
    try {
      final values = await Future.wait([
        store.read('appearance.palette'),
        store.read('appearance.brightness'),
        store.read('calendar.period'),
      ]);
      palette = AppPalette.values.firstWhere(
        (value) => value.name == values[0],
        orElse: () => AppPalette.standard,
      );
      brightness = values[1] == 'dark' ? Brightness.dark : Brightness.light;
      period = CalendarPeriod.values.firstWhere(
        (value) => value.name == values[2],
        orElse: () => CalendarPeriod.week,
      );
    } catch (_) {
      // Preferences are optional; the first-run defaults remain usable.
    }
    notifyListeners();
  }

  Future<bool> setPalette(AppPalette value) {
    palette = value;
    notifyListeners();
    return _save('appearance.palette', value.name);
  }

  Future<bool> setBrightness(Brightness value) {
    brightness = value;
    notifyListeners();
    return _save('appearance.brightness', value.name);
  }

  Future<bool> setPeriod(CalendarPeriod value) {
    period = value;
    notifyListeners();
    return _save('calendar.period', value.name);
  }

  Future<bool> _save(String key, String value) async {
    var saved = true;
    // Serialize writes so rapid changes cannot restore an older preference.
    final operation = _pendingWrite.then((_) async {
      try {
        await store.write(key, value);
      } catch (_) {
        saved = false;
      }
    });
    _pendingWrite = operation;
    await operation;
    return saved;
  }
}

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppearanceController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()!.notifier!;
}

Future<void> reportPreferenceSave(
  BuildContext context,
  Future<bool> operation,
) async {
  final saved = await operation;
  if (!saved && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A escolha foi aplicada, mas não foi possível salvá-la neste aparelho.',
        ),
      ),
    );
  }
}
