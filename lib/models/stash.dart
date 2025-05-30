import 'package:hive/hive.dart';

part 'stash.g.dart';

@HiveType(typeId: 0)
class Stash extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double currentAmount;

  @HiveField(3)
  double targetAmount;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime createdDate;

  @HiveField(6)
  List<Contribution> contributions;

  Stash({
    required this.id,
    required this.name,
    required this.currentAmount,
    required this.targetAmount,
    required this.category,
    required this.createdDate,
    List<Contribution>? contributions,
  }) : contributions = contributions ?? [];

  double get progressPercentage => 
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  bool get isCompleted => currentAmount >= targetAmount;

  void addContribution(double amount) {
    currentAmount += amount;
    contributions.add(Contribution(
      amount: amount,
      date: DateTime.now(),
    ));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currentAmount': currentAmount,
    'targetAmount': targetAmount,
    'category': category,
    'createdDate': createdDate.toIso8601String(),
    'contributions': contributions.map((c) => c.toJson()).toList(),
  };

  factory Stash.fromJson(Map<String, dynamic> json) => Stash(
    id: json['id'],
    name: json['name'],
    currentAmount: json['currentAmount'].toDouble(),
    targetAmount: json['targetAmount'].toDouble(),
    category: json['category'],
    createdDate: DateTime.parse(json['createdDate']),
    contributions: (json['contributions'] as List?)
        ?.map((c) => Contribution.fromJson(c))
        .toList(),
  );
}

@HiveType(typeId: 1)
class Contribution extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  DateTime date;

  Contribution({
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
    amount: json['amount'].toDouble(),
    date: DateTime.parse(json['date']),
  );
} 