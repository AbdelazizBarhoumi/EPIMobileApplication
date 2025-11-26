// ============================================================================
// CLUBS PAGE - Student Clubs and Organizations
// ============================================================================
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class ClubsPage extends StatelessWidget {
  const ClubsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Clubs & Organizations'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // My Clubs Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Clubs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            // Registered Clubs
            _buildClubCard(
              context,
              'Tech Club',
              'Technology & Innovation',
              'Member since Sep 2023',
              Icons.computer,
              Colors.blue,
              isRegistered: true,
            ),
            _buildClubCard(
              context,
              'Sports Club',
              'Athletics & Fitness',
              'Member since Jan 2024',
              Icons.sports_soccer,
              Colors.green,
              isRegistered: true,
            ),

            // Available Clubs Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Clubs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            _buildClubCard(
              context,
              'Music Club',
              'Musical Arts & Performance',
              '45 active members',
              Icons.music_note,
              Colors.purple,
            ),
            _buildClubCard(
              context,
              'Photography Club',
              'Visual Arts & Photography',
              '32 active members',
              Icons.camera_alt,
              Colors.orange,
            ),
            _buildClubCard(
              context,
              'Debate Club',
              'Public Speaking & Debate',
              '28 active members',
              Icons.forum,
              Colors.red,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(
    BuildContext context,
    String name,
    String category,
    String info,
    IconData icon,
    Color color, {
    bool isRegistered = false,
  }) {
    return InfoCard(
      child: Row(
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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      isRegistered ? Icons.check_circle : Icons.people,
                      size: 14,
                      color: isRegistered ? Colors.green : AppColors.grey,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        info,
                        style: TextStyle(
                          fontSize: 12,
                          color: isRegistered ? Colors.green : AppColors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Join/Leave club
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRegistered ? Colors.grey[300] : AppColors.primary,
              foregroundColor: isRegistered ? Colors.black87 : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isRegistered ? 'Joined' : 'Join'),
          ),
        ],
      ),
    );
  }
}

