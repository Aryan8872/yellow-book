class ReviewEntity {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String savedAmountText;
  final String reviewText;
  final String personalPickMerchant;
  final double rating;

  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.savedAmountText,
    required this.reviewText,
    required this.personalPickMerchant,
    this.rating = 5.0,
  });
}
