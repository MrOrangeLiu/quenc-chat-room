class User {
  String id;
  String name;
  String imageUrl;
  bool unread;

  User({
    this.id,
    this.name,
    this.imageUrl,
    this.unread,
  });

  User.toObject(String id, String name, String imageUrl) {
    this.id = id;
    this.name = name;
    this.imageUrl = imageUrl;
  }

  User.forGroup(String id, String name, String imageUrl, bool unread) {
    this.id = id;
    this.name = name;
    this.imageUrl = imageUrl;
    this.unread = unread;
  }

  User.fromJson(Map data) {
    this.id = data['id'];
    this.name = data['name'];
    this.imageUrl = data['imageUrl'];
  }

  User.fromList(List<dynamic> data) {
    this.id = data[0];
    this.name = data[1];
    this.imageUrl = data[2];
  }

  Map<String, dynamic> toJson(String id, String name, String imageUrl) {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
    };
  }

  Map<String, dynamic> convertToMap() {
    return {
      id: {
        "name": name,
        "imageUrl": imageUrl,
        "unread": true,
      }
    };
  }

  /*
  * {id: {'name': a@a.com, 'imageUrl': 'images/greg.jpg', 'unread': true}, ...}
  * */
  static Map<String, dynamic> combineToMap(List<User> users) {
    Map<String, dynamic> mapValue = {}; // Remember to initialize the map
    for (var user in users) {
//      print('User IDDDDD:' + user.id);
      mapValue[user.id] = {
        'name': user.name,
        'imageUrl': user.imageUrl,
        'unread':
            user.unread ?? false, // If unread is null than set it to false
      };
    }
//    print(mapValue.toString());
    return mapValue;
  }
}
