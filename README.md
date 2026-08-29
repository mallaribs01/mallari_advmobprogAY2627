# Bherliane Mhae S. Mallari
## INF233
## CTADMOBL Advanced Mobile Programming

A Flutter Project that focuses on advance topics. Covering the web to mobile transactions

## Lab Activity Instance

## Lab Activity 1: Discussion

After doing this activity, I learned how state management works in Flutter and why it is important for updating the user interface. I used Ephemeral State with setState() to manage the counter because it only belongs to a single screen. I also learned to use App State with the Provider package to manage the application's theme across multiple screens. The main difference is that ephemeral state is temporary and local to a widget, while app state is shared and can affect the entire application. Overall, this activity helped me understand when to use setState() for simple local changes and Provider for managing shared data more efficiently and I also learned how the light and dark mode was made in some apps.


## Lab Activity 2: Discussion

From what I learned and observed, The model keeps the product information from the API organized so the app can easily use it. Then the service is the part that connects to the API, gets the product data, and sends it to the app. For the screen, it takes the information and shows the products to the user. In doing this activity, the app is divided into different parts like models, services, screens, providers, and widgets. Each part has its own job, which makes the code easier to understand and manage. This also helps the app work properly with features like searching for products, viewing product details, and changing the theme.

## Long Exam Part 2: Discussion

After doing the long exam enhancements, these are the realizations and learnings I had. The application follows a straightforward architecture in which the Models, Services, and Screens work together to handle and present data. The Models, including User, Post, and Comment, describe the data structure and transform JSON responses from the API into Dart objects that can be easily accessed and used within the application. The Services, such as UserService, PostService, and CommentService, are responsible for communicating with the API. They send requests, process the responses, and convert the received data into the corresponding Models. Meanwhile, the Screens, including LoginScreen, NewsFeedScreen, ProfileScreen, and DetailScreen, interact with the Services to retrieve or submit information and then use the Models to present the data through the application's widgets. Overall, the data flows in the order of API → Services → Models → Screens → UI, resulting in a code structure that is organized, reusable, and easier to maintain.