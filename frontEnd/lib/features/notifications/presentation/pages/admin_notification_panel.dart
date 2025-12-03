// lib/features/notifications/presentation/pages/admin_notification_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../data/models/notification_model.dart';
import '../../data/models/notification_template.dart';
import '../../data/services/admin_notification_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';

/// Professional Admin Notification Panel with modern UI/UX
/// Features: Send notifications, templates, analytics dashboard
class AdminNotificationPanel extends StatefulWidget {
  const AdminNotificationPanel({super.key});

  @override
  State<AdminNotificationPanel> createState() => _AdminNotificationPanelState();
}

class _AdminNotificationPanelState extends State<AdminNotificationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late AdminNotificationService _adminService;
  final NotificationService _backendService = NotificationService();
  
  static String get _apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  // Form fields
  NotificationType _selectedType = NotificationType.general;
  NotificationPriority? _selectedPriority;
  NotificationTarget _selectedTarget = NotificationTarget.individual;
  NotificationTemplate? _selectedTemplate;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _actionUrlController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _classIdController = TextEditingController();
  final TextEditingController _majorIdController = TextEditingController();
  
  DateTime? _expiryDate;
  bool _isScheduled = false;
  DateTime? _scheduledTime;
  
  final Map<String, TextEditingController> _templateVariables = {};
  
  bool _isSending = false;
  String? _sendResult;
  bool _sendSuccess = false;

  List<Map<String, dynamic>> _majors = [];
  bool _majorsLoaded = false;

  // Cached students list for autocomplete to prevent rebuilds
  List<Map<String, dynamic>> _students = [];
  bool _studentsLoaded = false;
  String _selectedStudentDisplay = ''; // Stores display text for selected student

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _adminService = AdminNotificationService(FirebaseFirestore.instance);
    _loadMajors();
    _loadStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _actionUrlController.dispose();
    _userIdController.dispose();
    _classIdController.dispose();
    _majorIdController.dispose();
    _templateVariables.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildComposeTab(),
            _buildTemplatesTab(),
            _buildAnalyticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1A1A2E),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Notification Center',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Send & manage notifications',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1A1A2E),
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.edit_rounded, size: 20),
                text: 'Compose',
              ),
              Tab(
                icon: Icon(Icons.auto_awesome_rounded, size: 20),
                text: 'Templates',
              ),
              Tab(
                icon: Icon(Icons.analytics_rounded, size: 20),
                text: 'Analytics',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Audience Card
            _buildCard(
              title: 'Target Audience',
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF6366F1),
              child: _buildTargetSelector(),
            ),
            const SizedBox(height: 20),

            // Notification Type Card
            _buildCard(
              title: 'Notification Settings',
              icon: Icons.tune_rounded,
              iconColor: const Color(0xFF10B981),
              child: Column(
                children: [
                  _buildModernDropdown<NotificationType>(
                    label: 'Type',
                    value: _selectedType,
                    items: NotificationType.values,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedPriority = value.defaultPriority;
                        // Clear template when type changes to avoid dropdown value mismatch
                        _selectedTemplate = null;
                      });
                    },
                    itemBuilder: (type) => Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTypeIcon(type),
                            color: _getTypeColor(type),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(type.displayName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPrioritySelector(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Template Card
            _buildCard(
              title: 'Quick Template',
              icon: Icons.flash_on_rounded,
              iconColor: const Color(0xFFF59E0B),
              isOptional: true,
              child: _buildTemplateSelector(),
            ),
            const SizedBox(height: 20),

            // Message Content Card
            _buildCard(
              title: 'Message Content',
              icon: Icons.message_rounded,
              iconColor: const Color(0xFFEC4899),
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Enter notification title',
                    icon: Icons.title_rounded,
                    validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _messageController,
                    label: 'Message',
                    hint: 'Enter your message here...',
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                    validator: (v) => v?.isEmpty ?? true ? 'Message is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _actionUrlController,
                    label: 'Action URL (Optional)',
                    hint: '/grades, /bills, etc.',
                    icon: Icons.link_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Template Variables (if any)
            if (_selectedTemplate != null && _selectedTemplate!.variables.isNotEmpty)
              _buildCard(
                title: 'Template Variables',
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF8B5CF6),
                child: _buildTemplateVariables(),
              ),

            if (_selectedTemplate != null && _selectedTemplate!.variables.isNotEmpty)
              const SizedBox(height: 20),

            // Additional Options Card
            _buildCard(
              title: 'Additional Options',
              icon: Icons.settings_rounded,
              iconColor: const Color(0xFF64748B),
              isOptional: true,
              child: Column(
                children: [
                  _buildOptionTile(
                    title: 'Expiry Date',
                    subtitle: _expiryDate == null
                        ? 'Set when notification expires'
                        : 'Expires ${_formatDate(_expiryDate!)}',
                    icon: Icons.event_rounded,
                    trailing: _expiryDate == null
                        ? const Icon(Icons.add_circle_outline_rounded)
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.red),
                            onPressed: () => setState(() => _expiryDate = null),
                          ),
                    onTap: _selectExpiryDate,
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    title: 'Schedule Send',
                    subtitle: _scheduledTime == null
                        ? 'Send immediately'
                        : 'Scheduled: ${_formatDateTime(_scheduledTime!)}',
                    icon: Icons.schedule_send_rounded,
                    trailing: Switch(
                      value: _isScheduled,
                      onChanged: (value) {
                        setState(() => _isScheduled = value);
                        if (value) _selectScheduleTime();
                      },
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {
                      setState(() => _isScheduled = !_isScheduled);
                      if (_isScheduled) _selectScheduleTime();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Send Button
            _buildSendButton(),

            // Result Message
            if (_sendResult != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    bool isOptional = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (isOptional) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Optional',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Column(
      children: [
        // Target Type Selection
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              _buildTargetChip(
                target: NotificationTarget.individual,
                icon: Icons.person_rounded,
                label: 'Individual',
              ),
              _buildTargetChip(
                target: NotificationTarget.classGroup,
                icon: Icons.group_rounded,
                label: 'Class',
              ),
              _buildTargetChip(
                target: NotificationTarget.allStudents,
                icon: Icons.groups_rounded,
                label: 'All',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Target Input
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildTargetInput(),
        ),
      ],
    );
  }

  Widget _buildTargetChip({
    required NotificationTarget target,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTarget == target;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTarget = target),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInput() {
    switch (_selectedTarget) {
      case NotificationTarget.individual:
        if (!_studentsLoaded) {
          return const LinearProgressIndicator();
        }
        
        return Autocomplete<String>(
          key: const ValueKey('individual_autocomplete'),
          initialValue: TextEditingValue(text: _selectedStudentDisplay),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty || _students.isEmpty) {
              return const Iterable<String>.empty();
            }
            
            final query = textEditingValue.text.toLowerCase();
            return _students
                .where((student) => 
                    student['name'].toLowerCase().contains(query) ||
                    student['student_id'].toString().contains(query) ||
                    student['email'].toLowerCase().contains(query))
                .take(10)
                .map((student) => 
                    '${student['student_id']} - ${student['name']} (${student['major_name'] ?? 'No Major'})'
                );
          },
          onSelected: (String selection) {
            final studentId = selection.split(' - ')[0];
            _userIdController.text = studentId;
            _selectedStudentDisplay = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return _buildModernTextField(
              controller: controller,
              focusNode: focusNode,
              label: 'Search Student',
              hint: 'Search by name, ID, or email...',
              icon: Icons.person_search_rounded,
              validator: (v) => v?.isEmpty ?? true ? 'Student is required' : null,
              onChanged: (value) {
                _selectedStudentDisplay = value;
                if (value.contains(' - ')) {
                  _userIdController.text = value.split(' - ')[0];
                }
              },
            );
          },
        );

      case NotificationTarget.classGroup:
        return _buildModernTextField(
          key: const ValueKey('class'),
          controller: _classIdController,
          label: 'Class ID',
          hint: 'Enter class ID (e.g., CS301)',
          icon: Icons.class_rounded,
          validator: (v) => v?.isEmpty ?? true ? 'Class ID is required' : null,
        );

      case NotificationTarget.major:
        return _buildMajorSelector();

      case NotificationTarget.allStudents:
        return Container(
          key: const ValueKey('all'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Broadcast to All',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'This will send to all registered students',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPrioritySelector() {
    final priority = _selectedPriority ?? _selectedType.defaultPriority;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: NotificationPriority.values.map((p) {
            final isSelected = p == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPriority = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: p != NotificationPriority.low ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? p.color : p.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: p.color,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPriorityIcon(p),
                        size: 20,
                        color: isSelected ? Colors.white : p.color,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : p.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector() {
    final templates = NotificationTemplates.getTemplatesByType(_selectedType);
    
    // Validate that current template belongs to selected type, clear if not
    final validTemplateId = (templates.any((t) => t.id == _selectedTemplate?.id))
        ? _selectedTemplate?.id
        : null;
    
    return DropdownButtonFormField<String>(
      value: validTemplateId,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFF59E0B)),
      ),
      hint: const Text('Select a template'),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('None - Custom Message'),
        ),
        ...templates.map((template) => DropdownMenuItem(
              value: template.id,
              child: Text(template.name),
            )),
      ],
      onChanged: (templateId) {
        final template = templateId == null 
            ? null 
            : templates.firstWhere((t) => t.id == templateId);
        setState(() {
          _selectedTemplate = template;
          if (template != null) {
            _titleController.text = template.titleTemplate;
            _messageController.text = template.messageTemplate;
            if (template.actionUrl != null) {
              _actionUrlController.text = template.actionUrl!;
            }
            _templateVariables.clear();
            for (final variable in template.variables) {
              _templateVariables[variable] = TextEditingController();
            }
          }
        });
      },
    );
  }

  Widget _buildTemplateVariables() {
    if (_selectedTemplate == null) return const SizedBox.shrink();
    
    return Column(
      children: _selectedTemplate!.variables.map((variable) {
        // Ensure controller exists, create if missing
        _templateVariables[variable] ??= TextEditingController();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildModernTextField(
            controller: _templateVariables[variable]!,
            label: variable.replaceAll('_', ' ').toUpperCase(),
            hint: 'Enter {$variable}',
            icon: Icons.edit_rounded,
            validator: (v) => v?.isEmpty ?? true ? '$variable is required' : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: itemBuilder(item),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildSendButton() {
    final priority = _selectedPriority ?? _selectedType.defaultPriority;
    
    return Row(
      children: [
        // Preview Button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: priority.color, width: 2),
            ),
            child: ElevatedButton(
              onPressed: _isSending ? null : _showPreviewDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.preview_rounded, color: priority.color, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Preview',
                      style: TextStyle(
                        color: priority.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Send Button
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [priority.color, priority.color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: priority.color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScheduled ? Icons.schedule_send_rounded : Icons.send_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isScheduled ? 'Schedule' : 'Send',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPreviewDialog() {
    if (!_formKey.currentState!.validate()) return;

    String title = _titleController.text;
    String message = _messageController.text;

    // Fill template variables if template selected
    if (_selectedTemplate != null) {
      final values = <String, String>{};
      for (final variable in _selectedTemplate!.variables) {
        final controller = _templateVariables[variable];
        if (controller != null) {
          values[variable] = controller.text;
        }
      }
      title = _selectedTemplate!.getTitle(values);
      message = _selectedTemplate!.getMessage(values);
    }

    final priority = _selectedPriority ?? _selectedType.defaultPriority;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: priority.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.preview_rounded, color: priority.color),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Notification Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Preview Card (mimics how it will appear to students)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type & Priority badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(_selectedType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getTypeIcon(_selectedType), size: 14, color: _getTypeColor(_selectedType)),
                              const SizedBox(width: 6),
                              Text(
                                _selectedType.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getTypeColor(_selectedType),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: priority.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: priority.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Message
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    
                    // Action URL if present
                    if (_actionUrlController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.link_rounded, size: 14, color: Colors.blue[600]),
                          const SizedBox(width: 6),
                          Text(
                            _actionUrlController.text,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Expiry if set
                    if (_expiryDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: Colors.orange[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Expires: ${_formatDate(_expiryDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Target info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_rounded, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getTargetDescription(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _sendNotification();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: priority.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(_isScheduled ? 'Schedule Now' : 'Send Now'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTargetDescription() {
    switch (_selectedTarget) {
      case NotificationTarget.individual:
        return 'Sending to Student ID: ${_userIdController.text.isEmpty ? "(not specified)" : _userIdController.text}';
      case NotificationTarget.classGroup:
        return 'Sending to Class: ${_classIdController.text.isEmpty ? "(not specified)" : _classIdController.text}';
      case NotificationTarget.major:
        return 'Sending to Major: ${_majorIdController.text.isEmpty ? "(not specified)" : _majorIdController.text}';
      case NotificationTarget.allStudents:
        return 'Sending to ALL students';
      default:
        return 'Target not specified';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildResultCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sendSuccess
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _sendSuccess
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_sendSuccess ? Colors.green : Colors.red).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _sendSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: _sendSuccess ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _sendResult!,
              style: TextStyle(
                color: _sendSuccess ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final templates = NotificationTemplates.allTemplates;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = template.type;
                  _selectedTemplate = template;
                  _selectedPriority = template.priority;
                  _tabController.animateTo(0);
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            template.priority.color,
                            template.priority.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getTypeIcon(template.type),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(template.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  template.type.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getTypeColor(template.type),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: template.priority.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  template.priority.displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: template.priority.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            template.titleTemplate,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _adminService.getNotificationStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Error loading analytics', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Total Sent',
                    stats['totalSent'].toString(),
                    Icons.send_rounded,
                    const Color(0xFF6366F1),
                  ),
                  _buildStatCard(
                    'Success Rate',
                    '${stats['successRate']}%',
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                  _buildStatCard(
                    'Active',
                    stats['totalNotifications'].toString(),
                    Icons.notifications_active_rounded,
                    const Color(0xFFF59E0B),
                  ),
                  _buildStatCard(
                    'Failed',
                    stats['totalFailures'].toString(),
                    Icons.error_rounded,
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // By Type Section
              _buildAnalyticsSection(
                'By Type',
                Icons.category_rounded,
                (stats['byType'] as Map<String, dynamic>).entries.map((e) {
                  final type = NotificationType.values.firstWhere(
                    (t) => t.name == e.key,
                    orElse: () => NotificationType.general,
                  );
                  return _buildAnalyticsRow(
                    type.displayName,
                    e.value.toString(),
                    _getTypeColor(type),
                    _getTypeIcon(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // By Priority Section
              _buildAnalyticsSection(
                'By Priority',
                Icons.flag_rounded,
                (stats['byPriority'] as Map<String, dynamic>).entries.map((e) {
                  final priority = NotificationPriority.values.firstWhere(
                    (p) => p.name == e.key,
                    orElse: () => NotificationPriority.medium,
                  );
                  return _buildAnalyticsRow(
                    priority.displayName,
                    e.value.toString(),
                    priority.color,
                    _getPriorityIcon(priority),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMajorSelector() {
    if (!_majorsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<String>(
      value: _majorIdController.text.isEmpty ? null : _majorIdController.text,
      decoration: InputDecoration(
        labelText: 'Select Major',
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.school_rounded, color: Colors.grey[600]),
      ),
      items: _majors.map((major) {
        return DropdownMenuItem<String>(
          value: major['id'].toString(),
          child: Text('${major['code']} - ${major['name']}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _majorIdController.text = value ?? '');
      },
      validator: (value) => value?.isEmpty ?? true ? 'Major is required' : null,
    );
  }

  // Helper Methods
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

  IconData _getPriorityIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Icons.warning_rounded;
      case NotificationPriority.high:
        return Icons.priority_high_rounded;
      case NotificationPriority.medium:
        return Icons.remove_rounded;
      case NotificationPriority.low:
        return Icons.arrow_downward_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  Future<void> _selectScheduleTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _loadMajors() async {
    try {
      _majors = await _adminService.getMajors();
      _majorsLoaded = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to load majors: $e');
    }
  }

  Future<void> _loadStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> studentsData = responseData['data'] ?? [];
        
        _students = studentsData.map((student) => {
          'id': student['id'],
          'student_id': student['student_id'],
          'name': student['name'],
          'email': student['email'],
          'major_name': student['major_name'] ?? student['major']?['name'],
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }
    _studentsLoaded = true;
    if (mounted) setState(() {});
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _sendResult = null;
    });

    try {
      String title = _titleController.text;
      String message = _messageController.text;

      // Fill template variables
      if (_selectedTemplate != null) {
        final values = <String, String>{};
        for (final variable in _selectedTemplate!.variables) {
          final controller = _templateVariables[variable];
          if (controller != null) {
            values[variable] = controller.text;
          }
        }
        title = _selectedTemplate!.getTitle(values);
        message = _selectedTemplate!.getMessage(values);
      }

      String targetType;
      List<String>? targetUsers;
      List<String>? targetClasses;

      switch (_selectedTarget) {
        case NotificationTarget.individual:
          targetType = 'individual';
          targetUsers = [_userIdController.text.trim()];
          break;
        case NotificationTarget.classGroup:
          targetType = 'class';
          targetClasses = [_classIdController.text.trim()];
          break;
        case NotificationTarget.major:
          targetType = 'class';
          targetClasses = [_majorIdController.text.trim()];
          break;
        case NotificationTarget.allStudents:
          targetType = 'all';
          break;
        default:
          throw Exception('Invalid target type');
      }

      final result = await _backendService.send(
        title: title,
        message: message,
        type: _selectedType.name,
        targetType: targetType,
        senderId: 'admin',
        senderName: 'Admin',
        priority: (_selectedPriority ?? _selectedType.defaultPriority).name,
        targetUsers: targetUsers,
        targetClasses: targetClasses,
        metadata: {
          if (_actionUrlController.text.isNotEmpty) 'actionUrl': _actionUrlController.text,
          if (_expiryDate != null) 'expiryDate': _expiryDate!.toIso8601String(),
        },
      );

      if (result.success) {
        setState(() {
          _sendSuccess = true;
          _sendResult = 'Notification sent to ${result.recipients ?? 0} recipient(s)';
        });

        // Clear form
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _titleController.clear();
            _messageController.clear();
            _actionUrlController.clear();
            _userIdController.clear();
            _classIdController.clear();
            _majorIdController.clear();
            setState(() {
              _sendResult = null;
              _selectedTemplate = null;
              _expiryDate = null;
              _isScheduled = false;
              _scheduledTime = null;
            });
          }
        });
      } else {
        throw Exception(result.error ?? 'Failed to send notification');
      }
    } catch (e) {
      setState(() {
        _sendSuccess = false;
        _sendResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}
