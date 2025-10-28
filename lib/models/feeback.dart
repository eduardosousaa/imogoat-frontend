class FeedbackModel {
  final int? id;
  final int rating;
  final String comment;
  final int userId;
  final int immobileId;

  FeedbackModel({
    this.id,
    required this.rating,
    required this.comment,
    required this.userId,
    required this.immobileId,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'],
      rating: map['rating'],
      comment: map['comment'],
      userId: map['userId'],
      immobileId: map['immobileId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'userId': userId,
      'immobileId': immobileId,
    };
  }
}
