import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecipientPage extends StatefulWidget {
  const RecipientPage({super.key});

  @override
  _RecipientPageState createState() => _RecipientPageState();
}

class _RecipientPageState extends State<RecipientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _luggageIdController = TextEditingController();
  DateTime? _pickUpDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick-Up Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Pick-Up Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Move Luggage ID field to the top
                TextFormField(
                  controller: _luggageIdController,
                  decoration: const InputDecoration(labelText: "Luggage ID"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the luggage ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Recipient Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the recipient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Recipient Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: "Recipient ID Number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the recipient ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Date Picker for Pick-Up Date
                ListTile(
                  title: Text(_pickUpDate == null
                      ? 'Pick-Up Date: Not Selected'
                      : 'Pick-Up Date: ${_pickUpDate!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveRecipient,
                  child: const Text('Save Recipient'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Date picker for selecting pick-up date
  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _pickUpDate) {
      setState(() {
        _pickUpDate = selectedDate;
      });
    }
  }

  // Save recipient data to Firestore
  Future<void> _saveRecipient() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the Firestore instance
        final CollectionReference recipients = FirebaseFirestore.instance.collection('recipients');

        // Create a map with the recipient details
        Map<String, dynamic> recipientData = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'id': _idController.text,
          'luggageId': _luggageIdController.text,
          'pickUpDate': _pickUpDate ?? DateTime.now(),
        };

        // Add data to Firestore
        await recipients.add(recipientData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipient saved successfully')),
        );

        // Clear the form
        _nameController.clear();
        _phoneController.clear();
        _idController.clear();
        _luggageIdController.clear();
        setState(() {
          _pickUpDate = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
