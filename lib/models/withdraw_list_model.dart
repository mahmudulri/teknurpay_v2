import 'dart:convert';

WithdrawListModel withdrawListModelFromJson(String str) =>
    WithdrawListModel.fromJson(json.decode(str));

String withdrawListModelToJson(WithdrawListModel data) =>
    json.encode(data.toJson());

class WithdrawListModel {
  final bool? success;
  final int? code;
  final String? message;
  final Data? data;
  final List<dynamic>? payload;

  WithdrawListModel({
    this.success,
    this.code,
    this.message,
    this.data,
    this.payload,
  });

  factory WithdrawListModel.fromJson(Map<String, dynamic> json) =>
      WithdrawListModel(
        success: json["success"],
        code: json["code"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
        payload: List<dynamic>.from(json["payload"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "message": message,
    "data": data!.toJson(),
    "payload": List<dynamic>.from(payload!.map((x) => x)),
  };
}

class Data {
  final List<WithdrawRequest>? withdrawRequests;

  Data({this.withdrawRequests});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    withdrawRequests: List<WithdrawRequest>.from(
      json["withdraw_requests"].map((x) => WithdrawRequest.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "withdraw_requests": List<dynamic>.from(
      withdrawRequests!.map((x) => x.toJson()),
    ),
  };
}

class WithdrawRequest {
  final int? id;
  final String? resellerId;
  final String? currencyId;
  final String? amount;
  final String? commissionAmount;
  final String? netAmount;
  final BankDetails? bankDetails;
  final String? status;
  final dynamic requestedBy;
  final dynamic requestedById;
  final dynamic resellerNote;
  final dynamic adminNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  WithdrawRequest({
    this.id,
    this.resellerId,
    this.currencyId,
    this.amount,
    this.commissionAmount,
    this.netAmount,
    this.bankDetails,
    this.status,
    this.requestedBy,
    this.requestedById,
    this.resellerNote,
    this.adminNote,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory WithdrawRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawRequest(
        id: json["id"] == null ? null : json["id"],
        resellerId: json["reseller_id"] == null ? null : json["reseller_id"],
        currencyId: json["currency_id"] == null ? null : json["currency_id"],
        amount: json["amount"] == null ? null : json["amount"],
        commissionAmount: json["commission_amount"] == null
            ? null
            : json["commission_amount"],
        netAmount: json["net_amount"] == null ? null : json["net_amount"],

        bankDetails: json["bank_details"] == null
            ? null
            : BankDetails.fromJson(json["bank_details"]),

        status: json["status"] == null ? null : json["status"],
        requestedBy: json["requested_by"] == null ? null : json["requested_by"],
        requestedById: json["requested_by_id"] == null
            ? null
            : json["requested_by_id"],
        resellerNote: json["reseller_note"] == null
            ? null
            : json["reseller_note"],
        adminNote: json["admin_note"] == null ? null : json["admin_note"],

        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),

        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),

        deletedAt: json["deleted_at"] == null ? null : json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "reseller_id": resellerId,
    "currency_id": currencyId,
    "amount": amount,
    "commission_amount": commissionAmount,
    "net_amount": netAmount,
    "bank_details": bankDetails!.toJson(),
    "status": status,
    "requested_by": requestedBy,
    "requested_by_id": requestedById,
    "reseller_note": resellerNote,
    "admin_note": adminNote,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class BankDetails {
  final String? iban;
  final String? branch;
  final String? bankName;
  final String? swiftCode;
  final String? accountNumber;
  final String? accountHolderName;

  BankDetails({
    this.iban,
    this.branch,
    this.bankName,
    this.swiftCode,
    this.accountNumber,
    this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    iban: json["iban"] == null ? null : json["iban"],
    branch: json["branch"] == null ? null : json["branch"],
    bankName: json["bank_name"] == null ? null : json["bank_name"],
    swiftCode: json["swift_code"] == null ? null : json["swift_code"],
    accountNumber: json["account_number"] == null
        ? null
        : json["account_number"],
    accountHolderName: json["account_holder_name"] == null
        ? null
        : json["account_holder_name"],
  );

  Map<String, dynamic> toJson() => {
    "iban": iban,
    "branch": branch,
    "bank_name": bankName,
    "swift_code": swiftCode,
    "account_number": accountNumber,
    "account_holder_name": accountHolderName,
  };
}
