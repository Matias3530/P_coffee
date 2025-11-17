import '../repositorios/repositorio_productos.dart';

/// DTO para una fila de la planilla: ajuste de stock por producto.
class StockAdjustment {
  final int productoId;
  final int diferencia; // positivo para sumar, negativo para restar

  StockAdjustment({required this.productoId, required this.diferencia});
}

/// Resultado por fila
class StockAdjustmentResult {
  final StockAdjustment fila;
  final bool success;
  final String? message;

  StockAdjustmentResult({required this.fila, required this.success, this.message});
}

/// Resultado del caso de uso: resumen de la carga
class CargaStockResult {
  final int total;
  final int exitosos;
  final int fallidos;
  final List<StockAdjustmentResult> detalles;

  CargaStockResult({
    required this.total,
    required this.exitosos,
    required this.fallidos,
    required this.detalles,
  });
}

/// Caso de uso: aplicar una planilla de ajustes de stock.
///
/// Reglas:
/// - Cada fila indica un producto (por id) y una diferencia (int).
/// - Se intentará aplicar cada ajuste llamando a `ajustarStockProducto`.
/// - Si un producto no existe o la llamada falla, la fila queda como fallida.
class CargaDeStockDePlanilla {
  final RepositorioProductos repositorioProductos;

  CargaDeStockDePlanilla({required this.repositorioProductos});

  /// Ejecuta la carga. Devuelve un resumen con detalles por fila.
  Future<CargaStockResult> ejecutar(List<StockAdjustment> filas, {bool skipMissing = false}) async {
    final List<StockAdjustmentResult> detalles = [];
    int exitosos = 0;
    int fallidos = 0;

    for (final fila in filas) {
      try {
        // Verificar existencia (repositorio puede lanzar o devolver null en obtener)
        final producto = await repositorioProductos.obtenerProductoPorId(fila.productoId);
        if (producto == null) {
          if (skipMissing) {
            detalles.add(StockAdjustmentResult(fila: fila, success: false, message: 'Producto no encontrado, fila saltada'));
            fallidos++;
            continue;
          } else {
            detalles.add(StockAdjustmentResult(fila: fila, success: false, message: 'Producto no encontrado'));
            fallidos++;
            continue;
          }
        }

        final ok = await repositorioProductos.ajustarStockProducto(fila.productoId, fila.diferencia);
        if (ok) {
          detalles.add(StockAdjustmentResult(fila: fila, success: true));
          exitosos++;
        } else {
          detalles.add(StockAdjustmentResult(fila: fila, success: false, message: 'Fallo al aplicar ajuste'));
          fallidos++;
        }
      } catch (e) {
        detalles.add(StockAdjustmentResult(fila: fila, success: false, message: 'Excepción: $e'));
        fallidos++;
      }
    }

    return CargaStockResult(
      total: filas.length,
      exitosos: exitosos,
      fallidos: fallidos,
      detalles: detalles,
    );
  }
}
