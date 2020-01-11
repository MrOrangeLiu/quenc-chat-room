import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoScreen extends StatelessWidget {
  String url;
  FullPhotoScreen({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Full Photo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildFullPhotoView(url: url),
    );
  }
}

class _buildFullPhotoView extends StatefulWidget {
  final String url;
  _buildFullPhotoView({this.url});
  @override
  __buildFullPhotoViewState createState() => __buildFullPhotoViewState();
}

class __buildFullPhotoViewState extends State<_buildFullPhotoView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: NetworkImage(widget.url),
    ));
  }
}
