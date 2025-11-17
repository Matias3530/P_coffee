import '../entidades/pedido.dart';
import '../entidades/item_pedido.dart';
import '../repositorios/repositorio_pedidos.dart';
import '../repositorios/repositorio_productos.dart';

class UseCaseResult<T> {
  final bool success;
  final T? data;
  final String? message;
  UseCaseResult._(this.success, this.data, this.message);
  factory UseCaseResult.success(T data) => UseCaseResult._(true, data, null);
  factory UseCaseResult.failure(String message) => UseCaseResult._(false, null, message);
}

class CompraDePedido {
  final RepositorioPedidos repositorioPedidos;
  final RepositorioProductos repositorioProductos;

  CompraDePedido({
    required this.repositorioPedidos,
    required this.repositorioProductos,
  });

  Future<UseCaseResult<Pedido>> call(Pedido pedido) async {
    if (pedido.items.isEmpty) {
      return UseCaseResult.failure('El pedido no contiene items.');
    }

    double total = 0.0;
    final List<ItemPedido> itemsProcesados = [];

    for (final item in pedido.items) {
      final productoId = item.producto.id;
      final producto = await repositorioProductos.obtenerProductoPorId(productoId);

      if (producto == null) {
        return UseCaseResult.failure('Producto con id $productoId no encontrado.');
      }

      if (!producto.disponible) {
        return UseCaseResult.failure('Producto "${producto.nombre}" no disponible.');
      }

      // Validar stock
      if (producto.stock < item.cantidad) {
        return UseCaseResult.failure('Stock insuficiente para "${producto.nombre}" (tiene ${producto.stock}, pedido ${item.cantidad}).');
      }

      final subtotal = producto.precio * item.cantidad;
      total += subtotal;

      itemsProcesados.add(ItemPedido(
        id: item.id,
        producto: producto,
        cantidad: item.cantidad,
        subtotal: subtotal,
      ));
    }

    final pedidoAguardar = Pedido(
      id: pedido.id,
      fecha: pedido.fecha,
      estado: 'pendiente',
      items: itemsProcesados,
      total: total,
    );

    try {
      final Pedido pedidoGuardado = await repositorioPedidos.agregarPedido(pedidoAguardar);
      return UseCaseResult.success(pedidoGuardado);
    } catch (e) {
      return UseCaseResult.failure('Error al guardar el pedido: $e');
    }
  }
}
