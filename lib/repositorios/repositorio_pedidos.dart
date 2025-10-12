import '../entidades/pedido.dart';

abstract class RepositorioPedidos {
  Future<bool> agregarPedido(Pedido pedido);
  Future<Pedido?> obtenerPedidoPorId(int id);
  Future<List<Pedido>> listarPedidos();
  Future<bool> actualizarPedido(Pedido pedido);
  Future<bool> eliminarPedido(int id);
}




/*Casos de uso

AgregarProducto

ListarProductos

CrearPedido

CerrarPedido

ObtenerReporteDiario
*/