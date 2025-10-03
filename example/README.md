# Example App - YureTips & YurePayment

Cet exemple montre comment utiliser les librairies **YureTips** et **YurePayment** 
dans un projet Flutter.  
Il simule la création de transactions avec un provider de paiement 
et la gestion des pourboires (`tips`).

---

## 🚀 Prérequis

- [Flutter 3.35.4+](https://docs.flutter.dev/get-started/install)  
- Dart 3.9.2+  
- Un émulateur Android/iOS ou un device physique connecté  

---

## 📦 Installation

1. Clone le repo :
   ```bash
   git clone https://github.com/ton-org/ton-projet.git
 

2. Récupérer les dépendances
    Dépuis la racide du projet, dans votre terminal, faire :
        cd example
        flutter pub get
        cd ..
        cd yure_payment_core
        flutter pub get
        cd .. yure_tips
        flutter pub get

3. Lance l’application example:
    N.B : Au préalable, se mettre dans le dossier example
        flutter run 

## Structure

lib/ → Code source de l’app exemple

yure_payment_core/ → Package interne pour la gestion des paiements

yure_tips/ → Package interne pour la gestion des tips.
Il dépend aussi de yure_payment_core

