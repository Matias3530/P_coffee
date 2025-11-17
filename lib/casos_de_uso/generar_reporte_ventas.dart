import '../entidades/item_pedido.dart';
import '../repositorios/repositorio_pedidos.dart';

/// Resultado genérico para casos de uso locales.
class UseCaseResult<T> {
  final bool success;
  final T? data;
  final String? message;
  UseCaseResult._(this.success, this.data, this.message);
  factory UseCaseResult.success(T data) => UseCaseResult._(true, data, null);
  factory UseCaseResult.failure(String message) => UseCaseResult._(false, null, message);
}

class TopProducto {
  final int productoId;
  final String nombre;
  int cantidad;
  double totalVendido;

  TopProducto({required this.productoId, required this.nombre, this.cantidad = 0, this.totalVendido = 0.0});
}

class VentaPorDia {
  final DateTime fecha;
  final double total;
  VentaPorDia({required this.fecha, required this.total});
}

class ReporteVentas {
  final double totalVentas;
  final int totalPedidos;
  final double ticketPromedio;
  final List<TopProducto> topProductos;
  final List<VentaPorDia> ventasPorDia;

  ReporteVentas({required this.totalVentas, required this.totalPedidos, required this.ticketPromedio, required this.topProductos, required this.ventasPorDia});
}

/// Caso de uso: generar reporte de ventas entre dos fechas.
class GenerarReporteVentas {
  final RepositorioPedidos repositorioPedidos;

  GenerarReporteVentas({required this.repositorioPedidos});

  /// Ejecuta el reporte entre [desde] y [hasta]. Devuelve UseCaseResult con ReporteVentas.
  Future<UseCaseResult<ReporteVentas>> ejecutar(DateTime desde, DateTime hasta, {String? estadoFiltro, int topN = 10}) async {
    if (desde.isAfter(hasta)) return UseCaseResult.failure('Rango de fechas inválido: desde > hasta');

    try {
      final pedidos = await repositorioPedidos.listarPedidosEntreFechas(desde, hasta);

      // Filtrar por estado si se indicó
      final pedidosFiltrados = (estadoFiltro == null || estadoFiltro.trim().isEmpty)
          ? pedidos
          : pedidos.where((p) => p.estado.toLowerCase() == estadoFiltro.toLowerCase()).toList();

      double totalVentas = 0.0;
      final Map<int, TopProducto> productosMap = {};
      final Map<DateTime, double> ventasPorDiaMap = {};

      for (final p in pedidosFiltrados) {
        totalVentas += p.total;
        final dia = DateTime(p.fecha.year, p.fecha.month, p.fecha.day);
        ventasPorDiaMap[dia] = (ventasPorDiaMap[dia] ?? 0.0) + p.total;

        for (final ItemPedido it in p.items) {
          final pid = it.producto.id;
          final nombre = it.producto.nombre;
          final entry = productosMap.putIfAbsent(pid, () => TopProducto(productoId: pid, nombre: nombre));
          entry.cantidad += it.cantidad;
          entry.totalVendido += it.subtotal;
        }
      }

      final totalPedidos = pedidosFiltrados.length;
      final ticketPromedio = totalPedidos > 0 ? totalVentas / totalPedidos : 0.0;

      // Top productos ordenados por cantidad o por totalVendido (aquí por totalVendido)
      final topProductos = productosMap.values.toList()
        ..sort((a, b) => b.totalVendido.compareTo(a.totalVendido));

      final ventasPorDia = ventasPorDiaMap.entries
          .map((e) => VentaPorDia(fecha: e.key, total: e.value))
          .toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

      final reporte = ReporteVentas(
        totalVentas: totalVentas,
        totalPedidos: totalPedidos,
        ticketPromedio: ticketPromedio,
        topProductos: topProductos.take(topN).toList(),
        ventasPorDia: ventasPorDia,
      );

      return UseCaseResult.success(reporte);
    } catch (e) {
      return UseCaseResult.failure('Error al generar reporte: $e');
    }
  }
}
