import 'package:bloc/bloc.dart';
import '../repositorios/repositorio_pedidos.dart';

class ReporteVentas {
  final double totalVentas;
  final int totalPedidos;
  final double ticketPromedio;
  final Map<DateTime, double> ventasPorDia;
  ReporteVentas({required this.totalVentas, required this.totalPedidos, required this.ticketPromedio, required this.ventasPorDia});
}

abstract class ReportesState {}
class ReportesInitial extends ReportesState {}
class ReportesLoading extends ReportesState {}
class ReportesLoadSuccess extends ReportesState {
  final ReporteVentas reporte;
  ReportesLoadSuccess(this.reporte);
}
class ReportesFailure extends ReportesState {
  final String message;
  ReportesFailure(this.message);
}

class ReportesCubit extends Cubit<ReportesState> {
  final RepositorioPedidos repositorioPedidos;
  ReportesCubit({required this.repositorioPedidos}) : super(ReportesInitial());

  Future<void> generarReporte(DateTime desde, DateTime hasta) async {
    emit(ReportesLoading());
    try {
      final pedidos = await repositorioPedidos.listarPedidosEntreFechas(desde, hasta);
      double total = 0.0;
      final Map<DateTime, double> porDia = {};
      for (final p in pedidos) {
        total += p.total;
        final dia = DateTime(p.fecha.year, p.fecha.month, p.fecha.day);
        porDia[dia] = (porDia[dia] ?? 0.0) + p.total;
      }
      final totalPedidos = pedidos.length;
      final ticket = totalPedidos > 0 ? total / totalPedidos : 0.0;
      final reporte = ReporteVentas(totalVentas: total, totalPedidos: totalPedidos, ticketPromedio: ticket, ventasPorDia: porDia);
      emit(ReportesLoadSuccess(reporte));
    } catch (e) {
      emit(ReportesFailure('Error al generar reporte: $e'));
    }
  }
}
