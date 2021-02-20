import 'package:expressage_deliveryman/common/theme.dart';
import 'package:expressage_deliveryman/screens/login.dart';
import 'package:expressage_deliveryman/screens/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/map.dart';
import 'models/targets.dart';

void main() {
  runApp(MultiProvider(
    child: MyApp(),
    providers: [
      ChangeNotifierProvider(create: (context) => Targets()),
      ListenableProvider(create: (context) => BMapInfo()),
    ],
  ));
}

class MyApp extends StatelessWidget {
  final routes = {
    '/': (context) => DeliverymanLogin(),
    '/mainPage': (context, {arguments}) => MainPage(
          arguments: arguments,
        ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '快送宝',
      theme: appTheme,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        final String name = settings.name;
        final Function pageContentBuilder = this.routes[name];
        if (pageContentBuilder != null) {
          if (settings.arguments != null) {
            final Route route = MaterialPageRoute(
                builder: (context) =>
                    pageContentBuilder(context, arguments: settings.arguments));
            return route;
          } else {
            final Route route = MaterialPageRoute(
                builder: (context) => pageContentBuilder(context));
            return route;
          }
        }
        return null;
      },
    );
  }
}
