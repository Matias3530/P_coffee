import '../entidades/pedido.dart';

abstract class RepositorioPedidos {
  // Operaciones CRUD básicas
  Future<Pedido> agregarPedido(Pedido pedido);
  Future<Pedido?> obtenerPedidoPorId(int id);
  Future<List<Pedido>> listarPedidos();
  Future<bool> actualizarPedido(Pedido pedido);
  Future<bool> eliminarPedido(int id);

  // Consultas y operaciones útiles para casos de uso
  Future<List<Pedido>> listarPedidosPorEstado(String estado);
  Future<List<Pedido>> listarPedidosEntreFechas(DateTime desde, DateTime hasta);
  Future<bool> cambiarEstadoPedido(int idPedido, String nuevoEstado);
  Future<double> totalVentasEntreFechas(DateTime desde, DateTime hasta);
}




/*Casos de uso

AgregarProducto

ListarProductos

CrearPedido

CerrarPedido

ObtenerReporteDiario
*/