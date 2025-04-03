class StockInsuffisantException implements Exception {
  final String message;  
  StockInsuffisantException([this.message = "Le stock est insuffisant."]);
  @override
  String toString() => "StockInsuffisantException: $message";
}

class CommandeVideException implements Exception {
  final String message;
  CommandeVideException([this.message = "La commande est vide."]);
  @override
  String toString() => "CommandeVideException: $message";
}