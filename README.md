
# `YurePay`

### 1. `yure_payment_core`
- Contient les **interfaces principales** (`IPaymentProvider`, `IYurePaymentSdk`, etc.).
- Implémente la classe **`YurePayment`** : point d’entrée unique du SDK.
- Fournit un **backend simulé (`YurePayBackendService`)** pour gérer localement les transactions.
- Définit :
  - `PaymentRequest` → données envoyées par le commerçant.
  - `PaymentResult` → réponse d’un provider.
  - `PaymentStatus` → états d’une transaction (inProgress, succeeded, failed, canceled).
- Inclut des **providers de référence** (`MockProvider`, `VisaProvider`, …) pour simuler l’intégration de solutions réelles.

### 2. `yure_tips`
- Extension du core pour gérer les **tips (pourboires)**.
- Réutilise `yure_payment_core` pour initier et suivre les paiements de tips.
- Sert d’exemple de **feature construite au-dessus du SDK**.

### 3. `example`
- Petite app Flutter pour tester l’intégration des deux packages.
- Montre comment un commerçant peut initialiser le SDK, afficher les providers disponibles, et effectuer un paiement/tip.

### 4. `Modélisation`
- Trouvez la modélisation UML et l'architecture générale dans le dossier docs.


---

## 🚀 Fonctionnement général

1. **Le commerçant** crée un `PaymentRequest` avec son `merchantId`, le `provider` choisi, le montant et l’article.
2. `YurePayment` :
   - enregistre la transaction via `YurePayBackendService`,
   - délègue le traitement au **provider sélectionné**,
   - retourne immédiatement un **accusé de réception** avec l’`id` de transaction.
3. Le **provider** exécute le paiement (synchrone ou asynchrone).
4. Le backend local est mis à jour (succès, échec, annulation).
5. Le commerçant peut interroger le **statut** via l’API du SDK.

---

## ✨ Points clés

- **Extensible** : chaque nouveau provider se code dans une classe séparée implémentant `IPaymentProvider`.
- **Asynchrone** : retour immédiat au commerçant, avec suivi du statut par identifiant.
- **Découplé** : `yure_tips` prouve que n’importe quelle feature métier peut se greffer sur `yure_payment_core`.


---

## 🔧 Installation (dev)

Après avoir cloné le repo :

```bash
cd packages/yure_payment_core
flutter pub get

cd ../yure_tips
flutter pub get

cd ../../example
flutter pub get

```
Dans le dossier example, faire :

```bash
flutter run 
```