# Bherliane Mhae S. Mallari
## INF233
## CTADMOBL Advanced Mobile Programming

A Flutter Project that focuses on advance topics. Covering the web to mobile transactions

## Lab Activity Instance

## Lab Activity 1: Discussion

After doing this activity, I learned how state management works in Flutter and why it is important for updating the user interface. I used Ephemeral State with setState() to manage the counter because it only belongs to a single screen. I also learned to use App State with the Provider package to manage the application's theme across multiple screens. The main difference is that ephemeral state is temporary and local to a widget, while app state is shared and can affect the entire application. Overall, this activity helped me understand when to use setState() for simple local changes and Provider for managing shared data more efficiently and I also learned how the light and dark mode was made in some apps.


## Lab Activity 2: Discussion

From what I learned and observed, The model keeps the product information from the API organized so the app can easily use it. Then the service is the part that connects to the API, gets the product data, and sends it to the app. For the screen, it takes the information and shows the products to the user. In doing this activity, the app is divided into different parts like models, services, screens, providers, and widgets. Each part has its own job, which makes the code easier to understand and manage. This also helps the app work properly with features like searching for products, viewing product details, and changing the theme.

## Lab Activity 3: Discussion

After doing this activity, I learned how to create a Cart model and CartService to get and manage cart data from the DummyJSON API. I also learned how the CartScreen displays the data and handles loading and errors using FutureBuilder. This activity helped me understand the importance of separating the model, service, and screen so the code is more organized and easier to manage. I also learned how to get a specific cart using its ID and reuse the existing DetailScreen to view product details.

## Lab Activity 4: Discussion

From this lab activity, I was able to gain a better understanding of how the different parts of the application work together to manage and display data. The application uses a simple structure where the User Model, User Service, and Screens work together to manage and display user information. The User Model represents the data received from the API, such as the user ID, username, email, first name, last name, gender, and profile picture. The UserService is responsible for handling the API authentication and saving the user information locally using SharedPreferences. After the user successfully logs in, the saved information can be accessed by the ProfileScreen through the UserService and displayed on the profile page. For the cart feature, the saved user ID is used to identify the cart that belongs to the logged-in user. The CartService uses the user ID to request the correct cart data from the API, while the CartScreen displays the products and other cart details. Overall, this lab activity helped me understand how separating the Models, Services, and Screens makes the application more organized, easier to manage, and able to display the correct user and cart information.

## Lab Activity 5: Discussion

After doing the laboratory activity, I observed that the workflow of DummyJSON and Firebase in the Flutter application is different, but they work together to provide a complete authentication process. For the Sign In process, the application first checks the user’s credentials using DummyJSON, and if the account is not found, it can also check Firebase Authentication for users who registered through the Sign Up page. During Sign Up, the user enters their personal information, username, email, and password, which are saved through Firebase Authentication and Firestore. The main purpose of the UserService is to keep all the authentication and user-related functions in one place, such as signing in, creating an account, signing out, updating the username, changing the password, deleting an account, and getting user information, instead of putting these functions directly in the different screens. Firebase helps improve the Flutter application because it provides a more reliable way to manage registered users and their authentication details, while Firestore can store other information like the user’s name, age, contact number, and username. Overall, adding Firebase makes the application more complete because it allows users to create and manage real accounts while still using the existing DummyJSON authentication process.

## Long Exam Part 2: Discussion

After doing the long exam enhancements, these are the realizations and learnings I had. The application follows a straightforward architecture in which the Models, Services, and Screens work together to handle and present data. The Models, including User, Post, and Comment, describe the data structure and transform JSON responses from the API into Dart objects that can be easily accessed and used within the application. The Services, such as UserService, PostService, and CommentService, are responsible for communicating with the API. They send requests, process the responses, and convert the received data into the corresponding Models. Meanwhile, the Screens, including LoginScreen, NewsFeedScreen, ProfileScreen, and DetailScreen, interact with the Services to retrieve or submit information and then use the Models to present the data through the application's widgets. Overall, the data flows in the order of API → Services → Models → Screens → UI, resulting in a code structure that is organized, reusable, and easier to maintain.