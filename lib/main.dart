import 'package:NZVBTeamApp_Web/cup.dart';
import 'package:NZVBTeamApp_Web/utils/theme_notifier.dart';
import 'package:NZVBTeamApp_Web/utils/themes.dart';
import 'package:NZVBTeamApp_Web/tabs/ranking_tab.dart';
import 'package:NZVBTeamApp_Web/tabs/results_tab.dart';
import 'package:NZVBTeamApp_Web/tabs/schedule_tab.dart';
import 'package:flutter/material.dart';
import 'package:NZVBTeamApp_Web/settings.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  String _selectedTeam;
  String _leagueName;
  String _activeSeasonId =
      '6'; // laatst gespeelde seizoen voor corona 2019/2020

  Future<String> _getSavedTeamName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("teamName") ?? "0";
  }

  Future<String> _getLeagueName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("leagueName") ?? "";
  }

  Future<String> _getSavedActiveSeasonId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("activeSeasonId") ?? "0";
  }

  void _initializeLeagueAndTeam() {
    _getSavedActiveSeasonId().then((seasonId) {
      _getSavedTeamName().then((teamName) {
        _getLeagueName().then((leagueName) {
          if (teamName == "0" || seasonId != _activeSeasonId) {
            showNewDialog();
          }
          setState(() => _selectedTeam = teamName);
          setState(() => _leagueName = leagueName);
        });
      });
    });
  }

  Future<void> showNewDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Nieuw seizoen"),
          content: new Text("Eerst even je team en competitie instellen."),
          actions: <Widget>[
            new TextButton(
              child: new Text("OK"),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Settings(_activeSeasonId)));
                _getSavedTeamName().then((teamName) {
                  setState(() => _selectedTeam = teamName);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _initializeLeagueAndTeam();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_selectedTeam),
              Text(' '),
              Text(
                _leagueName,
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesome.trophy),
              color: Theme.of(context).accentIconTheme.color,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Cup(_selectedTeam)));
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: Theme.of(context).accentIconTheme.color,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Settings(_activeSeasonId)));
                _getSavedTeamName().then((teamName) {
                  setState(() => _selectedTeam = teamName);
                });
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
            RankingTab(_selectedTeam, _activeSeasonId),
            ScheduleTab(_selectedTeam, _activeSeasonId),
            ResultsTab(_selectedTeam, _activeSeasonId),
          ],
        ),
      ),
    );
  }
}
