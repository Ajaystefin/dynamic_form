import "package:flutter/material.dart";

/// Represents a comment associated with a contract,
/// including the comment text and timestamp.
@immutable
class ContractComment {
  /// Creates a [ContractComment] instance.
  const ContractComment({
    required this.text,
    required this.timestamp,
  });

  /// Comment text.
  final String text;

  /// Date and time when the comment was created.
  final DateTime timestamp;

  /// Returns a string representation of this [ContractComment].
  @override
  String toString() => "ContractComment(text: $text, timestamp: $timestamp)";

  /// Compares this [ContractComment] with another object for equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractComment &&
          text == other.text &&
          timestamp == other.timestamp;

  /// Returns the hash code for this [ContractComment].
  @override
  int get hashCode => Object.hash(text, timestamp);
}
