import '../models/stock.dart';

class StockService {
  // Mock stock data
  Future<List<Stock>> getStocks() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Stock(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 150.0,
        change: 2.5,
        changePercent: 1.69,
      ),
      Stock(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        price: 2800.0,
        change: -15.0,
        changePercent: -0.53,
      ),
      Stock(
        symbol: 'MSFT',
        name: 'Microsoft Corporation',
        price: 300.0,
        change: 5.0,
        changePercent: 1.69,
      ),
    ];
  }

  Future<Stock?> getStock(String symbol) async {
    final stocks = await getStocks();
    return stocks.firstWhere((stock) => stock.symbol == symbol);
  }
}