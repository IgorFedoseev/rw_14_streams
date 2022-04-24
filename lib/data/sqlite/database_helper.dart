import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static const _databaseName = 'MyRecipes.db';
  static const _databaseVersion = 1;

  static const recipeTable = 'Recipe';
  static const ingredientTable = 'Ingredient';
  static const recipeId = 'recipeId';
  static const ingredientId = 'ingredientId';

  static late BriteDatabase _streamDatabase;

  DatabaseHelper._privatConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privatConstructor();

  static var lock = Lock();

  static Database? _database;

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $recipeTable (
    $recipeId INTEGER PRIMARY KEY,
    label TEXT,
    image TEXT,
    url TEXT,
    calories REAL,
    totalWeight REAL,
    totalTime REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE $ingredientTable (
    $ingredientId INTEGER PRIMARY KEY,
    $recipeId INTEGER,
    name TEXT,
    weight REAL
    )
    ''');
  }

// this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, _databaseName);

    // TODO: Remember to turn off debugging before deploying app to store(s).
    Sqflite.setDebugModeOn(true);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<Database> get database async{
    final database = _database;
    if(database != null) return database;
    // Use this object to prevent concurrent access to data
    await lock.synchronized(() async {
      // lazily instantiate the db the first time it is accessed
      if(_database == null) {
        _database = await _initDatabase();
        _streamDatabase = BriteDatabase(_database!);
      }
    });
    return _database!;
  }

// TODO: Add getter for streamDatabase
}
