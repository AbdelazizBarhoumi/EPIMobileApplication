// ============================================================================
// ACTIVITIES PAGE - Campus Activities and Events
// ============================================================================
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});
  
  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  String selectedFilter = 'All';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Activities & Events'),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Academic'),
                _buildFilterChip('Sports'),
                _buildFilterChip('Cultural'),
                _buildFilterChip('Social'),
              ],
            ),
          ),
          
          // Activities List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildActivityCard(
                  'Tech Innovation Workshop',
                  'Learn about latest technologies and AI',
                  'Dec 15, 2024 - 10:00 AM',
                  'Building A, Room 301',
                  Icons.computer,
                  Colors.blue,
                  'Academic',
                  true,
                ),
                _buildActivityCard(
                  'Annual Football Tournament',
                  'Inter-department football competition',
                  'Dec 20-22, 2024',
                  'Sports Complex',
                  Icons.sports_soccer,
                  Colors.green,
                  'Sports',
                  false,
                ),
                _buildActivityCard(
                  'Cultural Festival 2024',
                  'Celebrate diversity with music and art',
                  'Dec 25, 2024 - 6:00 PM',
                  'Main Auditorium',
                  Icons.festival,
                  Colors.purple,
                  'Cultural',
                  true,
                ),
                _buildActivityCard(
                  'Career Fair',
                  'Meet top companies and explore opportunities',
                  'Jan 10, 2025 - 9:00 AM',
                  'Exhibition Hall',
                  Icons.business_center,
                  Colors.orange,
                  'Academic',
                  false,
                ),
                _buildActivityCard(
                  'Blood Donation Camp',
                  'Save lives by donating blood',
                  'Jan 15, 2025 - 8:00 AM',
                  'Medical Center',
                  Icons.health_and_safety,
                  Colors.red,
                  'Social',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new activity
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey[300]!),
        ),
      ),
    );
  }
  
  Widget _buildActivityCard(
    String title,
    String description,
    String dateTime,
    String location,
    IconData icon,
    Color color,
    String category,
    bool isRegistered,
  ) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
              const SizedBox(width: 5),
              Text(
                dateTime,
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: AppColors.grey),
              const SizedBox(width: 5),
              Text(
                location,
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Register/Unregister for event
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered ? Colors.grey[300] : color,
                foregroundColor: isRegistered ? Colors.black87 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(isRegistered ? 'Registered ✓' : 'Register Now'),
            ),
          ),
        ],
      ),
    );
  }
}

