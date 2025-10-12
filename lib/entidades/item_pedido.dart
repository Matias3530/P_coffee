import 'producto.dart';

class ItemPedido {
	final int id;
	final Producto producto;
	final int cantidad;
	final double subtotal;

	ItemPedido({
		required this.id,
		required this.producto,
		required this.cantidad,
		required this.subtotal,
	});
}
