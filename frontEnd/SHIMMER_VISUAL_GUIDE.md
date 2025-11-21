# Shimmer Loading Visual Guide

## What You'll See When Opening the App

### 1. **Login → Home Page Transition**

```
┌─────────────────────────────────────┐
│ [Loading State - 0.5s]              │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🔴 EPI App                      │ │ ← Red app bar
│ │ ⚪ ▭▭▭▭▭▭▭                     │ │ ← Grey shimmer circle + text lines
│ │    ▭▭▭▭                        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ▭▭▭▭▭▭▭▭▭▭    ▭▭▭▭▭▭▭▭▭▭      │ │ ← Financial card with 2 shimmer blocks
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Next Class                      │ │
│ │ ▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭              │ │ ← Next class shimmer text
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │    ▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭      │ │ ← Event carousel shimmer box
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Current Semester Courses            │
│ ┌─────────────────────────────────┐ │
│ │ ▭▭ ▭▭▭▭▭▭▭▭▭▭▭▭▭▭   ▭▭▭        │ │ ← Course shimmer
│ │ ▭▭ ▭▭▭▭▭▭▭▭▭▭▭▭▭▭   ▭▭▭        │ │ ← Course shimmer
│ │ ▭▭ ▭▭▭▭▭▭▭▭▭▭▭▭▭▭   ▭▭▭        │ │ ← Course shimmer
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 2. **After Data Loads (0.5-1s)**

```
┌─────────────────────────────────────┐
│ [Loaded State]                      │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🔴 EPI App                      │ │
│ │ 👤A Abdul Aziz Rhimi            │ │ ← Real avatar with first letter
│ │    Student                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 💰 TND 1250    📊 120 / 180    │ │ ← Real financial data
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Next Class                      │ │
│ │ Database Systems                │ │ ← Real course name
│ │ 🕐 14:00 - 15:30               │ │
│ │ 🏢 Room B-203                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │  [Event Image]                  │ │
│ │  Tech Conference 2025           │ │ ← Real event carousel
│ └─────────────────────────────────┘ │
│                                     │
│ Current Semester Courses            │
│ ┌─────────────────────────────────┐ │
│ │ 01 CS301: Data Structures   3CR │ │ ← Real courses
│ │ 02 CS302: Database Systems  3CR │ │
│ │ 03 CS303: Web Development   4CR │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Shimmer Animation

The shimmer effect is a **sliding gradient** that moves across placeholders:

```
Frame 1:  [▓░░░░░░░]  Light part on left
Frame 2:  [░▓░░░░░░]  Moving right...
Frame 3:  [░░▓░░░░░]  
Frame 4:  [░░░▓░░░░]  
Frame 5:  [░░░░▓░░░]  
Frame 6:  [░░░░░▓░░]  
Frame 7:  [░░░░░░▓░]  
Frame 8:  [░░░░░░░▓]  Light part on right
          (repeats)
```

- **Speed**: 1500ms per full cycle
- **Direction**: Left to right
- **Colors**: Grey base (E0E0E0) with lighter highlight (F5F5F5)
- **Smooth**: Uses easeInOutSine curve for natural acceleration

## Component Breakdown

### Avatar Shimmer
```
Before:  ⚪         (45px diameter grey circle)
After:   👤A        (First letter "A" in circle)
```

### Financial Card Shimmer
```
Before:  ▭▭▭▭▭▭▭▭▭▭  |  ▭▭▭▭▭▭▭▭▭▭
         Outstanding      Current Credits
         (80px wide)      (50px wide)

After:   TND 1250    |  120 / 180
         Outstanding      Current Credits
```

### Next Class Shimmer
```
Before:  Next Class
         ▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭
         (150px wide text placeholder)

After:   Next Class
         Database Systems
         🕐 14:00 - 15:30
         🏢 Room B-203
```

### Event Carousel Shimmer
```
Before:  ┌──────────────────┐
         │                  │
         │   ▭▭▭▭▭▭▭▭▭▭▭    │ (Full width x 200px height)
         │                  │
         └──────────────────┘

After:   ┌──────────────────┐
         │  [Event Image]   │
         │                  │
         │  Event Title     │
         └──────────────────┘
```

### Course Item Shimmer
```
Before:  ┌─────────────────────────────┐
         │ ▭▭ ▭▭▭▭▭▭▭▭▭▭▭▭▭  ▭▭▭     │
         │     (code) (name)  (credits)│
         └─────────────────────────────┘

After:   ┌─────────────────────────────┐
         │ 01 CS301           3CR      │
         │    Data Structures          │
         └─────────────────────────────┘
```

## Timeline

```
0ms     Login button pressed
        ↓
100ms   Navigate to Home Page
        ↓ [Shimmer Appears]
200ms   🟦 Shimmer placeholders visible
        ↓
300ms   📦 Cache data loads (if available)
        ↓ [Smooth transition]
400ms   ✅ Cached content visible
        ↓
500ms   🌐 API calls in background
        ↓
1500ms  📥 Fresh data arrives
        ↓ [UI updates seamlessly]
2000ms  ✅ All data refreshed
```

## Cache-First vs First-Time Login

### **First-Time Login** (No Cache)
- Shimmer shows for ~1-2 seconds
- Waits for API response
- Smooth transition to real content

### **Subsequent Opens** (With Cache)
- Shimmer shows for ~0.2-0.4 seconds
- Cached data appears almost instantly
- Background API refresh updates data silently
- User sees content immediately

## Color Specifications

```css
Base Color:      #E0E0E0  (grey[300])
Highlight Color: #F5F5F5  (grey[100])
Red Primary:     #B71C1C  (red[900])
Red Accent:      #C62828  (red[700])
White:           #FFFFFF
```

## Responsive Behavior

### Phone (Portrait)
- Full-width shimmer boxes
- Stacked layout
- Single column

### Tablet (Landscape)
- Wider shimmer placeholders
- Multi-column possible
- Larger component spacing

## Accessibility

- **Screen Readers**: Announce "Loading" state
- **Reduced Motion**: Shimmer still visible but less animated
- **High Contrast**: Maintains visibility
- **Color Blind**: Grey gradient works for all color vision types

## Best Practices Applied

✅ **Skeleton matches content**: Shimmer layout mirrors actual UI  
✅ **No jarring transitions**: Smooth fade from shimmer to content  
✅ **Immediate feedback**: User sees something instantly  
✅ **Progressive loading**: Show what's available first  
✅ **Cache-first**: Instant display on subsequent opens  
✅ **Background refresh**: Fresh data without blocking UI  
✅ **Modern UX**: Like Facebook, LinkedIn, Instagram  

## Comparison: Before vs After

### Before (Static Loading)
```
Home Page
  Loading...
  Loading...
  Loading...
  Loading...
```
❌ Boring  
❌ Feels slow  
❌ No visual feedback  
❌ Jarring when content appears  

### After (Shimmer Loading)
```
Home Page
  [Animated grey placeholders matching layout]
  ▭▭▭ ← shimmer →
  ▭▭▭▭▭ ← shimmer →
  [Smooth fade to real content]
```
✅ Modern  
✅ Feels fast  
✅ Clear visual feedback  
✅ Smooth transitions  
✅ Professional appearance  

---

**User Experience Goal**: Make the app feel **instant** and **responsive** even during network delays. Users should never see blank screens or static "Loading..." text. Instead, they see beautiful animated placeholders that match the final content layout, creating a seamless and professional experience.
