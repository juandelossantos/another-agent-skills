# Mobile Examples & Troubleshooting

This guide contains practical examples and common issues for `frontend-mobile`.

---

## Example 1: New Mobile App (15 Steps)

### Scenario
User: *"Crea una app de fitness para iOS y Android. Quiero seguimiento de workouts, progreso visual, y notificaciones de recordatorio. Estética moderna y oscura."*

### Step-by-Step

1. **Detect platform:** Mobile (iOS + Android)
2. **Invoke `frontend-mobile`**
3. **Phase 1 — Discovery:**
   - Audience: Fitness enthusiasts, public consumers
   - Purpose: Track workouts, visualize progress, reminders
   - Scope: Standard (4-6 screens: Dashboard, Workout, History, Profile, Settings)
   - Platform: Both (React Native + Expo recommended)
   - Native features: Push notifications, possibly GPS for runs
   - Visual: Modern, dark mode
   → User confirms

4. **Phase 2 — SPEC.md:**
   - Invoke `spec-driven-development`
   - Include: Platform targets (iOS 15+, Android API 26+)

5. **Phase 2 — DESIGN.md:**
   - Aesthetic: Swiss Minimal (dark variant) or Neo-Brutalist
   - Tokens: Dark background (#0A0A0F), accent (#FF6B35), typography (Inter display NO → use Space Grotesk or similar)
   → User confirms

6. **Design Asset Lock:**
   - Create `design/DESIGN-LOCK.md` + `design/approved/`

7. **PLAN phase:**
   - Invoke `planning-and-task-breakdown`
   - Screens: Onboarding → Dashboard → Workout Detail → Active Workout → History → Profile

8. **Phase 3 — Stack Lock:**
   - React Native 0.76+ + Expo SDK 52+
   - Reanimated 3.16+
   - React Native Gesture Handler
   - expo-notifications

9. **Phase 6 — Build:**
   - Theme provider with dark tokens
   - SafeAreaView on every screen
   - Tab navigation (Dashboard, History, Profile)
   - Stack navigation for Workout flows
   - Reanimated entrance animations
   - Push notification setup

10. **QA Gates:**
    - TypeScript passes
    - `expo prebuild` succeeds
    - No hardcoded colors
    - Accessibility labels on all interactives
    - Reduced motion respected
    - 375pt and 428pt tested

11. **SHIP:**
    - Prepare for App Store + Google Play
    - Icons, screenshots, descriptions

---

## Example 2: Adding Animation to Existing Component

### Scenario
User: *"Add animation to this exercise list. I want items to appear smoothly when entering the screen."*

### Solution

```tsx
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
  withDelay,
} from 'react-native-reanimated';

function ExerciseItem({ exercise, index }) {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(20);

  useEffect(() => {
    opacity.value = withDelay(index * 100, withTiming(1, { duration: 400 }));
    translateY.value = withDelay(index * 100, withTiming(0, { duration: 400 }));
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return (
    <Animated.View style={[styles.item, animatedStyle]}>
      <Text style={styles.name}>{exercise.name}</Text>
      <Text style={styles.duration}>{exercise.duration}</Text>
    </Animated.View>
  );
}
```

---

## Troubleshooting

### Issue: Fonts not loading in Expo

**Symptoms:** App shows system font instead of custom font.

**Solution:**
```tsx
import { useFonts } from 'expo-font';

function App() {
  const [fontsLoaded] = useFonts({
    'SpaceGrotesk-Bold': require('./assets/fonts/SpaceGrotesk-Bold.ttf'),
    'Inter-Regular': require('./assets/fonts/Inter-Regular.ttf'),
  });

  if (!fontsLoaded) {
    return <LoadingScreen />;
  }

  return <Navigation />;
}
```

**Root cause:** Fonts must be loaded before rendering. Always show a loading screen.

---

### Issue: SafeAreaView not working on Android

**Symptoms:** Content hidden under status bar or notch on Android.

**Solution:**
```tsx
import { SafeAreaView } from 'react-native-safe-area-context';

// Wrap your app root
function App() {
  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.container}>
        {/* Your app */}
      </SafeAreaView>
    </SafeAreaProvider>
  );
}
```

**Root cause:** `SafeAreaView` from `react-native` doesn't work on Android. Use `react-native-safe-area-context`.

---

### Issue: Reanimated not working (worklet error)

**Symptoms:** "Tried to synchronously call function from a different thread" error.

**Solution:**
```tsx
// ❌ WRONG: Calling JS function from worklet
const animatedStyle = useAnimatedStyle(() => ({
  opacity: someJsFunction(), // Error!
}));

// ✅ CORRECT: Pure worklet
const animatedStyle = useAnimatedStyle(() => ({
  opacity: interpolate(scrollY.value, [0, 100], [1, 0]),
}));
```

**Root cause:** Worklets run on UI thread. Can't call JS functions directly.

---

### Issue: Gesture handler conflicts with scroll

**Symptoms:** Pan gesture doesn't work inside ScrollView.

**Solution:**
```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler';

const panGesture = Gesture.Pan()
  .activeOffsetY([-10, 10]) // Only activate if vertical movement > 10
  .onUpdate((e) => {
    // Handle pan
  });

// Wrap ScrollView content, not the ScrollView itself
```

**Root cause:** Gestures compete. Use `activeOffsetY`/`activeOffsetX` to define activation zones.

---

### Issue: Push notifications not received on iOS simulator

**Symptoms:** Notifications work on device but not simulator.

**Solution:**
```tsx
// iOS simulator doesn't support remote push notifications
// Use local notifications for testing:
import * as Notifications from 'expo-notifications';

Notifications.scheduleNotificationAsync({
  content: { title: 'Test', body: 'This is a local notification' },
  trigger: { seconds: 2 },
});
```

**Root cause:** iOS simulator can't receive APNS (Apple Push Notification Service). Test on real device.

---

### Issue: App size too large

**Symptoms:** APK/IPA exceeds store limits or user complaints.

**Solutions:**
1. Use `expo-image` instead of `Image` (better compression)
2. Enable Hermes engine (default in Expo SDK 52+)
3. Remove unused native modules
4. Use ProGuard/R8 for Android
5. Strip debug symbols for iOS

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll test on simulator only." | Simulators are 10x faster. Always test on a mid-range real device. |
| "iOS and Android look the same." | Users expect platform-native patterns. Don't force iOS patterns on Android. |
| "I'll add accessibility later." | Screen readers and VoiceOver need proper labels from day one. |
| "Push notifications are easy." | They require server setup, permissions, and handling in killed state. Plan for it. |
| "Expo handles everything." | Expo simplifies, but you still need to understand native concepts. |
