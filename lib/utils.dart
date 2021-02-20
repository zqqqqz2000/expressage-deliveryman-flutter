import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

void api(String url, Map data, FutureOr callback(Map data)) {
  var client = http.Client();
  var uriResponse = client.post(
    SERVER_URL + url,
    body: jsonEncode(data),
    headers: {
      "Content-Type": "application/json",
    },
  );
  uriResponse.then((response) async {
    var data = jsonDecode(response.body);
    callback(data);
  });
}