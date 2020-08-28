import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:NZVBTeamApp_Web/utils/theme_notifier.dart';
import 'package:NZVBTeamApp_Web/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Settings> {

  var _darkTheme = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Instellingen'),
          centerTitle: true,
        ),
        bottomNavigationBar:
        Container(
          height: 50.0,
          color: Theme.of(context).backgroundColor,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Donker thema',
                    style: new TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor)),
                Switch(
                  activeColor: Theme.of(context).focusColor,
                  value: _darkTheme,
                  onChanged: (val) {
                    setState(() {
                      _darkTheme = val;
                    });
                    onThemeChanged(val, themeNotifier);
                  },
                ),
              ],
            ),
          ],
        ));
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }
}
