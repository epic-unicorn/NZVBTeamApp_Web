import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  PackageInfo _packageInfo = new PackageInfo(
      appName: 'appName',
      packageName: 'packageName',
      version: 'version',
      buildNumber: 'buildNumber');

  Future<void> _getPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Over deze app'),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Container(height: 30),
            Text('App version : ' + _packageInfo.version,
                style: new TextStyle(
                  fontSize: 16,
                )),
            Container(height: 10),
            Text('Build number : ' + _packageInfo.buildNumber,
                style: new TextStyle(
                  fontSize: 16,
                )),
            Container(height: 30),
            InkWell(
                child: new Text(
                  'Klik hier voor privacy beleid.',
                  style: new TextStyle(
                      fontSize: 16, decoration: TextDecoration.underline),
                ),
                onTap: () => launch(
                    'https://sites.google.com/view/nzvbteamapp-privacypolicy/home')),
          ],
        ));
  }
}
