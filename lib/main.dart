import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'pantallas/pantalla_principal.dart';
import 'pantallas/pantalla_productos.dart';
import 'pantallas/pantalla_estado_pedidos.dart';
import 'pantallas/pantalla_seleccion_tipo_pedido.dart';
import 'pantallas/pantalla_nuevos_pedidos.dart';
import 'adaptadadores/adaptador_productos_pedidos.dart';
import 'gestores/productos_cubit.dart';
import 'gestores/pedidos_cubit.dart';
import 'gestores/compra_cubit.dart';
import 'casos_de_uso/compra_de_pedido.dart';
import 'casos_de_uso/cancelar_compra_de_pedido.dart';

final _adaptador = AdaptadorProductosPedidos();
final _compraUsecase = CompraDePedido(repositorioPedidos: _adaptador, repositorioProductos: _adaptador);
final _cancelarUsecase = CancelarCompraDePedido(repositorioPedidos: _adaptador, repositorioProductos: _adaptador);

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
		GoRoute(
			path: '/seleccionar-tipo-pedido',
			builder: (context, state) => PantallaSeleccionTipoPedido(),
		),
		GoRoute(
			path: '/nuevo-pedido',
			builder: (context, state) => PantallaNuevosPedidos(tipoPedido: state.extra as String?),
		),
	],
);

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MultiBlocProvider(
			providers: [
				BlocProvider<ProductosCubit>(
					create: (_) => ProductosCubit(repositorio: _adaptador),
				),
				BlocProvider<PedidosCubit>(
							create: (_) {
								final cubit = PedidosCubit(repositorio: _adaptador);
								cubit.setCancelarUsecase(_cancelarUsecase);
								return cubit;
							},
				),
				BlocProvider<CompraCubit>(
					create: (_) => CompraCubit(usecase: _compraUsecase),
				),
			],
			child: MaterialApp.router(
				routerConfig: _router,
				title: 'Cafetería',
				theme: ThemeData(
					primarySwatch: Colors.brown,
				),
			),
		);
	}
}
