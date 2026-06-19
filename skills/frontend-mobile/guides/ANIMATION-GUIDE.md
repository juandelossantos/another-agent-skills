# Frontend Mobile — Animation Guide

Canonical skeletons and motion philosophy for React Native + Reanimated. All animations must respect `AccessibilityInfo.isReduceMotionEnabled()`.

---

## 1. Default Pattern: Reanimated Fade-Up

```tsx
import { useSharedValue, useAnimatedStyle, withSpring } from "react-native-reanimated";
import { useEffect } from "react";
import { useReducedMotion } from "react-native-reanimated";

export function FadeUp({ children, delay = 0 }: { children: React.ReactNode; delay?: number }) {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(24);
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce) {
      opacity.value = 1;
      translateY.value = 0;
      return;
    }
    const timer = setTimeout(() => {
      opacity.value = withSpring(1, { damping: 20, stiffness: 100 });
      translateY.value = withSpring(0, { damping: 20, stiffness: 100 });
    }, delay);
    return () => clearTimeout(timer);
  }, []);

  const style = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  return <Animated.View style={style}>{children}</Animated.View>;
}
```

---

## 2. Gesture-Based Animation (Reanimated + Gesture Handler)

```tsx
import { Gesture, GestureDetector } from "react-native-gesture-handler";
import Animated, { useSharedValue, useAnimatedStyle, withSpring } from "react-native-reanimated";

export function PressScale({ children }: { children: React.ReactNode }) {
  const scale = useSharedValue(1);

  const tap = Gesture.Tap()
    .onBegin(() => { scale.value = withSpring(0.96); })
    .onFinalize(() => { scale.value = withSpring(1); });

  const style = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <GestureDetector gesture={tap}>
      <Animated.View style={style}>{children}</Animated.View>
    </GestureDetector>
  );
}
```

---

## 3. Layout Animation (expo-layout-animation)

For list insertions, deletions, and reordering:

```tsx
import { LayoutAnimation, Platform, UIManager } from "react-native";

if (Platform.OS === "android" && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
// Then update state — the view animates automatically
```

---

## 4. Reduced Motion (AccessibilityInfo)

```tsx
import { AccessibilityInfo } from "react-native";

const [reduceMotion, setReduceMotion] = useState(false);

useEffect(() => {
  AccessibilityInfo.isReduceMotionEnabled().then(setReduceMotion);
  const sub = AccessibilityInfo.addEventListener("reduceMotionChanged", setReduceMotion);
  return () => sub.remove();
}, []);
```

---

## 5. Forbidden Patterns

- `Animated.timing` with `duration: 0` — use `useSharedValue` + `withSpring`
- Animating `width`, `height`, `top`, `left` — animate only `transform` and `opacity`
- No `requestAnimationFrame` loops — use Reanimated worklets
- No gesture state in React state — use Gesture Handler callbacks
- No layout animations without `LayoutAnimation` or Reanimated Layout
