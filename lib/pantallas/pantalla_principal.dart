import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Pantalla Principal')),
			body: Center(child: Text('Bienvenido a la Cafetería')),
			drawer: Drawer(
				child: ListView(
					children: [
						ListTile(
							title: Text('Productos'),
							onTap: () => context.push('/productos'),
						),
						ListTile(
							title: Text('Estado de Pedidos'),
							onTap: () => context.push('/estado-pedidos'),
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				icon: Icon(Icons.add_shopping_cart),
				label: Text('Agregar pedido'),
				onPressed: () {
					// Navega a la pantalla donde se selecciona cómo se desea el pedido
					context.push('/seleccionar-tipo-pedido');
				},
			),
		);
	}
}
