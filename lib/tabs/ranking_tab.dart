import 'dart:convert';
import 'package:NZVBTeamApp_Web/models/league.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class RankingTab extends StatefulWidget {
  @override
  _RankingTabState createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab>
    with AutomaticKeepAliveClientMixin<RankingTab> {
  League _selectedLeague;

  Future loadRankingList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _selectedLeague = new League(prefs.getString('leagueId') ?? '0',
        prefs.getString('leagueName') ?? 'HKA');

    if (_selectedLeague != null) {
      final response = await http.get(
          "https://cors-anywhere.herokuapp.com/https://cm.nzvb.nl/modules/nzvb/api/rankings.php?pouleId=" +
              _selectedLeague.id);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data[data.keys.first][_selectedLeague.name];
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10.0),
          height: 38,
          color: Theme.of(context).secondaryHeaderColor,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  '#',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'Team',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                flex: 5,
              ),
              Expanded(
                child: Text(
                  'G',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'W',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'GL',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'V',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'P',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'DPV',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'DPT',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'PM',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: FutureBuilder(
          builder: (context, teamRanking) {
            if (teamRanking.data == null) {
              return Container();
            }
            return ListView.builder(
              itemCount: teamRanking.data.length,
              itemBuilder: (context, index) {
                final data = teamRanking.data[index];
                return Container(
                  color: Theme.of(context).backgroundColor,
                  height: 35,
                  padding: EdgeInsets.only(left: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            data['nr'] == null ? '' : data['nr'].toString()),
                      ),
                      Expanded(
                        child: Text(
                          data['team_name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                        flex: 5,
                      ),
                      Expanded(
                        child:
                            Text(data['played'] == null ? '' : data['played']),
                      ),
                      Expanded(
                        child: Text(data['won'] == null ? '' : data['won']),
                      ),
                      Expanded(
                        child: Text(data['tied'] == null ? '' : data['tied']),
                      ),
                      Expanded(
                        child: Text(data['lost'] == null ? '' : data['lost']),
                      ),
                      Expanded(
                        child: Text(data['match_points'] == null
                            ? ''
                            : data['match_points']),
                      ),
                      Expanded(
                        child: Text(data['goals_total'] == null
                            ? ''
                            : data['goals_total']),
                      ),
                      Expanded(
                        child: Text(data['opponent_goals_total'] == null
                            ? ''
                            : data['opponent_goals_total']),
                      ),
                      Expanded(
                        child: Text(data['penalty_points'] == null
                            ? ''
                            : data['penalty_points']),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          future: loadRankingList(),
        ))
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}