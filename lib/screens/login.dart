// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:expressage_deliveryman/config.dart';
import 'package:expressage_deliveryman/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliverymanLogin extends StatelessWidget {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(80.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '快递员登录入口',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '用户名',
                    ),
                    onChanged: (value) => {this.username = value},
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '密码',
                    ),
                    onChanged: (value) => {this.password = value},
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  RaisedButton(
                    child: Text('登录'),
                    onPressed: () {
                      api('/deliveryman/login', {
                        'username': this.username,
                        'password': this.password
                      }, (data) async {
                        if (data['success']) {
                          SharedPreferences pers =
                              await SharedPreferences.getInstance();
                          pers.setString('token', data['token']);
                          Navigator.pushReplacementNamed(context, '/mainPage',
                              arguments: {'welcome': data['info']});
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Row(
                            children: [
                              Icon(Icons.close, color: Colors.red),
                              Text(data['info']),
                            ],
                          )));
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
