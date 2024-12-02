import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LuggageRegistrationPage extends StatefulWidget {
  const LuggageRegistrationPage({super.key});

  @override
  LuggageRegistrationPageState createState() => LuggageRegistrationPageState();
}

class LuggageRegistrationPageState extends State<LuggageRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController luggageDescriptionController = TextEditingController();
  final TextEditingController luggageSizeController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientPhoneController = TextEditingController();
  final TextEditingController recipientIdController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Checkbox state for fragile luggage
  bool isFragile = false;

  // County and Sub-County data
  final Map<String, List<String>> counties = {
    'Nairobi': ['Westlands', 'Kasarani', 'Embakasi', 'Langata', 'Kibra'],
    'Mombasa': ['Kisauni', 'Nyali', 'Likoni', 'Mvita', 'Changamwe'],
    'Kisumu': ['Kisumu East', 'Kisumu West', 'Kisumu Central', 'Seme', 'Nyakach'],
    'Kiambu': ['Kikuyu', 'Limuru', 'Thika Town', 'Kiambu', 'Juja', 'Ruiru'],
    'Nakuru': ['Nakuru East', 'Nakuru West', 'Naivasha', 'Gilgil', 'Njoro', 'Molo'],
  };

  String? selectedCounty;
  String? selectedSubCounty;

  // Generate a custom alphanumeric ID
  String _generateLuggageId(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Method to handle the luggage registration
  Future<void> _registerLuggage() async {
    if (_formKey.currentState!.validate()) {
      final luggageId = _generateLuggageId(8); // Custom ID with 8 characters

      final luggageData = {
        'luggageId': luggageId,
        'description': luggageDescriptionController.text,
        'size': luggageSizeController.text,
        'cost': costController.text,
        'isFragile': isFragile,
        'userName': userNameController.text,
        'userPhone': userPhoneController.text,
        'userId': userIdController.text,
        'recipientName': recipientNameController.text,
        'recipientPhone': recipientPhoneController.text,
        'recipientId': recipientIdController.text,
        'dropOffCounty': selectedCounty,
        'dropOffSubCounty': selectedSubCounty,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('luggage').doc(luggageId).set(luggageData);

        // Clear input fields
        luggageDescriptionController.clear();
        luggageSizeController.clear();
        costController.clear();
        userNameController.clear();
        userPhoneController.clear();
        userIdController.clear();
        recipientNameController.clear();
        recipientPhoneController.clear();
        recipientIdController.clear();
        setState(() {
          isFragile = false;
          selectedCounty = null;
          selectedSubCounty = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Luggage Registered Successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register luggage: ${e.toString()}")),
        );
      }
    }
  }

  // Method to calculate cost based on luggage weight
  void _calculateCost(String weight) {
    double ratePerKg = 60.0;
    double cost = 0;

    if (weight.isNotEmpty) {
      double weightInKg = double.tryParse(weight) ?? 0;
      cost = weightInKg * ratePerKg;
    }

    costController.text = "KES ${cost.toStringAsFixed(2)}";
  }

  // Method to navigate to the Driver Dashboard
  void _navigateToDriverDashboard() {
    Navigator.pushNamed(
      context,
      '/driverDashboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Luggage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToDriverDashboard,
            tooltip: "Go to Driver Dashboard",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: luggageDescriptionController,
                  decoration: const InputDecoration(labelText: "Luggage Description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isFragile,
                          onChanged: (value) {
                            setState(() {
                              isFragile = true;
                            });
                          },
                        ),
                        const Text("Fragile Luggage"),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: !isFragile,
                          onChanged: (value) {
                            setState(() {
                              isFragile = false;
                            });
                          },
                        ),
                        const Text("Non-Fragile Luggage"),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: luggageSizeController,
                  decoration: const InputDecoration(labelText: "Luggage Size (kg)"),
                  keyboardType: TextInputType.number,
                  onChanged: _calculateCost,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the luggage size in kg";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: "Estimated Cost (KES)"),
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                // User Information Input Fields
                TextFormField(
                  controller: userNameController,
                  decoration: const InputDecoration(labelText: "User Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the user's name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: userPhoneController,
                  decoration: const InputDecoration(labelText: "User Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the user's phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: userIdController,
                  decoration: const InputDecoration(labelText: "User Identification Number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the user's ID number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Recipient Information Input Fields
                TextFormField(
                  controller: recipientNameController,
                  decoration: const InputDecoration(labelText: "Recipient Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the recipient's name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: recipientPhoneController,
                  decoration: const InputDecoration(labelText: "Recipient Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the recipient's phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: recipientIdController,
                  decoration: const InputDecoration(labelText: "Recipient Identification Number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the recipient's ID number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // County dropdown
                DropdownButtonFormField<String>(
                  value: selectedCounty,
                  decoration: const InputDecoration(labelText: "Drop-Off County"),
                  items: counties.keys.map((county) {
                    return DropdownMenuItem(
                      value: county,
                      child: Text(county),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCounty = value;
                      selectedSubCounty = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Sub-County dropdown
                DropdownButtonFormField<String>(
                  value: selectedSubCounty,
                  decoration: const InputDecoration(labelText: "Drop-Off Sub-County"),
                  items: selectedCounty != null
                      ? counties[selectedCounty]!.map((subCounty) {
                    return DropdownMenuItem(
                      value: subCounty,
                      child: Text(subCounty),
                    );
                  }).toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      selectedSubCounty = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _registerLuggage,
                  child: const Text("Register Luggage"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
