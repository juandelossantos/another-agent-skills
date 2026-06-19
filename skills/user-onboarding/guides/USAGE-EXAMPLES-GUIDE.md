# Usage Examples Guide

How other skills use `user-profile.json` for personalization.

## `frontend-web` (with React + Tailwind + dark + minimalist)

> "I see you prefer React + Tailwind for web. For this project, I suggest dark mode minimalist. Confirm or explore other options?"

## `frontend-mobile` (Native: React Native + Expo)

> "I see you prefer React Native with Expo. Confirm for this app or explore Flutter?"

## `frontend-pwa` (Hybrid: Ionic/Capacitor + Next.js)

> "I see you prefer hybrid web apps with Ionic/Capacitor. I'll propose Next.js + Capacitor to publish on web now and App Store later. Confirm?"

## `architecture-analysis` (Node.js + PostgreSQL + Vercel)

> "Based on your profile (Node.js + PostgreSQL + Vercel), I propose:
> - A: Next.js fullstack (Vercel, your preference)
> - B: Decoupled (Node + Express)
> - C: Serverless (Cloudflare Workers)
> Review options or dive deeper into one?"

## `spec-driven-development` (Developer, fintech, 3-5 years)

> "I see you're a fintech developer with 3-5 years. I'll assume you need basic compliance and robust security. Correct?"

## Updating Preferences

**User:** *"I use Vue instead of React now"*

**Agent:**
1. Update `preferences.web_framework = "vue"`
2. Confirm: "Profile updated. I'll assume Vue going forward."
3. Ask: "Adapt this project to Vue, or only future projects?"
