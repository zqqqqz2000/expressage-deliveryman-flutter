import 'package:expressage_deliveryman/models/target.dart';
import 'package:flutter/cupertino.dart';

class Targets extends ChangeNotifier {
  List<Target> targets = [];

  void addTarget(Target target) {
    targets.add(target);
    notifyListeners();
  }

  void removeTarget(Target target) {
    targets.remove(target);
    notifyListeners();
  }

  void initTargets(List<Target> targets) {
    this.targets = targets;
    notifyListeners();
  }
}
