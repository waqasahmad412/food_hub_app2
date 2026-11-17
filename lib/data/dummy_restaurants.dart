import '../models/restaurant_model.dart';

/// Category keys shown as chips on the Home screen. "All" disables filtering.
const List<String> foodCategories = <String>[
  'All',
  'Pizza',
  'Burger',
  'Biryani',
  'Chinese',
  'Desi',
  'Fast Food',
  'Desserts',
  'Drinks',
];

/// Hardcoded sample restaurants powering the Browse Restaurants UI for now.
///
/// Field names match [Restaurant.toMap] so this list can later be uploaded
/// to (or replaced by) a Firestore `restaurants` collection without any
/// UI changes.
const List<Restaurant> dummyRestaurants = <Restaurant>[
  Restaurant(
    id: 'r1',
    name: 'Pizza Max',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
    cuisineType: 'Italian • Wood-fired Pizzas',
    rating: 4.5,
    deliveryTime: '25-35 min',
    category: 'Pizza',
  ),
  Restaurant(
    id: 'r2',
    name: 'Burger Lab',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
    cuisineType: 'American • Gourmet Burgers',
    rating: 4.7,
    deliveryTime: '20-30 min',
    category: 'Burger',
  ),
  Restaurant(
    id: 'r3',
    name: 'Karachi Biryani House',
    imageUrl:
        'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=800&q=80',
    cuisineType: 'Desi • Biryani & Pulao',
    rating: 4.8,
    deliveryTime: '30-40 min',
    category: 'Biryani',
  ),
  Restaurant(
    id: 'r4',
    name: 'Golden Dragon',
    imageUrl:
        'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800&q=80',
    cuisineType: 'Chinese • Noodles & Soup',
    rating: 4.4,
    deliveryTime: '35-45 min',
    category: 'Chinese',
  ),
  Restaurant(
    id: 'r5',
    name: 'Lahori Chargha Corner',
    imageUrl:
        'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&q=80',
    cuisineType: 'Desi • Curry & Tandoor',
    rating: 4.6,
    deliveryTime: '30-40 min',
    category: 'Desi',
  ),
  Restaurant(
    id: 'r6',
    name: 'Sweet Crush Bakery',
    imageUrl:
        'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800&q=80',
    cuisineType: 'Bakery • Desserts & Cakes',
    rating: 4.3,
    deliveryTime: '15-25 min',
    category: 'Desserts',
  ),
  Restaurant(
    id: 'r7',
    name: 'Chai Wala Cafe',
    imageUrl:
        'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&q=80',
    cuisineType: 'Cafe • Tea & Coffee',
    rating: 4.2,
    deliveryTime: '15-20 min',
    category: 'Drinks',
  ),
  Restaurant(
    id: 'r8',
    name: 'Kababjee BBQ Grill',
    imageUrl:
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
    cuisineType: 'Desi • BBQ & Kebabs',
    rating: 4.9,
    deliveryTime: '40-45 min',
    category: 'Desi',
  ),
  Restaurant(
    id: 'r9',
    name: 'Big Bite Burgers',
    imageUrl:
        'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80',
    cuisineType: 'Fast Food • Smashed Burgers',
    rating: 4.1,
    deliveryTime: '15-25 min',
    category: 'Burger',
  ),
  Restaurant(
    id: 'r10',
    name: 'Wok Express',
    imageUrl:
        'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&q=80',
    cuisineType: 'Chinese • Rice & Stir-fry',
    rating: 4.0,
    deliveryTime: '20-30 min',
    category: 'Chinese',
  ),
  Restaurant(
    id: 'r11',
    name: 'Crispy Fried Co.',
    imageUrl:
        'https://images.unsplash.com/photo-1562967914-608f82629710?w=800&q=80',
    cuisineType: 'Fast Food • Fried Chicken',
    rating: 4.4,
    deliveryTime: '15-25 min',
    category: 'Fast Food',
  ),
];

