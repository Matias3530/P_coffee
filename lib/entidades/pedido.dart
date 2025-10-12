import 'item_pedido.dart';

class Pedido {
	final int id;
	final DateTime fecha;
	final String estado;
	final List<ItemPedido> items;
	final double total;

	Pedido({
		required this.id,
		required this.fecha,
		required this.estado,
		required this.items,
		required this.total,
	});
}
