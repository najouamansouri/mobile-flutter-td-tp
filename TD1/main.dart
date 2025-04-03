import 'Produit.dart';
import 'Commande.dart';

void main() {
  Produit lait = Produit("Lait", 8.5, 100, "Boissons");
  Produit pain = Produit("Pain", 3.0, 50, "Boulangerie");
  Produit oeufs = Produit("Œufs", 12.0, 30, "Produits frais");
  Produit pommes = Produit("Pommes", 5.0, 80, "Fruits");

  Set<Produit> produitsGlobal = {lait, pain, oeufs, pommes};
  //filtrer les produits coutant plus de 50 DH
  List<Produit> produitsCouteux = produitsGlobal.where((produit) => produit.prix > 50).toList();
  produitsCouteux.forEach((produit) => produit.afficherDetails());
  // trouver le roduit le plus cher
  Produit produitCher = produitsGlobal.reduce((prev, actuel) => prev.prix < actuel.prix ? actuel : prev);
  produitCher.afficherDetails();
  // les produits aprés appliquer la remise de 10%
  List<Produit> listeAvecRemise = appliquerRemise10("Phone", produitsGlobal);
  listeAvecRemise.forEach((produit) => produit.afficherDetails());
  // fonction de haut niveau
  transformerPrix(produitsGlobal, null, (prix) => prix * 0.95);

  Commande commande1 = Commande();
  Commande commande2 = Commande();
  Commande commande3 = Commande();
  try {
    commande1.ajouterProduit(lait, 2);
    commande1.ajouterProduit(pain, 1);
    commande2.ajouterProduit(oeufs, 1);
    commande2.ajouterProduit(pommes, 3);
    commande3.ajouterProduit(pain, 4);
    commande3.ajouterProduit(oeufs, 10);
    
    print("\n--------------");
    commande1.calculerTotal();
    commande1.afficherCommande();
    print("\n--------------");
    commande2.calculerTotal();
    commande2.afficherCommande();
    print("\n--------------");
    commande3.calculerTotal();
    commande3.afficherCommande();
    print("\n--------------");
  } catch (e) {
    print("Erreur : $e");
  }
}