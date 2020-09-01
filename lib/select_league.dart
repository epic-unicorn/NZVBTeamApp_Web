import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/league.dart';

class SelectLeague extends StatefulWidget {
  @override
  _SelectLeagueState createState() => _SelectLeagueState();
}

class _SelectLeagueState extends State<SelectLeague> {
  final String _pouleIdsUrl =
      'https://cors-anywhere.herokuapp.com/http://cm.nzvb.nl/modules/nzvb/api/poule_ids.php';
  List<League> _leagues = new List<League>();
  League _selectedLeague = new League('', '');

  Future<List<League>> getLeagues() async {
    var res = await http.get(Uri.encodeFull(_pouleIdsUrl),
        headers: {'X-Requested-With': 'XMLHttpRequest'});
    Map resBody = jsonDecode(res.body);
    var test = resBody.keys.toList()..sort();
    _leagues.clear();

    // ACTIVE COMPETITION ID 2020/2021 = 6
    Map<String, String> values = Map<String, String>.from(resBody[test[4]]);
    values.forEach((k, v) => _leagues.add(League(k, v)));
    _leagues.removeWhere((x) => x.name == "Cup poule");
    return _leagues;
  }

  Future<void> saveLeague() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("leagueId", _selectedLeague.id);
    prefs.setString("leagueName", _selectedLeague.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Selecteer competitie'),
          centerTitle: true,
        ),
        body: new Column(
          children: <Widget>[
            new Container(
              height: 20,
            ),
            new Expanded(
                child: FutureBuilder(
              future: getLeagues(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<League>> snapshot) {
                if (!snapshot.hasData) return Container();
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = snapshot.data[index];
                    return ListTile(
                      title: Text(data.name),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        setState(() {
                          _selectedLeague = data;
                        });
                        saveLeague();
                        Navigator.pop(context, _selectedLeague.name);
                      },
                    );
                  },
                );
              },
            ))
          ],
        ));
  }
}
