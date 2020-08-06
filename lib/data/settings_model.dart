// A model that stores sharedPreferences for various bools (switches)
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Settings {
  AUTOSEARCH, ORDERINGBOTTOM, CONFIRMDELETE
}

class SettingsModel extends ChangeNotifier {
  // Maps for easier access
  final Map<Settings, bool> valueMap = {
    Settings.AUTOSEARCH: true,
    Settings.ORDERINGBOTTOM: false,
    Settings.CONFIRMDELETE: true,
  };
  static const Map<Settings, String> nameMap = {
    Settings.AUTOSEARCH: 'auto_search',
    Settings.ORDERINGBOTTOM: 'ordering_bottom',
    Settings.CONFIRMDELETE: 'confirm_delete',
  };

  SettingsModel():super() {
    load();
  }

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nameMap.forEach( (Settings setting, String name)
      => valueMap[setting] = prefs?.getBool(name) ?? valueMap[setting] ?? true
    );

    notifyListeners();
  }

  void setSetting(Settings setting, bool value) async {
    valueMap[setting] = value;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool(nameMap[setting], value);
  }

  bool getSetting(Settings setting) {
    return valueMap[setting];
  }
}