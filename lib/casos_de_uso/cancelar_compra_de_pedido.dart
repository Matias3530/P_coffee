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
/// Caso de uso: cancelar una compra/pedido.
/// Requisitos:
/// - El pedido debe existir.
/// - Sólo se puede cancelar si no está en estado ya finalizado (ej. 'entregado' o 'cancelado').
/// Acciones:
/// - Restaurar el stock de cada producto (usando ajustarStockProducto).
/// - Cambiar el estado del pedido a 'cancelado' usando cambiarEstadoPedido.
/// - Devolver el pedido actualizado en caso de éxito.
class CancelarCompraDePedido {
  final RepositorioPedidos repositorioPedidos;
  final RepositorioProductos repositorioProductos;

  CancelarCompraDePedido({
    required this.repositorioPedidos,
    required this.repositorioProductos,
  });

  Future<UseCaseResult<Pedido>> call(int idPedido) async {
    // Obtener pedido
    final pedido = await repositorioPedidos.obtenerPedidoPorId(idPedido);
    if (pedido == null) {
      return UseCaseResult.failure('Pedido con id $idPedido no encontrado.');
    }

    // Verificar estado
    final estadoActual = pedido.estado.toLowerCase();
    if (estadoActual == 'cancelado') {
      return UseCaseResult.failure('El pedido ya está cancelado.');
    }
    if (estadoActual == 'entregado' || estadoActual == 'finalizado' || estadoActual == 'cerrado') {
      return UseCaseResult.failure('No se puede cancelar un pedido que ya fue entregado o finalizado.');
    }

    // Restaurar stock
    for (final ItemPedido item in pedido.items) {
      try {
        final ok = await repositorioProductos.ajustarStockProducto(item.producto.id, item.cantidad);
        if (!ok) {
          return UseCaseResult.failure('Error al restaurar stock para el producto ${item.producto.id}.');
        }
      } catch (e) {
        return UseCaseResult.failure('Excepción al restaurar stock: $e');
      }
    }

    // Cambiar estado a 'cancelado'
    try {
      final changed = await repositorioPedidos.cambiarEstadoPedido(idPedido, 'cancelado');
      if (!changed) {
        return UseCaseResult.failure('Error al cambiar el estado del pedido.');
      }
    } catch (e) {
      return UseCaseResult.failure('Excepción al cambiar estado: $e');
    }

    // Recuperar pedido actualizado
    final pedidoActualizado = await repositorioPedidos.obtenerPedidoPorId(idPedido);
    if (pedidoActualizado == null) {
      return UseCaseResult.failure('Pedido no encontrado tras actualizar estado.');
    }

    return UseCaseResult.success(pedidoActualizado);
  }
}

