import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pantallas/pantalla_principal.dart';
import 'pantallas/pantalla_productos.dart';
import 'pantallas/pantalla_estado_pedidos.dart';

void main() {
	runApp(MyApp());
}

final GoRouter _router = GoRouter(
	routes: [
		GoRoute(
			path: '/',
			builder: (context, state) => PantallaPrincipal(),
		),
		GoRoute(
			path: '/productos',
			builder: (context, state) => PantallaProductos(),
		),
		GoRoute(
			path: '/estado-pedidos',
			builder: (context, state) => PantallaEstadoPedidos(),
		),
	],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp.router(
			routerConfig: _router,
			title: 'Cafetería',
			theme: ThemeData(
				primarySwatch: Colors.brown,
			),
		);
	}
}
