import 'dart:io';
import 'dart:typed_data';
import 'package:serenity/server/class_serenity_user.dart';
import 'package:sqlite3/sqlite3.dart';

class SerenityDatabase {
  // Tables
  static final String _userTable =
      "CREATE TABLE users(id INTEGER NOT NULL PRIMARY KEY, uuid TEXT, name TEXT, icon BLOB, banner BLOB, verified BOOL) STRICT";
  static final String _channelTable =
      "CREATE TABLE channeluuid(id INTEGER NOT NULL PRIMARY KEY, uuid TEXT, name TEXT, type TEXT) STRICT";
  static final String _serverConfigTable =
      "CREATE TABLE serverconfig(id INTEGER NOT NULL PRIMARY KEY, config TEXT) STRICT";
  static final String _messagesTable =
      "CREATE TABLE messages(id INTEGER NOT NULL PRIMARY KEY, uuid TEXT, message TEXT, user_uuid TEXT)";

  // Public Queries

  static final String _userInsertSQL =
      "INSERT INTO users (uuid, name, icon, banner, verified) VALUES (?, ?, ?, ?, ?)";
  static final String _userUpdateSQL =
      "UPDATE users SET name = ?, icon = ?, banner = ? WHERE uuid = ?";
  static final String _userDeleteSQL = "DELETE from users WHERE uuid = ?";
  static final String _messageInsertSQL =
      "INSERT INTO messages (uuid, message, user_uuid) VALUES (?, ?, ?)";
  static final String _messageUpdateSQL =
      "UPDATE messages SET message = ? WHERE uuid = ? AND user_uuid = ?";
  static final String _messageDeleteSQL =
      "DELETE from messages WHERE uuid = ? AND user_uuid = ?";

  /// Initializes the database with the tables needed to run
  /// the serenity server
  static void _initDatabase(Database db) {
    db.execute(_userTable);
    db.execute(_channelTable);
    db.execute(_serverConfigTable);
    db.execute(_messagesTable);
  }

  /// Compiles the publicly exposed queries
  static List<PreparedStatement> _prepareSQL(Database db) {
    String multiQuery =
        "$_userInsertSQL;$_userUpdateSQL;$_userDeleteSQL;$_messageInsertSQL;$_messageUpdateSQL;$_messageDeleteSQL";

    return db.prepareMultiple(multiQuery, persistent: true);
  }

  // Constructors

  /// This is the Default Constructor for the DB. The normal constructor should not be used
  ///
  /// This constructor takes in a File, creates the file if it does not exist, initializes the tables
  /// and prepares the public facing sql queries.
  factory SerenityDatabase.fromFile(File dbFile) {
    Database db;
    bool created = false;

    // Check if we need to create the DB file
    if (!dbFile.existsSync()) {
      dbFile.createSync();
      created = true;
    }

    db = sqlite3.open(dbFile.path);

    // Init if the file was just created
    if (created) {
      _initDatabase(db);
    }

    // Prepare public queries
    List<PreparedStatement> queries = _prepareSQL(db);

    return SerenityDatabase(db, queries[0], queries[1], queries[2], queries[3],
        queries[4], queries[5]);
  }

  SerenityDatabase(
    this.db,
    this._userInsert,
    this._userUpdate,
    this._userDelete,
    this._messageInsert,
    this._messageUpdate,
    this._messageDelete,
  );

  // Variables

  final Database db;

  /// Parameter Order: uuid, name, icon, banner, verified
  final PreparedStatement _userInsert;

  /// Parameter Order: name, icon, banner, WHERE uuid
  final PreparedStatement _userUpdate;

  /// Parameter Order: WHERE uuid
  final PreparedStatement _userDelete;

  /// Parameter Order: uuid, message, user_uuid
  final PreparedStatement _messageInsert;

  /// Parameter Order: message WHERE uuid AND user_uuid
  final PreparedStatement _messageUpdate;

  /// Parameter Order: WHERE uuid AND user_uuid
  final PreparedStatement _messageDelete;

  // Methods

  String getServerConfig() {
    ResultSet configSet = db.select("SELECT config FROM serverconfig");
    return configSet[0]["config"];
  }

  /// Queries the sqlite database and builds a list of SerenityUsers.
  List<SerenityUser> getUsers() {
    List<SerenityUser> userList = [];
    ResultSet userSet = db.select("SELECT * FROM users");

    for (Row row in userSet) {
      SerenityUser user = SerenityUser(
          row["uuid"], row["name"], Uint8List.view(row["icon"]), row["banner"]);
      userList.add(user);
    }

    return userList;
  }

  /// Queries the sqlite database and returns a list of all channel uuids
  List<String> getChannelUuids() {
    List<String> uuidList = [];

    ResultSet uuidSet = db.select("SELECT * FROM channeluuid");
    for (Row row in uuidSet) {
      uuidList.add(row["uuid"]);
    }

    return uuidList;
  }

  void insertUser(SerenityUser user) {
    _userInsert.execute(
        [user.userID, user.userName, user.userIcon, user.userBanner, false]);
  }

  void updateUser(SerenityUser user) {
    _userUpdate
        .execute([user.userName, user.userIcon, user.userBanner, user.userID]);
  }

  void deleteUser(SerenityUser user) {
    _userDelete.execute([user.userID]);
  }

  void insertMessage(String uuid, String message, SerenityUser user) {
    _messageInsert.execute([uuid, message, user.userID]);
  }

  void updateMessage(String message, String uuid, SerenityUser user) {
    _messageUpdate.execute([message, uuid, user.userID]);
  }

  void deleteMessage(String uuid, SerenityUser user) {
    _messageDelete.execute([uuid, user.userID]);
  }
}
