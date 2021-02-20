import 'dart:async';
import 'package:expressage_deliveryman/models/map.dart';
import 'package:expressage_deliveryman/models/targets.dart';
import 'package:flutter_bmflocation/bdmap_location_flutter_plugin.dart';
import 'package:flutter_bmflocation/flutter_baidu_location.dart';
import 'package:flutter_bmflocation/flutter_baidu_location_android_option.dart';
import 'package:flutter_bmfmap/BaiduMap/bmfmap_map.dart';
import 'package:flutter_bmfmap/BaiduMap/models/bmf_map_options.dart';
import 'package:flutter_bmfbase/BaiduMap/map/bmf_models.dart';
import 'package:flutter/cupertino.dart';

// import 'package:flutter_bmfutils/BaiduMap/bmfmap_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';
// import 'package:flutter_bmfbase/BaiduMap/bmfmap_base.dart' show BMF_COORD_TYPE;

class MainPage extends StatelessWidget {
  final arguments;

  MainPage({this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          Timer.run(() {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Row(
              children: [
                Icon(Icons.check, color: Colors.green),
                Text(arguments['welcome']),
              ],
            )));
          });
          return CenterMap();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_location_alt_outlined),
        onPressed: () async {
          BMapInfo map = context.read<BMapInfo>();
          if (map.coordinate != null) {
            map.controller.setCenterCoordinate(
              map.coordinate,
              true,
            );
            SharedPreferences pers = await SharedPreferences.getInstance();
            String token = pers.getString('token');
            api(
                '/deliveryman/update_position',
                {
                  'token': token,
                  'lng': map.coordinate.longitude,
                  'lat': map.coordinate.latitude,
                },
                (data) {
                  Fluttertoast.showToast(msg: data['info']);
                });
          } else {
            Fluttertoast.showToast(msg: "您的位置信息未加载完成，请等待");
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text('快递员导航'),
        actions: [
          IconButton(
              icon: Icon(Icons.list_alt),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomDraw();
                    });
              }),
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              })
        ],
      ),
    );
  }
}

class CenterMap extends StatefulWidget {
  LocationFlutterPlugin locationFlutterPlugin = LocationFlutterPlugin();
  StreamSubscription<Map<String, Object>> locationListener;

  @override
  State<StatefulWidget> createState() {
    return _CenterMap();
  }
}

class _CenterMap extends State<CenterMap> {
  @override
  void initState() {
    super.initState();
    this.widget.locationFlutterPlugin.requestPermission();
    this.widget.locationListener = this
        .widget
        .locationFlutterPlugin
        .onResultCallback()
        .listen((Map<String, Object> result) async {
      BMapInfo bMapInfo = context.read<BMapInfo>();
      if (bMapInfo.coordinate == null && bMapInfo.controller != null) {
        bMapInfo.controller?.setCenterCoordinate(
          BMFCoordinate(
            result['latitude'],
            result['longitude'],
          ),
          true,
        );
      }
      BMFCoordinate coordinate = BMFCoordinate(
        result['latitude'],
        result['longitude'],
      );
      bMapInfo.setCoordinate(coordinate);
      if (bMapInfo.controller != null) {
        BMFLocation location = BMFLocation(
            coordinate: coordinate,
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: -1.0,
            speed: -1.0,
            course: -1.0);
        BMFUserLocation userLocation = BMFUserLocation(
          location: location,
        );
        bMapInfo.controller?.updateLocationData(userLocation);

        BMFUserlocationDisplayParam displayParam = BMFUserlocationDisplayParam(
            locationViewOffsetX: 0,
            locationViewOffsetY: 0,
            accuracyCircleFillColor: Colors.red,
            accuracyCircleStrokeColor: Colors.blue,
            isAccuracyCircleShow: true,
            locationViewHierarchy:
                BMFLocationViewHierarchy.LOCATION_VIEW_HIERARCHY_BOTTOM);

        bMapInfo.controller?.updateLocationViewWithParam(displayParam);
      }
    });

    Timer.run(() {
      // 设置
      BaiduLocationAndroidOption androidOption =
          new BaiduLocationAndroidOption();
      androidOption.setCoorType("bd09ll"); // 设置返回的位置坐标系类型
      androidOption.setIsNeedAltitude(false); // 设置是否需要返回海拔高度信息
      androidOption.setIsNeedAddres(false); // 设置是否需要返回地址信息
      androidOption.setIsNeedLocationPoiList(false); // 设置是否需要返回周边poi信息
      androidOption.setIsNeedNewVersionRgc(false); // 设置是否需要返回最新版本rgc信息
      androidOption.setIsNeedLocationDescribe(false); // 设置是否需要返回位置描述
      androidOption.setOpenGps(true); // 设置是否需要使用gps
      androidOption.setLocationMode(LocationMode.Hight_Accuracy); // 设置定位模式
      androidOption.setScanspan(1000); // 设置发起定位请求时间间隔
      Map androidMap = androidOption.getMap();
      this.widget.locationFlutterPlugin.prepareLoc(androidMap, androidMap);

      this.widget.locationFlutterPlugin.startLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    BMFMapOptions mapOptions = BMFMapOptions(
      center: BMFCoordinate(39.917215, 116.380341),
      zoomLevel: 12,
      // mapPadding: BMFEdgeInsets(left: 0, top: 0)
    );
    return Center(
      child: BMFMapWidget(
        onBMFMapCreated: (controller) {
          BMapInfo bMapInfo = context.read<BMapInfo>();
          bMapInfo.setController(controller);
          controller?.showUserLocation(true);
        },
        mapOptions: mapOptions,
      ),
    );
  }
}

class BottomDraw extends StatelessWidget {
  Future<void> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 100)).then((e) {});
  }

  @override
  Widget build(BuildContext context) {
    Targets targets = Provider.of<Targets>(context);
    return RefreshIndicator(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.add_alert_outlined,
                    color: Colors.green,
                  ),
                  Text(
                    "任务清单",
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: List.generate(targets.targets.length,
                    (index) => Text(targets.targets[index].toString())),
              ),
            ),
          ],
        ),
        onRefresh: _onRefresh);
  }
}
