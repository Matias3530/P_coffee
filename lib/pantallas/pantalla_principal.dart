import 'package:flutter/material.dart';

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
							onTap: () => Navigator.pushNamed(context, '/productos'),
						),
						ListTile(
							title: Text('Estado de Pedidos'),
							onTap: () => Navigator.pushNamed(context, '/estado-pedidos'),
						),
					],
				),
			),
		);
	}
}
