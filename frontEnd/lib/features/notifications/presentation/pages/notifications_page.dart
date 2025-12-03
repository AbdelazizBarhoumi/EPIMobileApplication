// lib/features/notifications/presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/controllers/student_controller.dart';
import '../controllers/notification_controller.dart';
import '../../data/models/notification_model.dart';

/// Professional Student Notifications Page with modern UI/UX
/// Features: Real-time updates, smart filtering, grouped views, swipe actions
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  NotificationController? _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  NotificationPriority? _filterPriority;
  bool _showSearch = false;
  bool _isInitialized = false;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection.name == 'reverse') {
      if (_showFab) setState(() => _showFab = false);
    } else {
      if (!_showFab) setState(() => _showFab = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeController();
    }
  }

  void _initializeController() {
    final studentController = context.read<StudentController>();
    final student = studentController.student;
    final String userId = student?.id.toString() ?? 'anonymous';
    
    debugPrint('🔔 NotificationsPage: Initializing with student ID: $userId');
    
    final firestore = FirebaseFirestore.instance;
    _controller = NotificationController(userId, firestore);
    _controller!.initialize();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _controller?.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller!,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(innerBoxIsScrolled),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAllNotificationsTab(),
              _buildUnreadTab(),
              _buildGroupedTab(),
            ],
          ),
        ),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                const Color(0xFFD32F2F),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 60),
              child: Consumer<NotificationController>(
                builder: (context, controller, _) {
                  return _buildStatsHeader(controller);
                },
              ),
            ),
          ),
        ),
      ),
      title: _showSearch 
          ? _buildSearchField()
          : const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
        _buildFilterMenu(),
        _buildMoreMenu(),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
              Tab(text: 'Categories'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Search notifications...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
    );
  }

  Widget _buildStatsHeader(NotificationController controller) {
    final total = controller.notifications.length;
    final unread = controller.unreadCount;
    final critical = controller.notifications
        .where((n) => n.priority == NotificationPriority.critical && !n.read)
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard('Total', total, Icons.notifications_rounded, Colors.white),
        _buildStatCard('Unread', unread, Icons.mark_email_unread_rounded, Colors.amber),
        if (critical > 0)
          _buildStatCard('Urgent', critical, Icons.warning_rounded, Colors.redAccent[100]!),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return PopupMenuButton<NotificationPriority?>(
      icon: Stack(
        children: [
          const Icon(Icons.filter_list_rounded, color: Colors.white),
          if (_filterPriority != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _filterPriority!.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (priority) => setState(() => _filterPriority = priority),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              Icon(Icons.clear_all_rounded, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              const Text('All Priorities'),
              if (_filterPriority == null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: AppColors.primary, size: 18),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...NotificationPriority.values.map((priority) => PopupMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: priority.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(priority.displayName),
              if (_filterPriority == priority)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: AppColors.primary, size: 18),
                ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMoreMenu() {
    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            switch (value) {
              case 'mark_all':
                controller.markAllAsRead();
                _showSuccessSnackBar('All notifications marked as read');
                break;
              case 'refresh':
                controller.refresh();
                _showSuccessSnackBar('Refreshing...');
                break;
            }
          },
          itemBuilder: (context) => [
            if (controller.unreadCount > 0)
              const PopupMenuItem(
                value: 'mark_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Mark all as read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFab() {
    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        if (controller.unreadCount == 0 || !_showFab) {
          return const SizedBox.shrink();
        }
        
        return AnimatedScale(
          scale: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.extended(
            onPressed: () {
              controller.markAllAsRead();
              _showSuccessSnackBar('All marked as read');
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            label: Text(
              'Mark all (${controller.unreadCount})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllNotificationsTab() {
    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        if (controller.state == NotificationState.loading) {
          return _buildLoadingState();
        }

        if (controller.state == NotificationState.error) {
          return _buildErrorState(controller.error, controller.refresh);
        }

        var notifications = _applyFilters(controller.notifications);

        if (notifications.isEmpty) {
          if (controller.notifications.isEmpty) {
            return _buildEmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'No notifications yet',
              subtitle: 'When you receive notifications, they\'ll appear here',
              lottie: null,
            );
          }
          return _buildEmptyState(
            icon: Icons.search_off_rounded,
            title: 'No results',
            subtitle: 'Try adjusting your search or filters',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final showDateHeader = index == 0 ||
                  !_isSameDay(notifications[index - 1].timestamp, notification.timestamp);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader) _buildDateHeader(notification.timestamp),
                  _buildNotificationCard(notification, controller),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUnreadTab() {
    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        var notifications = controller.getUnreadNotifications();
        notifications = _applyFilters(notifications);

        if (notifications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'All caught up!',
            subtitle: 'You\'ve read all your notifications',
            iconColor: Colors.green,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(notifications[index], controller);
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupedTab() {
    return Consumer<NotificationController>(
      builder: (context, controller, _) {
        if (controller.notifications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.category_rounded,
            title: 'No notifications',
            subtitle: 'Notifications will be grouped by category here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: NotificationType.values.map((type) {
              var typeNotifications = controller.getNotificationsByType(type);
              typeNotifications = _applyFilters(typeNotifications);

              if (typeNotifications.isEmpty) return const SizedBox.shrink();

              final unreadCount = typeNotifications.where((n) => !n.read).length;

              return _buildCategorySection(
                type: type,
                notifications: typeNotifications,
                unreadCount: unreadCount,
                controller: controller,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection({
    required NotificationType type,
    required List<NotificationModel> notifications,
    required int unreadCount,
    required NotificationController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getTypeColor(type),
                  _getTypeColor(type).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _getTypeColor(type).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${notifications.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Notification Cards
          ...notifications.take(3).map((n) => _buildNotificationCard(n, controller)),
          if (notifications.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  // Could expand to show all
                },
                child: Text(
                  'View ${notifications.length - 3} more',
                  style: TextStyle(color: _getTypeColor(type)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationController controller) {
    final isUnread = !notification.read;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(
        alignment: Alignment.centerLeft,
        color: Colors.green,
        icon: Icons.check_rounded,
        label: 'Read',
      ),
      secondaryBackground: _buildDismissBackground(
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          controller.markAsRead(notification.id);
          _showSuccessSnackBar('Marked as read');
          return false;
        } else {
          return await _showDeleteConfirmation();
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          controller.deleteNotification(notification.id);
          _showSuccessSnackBar('Notification deleted');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: notification.isCritical
              ? Border.all(color: notification.priority.color, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? notification.priority.color.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isUnread ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _handleNotificationTap(notification, controller),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  _buildNotificationIcon(notification),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                  color: notification.isExpired
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: notification.priority.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: notification.priority.color.withOpacity(0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        // Priority Badge
                        if (notification.isUrgent) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: notification.priority.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: notification.priority.color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  notification.isCritical
                                      ? Icons.warning_rounded
                                      : Icons.priority_high_rounded,
                                  size: 12,
                                  color: notification.priority.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.priority.displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: notification.priority.color,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Message
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: notification.isExpired
                                ? Colors.grey
                                : Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Footer
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(notification.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(notification.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notification.type.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getTypeColor(notification.type),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (notification.isExpired) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'EXPIRED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTypeColor(notification.type).withOpacity(0.2),
                _getTypeColor(notification.type).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 24,
          ),
        ),
        if (notification.isCritical)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDismissBackground({
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: Colors.white),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatDateHeader(date),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    String? lottie,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Failed to load notifications',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  List<NotificationModel> _applyFilters(List<NotificationModel> notifications) {
    var filtered = notifications.where((n) {
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = n.title.toLowerCase().contains(_searchQuery) ||
            n.message.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }
      if (_filterPriority != null && n.priority != _filterPriority) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (a.read != b.read) return a.read ? 1 : -1;
      if (a.priority != b.priority) {
        return a.priority.sortOrder.compareTo(b.priority.sortOrder);
      }
      return b.timestamp.compareTo(a.timestamp);
    });

    return filtered;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    }
    return DateFormat('MMMM d, y').format(date);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(time);
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.exam:
        return Icons.school_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.grade:
        return Icons.grade_rounded;
      case NotificationType.event:
        return Icons.event_rounded;
      case NotificationType.schedule:
        return Icons.schedule_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.club:
        return Icons.groups_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.exam:
        return const Color(0xFFE53935);
      case NotificationType.payment:
        return const Color(0xFFD32F2F);
      case NotificationType.grade:
        return const Color(0xFF43A047);
      case NotificationType.event:
        return const Color(0xFF1E88E5);
      case NotificationType.schedule:
        return const Color(0xFFFB8C00);
      case NotificationType.announcement:
        return const Color(0xFF5E35B1);
      case NotificationType.club:
        return const Color(0xFF8E24AA);
      case NotificationType.general:
        return const Color(0xFF757575);
    }
  }

  void _handleNotificationTap(NotificationModel notification, NotificationController controller) {
    if (!notification.read) {
      controller.markAsRead(notification.id);
    }

    _showNotificationDetail(notification);
  }

  void _showNotificationDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationDetailSheet(
        notification: notification,
        onAction: () {
          Navigator.pop(context);
          _navigateToAction(notification);
        },
      ),
    );
  }

  void _navigateToAction(NotificationModel notification) {
    String? route;
    switch (notification.type) {
      case NotificationType.payment:
        route = '/bills';
        break;
      case NotificationType.grade:
        route = '/grades';
        break;
      case NotificationType.event:
        route = '/activities'; // Events -> Activities page
        break;
      case NotificationType.schedule:
        route = '/schedule';
        break;
      case NotificationType.club:
        route = '/clubs';
        break;
      case NotificationType.exam:
        route = '/schedule'; // Exams -> Schedule page
        break;
      case NotificationType.announcement:
        route = '/news'; // Announcements -> News page
        break;
      default:
        break;
    }
    
    if (route != null && mounted) {
      Navigator.pushNamed(context, route);
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Bottom sheet for notification details
class _NotificationDetailSheet extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onAction;

  const _NotificationDetailSheet({
    required this.notification,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor(notification.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(notification.type),
                          color: _getTypeColor(notification.type),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.type.displayName,
                              style: TextStyle(
                                color: _getTypeColor(notification.type),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (notification.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: notification.priority.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.priority.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Message
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Meta info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (notification.senderName != null)
                          _buildMetaRow(
                            Icons.person_outline_rounded,
                            'From',
                            notification.senderName!,
                          ),
                        _buildMetaRow(
                          Icons.access_time_rounded,
                          'Received',
                          DateFormat('MMMM d, y \u2022 h:mm a')
                              .format(notification.timestamp),
                        ),
                        if (notification.expiryDate != null)
                          _buildMetaRow(
                            Icons.event_rounded,
                            notification.isExpired ? 'Expired' : 'Expires',
                            DateFormat('MMMM d, y')
                                .format(notification.expiryDate!),
                            isExpired: notification.isExpired,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action button
                  if (_hasAction(notification.type))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getTypeColor(notification.type),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getActionLabel(notification.type),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value,
      {bool isExpired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isExpired ? Colors.red : Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isExpired ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAction(NotificationType type) {
    return type != NotificationType.general &&
        type != NotificationType.announcement;
  }

  String _getActionLabel(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return 'View Bills';
      case NotificationType.grade:
        return 'View Grades';
      case NotificationType.event:
        return 'View Events';
      case NotificationType.schedule:
        return 'View Schedule';
      case NotificationType.club:
        return 'View Clubs';
      case NotificationType.exam:
        return 'View Exams';
      default:
        return 'View Details';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.exam:
        return Icons.school_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.grade:
        return Icons.grade_rounded;
      case NotificationType.event:
        return Icons.event_rounded;
      case NotificationType.schedule:
        return Icons.schedule_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.club:
        return Icons.groups_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.exam:
        return const Color(0xFFE53935);
      case NotificationType.payment:
        return const Color(0xFFD32F2F);
      case NotificationType.grade:
        return const Color(0xFF43A047);
      case NotificationType.event:
        return const Color(0xFF1E88E5);
      case NotificationType.schedule:
        return const Color(0xFFFB8C00);
      case NotificationType.announcement:
        return const Color(0xFF5E35B1);
      case NotificationType.club:
        return const Color(0xFF8E24AA);
      case NotificationType.general:
        return const Color(0xFF757575);
    }
  }
}
