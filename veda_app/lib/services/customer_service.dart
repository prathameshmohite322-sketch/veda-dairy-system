import '../models/customer_model.dart';

class CustomerService {
  final List<CustomerModel> _customers = <CustomerModel>[
    const CustomerModel(
      id: 'c1',
      dairyId: 'dairy_veda_001',
      name: 'Amit Patil',
      phone: '9876543210',
      village: 'Satara Road',
      cattleType: 'Cow',
      isActive: true,
    ),
    const CustomerModel(
      id: 'c2',
      dairyId: 'dairy_veda_001',
      name: 'Sunita Jadhav',
      phone: '9876500011',
      village: 'Karad',
      cattleType: 'Buffalo',
      isActive: true,
    ),
    const CustomerModel(
      id: 'c3',
      dairyId: 'dairy_veda_001',
      name: 'Rohan Shinde',
      phone: '9876502233',
      village: 'Umbraj',
      cattleType: 'Cow',
      isActive: true,
    ),
  ];

  Future<List<CustomerModel>> fetchCustomers(String dairyId) async {
    return _customers
        .where((CustomerModel customer) => customer.dairyId == dairyId)
        .toList();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    _customers.insert(0, customer);
  }
}
