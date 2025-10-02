/// Enumération des statuts possibles d'un paiement
///
/// Représente le cycle de vie complet d'une transaction
enum PaymentStatus {
  /// Paiement en cours de traitement par le provider
  inProgress,

  /// Paiement traité avec succès, fonds transférés
  succeeded,

  /// Paiement annulé par l'utilisateur ou le marchand
  canceled,

  /// Paiement refusé par le provider ou erreur technique
  failed,
}
