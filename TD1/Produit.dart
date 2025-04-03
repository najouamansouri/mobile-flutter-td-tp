class Produit {
  String nom;
  double prix;
  int stock;
  String categorie;
  Produit (this.nom, this.prix, this.stock, this.categorie);
  void afficherDetails() {
    print("Détails du produit :");
    print("Nom: $nom\nPrix: $prix DH\nStock: $stock unité(s)\nCatégorie: $categorie\n");
  }
}

Produit? rechercherProduitParNom(String nom, Set<Produit> produitsGlobal) {
  if(produitsGlobal.contains(nom)) {
    for(Produit prod in produitsGlobal) {
      if(prod.nom == nom) return prod;
    }
  }
  return null;
}

List<Produit> appliquerRemise10(String categorie, Set<Produit> produitsGlobal) {
  return produitsGlobal.map((produit) {
    if(produit.categorie == categorie) produit.prix *= 0.9;
    return produit;
  }).toList();
}

void transformerPrix(Set<Produit> produitsGlobal, String? categorie, double Function(double) transformer){
  produitsGlobal.forEach((produit) {
    if(categorie != null) {
      if(produit.categorie == categorie) produit.prix = transformer(produit.prix);
    } else produit.prix = transformer(produit.prix);
  });
}