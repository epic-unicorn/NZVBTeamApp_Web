import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:nzvb_team_app/models/league.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ResultsTab extends StatefulWidget {
  final String? selectedTeam;
  final String activeSeasonId;
  final String? activeSeasonName;

  ResultsTab(this.selectedTeam, this.activeSeasonId, this.activeSeasonName,
      {Key? key})
      : super(key: key);
  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab>
    with AutomaticKeepAliveClientMixin<ResultsTab> {
  League? _league;

  Future loadResultList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _league = new League(prefs.getString("leagueId") ?? "0",
        prefs.getString("leagueName") ?? "");

    String _getResultsUrl =
        'https://cm.nzvb.nl/modules/nzvb/api/results.php?seasonId=' +
            widget.activeSeasonId +
            '&pouleId=' +
            _league!.id;

    debugPrint(_getResultsUrl);

    if (_league != null) {
      final response = await http.get(Uri.tryParse(_getResultsUrl)!);
      if (response.statusCode == 200) {
        Map data = json.decode(response.body);

        var activeSeason = data.entries
            .firstWhereOrNull((k) => k.key == widget.activeSeasonName);
        if (activeSeason == null) return null;

        return data[activeSeason.key][_league!.name];
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
                  'Uitslag',
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
                future: loadResultList(),
                builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) =>
                    snapshot.hasData
                        ? ListView.builder(
                            itemCount: snapshot.data!.length,
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
                                          child: Text(data['time']),
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
                                          child: Text(data['result']),
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