/// A small dummy menu per category so the details screen has realistic
/// content. Prices are in PKR. Replace with a Firestore query later.
List<MenuItem> dummyMenuFor(Restaurant restaurant) {
  switch (restaurant.category) {
    case 'Pizza':
      return const [
        MenuItem(
          name: 'Margherita Classic',
          price: 'PKR 1,199',
          description: 'Fresh mozzarella, basil & tomato sauce',
        ),
        MenuItem(
          name: 'Chicken Tikka Pizza',
          price: 'PKR 1,499',
          description: 'Desi tikka chunks, onion & green chillies',
        ),
        MenuItem(name: 'Pepperoni Feast', price: 'PKR 1,699'),
        MenuItem(name: 'Fajita Sicilian', price: 'PKR 1,599'),
        MenuItem(name: 'Garlic Bread Sticks', price: 'PKR 349'),
        MenuItem(name: 'Soft Drink (500ml)', price: 'PKR 120'),
      ];
    case 'Burger':
      return const [
        MenuItem(
          name: 'Zinger Stack',
          price: 'PKR 749',
          description: 'Crispy fillet, mayo & lettuce',
        ),
        MenuItem(
          name: 'Classic Beef Smash',
          price: 'PKR 849',
          description: 'Double smashed patty with cheddar',
        ),
        MenuItem(name: 'Double Decker', price: 'PKR 1,099'),
        MenuItem(name: 'Crispy Chicken Burger', price: 'PKR 649'),
        MenuItem(name: 'Loaded Fries', price: 'PKR 449'),
        MenuItem(name: 'Soft Drink (500ml)', price: 'PKR 120'),
      ];
    case 'Biryani':
      return const [
        MenuItem(
          name: 'Chicken Biryani',
          price: 'PKR 499',
          description: 'Served with raita & salad',
        ),
        MenuItem(name: 'Beef Biryani', price: 'PKR 599'),
        MenuItem(name: 'Special Karachi Biryani', price: 'PKR 749'),
        MenuItem(name: 'Extra Raita', price: 'PKR 99'),
        MenuItem(name: 'Cold Drink (500ml)', price: 'PKR 120'),
      ];
    case 'Chinese':
      return const [
        MenuItem(
          name: 'Chicken Chowmein',
          price: 'PKR 649',
          description: 'Stir-fried noodles with vegetables',
        ),
        MenuItem(name: 'Egg Fried Rice', price: 'PKR 549'),
        MenuItem(name: 'Chilli Chicken (Dry)', price: 'PKR 849'),
        MenuItem(name: 'Chicken Manchurian', price: 'PKR 799'),
        MenuItem(name: 'Hot & Sour Soup', price: 'PKR 399'),
        MenuItem(name: 'Spring Rolls (4 pcs)', price: 'PKR 349'),
      ];
    case 'Desi':
      return const [
        MenuItem(
          name: 'Lahori Chargha (Full)',
          price: 'PKR 899',
          description: 'Deep-fried marinated whole chicken',
        ),
        MenuItem(name: 'Chicken Karahi (Half)', price: 'PKR 1,199'),
        MenuItem(name: 'Seekh Kebab (4 pcs)', price: 'PKR 649'),
        MenuItem(name: 'Mutton Handi', price: 'PKR 1,699'),
        MenuItem(name: 'Butter Naan', price: 'PKR 60'),
        MenuItem(name: 'Fresh Salad', price: 'PKR 99'),
      ];
    case 'Fast Food':
      return const [
        MenuItem(
          name: 'Crispy Fried Chicken (2 pcs)',
          price: 'PKR 499',
          description: 'With dip of your choice',
        ),
        MenuItem(name: 'Zinger Paratha Roll', price: 'PKR 399'),
        MenuItem(name: 'Chicken Nuggets (6 pcs)', price: 'PKR 349'),
        MenuItem(name: 'Loaded Fries', price: 'PKR 449'),
        MenuItem(name: 'Coleslaw', price: 'PKR 149'),
      ];
    case 'Desserts':
      return const [
        MenuItem(
          name: 'Chocolate Lava Cake',
          price: 'PKR 549',
          description: 'Warm center with vanilla scoop',
        ),
        MenuItem(name: 'New York Cheesecake', price: 'PKR 699'),
        MenuItem(name: 'Brownie Sundae', price: 'PKR 599'),
        MenuItem(name: 'Mango Shake', price: 'PKR 349'),
        MenuItem(name: 'Gulab Jamun (4 pcs)', price: 'PKR 299'),
      ];
    case 'Drinks':
      return const [
        MenuItem(
          name: 'Doodh Patti Chai',
          price: 'PKR 149',
          description: 'Traditional slow-brewed milk tea',
        ),
        MenuItem(name: 'Kashmiri Chai', price: 'PKR 299'),
        MenuItem(name: 'Iced Latte', price: 'PKR 449'),
        MenuItem(name: 'Fresh Lime Soda', price: 'PKR 249'),
        MenuItem(name: 'Green Tea', price: 'PKR 129'),
      ];
    default:
      return const [
        MenuItem(name: 'Chef Special Platter', price: 'PKR 999'),
        MenuItem(name: 'Seasonal Special', price: 'PKR 749'),
        MenuItem(name: 'Beverage', price: 'PKR 120'),
        MenuItem(name: 'Side Order', price: 'PKR 249'),
        MenuItem(name: 'Dessert of the Day', price: 'PKR 349'),
      ];
  }
}
