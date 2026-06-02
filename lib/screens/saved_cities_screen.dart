import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../models/saved_city_model.dart';
import '../models/weather_model.dart';
import '../providers/saved_cities_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/tab_provider.dart';
import '../services/weather_service.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/city_list_tile.dart';
import '../widgets/loading_widget.dart';

const List<String> _popularCities = [
  
  'Karachi',
  'Lahore',
  'Islamabad',
  'Rawalpindi',
  'Faisalabad',
  'Multan',
  'Peshawar',
  'Quetta',
  'Sialkot',
  'Gujranwala',
  'Hyderabad',
  'Sukkur',
  'Bahawalpur',
  'Bahawalnagar',
  'Sargodha',
  'Sheikhupura',
  'Rahim Yar Khan',
  'Gujrat',
  'Mardan',
  'Kasur',
  'Sahiwal',
  'Okara',
  'Nawabshah',
  'Mirpur Khas',
  'Dera Ghazi Khan',
  'Jhelum',
  'Attock',
  'Chiniot',
  'Kamoke',
  'Sadiqabad',
  'Turbat',
  'Shikarpur',
  'Gwadar',
  'Abbottabad',
  'Mansehra',
  'Swat',
  'Mingora',

  
  'Mumbai',
  'Delhi',
  'Bangalore',
  'Hyderabad',
  'Chennai',
  'Kolkata',
  'Ahmedabad',
  'Pune',
  'Jaipur',
  'Surat',
  'Lucknow',
  'Kanpur',
  'Nagpur',
  'Indore',
  'Bhopal',
  'Patna',
  'Chandigarh',
  'Ludhiana',
  'Agra',
  'Varanasi',
  'Noida',
  'Gurgaon',

  
  'London',
  'Manchester',
  'Birmingham',
  'Liverpool',
  'Leeds',
  'Sheffield',
  'Bristol',
  'Edinburgh',
  'Glasgow',
  'Cardiff',
  'Oxford',
  'Cambridge',

  
  'New York',
  'Los Angeles',
  'Chicago',
  'Houston',
  'Phoenix',
  'Philadelphia',
  'San Antonio',
  'San Diego',
  'Dallas',
  'San Jose',
  'Austin',
  'San Francisco',
  'Seattle',
  'Boston',
  'Miami',
  'Las Vegas',
  'Washington',
  'Atlanta',
  'Denver',
  'Detroit',
  'Orlando',

  
  'Toronto',
  'Vancouver',
  'Montreal',
  'Calgary',
  'Ottawa',
  'Edmonton',
  'Winnipeg',

  
  'Dubai',
  'Abu Dhabi',
  'Sharjah',
  'Doha',
  'Riyadh',
  'Jeddah',
  'Mecca',
  'Medina',
  'Muscat',
  'Kuwait City',

  
  'Paris',
  'Berlin',
  'Rome',
  'Madrid',
  'Barcelona',
  'Amsterdam',
  'Brussels',
  'Vienna',
  'Prague',
  'Warsaw',
  'Budapest',
  'Zurich',
  'Stockholm',
  'Copenhagen',
  'Lisbon',
  'Athens',

  
  'Tokyo',
  'Osaka',
  'Kyoto',
  'Seoul',
  'Shanghai',
  'Beijing',
  'Hong Kong',
  'Singapore',
  'Bangkok',
  'Kuala Lumpur',
  'Jakarta',
  'Manila',
  'Ho Chi Minh City',
  'Hanoi',
  'Taipei',

  
  'Cairo',
  'Lagos',
  'Nairobi',
  'Johannesburg',
  'Cape Town',
  'Casablanca',
  'Accra',
  'Addis Ababa',

  
  'São Paulo',
  'Rio de Janeiro',
  'Buenos Aires',
  'Lima',
  'Bogotá',
  'Santiago',
  'Caracas',

  
  'Sydney',
  'Melbourne',
  'Brisbane',
  'Perth',
  'Auckland',
  'Wellington',
];
class SavedCitiesScreen extends ConsumerStatefulWidget {
  const SavedCitiesScreen({super.key});

  @override
  ConsumerState<SavedCitiesScreen> createState() => _SavedCitiesScreenState();
}

