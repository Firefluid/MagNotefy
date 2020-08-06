import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeSetting { DARK, LIGHT, SYSTEM }

class ThemeModel extends ChangeNotifier with WidgetsBindingObserver {
  ThemeSetting _themeSetting = ThemeSetting.SYSTEM;
  Brightness _brightnessValue = Brightness.light;

  ThemeModel() : super() {
    WidgetsBinding.instance.addObserver(this);
    load();
    setBrightness(WidgetsBinding.instance.window.platformBrightness);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness =
      WidgetsBinding.instance.window.platformBrightness;
    setBrightness(brightness);
  }

  void load() async {
    print('loading Theme Preferences...');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String setting = prefs.getString('theme');
    if (setting != null) {
      if (setting == 'light')
        setThemeSetting(ThemeSetting.LIGHT);
      else if (setting == 'dark')
        setThemeSetting(ThemeSetting.DARK);
    } else {
      prefs.setString('theme', 'system');
    }
  }

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (_themeSetting) {
      case ThemeSetting.LIGHT:
        prefs.setString('theme', 'light');
        break;
      case ThemeSetting.DARK:
        prefs.setString('theme', 'dark');
        break;
      case ThemeSetting.SYSTEM:
        prefs.setString('theme', 'system');
        break;
    }
  }

  void setBrightness(Brightness brightness) {
    if (brightness != _brightnessValue) {
      _brightnessValue = brightness;
      notifyListeners();
    }
  }

  void setThemeSetting(ThemeSetting themeSetting) {
    if (themeSetting != _themeSetting) {
      _themeSetting = themeSetting;
      notifyListeners();
    }
  }

  ThemeSetting get themeSetting => _themeSetting;

  PaperColors get paperColors {
    if (_themeSetting == ThemeSetting.LIGHT)
      return lightColors;
    else if (_themeSetting == ThemeSetting.DARK)
      return darkColors;
    else {
      if (_brightnessValue == Brightness.dark) return darkColors;
      return lightColors;
    }
  }

  ThemeData get themeData {
    if (_themeSetting == ThemeSetting.LIGHT)
      return lightTheme;
    else if (_themeSetting == ThemeSetting.DARK)
      return darkTheme;
    else {
      if (_brightnessValue == Brightness.dark) return darkTheme;
      return lightTheme;
    }
  }
}

class PaperColors {
  final Color background;
  final Color fill;
  final Color text;
  final Color textSecondary;
  final Color accent;
  final Color accentSecondary;

  const PaperColors(
      {this.background,
      this.fill,
      this.text,
      this.textSecondary,
      this.accent,
      this.accentSecondary});
}

/* FIGMA COLORS
background:       F0F3F5
fill:             FFFFFF
text:             111111
text secondary:   595959
accent:           1A55B8
accent secondary: E8F4FF
*/
const PaperColors lightColors = PaperColors(
  background: Color(0xffEBEFF2),
  fill: Color(0xffFFFFFF),
  text: Color(0xff111111),
  textSecondary: Color(0xff595959),
  accent: Color(0xff1A55B8),
  accentSecondary: Color(0xffE8F4FF),
);
const Color _background_light = Color(0xffEBEFF2);
const Color _fill_light = Color(0xffFFFFFF);
const Color _text_light = Color(0xff111111);
const Color _text_secondary_light = Color(0xff595959);
const Color _accent_light = Color(0xff1A55B8);
const Color _accent_secondary_light = Color(0xffE8F4FF);
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Roboto',

  dialogBackgroundColor: _fill_light,
  textSelectionColor: _accent_secondary_light,
  toggleableActiveColor: _accent_light,

  dialogTheme: DialogTheme(
    contentTextStyle: TextStyle(color: _text_secondary_light),
    titleTextStyle: TextStyle(
      color: _text_light,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  primaryColor: _fill_light, // in recent apps view
  scaffoldBackgroundColor: _background_light,
  cursorColor: _accent_light,
  hintColor: _accent_light,
  accentColor: _accent_light,
  textSelectionHandleColor: _accent_light,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _accent_secondary_light,
    foregroundColor: _accent_light,
  ),
  iconTheme: IconThemeData(
    color: _accent_light,
  ),
);

/* FIGMA COLORS
background:       000000
fill:             242424
text:             D3D3D3
text secondary:   B0B0B0
accent:           69B4FF
accent secondary: 6CB0F5
*/
const PaperColors darkColors = PaperColors(
  background: Color(0xff000000),
  fill: Color(0xff242424),
  text: Color(0xffE5E5E5),
  textSecondary: Color(0xffB0B0B0),
  accent: Color(0xff69B4FF),
  accentSecondary: Color(0xff78BDFA),
);
const Color _background_dark = Color(0xff000000);
const Color _fill_dark = Color(0xff242424);
const Color _text_dark = Color(0xffE5E5E5);
const Color _text_secondary_dark = Color(0xffB0B0B0);
const Color _accent_dark = Color(0xff69B4FF);
const Color _accent_secondary_dark = Color(0xff78BDFA);
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Roboto',

  dialogBackgroundColor: _fill_dark,
  textSelectionColor: _accent_secondary_dark,
  toggleableActiveColor: _accent_dark,

  dialogTheme: DialogTheme(
    contentTextStyle: TextStyle(color: _text_secondary_dark),
    titleTextStyle: TextStyle(
      color: _text_dark,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  primaryColor: _fill_dark, // in recent apps view
  scaffoldBackgroundColor: _background_dark,
  cursorColor: _accent_dark,
  hintColor: _accent_dark,
  accentColor: _accent_dark,
  textSelectionHandleColor: _accent_dark,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _accent_secondary_dark,
    foregroundColor: _background_dark,
  ),
  iconTheme: IconThemeData(
    color: _accent_dark,
  ),
);
