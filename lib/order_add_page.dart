import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'order_model.dart';
import 'database_helper.dart';

class OrderAddPage extends StatefulWidget {
  final Order? order;

  const OrderAddPage({super.key, this.order});

  @override
  OrderAddPageState createState() => OrderAddPageState();
}

class OrderAddPageState extends State<OrderAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderDateController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCustomer;
  String? _status;
  XFile? _productImage;
  XFile? _progressVideo;
  final ImagePicker _picker = ImagePicker();
  List<String> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _checkAdminStatus();

    if (widget.order != null) {
      _selectedCustomer = widget.order?.customerName;
      _orderDateController.text =
          widget.order?.orderDate.toLocal().toString().split(' ')[0] ?? '';
      _totalPriceController.text = widget.order?.totalPrice.toString() ?? '';
      _status = widget.order?.status;
      if (widget.order?.items.isNotEmpty ?? false) {
        final item = widget.order!.items.first;
        _productNameController.text = item.productName;
        _quantityController.text = item.quantity.toString();
        _priceController.text = item.price.toString();
        // Load images if necessary
      }
    }
  }

  Future<void> _loadCustomers() async {
    final customers = await DatabaseHelper.instance.getAllCustomers();
    setState(() {
      _customers = customers.map((user) => user.email).toList();
    });
  }

  Future<void> _checkAdminStatus() async {
    // Implement your logic to check if the user is an admin
    setState(() {
      // _isAdmin = true; // Replace with your actual logic
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Tambah Order' : 'Edit Order'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: _selectedCustomer,
                  decoration:
                      const InputDecoration(labelText: 'Nama Pelanggan'),
                  items: _customers
                      .map((customer) => DropdownMenuItem(
                            value: customer,
                            child: Text(customer),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomer = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama pelanggan harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _orderDateController,
                  decoration: const InputDecoration(labelText: 'Tanggal Order'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal order harus diisi';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _orderDateController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                TextFormField(
                  controller: _totalPriceController,
                  decoration: const InputDecoration(labelText: 'Total Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Total harga harus diisi';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Pending', 'Completed', 'Cancelled']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status harus dipilih';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga harus diisi';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final pickedImage = await _picker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {
                          _productImage = pickedImage;
                        });
                      },
                      child: const Text('Pilih Foto Produk'),
                    ),
                    if (_productImage != null) Text(' ${_productImage!.name}'),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final pickedVideo = await _picker.pickVideo(
                            source: ImageSource.gallery);
                        setState(() {
                          _progressVideo = pickedVideo;
                        });
                      },
                      child: const Text('Pilih Video Progress'),
                    ),
                    if (_progressVideo != null)
                      Text(' ${_progressVideo!.name}'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final newOrder = Order(
                        id: widget.order?.id ??
                            DateTime.now().millisecondsSinceEpoch,
                        customerName: _selectedCustomer ?? 'Unknown',
                        items: [
                          OrderItem(
                            productName: _productNameController.text,
                            quantity: int.parse(_quantityController.text),
                            price: double.parse(_priceController.text),
                            fotoProduk: _productImage?.path,
                            fotoProgress: _progressVideo?.path,
                          ),
                        ],
                        orderDate: DateTime.parse(_orderDateController.text),
                        totalPrice: double.parse(_totalPriceController.text),
                        status: _status,
                      );
                      Navigator.of(context).pop(newOrder);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
