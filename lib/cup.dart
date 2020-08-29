import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cup extends StatefulWidget {
  @override
  _CupState createState() => _CupState();
}

class _CupState extends State<Cup> {
  List<ListItem> cupResults;

  Future loadCupResults() async {
    final response = await http.get(
        "https://cors-anywhere.herokuapp.com/https://cm.nzvb.nl/modules/nzvb/api/cup_results.php");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data[data.keys.first];
      for (var game = 0; game < result.length; game++) {
        var items = result[game];
        if (cupResults.length != 0) {
          if (!roundExist(items['round'].toString())) {
            cupResults.add(new HeadingItem(items['round'].toString()));
            if (!matchExist(items['date'], items['team1'], items['team2'],
                items['result'])) {
              cupResults.add(new MatchItem(items['date'], items['start'],
                  items['team1'], items['team2'], items['result']));
            }
          } else {
            if (!matchExist(items['date'], items['team1'], items['team2'],
                items['result'])) {
              cupResults.add(new MatchItem(items['date'], items['start'],
                  items['team1'], items['team2'], items['result']));
            }
          }
        } else {
          // eerste wedstrijd in lijst, hoeven we niet te checken of die al bestaan
          cupResults.add(new HeadingItem(items['round'].toString()));
          cupResults.add(new MatchItem(items['date'], items['start'],
              items['team1'], items['team2'], items['result']));
        }
      }
    }
    return cupResults;
  }

  bool roundExist(String name) {
    var test =
        cupResults.whereType<HeadingItem>().where((x) => x.heading == name);
    return test.length > 0;
  }

  bool matchExist(String date, String team1, String team2, String result) {
    var test = cupResults.whereType<MatchItem>().where((x) =>
        x.date == date &&
        x.team1 == team1 &&
        x.team2 == team2 &&
        x.result == result);
    return test.length > 0;
  }

  @override
  void initState() {
    cupResults = new List<ListItem>();
    super.initState();

    cupResults.clear();
    loadCupResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Beker programma'),
          centerTitle: true,
        ),
        body: Column(
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
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      'Tijd',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      'Thuis',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Text(
                      'Uit',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Text(
                      'Uitslag',
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Expanded(
                child: FutureBuilder(
              builder: (context, cupResult) {
                if (cupResult.data == null) {
                  return Container();
                }
                return ListView.builder(
                  itemCount: cupResult.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = cupResult.data[index];
                    if (data is HeadingItem) {
                      return Container(
                        color: Theme.of(context).secondaryHeaderColor,
                        height: 35,
                        padding: EdgeInsets.only(left: 10.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Ronde ' + data.heading,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            )
                          ],
                        ),
                      );
                    }
                    if (data is MatchItem) {
                      return Container(
                        color: Theme.of(context).backgroundColor,
                        height: 35,
                        padding: EdgeInsets.only(left: 10.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                formatDate(DateTime.parse(data.date), [
                                  dd,
                                  '-',
                                  mm,
                                ]),
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: Text(data.time),
                              flex: 1,
                            ),
                            Expanded(
                              child: Text(
                                data.team1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              flex: 3,
                            ),
                            Expanded(
                              child: Text(
                                data.team2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              flex: 3,
                            ),
                            Expanded(
                              child: Text(data.result),
                              flex: 1,
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  },
                );
              },
              future: loadCupResults(),
            )),
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
  final String date;
  final String time;
  final String team1;
  final String team2;
  final String result;

  MatchItem(this.date, this.time, this.team1, this.team2, this.result);

  @override
  List<Object> get props => [date, time, team1, team2, result];
}
