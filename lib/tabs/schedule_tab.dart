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

  const ScheduleTab(this.selectedTeam, this.activeSeasonId, {Key? key})
      : super(key: key);
  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with AutomaticKeepAliveClientMixin<ScheduleTab> {
  League? _league;

  Future loadScheduleList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _league = League(prefs.getString("leagueId") ?? "0",
        prefs.getString("leagueName") ?? "");

    String getScheduleUrl =
        'https://cm.nzvb.nl/modules/nzvb/api/schedule.php?seasonId=${widget.activeSeasonId}&pouleId=${_league!.id}';

    debugPrint(getScheduleUrl);

    if (_league != null) {
      final response = await http.get(Uri.tryParse(getScheduleUrl)!);
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
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 10.0),
          height: 40,
          color: Theme.of(context).secondaryHeaderColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  'Datum',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Tijd',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Thuis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Uit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Zaal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
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
                                  child: Ink(
                                    color: data['team1'] ==
                                                widget.selectedTeam ||
                                            data['team2'] == widget.selectedTeam
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    height: 40,
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            formatDate(
                                                DateTime.parse(data['date']), [
                                              dd,
                                              '-',
                                              mm,
                                            ]),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            data['start'],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            data['team1'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            data['team2'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            data['location'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            },
                          )
                        : Container()))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
