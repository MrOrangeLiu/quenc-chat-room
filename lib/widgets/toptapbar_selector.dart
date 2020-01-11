import 'package:flutter/material.dart';

class TopTapBarSelector extends StatefulWidget {
  int currentIndex;
  Function onTap;

  TopTapBarSelector({this.currentIndex, this.onTap});
  @override
  _TopTapBarSelectorState createState() => _TopTapBarSelectorState();
}

class _TopTapBarSelectorState extends State<TopTapBarSelector> {
  final List<String> options = ['Messages', ' My Contacts'];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => widget.onTap(index),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Text(
                  options[index],
                  style: TextStyle(
                    color: index == widget.currentIndex
                        ? Colors.white
                        : Colors.white60,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
