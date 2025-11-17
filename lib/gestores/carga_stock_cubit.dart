import 'package:bloc/bloc.dart';
import '../casos_de_uso/carga_de_stock_de_planilla.dart';

abstract class CargaStockState {}
class CargaStockInitial extends CargaStockState {}
class CargaStockLoading extends CargaStockState {}
class CargaStockSuccess extends CargaStockState {
  final CargaStockResult resultado;
  CargaStockSuccess(this.resultado);
}
class CargaStockFailure extends CargaStockState {
  final String message;
  CargaStockFailure(this.message);
}

class CargaStockCubit extends Cubit<CargaStockState> {
  final CargaDeStockDePlanilla usecase;
  CargaStockCubit({required this.usecase}) : super(CargaStockInitial());

  Future<void> ejecutarCarga(List<StockAdjustment> filas, {bool skipMissing = false}) async {
    emit(CargaStockLoading());
    try {
      final res = await usecase.ejecutar(filas, skipMissing: skipMissing);
      emit(CargaStockSuccess(res));
    } catch (e) {
      emit(CargaStockFailure('Error al procesar planilla: $e'));
    }
  }
}
