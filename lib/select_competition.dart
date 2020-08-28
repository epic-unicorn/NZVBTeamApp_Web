import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:NZVBTeamApp_Web/utils/theme_notifier.dart';
import 'package:NZVBTeamApp_Web/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SelectCompetition extends StatefulWidget {

  @override
  _SelectCompetitionState createState() => _SelectCompetitionState();
}

class _SelectCompetitionState extends State<SelectCompetition> {

  Future<List<String>> getCompetitions() async {
    List<String> myList = ['Great Dinosaur', 'Humpy bumpy', 'Crazy horse'];

    return myList;
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
          new Container( height: 20,),
          new Expanded(
            child: FutureBuilder(
              builder: (context, competitionList) {
              if (competitionList.data == null) {
                return Container();
              }
              return ListView.builder(
                itemCount: competitionList.data.length,
                itemBuilder: (BuildContext context, int index) {
                  final data = competitionList.data[index];
                  return ListTile(
                    title: Text(data),
                    onTap: () {
                      // todo
                    },
                  );
                },
              );
              },
                future: getCompetitions(),
            ))
        ],
      )
    );
  }
}
