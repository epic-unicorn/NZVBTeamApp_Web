import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:nzvb_team_app/models/league.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';

class ScheduleTab extends StatefulWidget {
  final String? selectedTeam;
  final String activeSeasonId;

  ScheduleTab(this.selectedTeam, this.activeSeasonId, {Key? key})
      : super(key: key);
  @override
  _ScheduleTabState createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with AutomaticKeepAliveClientMixin<ScheduleTab> {
  League? _league;

  Future loadScheduleList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _league = new League(prefs.getString("leagueId") ?? "0",
        prefs.getString("leagueName") ?? "");

    String _getScheduleUrl =
        'https://cm.nzvb.nl/modules/nzvb/api/schedule.php?seasonId=' +
            widget.activeSeasonId +
            '&pouleId=' +
            _league!.id;

    debugPrint(_getScheduleUrl);

    if (_league != null) {
      final response = await http.get(Uri.tryParse(_getScheduleUrl)!);
      if (response.statusCode == 200) {
        Map data = json.decode(response.body);

        var activeSeasonName =
            data.entries.firstWhereOrNull((k) => k.value.length != 0);
        if (activeSeasonName == null) return null;

        return data[activeSeasonName.key][_league!.name];
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
          height: 40,
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
                future: loadScheduleList(),
                builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) =>
                    snapshot.hasData
                        ? ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final data = snapshot.data[index];
                              return InkWell(
                                  onTap: () {},
                                  child: new Ink(
                                    color: data['team1'] ==
                                                widget.selectedTeam ||
                                            data['team2'] == widget.selectedTeam
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    height: 40,
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            formatDate(
                                                DateTime.parse(data['date']), [
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
                                  ));
                            },
                          )
                        : Container()))
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
