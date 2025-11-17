import '../entidades/pedido.dart';
import '../repositorios/repositorio_pedidos.dart';

/// Resultado simple para los casos de uso locales.
class UseCaseResult<T> {
  final bool success;
  final T? data;
  final String? message;
  UseCaseResult._(this.success, this.data, this.message);
  factory UseCaseResult.success(T data) => UseCaseResult._(true, data, null);
  factory UseCaseResult.failure(String message) => UseCaseResult._(false, null, message);
}

/// Caso de uso: consultar estado de pedido y listados por estado.
class ConsultarEstadoDePedido {
  final RepositorioPedidos repositorioPedidos;

  ConsultarEstadoDePedido({required this.repositorioPedidos});

  /// Consultar un pedido por su id.
  Future<UseCaseResult<Pedido>> call(int idPedido) async {
    if (idPedido <= 0) return UseCaseResult.failure('Id de pedido inválido');
    try {
      final pedido = await repositorioPedidos.obtenerPedidoPorId(idPedido);
      if (pedido == null) return UseCaseResult.failure('Pedido no encontrado');
      return UseCaseResult.success(pedido);
    } catch (e) {
      return UseCaseResult.failure('Error al consultar pedido: $e');
    }
  }

  /// Listar pedidos cuyo estado coincida con [estado] (case-insensitive).
  Future<UseCaseResult<List<Pedido>>> listarPorEstado(String estado) async {
    if (estado.trim().isEmpty) return UseCaseResult.failure('Estado vacío');
    try {
      final lista = await repositorioPedidos.listarPedidosPorEstado(estado);
      return UseCaseResult.success(lista);
    } catch (e) {
      return UseCaseResult.failure('Error al listar pedidos por estado: $e');
    }
  }
}

