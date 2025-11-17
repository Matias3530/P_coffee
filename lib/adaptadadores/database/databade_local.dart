import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../entidades/producto.dart';
import '../../entidades/pedido.dart';
import '../../entidades/item_pedido.dart';

class DatabaseLocal {
  static final DatabaseLocal _instance = DatabaseLocal._internal();
  factory DatabaseLocal() => _instance;
  DatabaseLocal._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('pcoffee.db');
    return _db!;
  }

  Future<String> _getDbPath(String dbName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    return path;
  }

  Future<Database> _initDB(String fileName) async {
    final path = await _getDbPath(fileName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // agregar columna stock a productos
          await db.execute('ALTER TABLE productos ADD COLUMN stock INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        descripcion TEXT,
        disponible INTEGER NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        estado TEXT NOT NULL,
        total REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items_pedido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
        FOREIGN KEY (producto_id) REFERENCES productos(id)
      )
    ''');
  }

  // Productos CRUD
  Future<Producto> insertProducto(Producto p) async {
    final db = await database;
    final id = await db.insert('productos', {
      'nombre': p.nombre,
      'precio': p.precio,
      'descripcion': p.descripcion,
      'disponible': p.disponible ? 1 : 0,
      'stock': p.stock,
    });
  return Producto(id: id, nombre: p.nombre, precio: p.precio, descripcion: p.descripcion, disponible: p.disponible, stock: p.stock);
    
  }

  Future<Producto?> getProductoById(int id) async {
    final db = await database;
    final maps = await db.query('productos', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final m = maps.first;
    return Producto(
      id: m['id'] as int,
      nombre: m['nombre'] as String,
      precio: (m['precio'] as num).toDouble(),
      descripcion: m['descripcion'] as String? ?? '',
      disponible: (m['disponible'] as int) == 1,
      stock: (m['stock'] as int?) ?? 0,
    );
  }

  Future<List<Producto>> listProductos() async {
    final db = await database;
    final maps = await db.query('productos');
    return maps.map((m) => Producto(
      id: m['id'] as int,
      nombre: m['nombre'] as String,
      precio: (m['precio'] as num).toDouble(),
      descripcion: m['descripcion'] as String? ?? '',
      disponible: (m['disponible'] as int) == 1,
      stock: (m['stock'] as int?) ?? 0,
    )).toList();
  }

  Future<bool> updateProducto(Producto p) async {
    final db = await database;
    final rows = await db.update('productos', {
      'nombre': p.nombre,
      'precio': p.precio,
      'descripcion': p.descripcion,
      'disponible': p.disponible ? 1 : 0,
      'stock': p.stock,
    }, where: 'id = ?', whereArgs: [p.id]);
    return rows > 0;
  }

  Future<bool> deleteProducto(int id) async {
    final db = await database;
    final rows = await db.delete('productos', where: 'id = ?', whereArgs: [id]);
    return rows > 0;
  }

  // Pedidos CRUD (y manejo de items)
  Future<Pedido> insertPedido(Pedido pedido) async {
    final db = await database;
    // Insertar pedido y items en transacción; además decrementar stock de productos
    return await db.transaction<Pedido>((txn) async {
      final id = await txn.insert('pedidos', {
        'fecha': pedido.fecha.toIso8601String(),
        'estado': pedido.estado,
        'total': pedido.total,
      });

      for (final item in pedido.items) {
        await txn.insert('items_pedido', {
          'pedido_id': id,
          'producto_id': item.producto.id,
          'cantidad': item.cantidad,
          'subtotal': item.subtotal,
        });

        // decrementar stock
        await txn.execute('UPDATE productos SET stock = stock - ? WHERE id = ?', [item.cantidad, item.producto.id]);
      }

      return Pedido(id: id, fecha: pedido.fecha, estado: pedido.estado, items: pedido.items, total: pedido.total);
    });
  }

  Future<Pedido?> getPedidoById(int id) async {
    final db = await database;
    final maps = await db.query('pedidos', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final m = maps.first;
    final itemsMaps = await db.query('items_pedido', where: 'pedido_id = ?', whereArgs: [id]);
    final items = <ItemPedido>[];
    for (final im in itemsMaps) {
      final producto = await getProductoById(im['producto_id'] as int);
      if (producto == null) continue; // skip if product missing
      items.add(ItemPedido(
        id: im['id'] as int,
        producto: producto,
        cantidad: im['cantidad'] as int,
        subtotal: (im['subtotal'] as num).toDouble(),
      ));
    }
    return Pedido(
      id: m['id'] as int,
      fecha: DateTime.parse(m['fecha'] as String),
      estado: m['estado'] as String,
      items: items,
      total: (m['total'] as num).toDouble(),
    );
  }

  Future<List<Pedido>> listPedidosBetweenDates(DateTime desde, DateTime hasta) async {
    final db = await database;
    final desdeStr = desde.toIso8601String();
    final hastaStr = hasta.toIso8601String();
    final maps = await db.rawQuery(
      'SELECT * FROM pedidos WHERE fecha >= ? AND fecha <= ?',
      [desdeStr, hastaStr],
    );
    final pedidos = <Pedido>[];
    for (final m in maps) {
      final id = m['id'] as int;
      final pedido = await getPedidoById(id);
      if (pedido != null) pedidos.add(pedido);
    }
    return pedidos;
  }

  Future<bool> updatePedido(Pedido pedido) async {
    final db = await database;
    final rows = await db.update('pedidos', {
      'fecha': pedido.fecha.toIso8601String(),
      'estado': pedido.estado,
      'total': pedido.total,
    }, where: 'id = ?', whereArgs: [pedido.id]);

    // actualizar items: simplificación -> eliminar existentes y reinsertar
    await db.delete('items_pedido', where: 'pedido_id = ?', whereArgs: [pedido.id]);
    for (final item in pedido.items) {
      await db.insert('items_pedido', {
        'pedido_id': pedido.id,
        'producto_id': item.producto.id,
        'cantidad': item.cantidad,
        'subtotal': item.subtotal,
      });
    }

    return rows > 0;
  }

  // Ajustar stock (positivo = sumar, negativo = restar)
  Future<bool> ajustarStock(int productoId, int diferencia) async {
    final db = await database;
    final res = await db.rawUpdate('UPDATE productos SET stock = stock + ? WHERE id = ?', [diferencia, productoId]);
    return res > 0;
  }

  Future<bool> deletePedido(int id) async {
    final db = await database;
    final rows = await db.delete('pedidos', where: 'id = ?', whereArgs: [id]);
    return rows > 0;
  }

  // Util: cerrar DB
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
