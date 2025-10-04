import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_admin_app/service/product_service.dart';
import 'core/app_colors.dart';
import 'core/text_styles.dart';

class AddProductForm extends StatefulWidget {
  final Function()? onProductAdded;

  const AddProductForm({Key? key, this.onProductAdded}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _ratingController = TextEditingController(text: '0');
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController(text: 'No warranty');
  final TextEditingController _shippingController = TextEditingController(text: 'Ships in 1 day');
  final TextEditingController _returnPolicyController = TextEditingController(text: 'No return policy');
  final TextEditingController _minOrderController = TextEditingController(text: '1');
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _qrCodeController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();
  final TextEditingController _imagesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Predefined categories
  final List<String> _categories = [
    'Pizza',
    'Burger',
    'Sushi',
    'Dessert',
    'Drinks',
    'Chicken',
    'Slides',
  ];

  String _availabilityStatus = "In Stock";
  String _selectedCategory = 'Pizza';
  bool _isSubmitting = false;
  String? _nextProductId;
  int? _nextProductIdInt;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Get next product ID for document name
    final nextId = await ProductService.getNextProductId();
    setState(() {
      _nextProductId = nextId;
      _nextProductIdInt = int.tryParse(nextId) ?? 38; // Fallback to 38 if parsing fails
    });

    // Generate SKU based on product ID
    _skuController.text = 'PROD-$nextId-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create product data for Firebase WITH id field
      final productData = _createProductData();

      // Save to Firebase 'products' collection with numeric document ID
      await _firestore.collection('products').doc(_nextProductId).set(productData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product $_nextProductId added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Call callback to refresh products list
        widget.onProductAdded?.call();

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Map<String, dynamic> _createProductData() {
    // Parse tags
    final tags = _tagsController.text.isNotEmpty
        ? _tagsController.text.split(',').map((e) => e.trim()).toList()
        : [_selectedCategory.toLowerCase()];

    // Parse images
    final images = _imagesController.text.isNotEmpty
        ? _imagesController.text.split(',').map((e) => e.trim()).toList()
        : [_thumbnailController.text];

    // Get current timestamp for meta
    final currentTime = DateTime.now().toIso8601String();

    // Create the complete product data for Firebase
    // INCLUDING id field so it can be parsed by Product model
    return {
      'id': _nextProductIdInt, // This is crucial for your Product model
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'price': double.parse(_priceController.text),
      'discountPercentage': double.parse(_discountController.text),
      'rating': double.parse(_ratingController.text),
      'stock': int.parse(_stockController.text),
      'tags': tags,
      'brand': _brandController.text.isNotEmpty ? _brandController.text : null,
      'sku': _skuController.text,
      'weight': int.parse(_weightController.text),
      'dimensions': {
        'width': double.parse(_widthController.text),
        'height': double.parse(_heightController.text),
        'depth': double.parse(_depthController.text),
      },
      'warrantyInformation': _warrantyController.text,
      'shippingInformation': _shippingController.text,
      'availabilityStatus': _availabilityStatus,
      'returnPolicy': _returnPolicyController.text,
      'minimumOrderQuantity': int.parse(_minOrderController.text),
      'meta': {
        'barcode': _barcodeController.text,
        'qrCode': _qrCodeController.text,
        'createdAt': currentTime,
        'updatedAt': currentTime,
      },
      'images': images,
      'thumbnail': _thumbnailController.text,
      'reviews': [], // Empty reviews array for new product
      'createdAt': currentTime,
      'updatedAt': currentTime,
    };
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.orange,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool required = false,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.gray400),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.gray400),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: required ? (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        } : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: const Text('Add New Product',style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white
        ),),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _nextProductId == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product ID Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product ID: $_nextProductId',
                            style: TextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This ID will be stored in the document for proper parsing',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionHeader('Basic Information'),
              _buildTextFormField(
                controller: _titleController,
                label: 'Product Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product title';
                  }
                  return null;
                },
                required: true,
              ),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
                required: true,
              ),

              // Category Dropdown
              _buildDropdownField(
                value: _selectedCategory,
                label: 'Category',
                items: _categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                required: true,
              ),

              _buildSectionHeader('Pricing & Stock'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _priceController,
                      label: 'Price (₹)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid price';
                        }
                        return null;
                      },
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _discountController,
                      label: 'Discount %',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _ratingController,
                      label: 'Rating (0-5)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _stockController,
                      label: 'Stock Quantity',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                      required: true,
                    ),
                  ),
                ],
              ),

              _buildSectionHeader('Product Details'),
              _buildTextFormField(
                controller: _brandController,
                label: 'Brand Name',
              ),
              _buildTextFormField(
                controller: _skuController,
                label: 'SKU (Auto-generated)',
                readOnly: true,
              ),
              _buildTextFormField(
                controller: _weightController,
                label: 'Weight (grams)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid weight';
                  }
                  return null;
                },
                required: true,
              ),

              _buildSectionHeader('Dimensions (cm)'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _widthController,
                      label: 'Width',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter width';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Valid number';
                        }
                        return null;
                      },
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _heightController,
                      label: 'Height',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter height';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Valid number';
                        }
                        return null;
                      },
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _depthController,
                      label: 'Depth',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter depth';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Valid number';
                        }
                        return null;
                      },
                      required: true,
                    ),
                  ),
                ],
              ),

              _buildSectionHeader('Policies & Status'),
              _buildDropdownField(
                value: _availabilityStatus,
                label: 'Availability Status',
                items: ['In Stock', 'Out Of Stock', 'Limited Stock'],
                onChanged: (value) {
                  setState(() {
                    _availabilityStatus = value!;
                  });
                },
              ),
              _buildTextFormField(
                controller: _warrantyController,
                label: 'Warranty Information',
              ),
              _buildTextFormField(
                controller: _shippingController,
                label: 'Shipping Information',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipping info';
                  }
                  return null;
                },
                required: true,
              ),
              _buildTextFormField(
                controller: _returnPolicyController,
                label: 'Return Policy',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter return policy';
                  }
                  return null;
                },
                required: true,
              ),
              _buildTextFormField(
                controller: _minOrderController,
                label: 'Minimum Order Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter min order quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  return null;
                },
                required: true,
              ),

              _buildSectionHeader('Meta Information'),
              _buildTextFormField(
                controller: _barcodeController,
                label: 'Barcode',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter barcode';
                  }
                  return null;
                },
                required: true,
              ),
              _buildTextFormField(
                controller: _qrCodeController,
                label: 'QR Code',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter QR code';
                  }
                  return null;
                },
                required: true,
              ),

              _buildSectionHeader('Images & Tags'),
              _buildTextFormField(
                controller: _thumbnailController,
                label: 'Thumbnail URL',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter thumbnail URL';
                  }
                  if (!value.startsWith('http')) {
                    return 'Please enter valid URL';
                  }
                  return null;
                },
                required: true,
              ),
              _buildTextFormField(
                controller: _imagesController,
                label: 'Additional Image URLs (comma separated)',
                maxLines: 2,
              ),
              _buildTextFormField(
                controller: _tagsController,
                label: 'Tags (comma separated)',
                maxLines: 2,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Add Product $_nextProductId',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _ratingController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _weightController.dispose();
    _warrantyController.dispose();
    _shippingController.dispose();
    _returnPolicyController.dispose();
    _minOrderController.dispose();
    _barcodeController.dispose();
    _qrCodeController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    _thumbnailController.dispose();
    _imagesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}