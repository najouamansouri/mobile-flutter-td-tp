import 'Produit.dart';
import 'exceptions.dart';

class Commande {
  late int id;
  Map<Produit, int> produits = {};
  double total = 0.0;
  static int lastInsertId = 0;
  
  Commande(){
    id = ++lastInsertId;
  }

  void ajouterProduit(Produit produit, int quantite) {
    if(produit.stock < quantite) {
      throw StockInsuffisantException();
    }
    produits.putIfAbsent(produit, () => quantite);
    produit.stock -= quantite;
  }

  void calculerTotal() {
    produits.forEach((produit, quantite) => total += quantite * produit.prix);
  }

  void afficherCommande() {
    if(produits.isEmpty) {
      throw CommandeVideException();
    }
    print("Bilan de commande :");
    print("ID : $id");
    produits.entries.map((element) {
      return " -> " + element.key.nom + " ------------ " + element.value.toString() + " unité(s)";
    }).forEach(print);
    print("Total : $total DH");
  }
}