import 'package:api_client/api_fonctions.dart';

void main() async {
  // Base URL for the server
  final String baseUrl = 'http://localhost:3000';

  // Add a new product
  final newProduct1 = {'name': 'Produit 1', 'price': 100, 'stock': 17, 'categorie': 'Categorie 1'};
  await addProduct(baseUrl, newProduct1);
  final newProduct2 = {'name': 'Produit 2', 'price': 75, 'stock': 42, 'categorie': 'Categorie 2'};
  await addProduct(baseUrl, newProduct2);
  final newProduct3 = {'name': 'Produit 3', 'price': 128, 'stock': 8, 'categorie': 'Categorie 1'};
  await addProduct(baseUrl, newProduct3);

  //fetch all products
  await getProducts(baseUrl);

  // Add a new order
  final newOrder1 = {'id': 1, 'products': {'Produit 1': 2, 'Produit 3': 4}, 'total': 712};
  await addOrder(baseUrl, newOrder1);
  final newOrder2 = {'id': 2, 'products': {'Produit 3': 3, 'Produit 2': 7}, 'total': 909};
  await addOrder(baseUrl, newOrder2);

  // fetch all orders
  await getOrders(baseUrl);
}