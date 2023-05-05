import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:nzvb_team_app/models/league.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class RankingTab extends StatefulWidget {
  final String? selectedTeam;
  final String activeSeasonId;

  const RankingTab(this.selectedTeam, this.activeSeasonId, {Key? key})
      : super(key: key);
  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab>
    with AutomaticKeepAliveClientMixin<RankingTab> {
  League? _league;

  Future loadRankingList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _league = League(prefs.getString("leagueId") ?? "0",
        prefs.getString("leagueName") ?? "");

    String getRankingUrl =
        'https://cm.nzvb.nl/modules/nzvb/api/rankings.php?seasonId=${widget.activeSeasonId}&pouleId=${_league!.id}';

    debugPrint(getRankingUrl);

    if (_league != null) {
      final response = await http.get(Uri.tryParse(getRankingUrl)!);
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
          color: Theme.of(context).secondaryHeaderColor,
          padding: const EdgeInsets.only(left: 10.0),
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Expanded(
                child: Text(
                  '#',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  'Team',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'G',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'W',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'GL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'V',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'P',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'DPV',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'DPT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'PM',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: FutureBuilder(
                future: loadRankingList(),
                builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) =>
                    snapshot.hasData
                        ? ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data[index];
                              return Container(
                                color: data['team_name'] == widget.selectedTeam
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).scaffoldBackgroundColor,
                                height: 40,
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(data['nr'] == null
                                          ? ''
                                          : data['nr'].toString()),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        data['team_name'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(data['played'] ?? '0'),
                                    ),
                                    Expanded(
                                      child: Text(data['won'] ?? '0'),
                                    ),
                                    Expanded(
                                      child: Text(data['tied'] ?? '0'),
                                    ),
                                    Expanded(
                                      child: Text(data['lost'] ?? '0'),
                                    ),
                                    Expanded(
                                      child: Text(data['match_points'] ?? '0'),
                                    ),
                                    Expanded(
                                      child: Text(data['goals_total'] ?? '0'),
                                    ),
                                    Expanded(
                                      child: Text(
                                          data['opponent_goals_total'] ?? '0'),
                                    ),
                                    Expanded(
                                      child:
                                          Text(data['penalty_points'] ?? '0'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Container()))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
