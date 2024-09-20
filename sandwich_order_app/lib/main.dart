import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Order App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Order App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/sandwichhh.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Order Sandwich',
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CustomerNameScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Select Sandwich'),
                  ),
                ],
              ),
            ),
          ),
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Expanded(
                child: cart.customerOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders yet',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.customerOrders.length,
                        itemBuilder: (context, index) {
                          final customerName =
                              cart.customerOrders.keys.elementAt(index);
                          final order = cart.customerOrders[customerName]!;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            child: ListTile(
                              title: Text(
                                customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              subtitle: Text(
                                '${order.length} item(s) - Total: \$${cart.getTotalForCustomer(customerName).toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerOrderScreen(
                                        customerName: customerName),
                                  ),
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  cart.removeCustomer(customerName);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return ElevatedButton(
                onPressed: cart.customerOrders.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRCodePage()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color.fromARGB(255, 230, 230, 230),
                 
                ),
                child: const Text('Proceed to Payment'),
                
              );
            },
          ),
        ],
      ),
    );
  }
}


class CustomerNameScreen extends StatelessWidget {
  const CustomerNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Customer Name'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SandwichPage(customerName: controller.text),
                    ),
                  );
                }
              },
              child: const Text('Continue to Select Sandwich'),
            ),
          ],
        ),
      ),
    );
  }
}


class CartModel extends ChangeNotifier {
  final Map<String, List<Sandwich>> _customerOrders = {};

  Map<String, List<Sandwich>> get customerOrders => _customerOrders;

  void addToCart(String customerName, Sandwich sandwich) {
    if (!_customerOrders.containsKey(customerName)) {
      _customerOrders[customerName] = [];
    }
    _customerOrders[customerName]!.add(sandwich);
    notifyListeners();
  }

  void removeFromCart(String customerName, Sandwich sandwich) {
    _customerOrders[customerName]!.remove(sandwich);
    if (_customerOrders[customerName]!.isEmpty) {
      _customerOrders.remove(customerName);
    }
    notifyListeners();
  }

  void removeCustomer(String customerName) {
    _customerOrders.remove(customerName);
    notifyListeners();
  }

  void clearCart() {
    _customerOrders.clear();
    notifyListeners();
  }

  double getTotalForCustomer(String customerName) {
    return _customerOrders[customerName]!
        .fold(0, (sum, item) => sum + item.price);
  }

  double get totalPrice {
    return _customerOrders.values
        .expand((order) => order)
        .fold(0, (sum, item) => sum + item.price);
  }
}



class Sandwich {
  final String name;
  final double price;
  final String image;
  final String type;

  Sandwich(
      {required this.name,
      required this.price,
      required this.image,
      required this.type});
}

class CustomerOrderScreen extends StatelessWidget {
  final String customerName;

  const CustomerOrderScreen({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$customerName\'s Order'),
        centerTitle: true,
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          final order = cart.customerOrders[customerName] ?? [];
          return ListView.builder(
            itemCount: order.length,
            itemBuilder: (context, index) {
              final sandwich = order[index];
              return Card(
                child: ListTile(
                  leading: Image.asset(sandwich.image, width: 80, height: 80),
                  title: Text(sandwich.name),
                  subtitle: Text('\$${sandwich.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      cart.removeFromCart(customerName, sandwich);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer QR Codes'),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return ListView.builder(
            itemCount: cart.customerOrders.length,
            itemBuilder: (context, index) {
              final customerName = cart.customerOrders.keys.elementAt(index);
              final totalAmount = cart.getTotalForCustomer(customerName);
              
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: \$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/qrMayur.jpg',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          cart.removeCustomer(customerName);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$customerName\'s order has been completed')),
                          );
                        },
                        child: const Text('Complete Order'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SandwichPage extends StatefulWidget {
  final String customerName;

  const SandwichPage({super.key, required this.customerName});

  @override
  // ignore: library_private_types_in_public_api
  _SandwichPageState createState() => _SandwichPageState();
}

class _SandwichPageState extends State<SandwichPage> {
  final Map<String, List<Sandwich>> sandwichCategories = {
    'Vegetarian': [
      Sandwich(
          name: 'Veg Delight',
          price: 5.0,
          image: 'assets/sandwichhh.png',
          type: 'Vegetarian'),
      Sandwich(
          name: 'Cheese Veggie',
          price: 5.5,
          image: 'assets/sandwichhh.png',
          type: 'Vegetarian'),
    ],
    'Non-Vegetarian': [
      Sandwich(
          name: 'Chicken Classic',
          price: 7.0,
          image: 'assets/sandwichhh.png',
          type: 'Non-Vegetarian'),
      Sandwich(
          name: 'Turkey Club',
          price: 7.5,
          image: 'assets/sandwichhh.png',
          type: 'Non-Vegetarian'),
    ],
    'Vegan': [
      Sandwich(
          name: 'Vegan Supreme',
          price: 6.0,
          image: 'assets/sandwichhh.png',
          type: 'Vegan'),
      Sandwich(
          name: 'Avocado Delight',
          price: 6.5,
          image: 'assets/sandwichhh.png',
          type: 'Vegan'),
    ],
  };

String selectedCategory = 'Vegetarian';
  final _toastMessages = <Widget>[];
  final Map<String, int> _sandwichCounts = {};

  @override
  void initState() {
    super.initState();
    // Initialize sandwich counts
    for (var category in sandwichCategories.values) {
      for (var sandwich in category) {
        _sandwichCounts[sandwich.name] = 0;
      }
    }
  }

  void _showToast(String message) {
    setState(() {
      _toastMessages.add(_buildToastMessage(message));
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (_toastMessages.isNotEmpty) {
          _toastMessages.removeAt(0);
        }
      });
    });
  }

  Widget _buildToastMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Sandwiches for ${widget.customerName}'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sandwichCategories.keys.length,
                  itemBuilder: (context, index) {
                    final category = sandwichCategories.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sandwichCategories[selectedCategory]!.length,
                  itemBuilder: (context, index) {
                    final sandwich =
                        sandwichCategories[selectedCategory]![index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading:
                            Image.asset(sandwich.image, width: 80, height: 80),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                sandwich.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (_sandwichCounts[sandwich.name]! > 0)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '+${_sandwichCounts[sandwich.name]}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${sandwich.type}'),
                            Text(
                                'Price: \$${sandwich.price.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          child: const Text('Add'),
                          onPressed: () {
                            Provider.of<CartModel>(context, listen: false)
                                .addToCart(widget.customerName, sandwich);
                            setState(() {
                              _sandwichCounts[sandwich.name] =
                                  (_sandwichCounts[sandwich.name] ?? 0) + 1;
                            });
                            _showToast(
                                '${sandwich.name} added to ${widget.customerName}\'s order');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _toastMessages,
            ),
          ),
        ],
      ),
    );
  }
}
