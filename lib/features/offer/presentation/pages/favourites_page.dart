import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/offer/presentation/bloc/favourites_bloc.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/search/presentation/pages/search_page.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FavouritesBloc>()..add(const FavouritesLoadRequested()),
      child: const _FavouritesView(),
    );
  }
}

class _FavouritesView extends StatelessWidget {
  const _FavouritesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

        return Scaffold(
          backgroundColor: AppTheme.canvasBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: BlocBuilder<FavouritesBloc, FavouritesState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saved Offers',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26, fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary, letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  '${state.favourites.length} saved',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Count badge
                          if (state.favourites.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD93025).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Color(0xFFD93025), size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${state.favourites.length}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13, fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD93025),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ── Content ───────────────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<FavouritesBloc>().add(const FavouritesLoadRequested());
                    },
                    child: BlocBuilder<FavouritesBloc, FavouritesState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.darkPill),
                          );
                        }

                        if (state.favourites.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            children: [_EmptyState(user: user)],
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: state.favourites.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _FavouriteOfferCard(offer: state.favourites[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final User? user;
  const _EmptyState({this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFD93025).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 44, color: Color(0xFFD93025),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No saved offers yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start saving offers you love by tapping the ♥ on any deal',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500, height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: user != null ? () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ) : null,
            icon: const Icon(Icons.explore_rounded, size: 18),
            label: const Text('Browse Offers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkPill,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteOfferCard extends StatelessWidget {
  final OfferEntity offer;
  const _FavouriteOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final imageUrl = offer.imageUrl ?? (offer.images.isNotEmpty ? offer.images.first : null);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OfferDetailPage(offer: offer)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Row(
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: SizedBox(
                width: 100, height: 100,
                child: imageUrl != null
                    ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceSubtle,
                          child: const Icon(Icons.local_offer_rounded, color: AppTheme.textMuted)))
                    : Container(color: AppTheme.surfaceSubtle,
                        child: const Icon(Icons.local_offer_rounded, color: AppTheme.textMuted)),
              ),
            ),
            // ── Info ──────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.merchantName ?? offer.merchant?.name ?? 'Merchant',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      offer.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (offer.discountPercentage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5A93C).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${offer.discountPercentage}% OFF',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: const Color(0xFFE5A93C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(Icons.star_rounded, color: Color(0xFFE5A93C), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          offer.rating.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Heart icon ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: BlocBuilder<FavouritesBloc, FavouritesState>(
                builder: (context, state) => GestureDetector(
                  onTap: () => context.read<FavouritesBloc>().add(FavouriteToggled(offer.id ?? '')),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      state.isFavourite(offer.id ?? '') ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(state.isFavourite(offer.id ?? '')),
                      color: const Color(0xFFD93025), size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
