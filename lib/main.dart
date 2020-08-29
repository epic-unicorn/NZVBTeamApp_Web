import 'package:NZVBTeamApp_Web/cup.dart';
import 'package:NZVBTeamApp_Web/select_league.dart';
import 'package:NZVBTeamApp_Web/utils/theme_notifier.dart';
import 'package:NZVBTeamApp_Web/utils/themes.dart';
import 'package:NZVBTeamApp_Web/tabs/ranking_tab.dart';
import 'package:NZVBTeamApp_Web/tabs/results_tab.dart';
import 'package:NZVBTeamApp_Web/tabs/schedule_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:NZVBTeamApp_Web/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
        child: MyNzvbApp(),
      ),
    );
  });
}

class MyNzvbApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'NZVB Team App',
      theme: themeNotifier.getTheme(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedLeague;
  Future _getSelectedLeague() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var leagueId = prefs.getString("leagueId");

    if (leagueId != null) {
      setState(() => _selectedLeague = prefs.getString("leagueName"));
    }
  }

  @override
  void initState() {
    _getSelectedLeague();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Mijn competitie'),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SelectLeague()));
                setState(() => _selectedLeague = result);
              },
              child: Text(_selectedLeague ?? "HKA"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
            IconButton(
              icon: Icon(FontAwesome.trophy),
              color: Theme.of(context).accentIconTheme.color,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Cup()));
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: Theme.of(context).accentIconTheme.color,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Settings()));
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Stand'),
              Tab(text: 'Programma'),
              Tab(text: 'Uitslagen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RankingTab(),
            ScheduleTab(),
            ResultsTab(),
          ],
        ),
      ),
    );
  }
}
