import 'dart:developer';
import 'package:animation/model/spending_Model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/database_model.dart';

class DbHelper {
  DbHelper._();

  static DbHelper dbHelper = DbHelper._();

  Database? database;

  Future<void> initializeDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "database.db");
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        String categoryQuery = """
          CREATE TABLE IF NOT EXISTS Category (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_name TEXT NOT NULL,
            category_image BLOB
          )
        """;
        db.execute(categoryQuery);
        log("Categoty Database Created successfully...");

        String spendingQuery =
            "CREATE TABLE IF NOT EXISTS spending(spending_id INTEGER PRIMARY KEY AUTOINCREMENT, spending_amount NUMERIC NOT NULL, spending_type TEXT NOT NULL, spending_category INTEGER NOT NULL);";
        await db.execute(spendingQuery);

        log("==========");
        log("Spending Table created successfully");
        log("==========");
      },
    );
  }

  Future<int> insertData({required CategoryModel model}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = """
      INSERT INTO Category (category_name, category_image)
      VALUES (?, ?);
    """;
    List<dynamic> arguments = [model.name, model.image];
    return database!.rawInsert(query, arguments);
  }

  Future<List<CategoryModel>> fetchData() async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = """
      SELECT * FROM Category;
    """;
    List<Map<String, dynamic>> data = await database!.rawQuery(query);
    List<CategoryModel> models = data
        .map(
          (e) => CategoryModel(
            id: e['id'],
            name: e['category_name'],
            image: e['category_image'],
          ),
        )
        .toList();
    return models;
  }

  Future<int> deleteData({required int id}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = """
    DELETE FROM Category WHERE id = ?;
    """;
    List<int> argument = [id];
    log("Data deleted successfully... ::::::: $id");
    return database!.rawDelete(query, argument);
  }

  Future<int> updateData({required CategoryModel model}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = """
      UPDATE Category SET category_name = ?,
      category_image = ?
      WHERE id = ?;
    """;
    List<dynamic> args = [model.name, model.image, model.id];
    log("Data updated successfully...");
    return database!.rawUpdate(query, args);
  }

  Future<List<CategoryModel>> searchCategory({required String data}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = "SELECT * FROM Category WHERE category_name LIKE '%$data%';";
    List<Map<String, dynamic>> searchCategory = await database!.rawQuery(query);

    List<CategoryModel> allSearchCategory =
        searchCategory.map((e) => CategoryModel.fromMap(data: e)).toList();
    return allSearchCategory;
  }

  Future<int> insertSpending({required SpendingModel spending}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query =
        "INSERT INTO spending(spending_amount, spending_type, spending_category) VALUES(?,?,?);";
    List args = [
      spending.spending_amount,
      spending.spending_type,
      spending.spending_category,
    ];

    int res = await database!.rawInsert(query, args);
    return res;
  }

  Future<List<SpendingModel>> fetchAllSpending() async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = "SELECT * FROM spending;";
    List<Map<String, dynamic>> allRecords = await database!.rawQuery(query);

    List<SpendingModel> allSpending = allRecords
        .map((Map<String, dynamic> e) => SpendingModel.fromMap(data: e))
        .toList();

    return allSpending;
  }

  Future<CategoryModel> findCategory({required int id}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = "SELECT * FROM Category WHERE id=?;";
    List args = [id];

    List<Map<String, dynamic>> foundedCategory =
        await database!.rawQuery(query, args);

    List<CategoryModel> category = foundedCategory
        .map((Map<String, dynamic> e) => CategoryModel.fromMap(data: e))
        .toList();

    return category[0];
  }

  Future<int> deleteSpending({required int spending_id}) async {
    if (database == null) {
      await initializeDatabase();
    }

    String query = "DELETE FROM spending WHERE spending_id = ?";
    List args = [spending_id];
    int res = await database!.rawDelete(query, args);

    log("Data deleted successfully... $spending_id");
    return res;
  }

  // update spending (spendingList)
  Future<int> updateSpendingData({required SpendingModel model}) async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = """
    UPDATE spending SET spending_category = ?,
    spending_amount = ?,
    spending_type = ?
    WHERE spending_id = ?;
  """;
    List<dynamic> args = [
      model.spending_category,
      model.spending_amount,
      model.spending_type,
      model.spending_id
    ];
    int res = await database!.rawUpdate(query, args);
    log("Data updated successfully...");
    return res;
  }

  // fetch updated category (spendingList)
  Future<List<SpendingModel>> fetchSpendingData() async {
    if (database == null) {
      await initializeDatabase();
    }
    String query = """
    SELECT * FROM spending;
  """;
    List<Map<String, dynamic>> data = await database!.rawQuery(query);
    List<SpendingModel> models = data
        .map((e) => SpendingModel(
              spending_id: e['spending_id'],
              spending_amount: e['spending_amount'],
              spending_type: e['spending_type'],
              spending_category: e['spending_category'],
            ))
        .toList();
    return models;
  }
}
