import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

Future<void> _launchInBrowser(Uri url) async {
  debugPrint('Try to launch $url');

  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    debugPrint('Could not launch $url');
  }
}

class _AboutState extends State<About> {
  PackageInfo _packageInfo = PackageInfo(
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Over deze app'),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Container(height: 30),
            Text('App version : ${_packageInfo.version}',
                style: const TextStyle(
                  fontSize: 16,
                )),
            Container(height: 10),
            Text('Build number : ${_packageInfo.buildNumber}',
                style: const TextStyle(
                  fontSize: 16,
                )),
            Container(height: 30),
            InkWell(
                child: const Text(
                  'Klik hier voor privacy beleid.',
                  style: TextStyle(
                      fontSize: 16, decoration: TextDecoration.underline),
                ),
                onTap: () => _launchInBrowser(Uri(
                    scheme: 'https',
                    host: 'sites.google.com',
                    path: 'view/nzvbteamapp-privacypolicy/home')))
          ],
        ));
  }
}