class _SavedCitiesScreenState extends ConsumerState<SavedCitiesScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final Map<String, WeatherModel?> _weatherCache = {};
  final Map<String, bool> _loadingMap = {};
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
    Future.microtask(_fetchAllWeather);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAllWeather() async {
    final cities = ref.read(savedCitiesProvider).cities;
    // Fetch all city weather in parallel instead of sequentially.
    await Future.wait(cities.map(_fetchCityWeather));
  }

  Future<void> _fetchCityWeather(SavedCityModel city) async {
    if (!mounted) return;
    setState(() => _loadingMap[city.id] = true);
    try {
      final w = await _weatherService.getCurrentWeatherByCity(city.cityName);
      if (mounted) {
        setState(() {
          _weatherCache[city.id] = w;
          _loadingMap[city.id] = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMap[city.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedState = ref.watch(savedCitiesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<SavedCitiesState>(savedCitiesProvider, (_, current) {
      if (current.successMessage != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(current.successMessage!),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        ref.read(savedCitiesProvider.notifier).clearMessages();
      }
      if (current.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(current.errorMessage!),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        ref.read(savedCitiesProvider.notifier).clearMessages();
      }
    });

    // Foolproof: check for any cities that need weather fetched whenever the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final city in savedState.cities) {
        if (!_weatherCache.containsKey(city.id) &&
            !(_loadingMap[city.id] ?? false)) {
          _fetchCityWeather(city);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Saved Cities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddCityDialog,
          ),
        ],
      ),
      body: savedState.isLoading
          ? const LoadingWidget(message: 'Loading saved cities...')
          : savedState.isEmpty
          ? _buildEmptyState(isDark)
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(savedCitiesProvider.notifier)
                      .fetchSavedCities();
                  _fetchAllWeather();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: savedState.cities.length,
                  itemBuilder: (context, index) {
                    final city = savedState.cities[index];
                    return Dismissible(
                      key: Key(city.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        ref
                            .read(savedCitiesProvider.notifier)
                            .removeCity(city.id, city.cityName);
                        setState(() {
                          _weatherCache.remove(city.id);
                          _loadingMap.remove(city.id);
                        });
                      },
                      child: AnimatedListItem(
                        delay: index * 80,
                        child: CityListTile(
                          city: city,
                          weatherData: _weatherCache[city.id],
                          isLoadingWeather: _loadingMap[city.id] ?? false,
                          onTap: () {
                            ref
                                .read(weatherProvider.notifier)
                                .fetchWeatherByCity(city.cityName);
                            ref.read(tabIndexProvider.notifier).state = 0;
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Loading ${city.cityName} weather...',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                          },
                          onDelete: () => _confirmDelete(city),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  size: 46,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No saved cities yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to add your favorite cities\nfor quick weather access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _showAddCityDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Your First City'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(SavedCityModel city) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove City'),
        content: Text('Remove ${city.cityName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(savedCitiesProvider.notifier)
                  .removeCity(city.id, city.cityName);
              setState(() {
                _weatherCache.remove(city.id);
                _loadingMap.remove(city.id);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddCityDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        List<String> suggestions = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Add City',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 320,
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ctrl,
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. London, Karachi, Dubai',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.primaryBlue,
                        ),
                        suffixIcon: ctrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  ctrl.clear();
                                  setState(() {
                                    suggestions = [];
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E2633)
                            : Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        final query = val.trim().toLowerCase();
                        setState(() {
                          if (query.isEmpty) {
                            suggestions = [];
                          } else {
                            suggestions = _popularCities
                                .where((city) => city.toLowerCase().contains(query))
                                .take(5)
                                .toList();
                          }
                        });
                      },
                      onSubmitted: (_) async {
                        final name = ctrl.text.trim();
                        Navigator.pop(ctx);
                        await _addCity(name);
                      },
                    ),
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2633) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                            itemBuilder: (context, index) {
                              final option = suggestions[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.location_city_rounded,
                                  size: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                dense: true,
                                onTap: () {
                                  ctrl.text = option;
                                  setState(() {
                                    suggestions = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = ctrl.text.trim();
                    Navigator.pop(ctx);
                    await _addCity(name);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addCity(String name) async {
    if (name.isEmpty) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Searching city...'),
            ],
          ),
          duration: const Duration(seconds: 15),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

    try {
      final weather = await _weatherService.getCurrentWeatherByCity(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      final city = SavedCityModel(
        id: '',
        cityName: weather.cityName,
        countryCode: weather.countryCode,
        latitude: weather.latitude,
        longitude: weather.longitude,
        savedAt: DateTime.now(),
      );

      await ref.read(savedCitiesProvider.notifier).addCity(city);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
