# Shopping List (Basic)

Shopping List is a Flutter app that helps you with your weekly shopping! You can add items on your screen with the fitting category, like meat or vegetable, and the ammount you need to by. This code was produced during the completion of the Flutter course [A Complete Guide to the Flutter SDK & Flutter Framework for building native iOS and Android apps](https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/learn/lecture/37130436#overview).

## Basic functionality
- Displaying a list of shopping items.
- Adding new items to the list.
- Removing items from the list.
- Validating user input.

### Screenshots 
<div align="center">
  <img src="empty_list.png" alt="Start screen without items" width="200"/>
  <img src="adding_item.png" alt="Form to input new items" width="200"/>
  <img src="invalid_input.png" alt="Throwing errors when the input isn't valid" width="200"/>
  <img src="filled_list.png" alt="Example shopping list with dummy items" width="200"/>
</div>

### Example walkthrough
<div align="center">
  <img src="walkthrough.gif" alt="Walkthrough" width="200"/>
</div>

## Topics covered (Branch Basic)

- Used the Form widget to be able to include more specific functionality for user inputs in forms.
- Learned about the validator function and used it to validate user input.
- Used TextFormField and DorpdownButtonFormField for more specific functionalities.
- Used a GlobalKey to keep the internal state and not rebuild the underlying widegt which was the form widget.
- Used the GlobalKey to save user input.