class StrategiesComments {
  StrategiesComments({
    required this.relationshipStrategy,
    required this.depositStrategy,
    required this.transactionBankingComments,
    required this.tradeFinanceComments,
    required this.treasuryComments,
  });

  factory StrategiesComments.fromJson(Map<String, dynamic> json) {
    return StrategiesComments(
      relationshipStrategy: json["relationshipStrategy"] as String,
      depositStrategy: json["depositStrategy"] as String,
      transactionBankingComments: json["transactionBankingComments"] as String,
      tradeFinanceComments: json["tradeFinanceComments"] as String,
      treasuryComments: json["treasuryComments"] as String,
    );
  }
  final String relationshipStrategy;
  final String depositStrategy;
  final String transactionBankingComments;
  final String tradeFinanceComments;
  final String treasuryComments;

  Map<String, dynamic> toJson() {
    return {
      "relationshipStrategy": relationshipStrategy,
      "depositStrategy": depositStrategy,
      "transactionBankingComments": transactionBankingComments,
      "tradeFinanceComments": tradeFinanceComments,
      "treasuryComments": treasuryComments,
    };
  }

  /// Creates a copy of the current [StrategiesComments] instance while
  /// replacing
  /// any provided fields with new values.
  StrategiesComments copyWith({
    String? relationshipStrategy,
    String? depositStrategy,
    String? transactionBankingComments,
    String? tradeFinanceComments,
    String? treasuryComments,
  }) {
    return StrategiesComments(
      relationshipStrategy: relationshipStrategy ?? this.relationshipStrategy,
      depositStrategy: depositStrategy ?? this.depositStrategy,
      transactionBankingComments:
          transactionBankingComments ?? this.transactionBankingComments,
      tradeFinanceComments: tradeFinanceComments ?? this.tradeFinanceComments,
      treasuryComments: treasuryComments ?? this.treasuryComments,
    );
  }
}
