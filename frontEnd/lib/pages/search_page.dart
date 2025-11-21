// ============================================================================
// SEARCH PAGE - Search Functionality
// ============================================================================
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Search', showBackButton: false),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses, events, clubs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Show filter options
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Category Filters
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All', Icons.grid_view),
                _buildCategoryChip('Courses', Icons.book),
                _buildCategoryChip('Events', Icons.event),
                _buildCategoryChip('Clubs', Icons.groups),
                _buildCategoryChip('People', Icons.person),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Search Results or Recent Searches
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildRecentSearches()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.grey),
            const SizedBox(width: 5),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = label;
          });
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
  
  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Clear All'),
            ),
          ],
        ),
        _buildRecentItem('Data Structures', Icons.book),
        _buildRecentItem('Tech Club', Icons.groups),
        _buildRecentItem('Football Tournament', Icons.event),
        const SizedBox(height: 20),
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        _buildRecentItem('Course Registration', Icons.app_registration),
        _buildRecentItem('Exam Schedule', Icons.calendar_today),
        _buildRecentItem('Library Hours', Icons.schedule),
      ],
    );
  }
  
  Widget _buildRecentItem(String text, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey),
      title: Text(text),
      trailing: const Icon(Icons.north_west, size: 16),
      onTap: () {
        _searchController.text = text;
        setState(() {});
      },
    );
  }
  
  Widget _buildSearchResults() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Search Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        _buildResultCard(
          'Data Structures and Algorithms',
          'Course - CS301',
          Icons.book,
          Colors.blue,
        ),
        _buildResultCard(
          'Tech Innovation Workshop',
          'Event - Dec 15, 2024',
          Icons.event,
          Colors.purple,
        ),
        _buildResultCard(
          'Tech Club',
          'Club - 78 members',
          Icons.groups,
          Colors.green,
        ),
      ],
    );
  }
  
  Widget _buildResultCard(String title, String subtitle, IconData icon, Color color) {
    return InfoCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

