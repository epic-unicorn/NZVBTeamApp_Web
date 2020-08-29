import 'dart:convert';
import 'package:NZVBTeamApp_Web/models/league.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';

class ScheduleTab extends StatefulWidget {
  final String selectedTeam;
  ScheduleTab(this.selectedTeam, {Key key}) : super(key: key);

  @override
  _ScheduleTabState createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with AutomaticKeepAliveClientMixin<ScheduleTab> {
  League _selectedLeague;

  Future loadScheduleList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _selectedLeague = new League(prefs.getString('leagueId') ?? '0',
        prefs.getString('leagueName') ?? 'HKA');

    if (_selectedLeague != null) {
      final response = await http.get(
          "https://cors-anywhere.herokuapp.com/http://cm.nzvb.nl/modules/nzvb/api/schedule.php?pouleId=" +
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
                  'Datum',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                flex: 1,
              ),
              Expanded(
                child: Text(
                  'Tijd',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                flex: 1,
              ),
              Expanded(
                child: Text(
                  'Thuis',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                flex: 3,
              ),
              Expanded(
                child: Text(
                  'Uit',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                flex: 3,
              ),
              Expanded(
                child: Text(
                  'Zaal',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Expanded(
            child: FutureBuilder(
          builder: (context, teamSchedule) {
            if (teamSchedule.data == null) {
              return Container();
            }
            return ListView.builder(
              itemCount: teamSchedule.data.length,
              itemBuilder: (BuildContext context, int index) {
                final data = teamSchedule.data[index];
                return Container(
                  color: data['team1'] == widget.selectedTeam ||
                          data['team2'] == widget.selectedTeam
                      ? Theme.of(context).focusColor
                      : Theme.of(context).backgroundColor,
                  height: 35,
                  padding: EdgeInsets.only(left: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          formatDate(DateTime.parse(data['date']), [
                            dd,
                            '-',
                            mm,
                          ]),
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child: Text(
                          data['start'],
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child: Text(
                          data['team1'],
                          overflow: TextOverflow.ellipsis,
                        ),
                        flex: 3,
                      ),
                      Expanded(
                        child: Text(
                          data['team2'],
                          overflow: TextOverflow.ellipsis,
                        ),
                        flex: 3,
                      ),
                      Expanded(
                        child: Text(
                          data['location'],
                          overflow: TextOverflow.ellipsis,
                        ),
                        flex: 1,
                      ),
                    ],
                  ),
                );
              },
            );
          },
          future: loadScheduleList(),
        ))
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
