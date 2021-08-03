import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:NZVBTeamApp_Web/models/league.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:NZVBTeamApp_Web/utils/theme_notifier.dart';
import 'package:NZVBTeamApp_Web/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  String activeSeasonId;

  Settings(this.activeSeasonId, {Key key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Settings> {
  var _darkTheme = false;

  League _selectedLeague;
  String _selectedTeamName;

  List<League> _leagues = new List<League>();
  List<String> _teams = new List<String>();

  Future<List<League>> _getLeaguesFromActiveSeason() async {
    final String _pouleIdsUrl =
        'https://thingproxy.freeboard.io/fetch/http://cm.nzvb.nl/modules/nzvb/api/poule_ids.php';
    var res = await http.get(Uri.encodeFull(_pouleIdsUrl));
    Map resBody = jsonDecode(res.body);
    _leagues.clear();

    var activeSeasonLeagues = resBody.entries
        .firstWhere((k) => k.key == widget.activeSeasonId, orElse: () => null);
    if (activeSeasonLeagues == null) return _leagues;

    Map<String, String> values =
        Map<String, String>.from(activeSeasonLeagues.value);
    values.forEach((k, v) => _leagues.add(League(k, v)));
    _leagues
        .removeWhere((x) => x.name == 'Cup poule'); // not needed in this list
    return _leagues;
  }

  Future<List<String>> _getTeamsFromSelectedLeague(String leagueId) async {
    String _getTeamNamesUrl =
        'https://thingproxy.freeboard.io/fetch/http://cm.nzvb.nl/modules/nzvb/api/rankings.php?seasonId=' +
            widget.activeSeasonId +
            '&pouleId=' +
            leagueId;
    var res = await http.get(Uri.encodeFull(_getTeamNamesUrl));
    Map resBody = jsonDecode(res.body);
    _teams.clear();

    var activeSeasonName = resBody.entries
        .firstWhere((k) => k.value.length != 0, orElse: () => null);
    if (activeSeasonName == null) return _teams;

    var result = resBody[activeSeasonName.key].map((key, value) =>
        MapEntry<String, List<dynamic>>(key, List<dynamic>.from(value)));

    for (var key in result.keys) {
      List<dynamic> x = result[key];
      if (x.length > 0) {
        for (var team in x) {
          _teams.add(team['team_name']);
        }
      }
    }
    return _teams;
  }

  Future<String> _getSavedLeagueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('leagueId') ?? '0';
  }

  Future<String> _getSavedTeamName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('teamName') ?? '0';
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('leagueId', _selectedLeague.id);
    prefs.setString('leagueName', _selectedLeague.name);
    prefs.setString('teamName', _selectedTeamName);
    prefs.setString('activeSeasonId', widget.activeSeasonId);
  }

  void _initializeSettingsPage() {
    _getSavedLeagueId().then((leagueId) {
      _getLeaguesFromActiveSeason().then((leagues) {
        if (leagueId != '0') {
          _getTeamsFromSelectedLeague(leagueId).then((teams) {
            setState(() {
              _teams = teams;
              _selectedLeague = leagues.where((x) => x.id == leagueId).first;
            });
            _getTeamName();
          });
        }
      });
    });
  }

  void _getTeamName() {
    _getSavedTeamName().then((teamName) {
      setState(() => _selectedTeamName = teamName);
    });
  }

  @override
  void initState() {
    _initializeSettingsPage();
    super.initState();
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
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
        body: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Container(height: 20),
            Text('Selecteer een competitie',
                style: new TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor)),
            new DropdownButtonHideUnderline(
                child: new FutureBuilder<List<League>>(
                    future: _getLeaguesFromActiveSeason(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<League>> snapshot) {
                      if (!snapshot.hasData) return Container();
                      return DropdownButton<League>(
                        items: snapshot.data
                            .map((competition) => DropdownMenuItem<League>(
                                  child: Text(competition.name),
                                  value: competition,
                                ))
                            .toList(),
                        onChanged: (League value) {
                          _getTeamsFromSelectedLeague(value.id).then((teams) {
                            setState(() => _teams = teams);
                          });
                          setState(() {
                            _selectedLeague = value;
                          });

                          _saveSettings();
                        },
                        value: _selectedLeague == null
                            ? _selectedLeague
                            : _leagues
                                .where((i) => i.id == _selectedLeague.id)
                                .first,
                      );
                    })),
            Container(height: 20),
            Text('Selecteer een team',
                style: new TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor)),
            new DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  items: _teams.map((String teamName) {
                    return DropdownMenuItem<String>(
                      value: teamName,
                      child: Text(teamName),
                    );
                  }).toList(),
                  onChanged: (String team) {
                    setState(() {
                      _selectedTeamName = team;
                    });
                    _saveSettings();
                  },
                  value: _teams.where((i) => i == _selectedTeamName).length > 0
                      ? _selectedTeamName
                      : null),
            ),
            Container(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Donker thema',
                    style: new TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor)),
                Switch(
                  activeColor: Theme.of(context).accentColor,
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
}
