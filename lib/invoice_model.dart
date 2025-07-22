enum InvoiceStatus { draft, pending, approved, sent, paid, overdue, cancelled }
enum PaymentStatus { unpaid, partiallyPaid, paid, refunded }

class InvoiceItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double taxRate;

  InvoiceItem({
    String? id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0.0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'].toDouble(),
      unitPrice: json['unitPrice'].toDouble(),
      taxRate: json['taxRate']?.toDouble() ?? 0.0,
    );
  }

  InvoiceItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  Customer({
    String? id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final Customer customer;
  final List<InvoiceItem> items;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final PaymentStatus paymentStatus;
  final String notes;
  final double discountPercentage;
  final double taxRate;
  final String approvedBy;
  final DateTime? approvedDate;
  final DateTime? paidDate;
  final double paidAmount;
  final String paymentMethod;
  final String paymentReference;

  Invoice({
    String? id,
    required this.invoiceNumber,
    required this.customer,
    required this.items,
    required this.issueDate,
    required this.dueDate,
    this.status = InvoiceStatus.draft,
    this.paymentStatus = PaymentStatus.unpaid,
    this.notes = '',
    this.discountPercentage = 0.0,
    this.taxRate = 0.0,
    this.approvedBy = '',
    this.approvedDate,
    this.paidDate,
    this.paidAmount = 0.0,
    this.paymentMethod = '',
    this.paymentReference = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get discountAmount => subtotal * (discountPercentage / 100);
  double get subtotalAfterDiscount => subtotal - discountAmount;
  double get taxAmount => subtotalAfterDiscount * (taxRate / 100) +
      items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get total => subtotalAfterDiscount + taxAmount;
  double get remainingAmount => total - paidAmount;

  bool get isOverdue => status == InvoiceStatus.sent &&
      paymentStatus != PaymentStatus.paid &&
      DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customer': customer.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString(),
      'paymentStatus': paymentStatus.toString(),
      'notes': notes,
      'discountPercentage': discountPercentage,
      'taxRate': taxRate,
      'approvedBy': approvedBy,
      'approvedDate': approvedDate?.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      customer: Customer.fromJson(json['customer']),
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      status: InvoiceStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
            (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      notes: json['notes'] ?? '',
      discountPercentage: json['discountPercentage']?.toDouble() ?? 0.0,
      taxRate: json['taxRate']?.toDouble() ?? 0.0,
      approvedBy: json['approvedBy'] ?? '',
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      paidAmount: json['paidAmount']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentReference: json['paymentReference'] ?? '',
    );
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    Customer? customer,
    List<InvoiceItem>? items,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    PaymentStatus? paymentStatus,
    String? notes,
    double? discountPercentage,
    double? taxRate,
    String? approvedBy,
    DateTime? approvedDate,
    DateTime? paidDate,
    double? paidAmount,
    String? paymentMethod,
    String? paymentReference,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxRate: taxRate ?? this.taxRate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      paidDate: paidDate ?? this.paidDate,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }
}