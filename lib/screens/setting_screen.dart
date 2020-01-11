import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OrangeChat/models/user_model.dart';
import 'package:OrangeChat/screens/home_screen.dart';

class SettingScreen extends StatefulWidget {
  static const String id = 'setting_screen';
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SharedPreferences prefs;

  String id = '';
  String name = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    name = prefs.getString('name') ?? '';
    imageUrl = prefs.getString('imageUrl') ?? 'images/greg.jpg';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 82.0,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
          ),
          Positioned(
            top: 75.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45.5),
                  topRight: Radius.circular(45.5),
                ),
                color: Colors.white,
              ),
              height: MediaQuery.of(context).size.height - 100.0,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Positioned(
            top: 30.0,
            left: (MediaQuery.of(context).size.width / 2) - 100.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200.0,
              width: 200.0,
            ),
          ),
          Positioned(
            top: 260.0,
            left: 25.0,
            right: 25.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
//                  color: Colors.red,
                  child: Text(name,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                SizedBox(height: 30.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
