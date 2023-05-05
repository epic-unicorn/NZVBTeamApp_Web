import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cup extends StatefulWidget {
  final String selectedTeam;

  const Cup(this.selectedTeam, {Key? key}) : super(key: key);

  @override
  State<Cup> createState() => _CupState();
}

class _CupState extends State<Cup> {
  final List<ListItem> _cupResults = <ListItem>[];

  Future loadCupResults() async {
    final response = await http.get(
        Uri.tryParse('https://cm.nzvb.nl/modules/nzvb/api/cup_results.php')!);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data[data.keys.first];
      for (var game = 0; game < result.length; game++) {
        var items = result[game];
        if (_cupResults.isNotEmpty) {
          if (!roundExist(items['round'].toString())) {
            _cupResults.add(HeadingItem(items['round'].toString()));
            if (!matchExist(items['date'], items['team1'], items['team2'],
                items['result'])) {
              _cupResults.add(MatchItem(items['date'], items['start'],
                  items['team1'], items['team2'], items['result']));
            }
          } else {
            if (!matchExist(items['date'], items['team1'], items['team2'],
                items['result'])) {
              _cupResults.add(MatchItem(items['date'], items['start'],
                  items['team1'], items['team2'], items['result']));
            }
          }
        } else {
          // eerste wedstrijd in lijst, hoeven we niet te checken of die al bestaan
          _cupResults.add(HeadingItem(items['round'].toString()));
          _cupResults.add(MatchItem(items['date'], items['start'],
              items['team1'], items['team2'], items['result']));
        }
      }
    }
    return _cupResults;
  }

  bool roundExist(String name) {
    var test =
        _cupResults.whereType<HeadingItem>().where((x) => x.heading == name);
    return test.isNotEmpty;
  }

  bool matchExist(String? date, String? team1, String? team2, String? result) {
    var test = _cupResults.whereType<MatchItem>().where((x) =>
        x.date == date &&
        x.team1 == team1 &&
        x.team2 == team2 &&
        x.result == result);
    return test.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _cupResults.clear();
    loadCupResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Beker programma'),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: 38,
              color: Theme.of(context).secondaryHeaderColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Datum',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Tijd',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Thuis',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Uit',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Uitslag',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: FutureBuilder(
                    future: loadCupResults(),
                    builder: (BuildContext ctx,
                            AsyncSnapshot<dynamic> snapshot) =>
                        snapshot.hasData
                            ? ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final data = snapshot.data[index];
                                  if (data is HeadingItem) {
                                    return Container(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      height: 35,
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Ronde ${data.heading}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  if (data is MatchItem) {
                                    return Container(
                                      color: data.team1 ==
                                                  widget.selectedTeam ||
                                              data.team2 == widget.selectedTeam
                                          ? Theme.of(context).focusColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .background,
                                      height: 35,
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              formatDate(
                                                  DateTime.parse(data.date!), [
                                                dd,
                                                '-',
                                                mm,
                                              ]),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(data.time!),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              data.team1!,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              data.team2!,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(data.result!),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              )
                            : Container()))
          ],
        ));
  }
}

abstract class ListItem {}

class HeadingItem implements ListItem {
  String heading;
  HeadingItem(this.heading);
}

class MatchItem implements ListItem {
  final String? date;
  final String? time;
  final String? team1;
  final String? team2;
  final String? result;

  MatchItem(this.date, this.time, this.team1, this.team2, this.result);

  List<Object?> get props => [date, time, team1, team2, result];
}
