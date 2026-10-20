import 'dart:convert';

PaymentMethodModel paymentMethodModelFromJson(String str) =>
    PaymentMethodModel.fromJson(json.decode(str));

String paymentMethodModelToJson(PaymentMethodModel data) =>
    json.encode(data.toJson());

class PaymentMethodModel {
  final bool? success;
  final int? code;
  final String? message;
  final Data? data;
  final List<dynamic>? payload;

  PaymentMethodModel({
    this.success,
    this.code,
    this.message,
    this.data,
    this.payload,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      success: json["success"] is bool ? json["success"] : null,
      code: json["code"] is int
          ? json["code"]
          : int.tryParse(json["code"]?.toString() ?? ""),
      message: json["message"]?.toString(),

      data: json["data"] is Map
          ? Data.fromJson(Map<String, dynamic>.from(json["data"]))
          : null,

      payload: json["payload"] is List
          ? List<dynamic>.from(json["payload"])
          : <dynamic>[],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "message": message,
    "data": data?.toJson(),
    "payload": payload ?? [],
  };
}

class Data {
  final List<PaymentMethod>? paymentMethods;

  Data({this.paymentMethods});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      paymentMethods: json["payment_methods"] is List
          ? List<PaymentMethod>.from(
              json["payment_methods"].map(
                (x) => PaymentMethod.fromJson(Map<String, dynamic>.from(x)),
              ),
            )
          : <PaymentMethod>[],
    );
  }

  Map<String, dynamic> toJson() => {
    "payment_methods": paymentMethods?.map((x) => x.toJson()).toList() ?? [],
  };
}

class PaymentMethod {
  final int? id;
  final String? methodName;
  final String? bankName;
  final String? accountHolderName;
  final String? cardNumber;
  final String? accountNumber;
  final String? shebaNumber;
  final String? notes;
  final String? accountDetails;
  final String? accountImage;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic performedBy;

  PaymentMethod({
    this.id,
    this.methodName,
    this.bankName,
    this.accountHolderName,
    this.cardNumber,
    this.accountNumber,
    this.shebaNumber,
    this.notes,
    this.accountDetails,
    this.accountImage,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.performedBy,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json["id"] is int
          ? json["id"]
          : int.tryParse(json["id"]?.toString() ?? ""),

      methodName: json["method_name"]?.toString(),

      bankName: json["bank_name"]?.toString(),

      accountHolderName: json["account_holder_name"]?.toString(),

      cardNumber: json["card_number"]?.toString(),

      accountNumber: json["account_number"]?.toString(),

      shebaNumber: json["sheba_number"]?.toString(),

      notes: json["notes"]?.toString(),

      accountDetails: json["account_details"]?.toString(),

      accountImage: json["account_image"]?.toString(),

      status: json["status"]?.toString(),

      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"].toString()),

      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"].toString()),

      performedBy: json["performed_by"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "method_name": methodName,
    "bank_name": bankName,
    "account_holder_name": accountHolderName,
    "card_number": cardNumber,
    "account_number": accountNumber,
    "sheba_number": shebaNumber,
    "notes": notes,
    "account_details": accountDetails,
    "account_image": accountImage,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "performed_by": performedBy,
  };
}
