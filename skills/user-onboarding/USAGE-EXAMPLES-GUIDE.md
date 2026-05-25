# Usage Examples Guide

How other skills use `user-profile.json` for personalization.

## `frontend-web` (with React + Tailwind + dark + minimalist)

> "Veo que prefieres React + Tailwind para web. Para este proyecto, sugiero dark mode minimalista. ¿Confirmas o exploramos otras opciones?"

## `frontend-mobile` (Native: React Native + Expo)

> "Veo que prefieres React Native nativo con Expo. ¿Confirmas para esta app o exploramos Flutter?"

## `frontend-pwa` (Hybrid: Ionic/Capacitor + Next.js)

> "Veo que prefieres web apps híbridas con Ionic/Capacitor. Propondré Next.js + Capacitor para publicar en web ahora y App Store después. ¿Confirmas?"

## `architecture-analysis` (Node.js + PostgreSQL + Vercel)

> "Basado en tu perfil (Node.js + PostgreSQL + Vercel), propongo:
> - A: Next.js fullstack (Vercel, tu preferencia)
> - B: Decoupled (Node + Express)
> - C: Serverless (Cloudflare Workers)
> ¿Revisas opciones o profundizo en una?"

## `spec-driven-development` (Developer, fintech, 3-5 years)

> "Sé que eres developer en fintech con 3-5 años. Asumo que necesitas compliance básico y seguridad robusta. ¿Correcto?"

## Updating Preferences

**User:** *"Ahora uso Vue en lugar de React"*

**Agent:**
1. Update `preferences.web_framework = "vue"`
2. Confirm: "He actualizado tu perfil. Ahora asumiré Vue."
3. Ask: "¿Adaptamos este proyecto a Vue, o solo para futuros?"
