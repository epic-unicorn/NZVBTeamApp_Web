import 'dart:convert';
import 'package:nzvb_team_app/tabs/ranking_tab.dart';
import 'package:nzvb_team_app/tabs/results_tab.dart';
import 'package:nzvb_team_app/tabs/schedule_tab.dart';
import 'package:flutter/material.dart';
import 'package:nzvb_team_app/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyNzvbApp());
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
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(primary: Color(0xFFdb8a2d))),
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
  String _savedSeasonId = '0';
  String _activeSeasonName;

  Future<String> _getSavedTeamName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("teamName") ?? "0";
  }

  Future<String> _getLeagueName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("leagueName") ?? "";
  }

  Future<String> _getSavedSeasonId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("savedSeasonId") ?? "0";
  }

  Future<String> _getActiveSeasonIdLegacy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("activeSeasonId") ?? "0";
  }

  void _initializeLeagueAndTeam() {
    _getActiveSeasonId().then((activeSeasonId) {
      _getActiveSeasonIdLegacy().then((activeSeasonIdLegacy) {
        _getSavedSeasonId().then((savedSeasonId) {
          _getActiveSeasonName(savedSeasonId).then((activeSeasonName) {
            setState(() {
              _savedSeasonId = savedSeasonId;
              _activeSeasonName = activeSeasonName;
            });
            // legacy migration
            if (activeSeasonIdLegacy != "0") {
              _savedSeasonId = activeSeasonIdLegacy;
            }
            _getSavedTeamName().then((teamName) {
              _getLeagueName().then((leagueName) {
                if (teamName == "0" || _savedSeasonId == "0") {
                  showNewDialog();
                }
                setState(() => _selectedTeam = teamName);
                setState(() => _leagueName = leagueName);
              });
            });
          });
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
            new ElevatedButton(
              child: new Text("OK"),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Settings(_savedSeasonId, true)));

                _getActiveSeasonName(_savedSeasonId).then((seasonName) {
                  setState(() {
                    _activeSeasonName = seasonName;
                  });
                });
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

  Future _getActiveSeasonId() async {
    final response = await http
        .get(Uri.tryParse("http://cm.nzvb.nl/modules/nzvb/api/season_ids.php"));
    if (response.statusCode == 200) {
      Map data = json.decode(response.body);
      var activeSeason = data.entries
          .lastWhere((k) => k.value.length != 0, orElse: () => null);
      if (activeSeason == null) return null;
      debugPrint('Latest season ID: ' + activeSeason.key);

      return activeSeason.key;
    }
    return "0";
  }

  Future<String> _getActiveSeasonName(String seasonId) async {
    final response = await http
        .get(Uri.tryParse("http://cm.nzvb.nl/modules/nzvb/api/season_ids.php"));
    if (response.statusCode == 200 && seasonId != "0") {
      Map data = json.decode(response.body);

      return data.entries
          .firstWhere((element) => element.key == seasonId)
          .value;
    }
    return "";
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('NZVB Team App '),
              Text(_leagueName ?? ' ',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFdb8a2d))),
              Text(' '),
              Text(_activeSeasonName ?? ' ',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey)),
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
                            Settings(_savedSeasonId, false)));

                _getSavedSeasonId().then((savedSeasonId) {
                  setState(() => _savedSeasonId = savedSeasonId);
                  _getActiveSeasonName(savedSeasonId).then((seasonName) {
                    setState(() {
                      _activeSeasonName = seasonName;
                    });
                  });
                });

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
            RankingTab(_selectedTeam, _savedSeasonId),
            ScheduleTab(_selectedTeam, _savedSeasonId),
            ResultsTab(_selectedTeam, _savedSeasonId, _activeSeasonName),
          ],
        ),
      ),
    );
  }
}
