import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';
import 'order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _databaseName = 'users.db'; // Pastikan nama database benar
  static const _databaseVersion = 1;

  // User Table
  static const table = 'users';
  static const columnId = 'id';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnRole = 'role';
  static const columnFoto = 'foto';

  // Order Table
  static const _orderTable = 'orders';
  static const _orderColumnId = 'id';
  static const _orderColumnCustomerName = 'customerName';
  static const _orderColumnTotalPrice = 'totalPrice';
  static const _orderColumnOrderDate = 'orderDate';
  static const _orderColumnStatus = 'status';
  static const _orderColumnNomorFaktur = 'nomorFaktur';
  static const _orderColumnFotoProdukURL = 'fotoProdukURL';
  static const _orderColumnFotoProgressURL = 'fotoProgressURL';

  // Order Item Table
  static const _orderItemTable = 'orderItems';
  static const _orderItemColumnId = 'id';
  static const _orderItemColumnOrderId =
      'orderId'; // Foreign key ke tabel orders
  static const _orderItemColumnProductName = 'productName';
  static const _orderItemColumnQuantity = 'quantity';
  static const _orderItemColumnPrice = 'price';
  static const _orderItemColumnFotoProduk = 'fotoProduk';
  static const _orderItemColumnFotoProgress = 'fotoProgress';

  Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnEmail TEXT NOT NULL,
      $columnPassword TEXT NOT NULL,
      $columnRole TEXT NOT NULL,
      $columnFoto TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE $_orderTable (
      $_orderColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $_orderColumnCustomerName TEXT NOT NULL,
      $_orderColumnTotalPrice REAL NOT NULL,
      $_orderColumnOrderDate TEXT NOT NULL,
      $_orderColumnStatus TEXT NOT NULL,
      $_orderColumnNomorFaktur TEXT,
      $_orderColumnFotoProdukURL TEXT,
      $_orderColumnFotoProgressURL TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE $_orderItemTable (
      $_orderItemColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $_orderItemColumnOrderId INTEGER NOT NULL,
      $_orderItemColumnProductName TEXT NOT NULL,
      $_orderItemColumnQuantity INTEGER NOT NULL,
      $_orderItemColumnPrice REAL NOT NULL,
      $_orderItemColumnFotoProduk TEXT,
      $_orderItemColumnFotoProgress TEXT,
      FOREIGN KEY ($_orderItemColumnOrderId) REFERENCES $_orderTable ($_orderColumnId)
    )
  ''');
    await db.insert(table, {
      columnEmail: 'admin@melintu.com',
      columnPassword: 'password', //
      columnRole: 'admin',
      columnFoto: 'default.png'
    });
  }

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<bool> isAdmin(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result =
        await db.query(table, where: '$columnEmail = ?', whereArgs: [email]);

    if (result.isNotEmpty && result.first['role'] == 'admin') {
      return true;
    }
    return false;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps =
        await db.query(table, where: '$columnEmail = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<User?> getUserProfile(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user', // Replace with your table name
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllCustomers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnRole != ?',
      whereArgs: ['admin'],
    );
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }
  // order

  Future<int> insertOrder(Order order) async {
    Database db = await instance.database;
    String orderDateIso = order.orderDate.toIso8601String();
    return await db.insert(_orderTable, {
      _orderColumnCustomerName: order.customerName,
      _orderColumnTotalPrice: order.totalPrice,
      _orderColumnOrderDate: orderDateIso,
      _orderColumnStatus: order.status,
      _orderColumnNomorFaktur: order.nomorFaktur,
      _orderColumnFotoProdukURL: order.fotoProdukURL,
      _orderColumnFotoProgressURL: order.fotoProgressURL,
    });
  }

  Future<List<Order>> getAllOrders() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(_orderTable);
    return List.generate(maps.length, (i) {
      DateTime orderDate = DateTime.parse(maps[i][_orderColumnOrderDate]);
      return Order(
        id: maps[i][_orderColumnId],
        customerName: maps[i][_orderColumnCustomerName],
        totalPrice: maps[i][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[i][_orderColumnStatus],
        nomorFaktur: maps[i][_orderColumnNomorFaktur],
        fotoProdukURL: maps[i][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[i][_orderColumnFotoProgressURL],
        items: [], // Kamu perlu mengambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    });
  }

  Future<Order?> getOrderById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderTable,
      where: '$_orderColumnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      DateTime orderDate = DateTime.parse(maps[0][_orderColumnOrderDate]);
      return Order(
        id: maps[0][_orderColumnId],
        customerName: maps[0][_orderColumnCustomerName],
        totalPrice: maps[0][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[0][_orderColumnStatus],
        nomorFaktur: maps[0][_orderColumnNomorFaktur],
        fotoProdukURL: maps[0][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[0][_orderColumnFotoProgressURL],
        items: [], // Kamu perlu mengambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    }
    return null;
  }

  Future<int> updateOrder(Order order) async {
    Database db = await instance.database;
    String orderDateIso = order.orderDate.toIso8601String();
    return await db.update(
      _orderTable,
      {
        _orderColumnCustomerName: order.customerName,
        _orderColumnTotalPrice: order.totalPrice,
        _orderColumnOrderDate: orderDateIso,
        _orderColumnStatus: order.status,
        _orderColumnNomorFaktur: order.nomorFaktur,
        _orderColumnFotoProdukURL: order.fotoProdukURL,
        _orderColumnFotoProgressURL: order.fotoProgressURL,
      },
      where: '$_orderColumnId = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    Database db = await instance.database;
    return await db.delete(
      _orderTable,
      where: '$_orderColumnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertOrderItem(OrderItem item, int orderId) async {
    Database db = await instance.database;
    return await db.insert(_orderItemTable, {
      _orderItemColumnOrderId: orderId,
      _orderItemColumnProductName: item.productName,
      _orderItemColumnQuantity: item.quantity,
      _orderItemColumnPrice: item.price,
      _orderItemColumnFotoProduk: item.fotoProduk,
      _orderItemColumnFotoProgress: item.fotoProgress,
    });
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderItemTable,
      where: '$_orderItemColumnOrderId = ?',
      whereArgs: [orderId],
    );
    return List.generate(maps.length, (i) {
      return OrderItem(
        productName: maps[i][_orderItemColumnProductName],
        quantity: maps[i][_orderItemColumnQuantity],
        price: maps[i][_orderItemColumnPrice],
        fotoProduk: maps[i][_orderItemColumnFotoProduk],
        fotoProgress: maps[i][_orderItemColumnFotoProgress],
      );
    });
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderTable,
      where: '$_orderColumnStatus = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) {
      DateTime orderDate = DateTime.parse(maps[i][_orderColumnOrderDate]);
      return Order(
        id: maps[i][_orderColumnId],
        customerName: maps[i][_orderColumnCustomerName],
        totalPrice: maps[i][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[i][_orderColumnStatus],
        nomorFaktur: maps[i][_orderColumnNomorFaktur],
        fotoProdukURL: maps[i][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[i][_orderColumnFotoProgressURL],
        items: [], // Kamu perlu mengambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    });
  }
}
