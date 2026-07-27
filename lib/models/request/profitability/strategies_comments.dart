/// Represents strategy-related comments for a customer relationship.
class StrategiesComments {
  /// Creates a [StrategiesComments] instance.
  StrategiesComments({
    required this.relationshipStrategy,
    required this.depositStrategy,
    required this.transactionBankingComments,
    required this.tradeFinanceComments,
    required this.treasuryComments,
  });

  /// Creates a [StrategiesComments] instance from a JSON map.
  factory StrategiesComments.fromJson(Map<String, dynamic> json) {
    return StrategiesComments(
      relationshipStrategy: json["relationshipStrategy"] as String,
      depositStrategy: json["depositStrategy"] as String,
      transactionBankingComments: json["transactionBankingComments"] as String,
      tradeFinanceComments: json["tradeFinanceComments"] as String,
      treasuryComments: json["treasuryComments"] as String,
    );
  }

  /// Relationship strategy comments.
  final String relationshipStrategy;

  /// Deposit strategy comments.
  final String depositStrategy;

  /// Transaction banking comments.
  final String transactionBankingComments;

  /// Trade finance comments.
  final String tradeFinanceComments;

  /// Treasury comments.
  final String treasuryComments;

  /// Converts this [StrategiesComments] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "relationshipStrategy": relationshipStrategy,
      "depositStrategy": depositStrategy,
      "transactionBankingComments": transactionBankingComments,
      "tradeFinanceComments": tradeFinanceComments,
      "treasuryComments": treasuryComments,
    };
  }

  /// Creates a copy of this [StrategiesComments]
  /// with the specified fields replaced.
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
