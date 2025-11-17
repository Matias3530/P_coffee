import '../repositorios/repositorio_productos.dart';
import '../repositorios/repositorio_pedidos.dart';
import '../entidades/producto.dart';
import '../entidades/pedido.dart';
import 'database/databade_local.dart';

/// Adaptador que implementa los puertos de productos y pedidos usando SQLite.
class AdaptadorProductosPedidos implements RepositorioProductos, RepositorioPedidos {
  final DatabaseLocal _db = DatabaseLocal();

  // RepositorioProductos
  @override
  Future<Producto> agregarProducto(Producto producto) async {
    return await _db.insertProducto(producto);
  }

  @override
  Future<bool> actualizarDisponibilidad(int id, bool disponible) async {
    final p = await _db.getProductoById(id);
    if (p == null) return false;
    final updated = Producto(
      id: p.id,
      nombre: p.nombre,
      precio: p.precio,
      descripcion: p.descripcion,
      disponible: disponible,
      stock: p.stock,
    );
    return await _db.updateProducto(updated);
  }

  @override
  Future<bool> actualizarProducto(Producto producto) async {
    return await _db.updateProducto(producto);
  }

  @override
  Future<bool> eliminarProducto(int id) async {
    return await _db.deleteProducto(id);
  }

  @override
  Future<List<Producto>> listarProductos() async {
    return await _db.listProductos();
  }

  @override
  Future<List<Producto>> listarProductosDisponibles() async {
    final all = await _db.listProductos();
    return all.where((p) => p.disponible).toList();
  }

  @override
  Future<Producto?> obtenerProductoPorId(int id) async {
    return await _db.getProductoById(id);
  }

  /// Ajuste de stock: dado que el modelo `Producto` no contiene un campo de stock
  /// en esta versión, implementamos una operación limitada: si la diferencia es
  /// positiva se marca como disponible; si es negativa no cambiamos stock pero
  /// devolvemos true para indicar que la operación fue aceptada. Idealmente
  /// habría un campo `stock` en la entidad y en la BD.
  @override
  Future<bool> ajustarStockProducto(int id, int diferencia) async {
    // Usar la implementación real en DatabaseLocal
    return await _db.ajustarStock(id, diferencia);
  }

  // RepositorioPedidos
  @override
  Future<Pedido> agregarPedido(Pedido pedido) async {
    return await _db.insertPedido(pedido);
  }

  @override
  Future<bool> actualizarPedido(Pedido pedido) async {
    return await _db.updatePedido(pedido);
  }

  @override
  Future<bool> eliminarPedido(int id) async {
    return await _db.deletePedido(id);
  }

  @override
  Future<Pedido?> obtenerPedidoPorId(int id) async {
    return await _db.getPedidoById(id);
  }

  @override
  Future<List<Pedido>> listarPedidos() async {
    // Usamos un rango amplio para recuperar todos los pedidos
    final desde = DateTime.fromMillisecondsSinceEpoch(0);
    final hasta = DateTime(3000);
    return await _db.listPedidosBetweenDates(desde, hasta);
  }

  @override
  Future<List<Pedido>> listarPedidosPorEstado(String estado) async {
    final db = await _db.database;
    final rows = await db.query('pedidos', where: 'lower(estado) = ?', whereArgs: [estado.toLowerCase()]);
    final pedidos = <Pedido>[];
    for (final r in rows) {
      final id = r['id'] as int;
      final p = await obtenerPedidoPorId(id);
      if (p != null) pedidos.add(p);
    }
    return pedidos;
  }

  @override
  Future<List<Pedido>> listarPedidosEntreFechas(DateTime desde, DateTime hasta) async {
    return await _db.listPedidosBetweenDates(desde, hasta);
  }

  @override
  Future<bool> cambiarEstadoPedido(int idPedido, String nuevoEstado) async {
    final pedido = await _db.getPedidoById(idPedido);
    if (pedido == null) return false;
    final updated = Pedido(id: pedido.id, fecha: pedido.fecha, estado: nuevoEstado, items: pedido.items, total: pedido.total);
    return await _db.updatePedido(updated);
  }

  @override
  Future<double> totalVentasEntreFechas(DateTime desde, DateTime hasta) async {
    final pedidos = await _db.listPedidosBetweenDates(desde, hasta);
    double total = 0.0;
    for (final p in pedidos) {
      total += p.total;
    }
    return total;
  }
}
