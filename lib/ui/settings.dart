import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magnotes/data/settings_model.dart';
import 'package:magnotes/ui/global_widgets.dart';
import 'package:magnotes/data/theme_model.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperStack(
        // Header (Appbar)
        above: Row(
          children: <Widget>[
            BackButton(),
            Text(
              "Settings",
              style: TextStyle(
                  color: Provider.of<ThemeModel>(context).paperColors.text,
                  fontSize: 20
              ),
            ),
          ],
        ),
        // Content
        child: SafeArea(
          child: Column(
            children: [
              Container(height: 60.0 - 16.0), // Offset under the Appbar
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                    child: SettingsList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          header: 'General',
          children: [
            SwitchTile(
              label: 'Auto-search when inputting text',
              setting: Settings.AUTOSEARCH,
            ),
            SwitchTile(
              label: 'Order notes by ascending date',
              setting: Settings.ORDERINGBOTTOM,
            ),
            SwitchTile(
              isLastTile: true,
              label: 'Confirm before deleting',
              setting: Settings.CONFIRMDELETE,
            ),
          ],
        ),
        SettingsGroup(
          header: 'Appearance',
          children: [
            SettingsTile(
              isLastTile: true,
              label: 'Theme',
              child: Consumer<ThemeModel>(
                builder: (context, themeModel, _) {
                  return DropdownButton<ThemeSetting>(
                    underline: Container(
                      height: 1,
                      color: Provider.of<ThemeModel>(context).paperColors.accent,
                    ),
                    onChanged: (ThemeSetting themeSetting) {
                      setState(() {
                        themeModel.setThemeSetting(themeSetting);
                        themeModel.save();
                      });
                    },
                    focusColor: themeModel.paperColors.accent,
                    value: themeModel.themeSetting,
                    items: [
                      DropdownMenuItem<ThemeSetting>(
                        value: ThemeSetting.DARK,
                        child: Row(
                          children: [
                            Icon(Icons.brightness_3),
                            Text('Dark'),
                          ],
                        ),
                      ),
                      DropdownMenuItem<ThemeSetting>(
                        value: ThemeSetting.LIGHT,
                        child: Row(
                          children: [
                            Icon(Icons.brightness_7),
                            Text('Light'),
                          ],
                        ),
                      ),
                      DropdownMenuItem<ThemeSetting>(
                        value: ThemeSetting.SYSTEM,
                        child: Row(
                          children: [
                            Icon(Icons.settings),
                            Text('System'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final String header;
  final List<Widget> children;

  const SettingsGroup({Key key, this.header, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Provider.of<ThemeModel>(context).paperColors.textSecondary
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Provider.of<ThemeModel>(context).paperColors.fill,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Group name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(header, style: headerStyle),
            ),
            // Group widgets
            Column(
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

// A modified version of SettingsTile with a switch
class SwitchTile extends StatelessWidget {
  final String label;
  final Settings setting;
  final bool isLastTile;

  const SwitchTile({Key key, this.label, this.setting, this.isLastTile})
      : super(key: key);

  void toggle(BuildContext context) {
    SettingsModel settingsModel =
        Provider.of<SettingsModel>(context, listen: false);
    settingsModel.setSetting(setting, !settingsModel.getSetting(setting));
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      isLastTile: isLastTile,
      onTap: () => toggle(context),
      label: label,
      child: Switch(
        value: Provider.of<SettingsModel>(context).getSetting(setting),
        onChanged: (value) => Provider.of<SettingsModel>(context, listen: false)
            .setSetting(setting, value),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isLastTile; // Used to give the InkWell rounded corners
  final void Function() onTap;

  SettingsTile({Key key, this.onTap, this.label, this.child, this.isLastTile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: (isLastTile ?? false)
          ? BorderRadius.vertical(bottom: Radius.circular(8))
          : BorderRadius.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Row(
          children: [
            // A description of the setting
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Provider.of<ThemeModel>(context).paperColors.text
                ),
              ),
            ),
            SizedBox(width: 16),
            child,
          ],
        ),
      ),
    );
  }
}
