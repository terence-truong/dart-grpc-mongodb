import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  Db? _db;

  Future<void> close() async {
    if (_db != null) {
      await _db?.close();
    }
  }

  Future<Db> getConnection() async {
    var db = Db('mongodb://db:27017/iron');
    await db.open();
    _db = db;
    return _db!;
  }
}
