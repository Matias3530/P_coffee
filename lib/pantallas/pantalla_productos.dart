import 'package:flutter/material.dart';

class PantallaProductos extends StatelessWidget {
  const PantallaProductos({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Productos')),
			body: Center(child: Text('Listado de productos')),
		);
	}
}
