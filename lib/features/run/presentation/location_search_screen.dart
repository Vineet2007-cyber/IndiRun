import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../application/pre_run_controller.dart';
import '../domain/location_result.dart';
import 'pin_drop_screen.dart';

/// S11 Search results — full-screen search for a destination.
///
/// Returns a [LocationResult] via [Navigator.pop] when the user selects
/// a result or confirms a pin drop.
class LocationSearchScreen extends ConsumerStatefulWidget {
  const LocationSearchScreen({super.key, required this.isOffline});
  final bool isOffline;

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState
    extends ConsumerState<LocationSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    ref.read(locationSearchProvider.notifier).onQueryChanged(
          q,
          isOffline: widget.isOffline,
        );
  }

  void _select(LocationResult result) {
    ref.read(locationSearchProvider.notifier).selectResult(result);
    Navigator.of(context).pop(result);
  }

  void _clear() {
    _controller.clear();
    ref.read(locationSearchProvider.notifier).clear();
    _focusNode.requestFocus();
  }

  Future<void> _openPinDrop() async {
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PinDropScreen(),
      ),
    );
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(locationSearchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search by location',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMutedOf(context),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          suffixIcon: search.query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: _clear,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(child: _buildBody(context, search, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState search, ThemeData theme) {
    switch (search.phase) {
      case SearchPhase.idle:
        return _IdleBody(
          recentSearches: search.recentSearches,
          onSelect: _select,
          onPinDrop: _openPinDrop,
        );

      case SearchPhase.loading:
        return const Center(child: CircularProgressIndicator());

      case SearchPhase.results:
        return _ResultsList(
          results: search.results,
          onSelect: _select,
          onPinDrop: _openPinDrop,
        );

      case SearchPhase.empty:
        return _EmptyBody(onPinDrop: _openPinDrop);

      case SearchPhase.offline:
        return _OfflineBody(onPinDrop: _openPinDrop);

      case SearchPhase.error:
        return _ErrorSearchBody(
          message: search.errorMessage ?? 'Something went wrong',
          onPinDrop: _openPinDrop,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body states
// ─────────────────────────────────────────────────────────────────────────────

class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.recentSearches,
    required this.onSelect,
    required this.onPinDrop,
  });

  final List<LocationResult> recentSearches;
  final ValueChanged<LocationResult> onSelect;
  final VoidCallback onPinDrop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _UseCurrentLocation(onTap: () {
          onSelect(const LocationResult(
            name: 'My location',
            subtitle: '',
            lat: 0,
            lng: 0,
          ));
        }),
        if (recentSearches.isNotEmpty) ...[
          _SectionHeader('Recent'),
          ...recentSearches.map((r) => _LocationTile(
                result: r,
                onTap: () => onSelect(r),
              )),
        ],
        _PinDropTile(onTap: onPinDrop),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.onSelect,
    required this.onPinDrop,
  });

  final List<LocationResult> results;
  final ValueChanged<LocationResult> onSelect;
  final VoidCallback onPinDrop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _UseCurrentLocation(onTap: () {
          onSelect(const LocationResult(
            name: 'My location',
            subtitle: '',
            lat: 0,
            lng: 0,
          ));
        }),
        ...results.map((r) => _LocationTile(
              result: r,
              onTap: () => onSelect(r),
            )),
        _PinDropTile(onTap: onPinDrop),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              'Results limited to India',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMutedOf(context),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onPinDrop});
  final VoidCallback onPinDrop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text(
            'No results found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMutedOf(context),
                ),
          ),
        ),
        _PinDropTile(onTap: onPinDrop),
      ],
    );
  }
}

class _OfflineBody extends StatelessWidget {
  const _OfflineBody({required this.onPinDrop});
  final VoidCallback onPinDrop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const Icon(Icons.wifi_off, size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text(
                'Search needs internet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMutedOf(context),
                    ),
              ),
            ],
          ),
        ),
        _PinDropTile(onTap: onPinDrop),
      ],
    );
  }
}

class _ErrorSearchBody extends StatelessWidget {
  const _ErrorSearchBody({required this.message, required this.onPinDrop});
  final String message;
  final VoidCallback onPinDrop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
        ),
        _PinDropTile(onTap: onPinDrop),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared tiles
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMutedOf(context),
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _UseCurrentLocation extends StatelessWidget {
  const _UseCurrentLocation({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.primaryContainer.withValues(alpha: 0.3),
      leading: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.my_location,
            color: Colors.white, size: 18),
      ),
      title: Text(
        'Use my current location',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
      ),
      onTap: onTap,
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.result, required this.onTap});
  final LocationResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.circle, size: 8, color: AppColors.textSecondary),
      title: Text(result.name,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: result.subtitle.isNotEmpty
          ? Text(result.subtitle,
              style: Theme.of(context).textTheme.bodySmall)
          : null,
      onTap: onTap,
    );
  }
}

class _PinDropTile extends StatelessWidget {
  const _PinDropTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.outlineOf(context),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.diamond_outlined,
            color: AppColors.primary, size: 20),
        title: const Text(
          "Can't find it? Choose on map",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
