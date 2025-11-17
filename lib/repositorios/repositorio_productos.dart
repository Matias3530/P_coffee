import '../entidades/producto.dart';

abstract class RepositorioProductos {
  // Operaciones CRUD básicas
  Future<Producto> agregarProducto(Producto producto);
  Future<Producto?> obtenerProductoPorId(int id);
  Future<List<Producto>> listarProductos();
  Future<bool> actualizarProducto(Producto producto);
  Future<bool> eliminarProducto(int id);

  // Operaciones adicionales útiles para casos de uso
  Future<List<Producto>> listarProductosDisponibles();
  Future<bool> ajustarStockProducto(int id, int diferencia);
  Future<bool> actualizarDisponibilidad(int id, bool disponible);
}
