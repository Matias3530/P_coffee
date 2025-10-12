import '../entidades/producto.dart';

abstract class RepositorioProductos {
  Future<bool> agregarProducto(Producto producto);
  Future<Producto?> obtenerProductoPorId(int id);
  Future<List<Producto>> listarProductos();
  Future<bool> actualizarProducto(Producto producto);
  Future<bool> eliminarProducto(int id);
}
