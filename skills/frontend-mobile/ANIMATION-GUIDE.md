# Mobile Animation Guide

This guide contains the complete Phase 5 Animation System for `frontend-mobile`.

## Philosophy

Mobile animations must feel **native**, not ported from web. They should:
- Follow platform conventions (iOS spring physics, Android easing curves)
- Respect battery life (don't animate things that don't need animation)
- Work at 60fps on mid-range devices
- Respect `AccessibilityInfo.isReduceMotionEnabled()`

---

## Primary Pattern: Reanimated 3

### Setup

```tsx
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  withDelay,
  Easing,
} from 'react-native-reanimated';
```

### Entrance Animation: Fade + Slide Up

```tsx
function FadeInView({ children, delay = 0 }) {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(20);

  useEffect(() => {
    opacity.value = withDelay(delay, withTiming(1, { duration: 400 }));
    translateY.value = withDelay(delay, withSpring(0, { damping: 12 }));
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return <Animated.View style={animatedStyle}>{children}</Animated.View>;
}
```

### Spring Physics (iOS-like)

```tsx
// iOS-style spring
withSpring(targetValue, {
  damping: 12,    // Higher = less bounce
  stiffness: 100, // Higher = faster
  mass: 1,
});
```

### Gesture-Driven Animation

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler';

function SwipeableCard() {
  const translateX = useSharedValue(0);

  const gesture = Gesture.Pan()
    .onUpdate((e) => {
      translateX.value = e.translationX;
    })
    .onEnd((e) => {
      if (Math.abs(e.translationX) > 100) {
        // Swipe far enough → dismiss
        translateX.value = withSpring(Math.sign(e.translationX) * 500);
      } else {
        // Snap back
        translateX.value = withSpring(0);
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.card, animatedStyle]}>
        {/* Card content */}
      </Animated.View>
    </GestureDetector>
  );
}
```

---

## Scroll-Driven Animations

### Header Collapse on Scroll

```tsx
import Animated, {
  useAnimatedScrollHandler,
  interpolate,
  Extrapolation,
} from 'react-native-reanimated';

function CollapsibleHeader() {
  const scrollY = useSharedValue(0);

  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (e) => {
      scrollY.value = e.contentOffset.y;
    },
  });

  const headerHeight = useAnimatedStyle(() => ({
    height: interpolate(
      scrollY.value,
      [0, 100],
      [120, 60],
      Extrapolation.CLAMP
    ),
  }));

  return (
    <View>
      <Animated.View style={[styles.header, headerHeight]}>
        {/* Header content */}
      </Animated.View>
      <Animated.ScrollView onScroll={scrollHandler} scrollEventThrottle={16}>
        {/* Scroll content */}
      </Animated.ScrollView>
    </View>
  );
}
```

---

## Platform-Specific Patterns

### iOS: Smooth Transitions

```tsx
// iOS prefers spring-based transitions
withSpring(targetValue, { damping: 15, stiffness: 150 });
```

### Android: Material Motion

```tsx
// Android Material uses specific easing curves
withTiming(targetValue, {
  duration: 300,
  easing: Easing.bezier(0.4, 0.0, 0.2, 1), // Material standard
});
```

---

## Accessibility: Reduced Motion

```tsx
import { AccessibilityInfo } from 'react-native';

function AccessibleAnimation() {
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    AccessibilityInfo.isReduceMotionEnabled().then(setReduceMotion);
  }, []);

  const animate = (value) => {
    if (reduceMotion) {
      // Instant change, no animation
      return value;
    }
    return withSpring(value, { damping: 12 });
  };

  // Use animate() instead of withSpring directly
}
```

---

## Performance Rules

1. **Only animate `transform` and `opacity`**
   - ✅ `translateX`, `translateY`, `scale`, `rotate`, `opacity`
   - ❌ `width`, `height`, `top`, `left`, `margin`

2. **Use `useAnimatedStyle`, not inline styles**
   - Worklet runs on UI thread, not JS thread

3. **Avoid re-renders during animation**
   - Don't setState in gesture onUpdate
   - Use shared values

4. **Test on real devices**
   - Simulators are 10x faster than mid-range Android

---

## Forbidden Patterns

| Pattern | Why Forbidden | Alternative |
|---|---|---|
| `LayoutAnimation` (RN built-in) | Unreliable, buggy on Android | Reanimated layout animations |
| `Animated` API (RN built-in) | Slower, fewer features | Reanimated |
| Animating `flex` values | Layout thrashing | Animate `transform` instead |
| `setState` in `onScroll` | 60 re-renders/second | Use shared values + animated styles |
| Complex calculations in worklet | UI thread blocking | Pre-calculate, animate result |

---

## Verification Checklist

Before declaring animations complete:
- [ ] All animations respect `AccessibilityInfo.isReduceMotionEnabled()`
- [ ] Only `transform` and `opacity` are animated
- [ ] Gestures feel native (spring physics, not linear)
- [ ] 60fps on mid-range device (tested, not assumed)
- [ ] No re-renders during animation
- [ ] iOS and Android both tested (behaviors differ)
