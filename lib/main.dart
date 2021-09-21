import 'package:nzvb_team_app/tabs/ranking_tab.dart';
import 'package:nzvb_team_app/tabs/results_tab.dart';
import 'package:nzvb_team_app/tabs/schedule_tab.dart';
import 'package:flutter/material.dart';
import 'package:nzvb_team_app/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyNzvbApp(),
  );
}

class MyNzvbApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NZVB Team App',
      theme: ThemeData(
        accentColor: Color(0xFFdb8a2d),
        primaryColor: Color(0xFFdb8a2d),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: Color(0xFFdb8a2d)),
        ),
        brightness: Brightness.dark,
      ),
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
  String _activeSeasonId = '8'; // huidig actieve seizoen 2021/2022

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
                _getLeagueName().then((leagueName) {
                  setState(() => _leagueName = leagueName);
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
        appBar: AppBar(
          title: Row(
            children: [
              Text(_selectedTeam ?? 'NZVB Team App'),
              Text(' '),
              Text(_leagueName ?? '', style: TextStyle(fontSize: 14))
            ],
          ),
          actions: <Widget>[
            /*
            IconButton(
              icon: Icon(FontAwesome.trophy),
              color: Theme.of(context).iconTheme.color,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Cup(_selectedTeam)));
              },
            ),
            */
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Settings(_activeSeasonId)));
                _getSavedTeamName().then((teamName) {
                  setState(() => _selectedTeam = teamName);
                });
                _getLeagueName().then((leagueName) {
                  setState(() => _leagueName = leagueName);
                });
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Color(0xFFdb8a2d),
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
