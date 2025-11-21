# Shimmer Loading - Quick Implementation Guide

## How to Add Shimmer Loading to Any Page

### Step 1: Import the Shimmer Widget

```dart
import 'package:epiapp/shared/widgets/shimmer_loading.dart';
```

### Step 2: Detect Loading State

```dart
Consumer<YourController>(
  builder: (context, controller, child) {
    final data = controller.yourData;
    final isLoading = data == null;  // or data.isEmpty for lists
    
    // Your UI here
  },
)
```

### Step 3: Show Shimmer When Loading

```dart
if (isLoading) {
  return ShimmerText(width: 120, height: 16);
} else {
  return Text(data.actualValue);
}
```

## Pre-Built Shimmer Components

### 1. ShimmerBox
```dart
// Rectangular placeholder
ShimmerBox(
  width: 200,
  height: 100,
  borderRadius: BorderRadius.circular(10),
)
```

**Use for**: Cards, images, buttons, containers

### 2. ShimmerCircle
```dart
// Circular placeholder
ShimmerCircle(diameter: 50)
```

**Use for**: Avatars, profile pictures, circular buttons

### 3. ShimmerText
```dart
// Text line placeholder
ShimmerText(
  width: 150,
  height: 14,
)
```

**Use for**: Text labels, titles, descriptions

## Common Patterns

### Avatar with Name
```dart
isLoading
  ? Row(
      children: [
        const ShimmerCircle(diameter: 50),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerText(width: 120, height: 16),
            const SizedBox(height: 4),
            const ShimmerText(width: 80, height: 12),
          ],
        ),
      ],
    )
  : Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name),
            Text(user.role),
          ],
        ),
      ],
    )
```

### Card with Icon and Text
```dart
isLoading
  ? Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ShimmerBox(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerText(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                const ShimmerText(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    )
  : YourRealCard()
```

### List of Items
```dart
isLoading
  ? Column(
      children: List.generate(
        5, // Number of shimmer items
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildItemShimmer(),
        ),
      ),
    )
  : ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => YourListItem(items[index]),
    )
```

### Image Placeholder
```dart
isLoading
  ? ShimmerBox(
      width: double.infinity,
      height: 200,
      borderRadius: BorderRadius.circular(12),
    )
  : Image.network(
      imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    )
```

## Example: Complete Page Implementation

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:epiapp/shared/widgets/shimmer_loading.dart';
import 'package:epiapp/core/controllers/your_controller.dart';

class YourPage extends StatefulWidget {
  const YourPage({super.key});

  @override
  State<YourPage> createState() => _YourPageState();
}

class _YourPageState extends State<YourPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<YourController>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Page'),
      ),
      body: Consumer<YourController>(
        builder: (context, controller, child) {
          final data = controller.data;
          final isLoading = data == null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Section
              isLoading
                  ? _buildHeaderShimmer()
                  : _buildHeader(data),
              
              const SizedBox(height: 24),

              // Content Section
              isLoading
                  ? _buildContentShimmer()
                  : _buildContent(data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerText(width: 200, height: 24),
        const SizedBox(height: 8),
        const ShimmerText(width: 150, height: 16),
      ],
    );
  }

  Widget _buildContentShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildItemShimmer(),
        ),
      ),
    );
  }

  Widget _buildItemShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerText(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const ShimmerText(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(YourData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(data.subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildContent(YourData data) {
    return Column(
      children: data.items.map((item) => YourItemWidget(item)).toList(),
    );
  }
}
```

## Sizing Guidelines

### Text Placeholders
- **Small text** (12px): height: 12
- **Body text** (14px): height: 14
- **Subheading** (16px): height: 16
- **Heading** (20px): height: 20
- **Large heading** (24px): height: 24

### Common Widths
- **Short label**: 60-80px
- **Medium text**: 100-150px
- **Long text**: 200-250px
- **Full width**: `double.infinity`

### Component Sizes
- **Small avatar**: 40px
- **Medium avatar**: 50px
- **Large avatar**: 80px
- **Icon button**: 40x40px
- **Card height**: 120-200px

## Best Practices

### ✅ DO
- Match shimmer layout to actual content
- Use consistent spacing between shimmer elements
- Show 3-5 shimmer items for lists
- Use `double.infinity` for full-width placeholders
- Keep shimmer simple (don't over-detail)

### ❌ DON'T
- Don't show too many shimmer items (max 5)
- Don't use shimmer for static content
- Don't mix shimmer with actual content
- Don't use shimmer for instant operations
- Don't forget border radius on shimmer boxes

## Loading State Patterns

### Pattern 1: Simple Null Check
```dart
final isLoading = data == null;
```
**Use when**: Single object/entity

### Pattern 2: Empty List Check
```dart
final isLoading = items.isEmpty && controller.errorMessage == null;
```
**Use when**: List of items that might be legitimately empty

### Pattern 3: Controller State
```dart
final isLoading = controller.state == LoadingState.loading;
```
**Use when**: Controller has explicit state enum

### Pattern 4: Combined Check
```dart
final isLoading = data == null || data.isEmpty;
```
**Use when**: Multiple loading indicators needed

## Troubleshooting

### Problem: Shimmer doesn't animate
**Solution**: Ensure `ShimmerLoading` widget wraps your shimmer components

### Problem: Shimmer appears too long
**Solution**: Check cache implementation - data should load from cache first

### Problem: Shimmer layout doesn't match content
**Solution**: Measure actual component sizes and match shimmer dimensions

### Problem: Flickering between states
**Solution**: Add small delay before showing shimmer (100-200ms)

### Problem: Shimmer too bright/dark
**Solution**: Adjust base and highlight colors in `ShimmerLoading` widget

## Animation Customization

Want to change the shimmer effect? Edit `lib/shared/widgets/shimmer_loading.dart`:

```dart
// Change speed
duration: const Duration(milliseconds: 1000), // Faster (default: 1500)

// Change curve
curve: Curves.linear, // Constant speed (default: easeInOutSine)

// Change colors
baseColor: Colors.grey[400]!, // Darker base
highlightColor: Colors.grey[200]!, // Lighter highlight

// Change direction
Tween<double>(begin: 2, end: -2) // Right to left (default: -2 to 2)
```

## Quick Checklist

Before marking shimmer implementation complete:

- [ ] Import shimmer_loading.dart
- [ ] Detect loading state (isLoading variable)
- [ ] Create shimmer placeholder methods
- [ ] Replace "Loading..." text with shimmer
- [ ] Match shimmer layout to actual content
- [ ] Test with slow network (DevTools → Network → Slow 3G)
- [ ] Test cache-first loading (close and reopen app)
- [ ] Verify smooth transitions
- [ ] Check on different screen sizes
- [ ] Ensure accessibility (screen reader announces loading)

---

**Remember**: The goal is to make loading feel **instant** and **smooth**. Users should see beautiful placeholders instead of blank screens or text spinners!
