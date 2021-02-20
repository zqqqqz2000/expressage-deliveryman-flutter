import 'package:flutter/cupertino.dart';
import 'package:flutter_bmfbase/BaiduMap/map/bmf_models.dart';
import 'package:flutter_bmfmap/BaiduMap/bmfmap_map.dart';

class BMapInfo extends ChangeNotifier {
  BMFCoordinate coordinate;
  BMFMapController controller;

  void setCoordinate(BMFCoordinate coordinate) {
    this.coordinate = coordinate;
    // notifyListeners();
  }

  void setController(BMFMapController controller) {
    this.controller = controller;
    // notifyListeners();
  }
}
