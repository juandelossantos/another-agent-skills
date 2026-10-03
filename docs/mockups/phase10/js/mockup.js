/*
 * Another Agent Skills - Phase 10 landing MOCKUP
 * docs/mockups/phase10/js/mockup.js
 *
 * Self-contained: inline EN/ES i18n, theme + lang toggles, terminal animation,
 * and the three explanatory animations (flow, harness, loop). No libraries.
 * Progressive enhancement: all content is visible by default; JS only adds motion.
 */
(function () {
  'use strict';

  var doc = document.documentElement;
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* =========================================================
     i18n
     ========================================================= */

  var I18N = {
    en: {
      a11y: {
        skip: 'Skip to content',
        langToEs: 'Switch to Spanish',
        langToEn: 'Switch to English',
        theme: 'Toggle color theme',
        menu: 'Menu',
        copy: 'Copy install command'
      },
      theme: { dark: 'Dark', light: 'Light' },
      nav: {
        flow: 'Flow', harness: 'Harness', loop: 'The Loop', enforcement: 'Enforcement',
        skills: 'Skills', workflows: 'Workflows', faq: 'FAQ', docs: 'Docs', github: 'GitHub'
      },
      hero: {
        tag: '/// system',
        title1: 'Turn AI agents into',
        title2: 'disciplined senior engineers.',
        thesis: 'Most skill libraries sell capability.',
        thesisAccent: 'We sell discipline you can verify.',
        social: 'Open source \u00b7 MIT License \u00b7 Works offline \u00b7 No lock-in'
      },
      terminal: {
        detected: 'Detected: OpenCode \u00b7 Claude Code \u00b7 Cursor \u00b7 Codex \u00b7 Gemini',
        installed: 'Installed 57 skills \u00b7 wired the harness \u00b7 armed the gates.',
        done: 'DONE. Run init-agents in any project.',
        channels: 'Channels: git and curl live \u00b7 npm and brew soon.'
      },
      problem: {
        label: '01 / the problem',
        title: 'Agents default to the shortest path.',
        tldr: 'TL;DR: capable models still skip tests, review, and context. The gap is process, not intelligence.',
        card1Title: 'No tests before commit',
        card1Desc: 'Code that looks correct and breaks in production.',
        card2Title: 'No review before push',
        card2Desc: 'Two agents overwrite each other without noticing.',
        card3Title: 'Generic output only',
        card3Desc: 'The same patterns regardless of context or stack.',
        card4Title: 'Failures are silent',
        card4Desc: 'Damage is discovered hours later, by a human.',
        metr: 'When developers used AI, they took 19 percent longer. They estimated AI saved them 20 percent of the time.',
        metrSource: 'Becker et al., METR, July 2025',
        conclusion: 'The gap between capable and reliable is not intelligence. It is process.'
      },
      flow: {
        label: '01 / lifecycle',
        title: 'Six phases. A path that draws itself.',
        tldr: 'TL;DR: every task runs DEFINE, PLAN, BUILD, VERIFY, REVIEW, SHIP. No phase is optional and each one has an exit criterion.',
        define: { name: 'DEFINE', exit: 'Spec approved, scope locked' },
        plan: { name: 'PLAN', exit: 'Tasks small, dependencies mapped' },
        build: { name: 'BUILD', exit: 'One slice, tests written first' },
        verify: { name: 'VERIFY', exit: 'Tests pass, behavior matches spec' },
        review: { name: 'REVIEW', exit: 'No P0 issues, security checked' },
        ship: { name: 'SHIP', exit: 'Clean commit, gates green' },
        conclusion: 'No phase is optional. Every step has a skill. Every skill has a gate.'
      },
      harness: {
        label: '02 / the harness',
        title: 'A task flows down the machine.',
        tldr: 'TL;DR: the Harness is six layers around the model. A bad change reaches the guardrails layer and is blocked there, then logged.',
        l1Name: 'Instructions', l1Desc: 'Who the agent is and what it must never do.',
        l2Name: 'Tools', l2Desc: 'Task-specific capabilities, loaded on demand.',
        l3Name: 'Sandboxes', l3Desc: 'Where commands run, isolated from your system.',
        l4Name: 'Orchestration', l4Desc: 'When tools fire and how agents coordinate.',
        l5Name: 'Guardrails', l5Desc: 'Deterministic hooks at lifecycle points.',
        l6Name: 'Observability', l6Desc: 'Evidence it works or is quietly drifting.',
        blocked: 'BLOCKED',
        logged: 'logged',
        blockedNote: 'Blocked at Guardrails: a code change arrived without a matching test. Observability recorded it.',
        conclusion: 'A rule that lives only in a file is a suggestion. A rule that lives in a layer is a gate.'
      },
      loop: {
        label: '03 / the loop',
        title: 'The agent that audits itself.',
        tldr: 'TL;DR: every session can audit, diagnose, fix, and record an ADR. Findings become fixes, and fixes become decisions on record.',
        audit: 'Audit: scan core files for drift',
        diagnose: 'Diagnose: classify the root cause',
        fix: 'Fix: propose and apply with approval',
        adr: 'ADR: record the decision',
        repeat: 'Repeat: each run raises the floor',
        auditShort: 'audit', diagnoseShort: 'diagnose', fixShort: 'fix', adrShort: 'ADR', repeatShort: 'repeat',
        found: 'issues found', fixed: 'fixed', regressions: 'regressions',
        conclusion: 'Verification without evidence is inspection.'
      },
      enforcement: {
        label: '04 / enforcement',
        title: 'Show the block. Do not promise it.',
        tldr: 'TL;DR: a code change with no matching test is blocked locally by L1 and cannot be merged without the remote gates check at L2.',
        l1Title: 'Local hooks', l1Desc: 'Fast, advisory feedback before a commit leaves your machine.',
        l2Title: 'Remote gates check', l2Desc: 'A required status check. The committer cannot skip it. GitHub only.',
        l3Title: 'CODEOWNERS review', l3Desc: 'A human owns the sensitive paths. Review is required. GitHub only.',
        proofTitle: 'Real output: a blocked commit',
        proofNote1: 'The same check runs remotely as the required ',
        proofNote2: ' status, so it cannot be bypassed by the committer.',
        evidence: 'Read the remote enforcement evidence'
      },
      compat: {
        label: '06 / compatibility',
        title: 'One install. Any agent. Any stack.',
        tldr: 'TL;DR: the installer detects your agent and your stack, then wires the matching skills and hooks.',
        more: '15 agents detected',
        stack: 'Stack-agnostic: Node, Rust, Python, Go, Ruby, Dart, or any stack. init-agents writes STACK_CONFIG.md.',
        link: 'See the agent adapter matrix'
      },
      skills: {
        label: '05 / skills',
        title: 'Skills, chipped by phase.',
        tldr: 'TL;DR: 57 curated skills mapped to the lifecycle. Use all of them or the ones your workflow needs.',
        catFoundation: 'Foundation',
        catFoundationDesc: 'Contracts, context, and the interview that locks scope before code.',
        catProcess: 'Process', catFrontend: 'Build', catDebug: 'Verify', catQuality: 'Review',
        catDevops: 'Ship', catDesignReview: 'Design review', catDesignReviewTitle: 'Design review suite',
        catMeta: 'Meta', catMetaTitle: 'Meta-skills',
        stats: '57 skills \u00b7 151 guides \u00b7 6 harness components \u00b7 an eval for each',
        learn: 'Browse the full catalog'
      },
      workflows: {
        label: '08 / workflows',
        title: 'Enforcement that adapts to your project.',
        tldr: 'TL;DR: with no git you get rules only. Add git for L1 hooks. Add GitHub for L2 and L3. Re-run init-agents after each change.',
        w1Name: 'No git', w1Desc: 'Independent or private, no VCS. Rules and AGENTS.md install, but there are no hooks and no remote gate. Enforcement is convention only.',
        w2Name: 'Local git', w2Desc: 'A private repo or a non-GitHub forge. L1 hooks are active. There is no L2 or L3, so the remote authority is missing.',
        w3Name: 'Git + GitHub', w3Desc: 'Full L1 + L2 + L3. The remote gates check is required, CODEOWNERS owns sensitive paths, and the committer cannot skip either.',
        w4Name: 'Git later', w4Desc: 'No git now, git and GitHub later. The key rule: re-run init-agents after git init and after adding the remote. It detects what is now available and installs the missing layers.',
        upgrade: 'Upgrade:', thenReinit: 'then re-run', afterEach: 'after each change'
      },
      faq: {
        label: '06 / faq',
        title: 'Questions, answered plainly.',
        q1: 'What is Another Agent Skills?',
        a1: 'A framework of 57 composable skills that turn AI coding agents into disciplined senior engineers. It adds mechanical enforcement, not just prompts. Skills follow a six-phase lifecycle: Define, Plan, Build, Verify, Review, Ship.',
        q2: 'How does mechanical enforcement work?',
        a2: 'Three layers. L1 is local git hooks for fast, advisory feedback. L2 is a required remote gates check that the committer cannot skip. L3 is CODEOWNERS review for sensitive paths. A code change with no matching test is blocked, locally and remotely.',
        q3: 'Which agents does it support?',
        a3: 'Designed for OpenCode. Portable to Claude Code, Cursor, Codex, Gemini CLI, GitHub Copilot, Windsurf, Aider, and any agent that reads AGENTS.md. The installer detects the agent and wires the matching skills and hooks.',
        q4: 'Is it free?',
        a4: 'Yes. MIT License. Open source. No subscriptions and no paid tiers. The installer, the skills, and the enforcement are all free.',
        q5: 'Can an agent still break the rules?',
        a5: 'Yes. The hooks make it harder, not impossible. An agent could misread an ambiguous approval or act outside protocol. These gates create friction, not guarantees. The human stays in the loop, and the human stays alert.',
        q6: 'What is the Harness?',
        a6: 'The Harness is everything around the model that turns raw intelligence into reliable output: instructions, tools, sandboxes, orchestration, guardrails, and observability. Agent equals Model plus Harness. Most agent failures are configuration failures.',
        q7: 'How do I install it?',
        a7: 'Three channels. Clone and run install.sh, or use the pinned curl bootstrap from the latest release, or install through npm. Then run init-agents in any project. Git and curl are live today. npm and Homebrew are coming soon.'
      },
      cta: {
        label: '07 / start',
        title: 'Give your agent a gate it cannot forget.',
        lead: 'One command. The installer detects your agent and your stack, then arms the enforcement.',
        copy: 'Copy', live: 'live', soon: 'soon',
        social: 'Open source \u00b7 MIT License \u00b7 Works offline \u00b7 No lock-in'
      },
      footer: {
        docs: 'Documentation', github: 'GitHub',
        copy: 'v6.3.0 \u00b7 MIT License \u00b7 Made by @juandelossantos'
      }
    },

    es: {
      a11y: {
        skip: 'Saltar al contenido',
        langToEs: 'Cambiar a espa\u00f1ol',
        langToEn: 'Cambiar a ingl\u00e9s',
        theme: 'Cambiar tema de color',
        menu: 'Men\u00fa',
        copy: 'Copiar comando de instalaci\u00f3n'
      },
      theme: { dark: 'Oscuro', light: 'Claro' },
      nav: {
        flow: 'Flujo', harness: 'Harness', loop: 'El bucle', enforcement: 'Enforcement',
        skills: 'Skills', workflows: 'Flujos', faq: 'FAQ', docs: 'Docs', github: 'GitHub'
      },
      hero: {
        tag: '/// sistema',
        title1: 'Convierte agentes de IA en',
        title2: 'ingenieros senior disciplinados.',
        thesis: 'La mayor\u00eda de librer\u00edas de skills venden capacidad.',
        thesisAccent: 'Nosotros vendemos disciplina que puedes verificar.',
        social: 'Open source \u00b7 Licencia MIT \u00b7 Funciona offline \u00b7 Sin lock-in'
      },
      terminal: {
        detected: 'Detectado: OpenCode \u00b7 Claude Code \u00b7 Cursor \u00b7 Codex \u00b7 Gemini',
        installed: '57 skills instaladas \u00b7 harness conectado \u00b7 puertas armadas.',
        done: 'LISTO. Ejecuta init-agents en cualquier proyecto.',
        channels: 'Canales: git y curl activos \u00b7 npm y brew pronto.'
      },
      problem: {
        label: '01 / el problema',
        title: 'Los agentes eligen el camino m\u00e1s corto.',
        tldr: 'TL;DR: modelos capaces igual se saltan tests, review y contexto. La brecha es proceso, no inteligencia.',
        card1Title: 'Sin tests antes del commit',
        card1Desc: 'C\u00f3digo que parece correcto y falla en producci\u00f3n.',
        card2Title: 'Sin review antes del push',
        card2Desc: 'Dos agentes se sobrescriben sin darse cuenta.',
        card3Title: 'Output gen\u00e9rico',
        card3Desc: 'Los mismos patrones sin importar el contexto ni el stack.',
        card4Title: 'Fallos silenciosos',
        card4Desc: 'El da\u00f1o se descubre horas despu\u00e9s, por una persona.',
        metr: 'Cuando los desarrolladores usaron IA, tardaron 19 por ciento m\u00e1s. Estimaron que la IA les ahorr\u00f3 20 por ciento del tiempo.',
        metrSource: 'Becker et al., METR, julio 2025',
        conclusion: 'La brecha entre capaz y confiable no es inteligencia. Es proceso.'
      },
      flow: {
        label: '01 / ciclo de vida',
        title: 'Seis fases. Un camino que se dibuja solo.',
        tldr: 'TL;DR: cada tarea pasa por DEFINIR, PLANEAR, CONSTRUIR, VERIFICAR, REVISAR y ENTREGAR. Ninguna fase es opcional y cada una tiene criterio de salida.',
        define: { name: 'DEFINIR', exit: 'Spec aprobado, alcance bloqueado' },
        plan: { name: 'PLANEAR', exit: 'Tareas chicas, dependencias mapeadas' },
        build: { name: 'CONSTRUIR', exit: 'Un slice, tests escritos primero' },
        verify: { name: 'VERIFICAR', exit: 'Tests pasan, coincide con el spec' },
        review: { name: 'REVISAR', exit: 'Sin issues P0, seguridad revisada' },
        ship: { name: 'ENTREGAR', exit: 'Commit limpio, puertas en verde' },
        conclusion: 'Ninguna fase es opcional. Cada paso tiene una skill. Cada skill tiene una puerta.'
      },
      harness: {
        label: '02 / el harness',
        title: 'Una tarea baja por la m\u00e1quina.',
        tldr: 'TL;DR: el Harness son seis capas alrededor del modelo. Un cambio malo llega a la capa de guardrails y se bloquea ah\u00ed, y queda registrado.',
        l1Name: 'Instrucciones', l1Desc: 'Qui\u00e9n es el agente y qu\u00e9 no debe hacer jam\u00e1s.',
        l2Name: 'Herramientas', l2Desc: 'Capacidades espec\u00edficas, cargadas bajo demanda.',
        l3Name: 'Sandboxes', l3Desc: 'D\u00f3nde corren los comandos, aislados de tu sistema.',
        l4Name: 'Orquestaci\u00f3n', l4Desc: 'Cu\u00e1ndo se activa cada herramienta y c\u00f3mo se coordinan.',
        l5Name: 'Guardrails', l5Desc: 'Hooks deterministas en puntos del ciclo de vida.',
        l6Name: 'Observabilidad', l6Desc: 'Evidencia de que funciona o est\u00e1 derivando.',
        blocked: 'BLOQUEADO',
        logged: 'registrado',
        blockedNote: 'Bloqueado en Guardrails: lleg\u00f3 un cambio de c\u00f3digo sin test que lo cubra. Observabilidad lo registr\u00f3.',
        conclusion: 'Una regla que vive solo en un archivo es una sugerencia. Una regla que vive en una capa es una puerta.'
      },
      loop: {
        label: '03 / el bucle',
        title: 'El agente que se audita a s\u00ed mismo.',
        tldr: 'TL;DR: cada sesi\u00f3n puede auditar, diagnosticar, arreglar y registrar un ADR. Los hallazgos se vuelven fixes, y los fixes se vuelven decisiones registradas.',
        audit: 'Auditar: escanear archivos core buscando deriva',
        diagnose: 'Diagnosticar: clasificar la causa ra\u00edz',
        fix: 'Arreglar: proponer y aplicar con aprobaci\u00f3n',
        adr: 'ADR: registrar la decisi\u00f3n',
        repeat: 'Repetir: cada corrida sube el piso',
        auditShort: 'auditar', diagnoseShort: 'diagnosticar', fixShort: 'arreglar', adrShort: 'ADR', repeatShort: 'repetir',
        found: 'issues encontrados', fixed: 'arreglados', regressions: 'regresiones',
        conclusion: 'Verificaci\u00f3n sin evidencia es inspecci\u00f3n.'
      },
      enforcement: {
        label: '04 / enforcement',
        title: 'Mostrar el bloqueo. No prometerlo.',
        tldr: 'TL;DR: un cambio de c\u00f3digo sin test que lo cubra se bloquea localmente por L1 y no se puede mergear sin el check remoto gates de L2.',
        l1Title: 'Hooks locales', l1Desc: 'Feedback r\u00e1pido y advisory antes de que el commit salga de tu m\u00e1quina.',
        l2Title: 'Check remoto gates', l2Desc: 'Un status check requerido. El committer no puede saltarlo. Solo GitHub.',
        l3Title: 'Review CODEOWNERS', l3Desc: 'Una persona es due\u00f1a de las rutas sensibles. El review es requerido. Solo GitHub.',
        proofTitle: 'Salida real: un commit bloqueado',
        proofNote1: 'El mismo check corre en remoto como el status requerido ',
        proofNote2: ', as\u00ed que el committer no puede saltearlo.',
        evidence: 'Leer la evidencia de enforcement remoto'
      },
      compat: {
        label: '06 / compatibilidad',
        title: 'Una instalaci\u00f3n. Cualquier agente. Cualquier stack.',
        tldr: 'TL;DR: el instalador detecta tu agente y tu stack, y conecta las skills y hooks correspondientes.',
        more: '15 agentes detectados',
        stack: 'Agn\u00f3stico de stack: Node, Rust, Python, Go, Ruby, Dart, o cualquier stack. init-agents escribe STACK_CONFIG.md.',
        link: 'Ver la matriz de adaptadores de agentes'
      },
      skills: {
        label: '05 / skills',
        title: 'Skills, etiquetadas por fase.',
        tldr: 'TL;DR: 57 skills curadas, mapeadas al ciclo de vida. Usa todas o solo las que tu flujo necesita.',
        catFoundation: 'Fundamentos',
        catFoundationDesc: 'Contratos, contexto y la entrevista que bloquea el alcance antes del c\u00f3digo.',
        catProcess: 'Proceso', catFrontend: 'Construcci\u00f3n', catDebug: 'Verificaci\u00f3n', catQuality: 'Revisi\u00f3n',
        catDevops: 'Entrega', catDesignReview: 'Design review', catDesignReviewTitle: 'Suite de design review',
        catMeta: 'Meta', catMetaTitle: 'Meta-skills',
        stats: '57 skills \u00b7 151 gu\u00edas \u00b7 6 componentes del harness \u00b7 un eval para cada una',
        learn: 'Explorar el cat\u00e1logo completo'
      },
      workflows: {
        label: '08 / flujos',
        title: 'Enforcement que se adapta a tu proyecto.',
        tldr: 'TL;DR: sin git tienes solo reglas. Con git sumas hooks L1. Con GitHub sumas L2 y L3. Re-ejecuta init-agents despu\u00e9s de cada cambio.',
        w1Name: 'Sin git', w1Desc: 'Independiente o privado, sin VCS. Las reglas y AGENTS.md se instalan, pero no hay hooks ni gate remoto. El enforcement es solo por convenci\u00f3n.',
        w2Name: 'Git local', w2Desc: 'Un repo privado o una forja que no es GitHub. Los hooks L1 est\u00e1n activos. No hay L2 ni L3, as\u00ed que falta la autoridad remota.',
        w3Name: 'Git + GitHub', w3Desc: 'L1 + L2 + L3 completos. El check remoto gates es requerido, CODEOWNERS es due\u00f1o de las rutas sensibles, y el committer no puede saltear ninguno.',
        w4Name: 'Git despu\u00e9s', w4Desc: 'Sin git ahora, git y GitHub despu\u00e9s. La regla clave: re-ejecuta init-agents despu\u00e9s de git init y despu\u00e9s de agregar el remoto. Detecta lo que ahora est\u00e1 disponible e instala las capas faltantes.',
        upgrade: 'Mejorar:', thenReinit: 'despu\u00e9s re-ejecuta', afterEach: 'despu\u00e9s de cada cambio'
      },
      faq: {
        label: '06 / faq',
        title: 'Preguntas, respondidas sin vueltas.',
        q1: '\u00bfQu\u00e9 es Another Agent Skills?',
        a1: 'Un framework de 57 skills compuestos que convierten agentes de IA en ingenieros senior disciplinados. Agrega enforcement mec\u00e1nico, no solo prompts. Las skills siguen un ciclo de seis fases: Definir, Planear, Construir, Verificar, Revisar, Entregar.',
        q2: '\u00bfC\u00f3mo funciona el enforcement mec\u00e1nico?',
        a2: 'Tres capas. L1 son hooks de git locales para feedback r\u00e1pido y advisory. L2 es un check remoto gates requerido que el committer no puede saltar. L3 es review de CODEOWNERS para rutas sensibles. Un cambio de c\u00f3digo sin test que lo cubra se bloquea, local y remotamente.',
        q3: '\u00bfQu\u00e9 agentes soporta?',
        a3: 'Dise\u00f1ado para OpenCode. Portable a Claude Code, Cursor, Codex, Gemini CLI, GitHub Copilot, Windsurf, Aider y cualquier agente que lea AGENTS.md. El instalador detecta el agente y conecta las skills y hooks correspondientes.',
        q4: '\u00bfEs gratis?',
        a4: 'S\u00ed. Licencia MIT. Open source. Sin suscripciones ni tiers pagos. El instalador, las skills y el enforcement son gratis.',
        q5: '\u00bfUn agente puede romper las reglas igual?',
        a5: 'S\u00ed. Los hooks lo hacen m\u00e1s dif\u00edcil, no imposible. Un agente podr\u00eda malinterpretar una aprobaci\u00f3n ambigua o actuar fuera del protocolo. Estas puertas crean fricci\u00f3n, no garant\u00edas. La persona sigue en el loop, y la persona sigue atenta.',
        q6: '\u00bfQu\u00e9 es el Harness?',
        a6: 'El Harness es todo lo que rodea al modelo y convierte inteligencia cruda en output confiable: instrucciones, herramientas, sandboxes, orquestaci\u00f3n, guardrails y observabilidad. Agente es igual a Modelo m\u00e1s Harness. La mayor\u00eda de los fallos de agentes son fallos de configuraci\u00f3n.',
        q7: '\u00bfC\u00f3mo lo instalo?',
        a7: 'Tres canales. Clona y ejecuta install.sh, o usa el bootstrap curl pineado del \u00faltimo release, o instala v\u00eda npm. Despu\u00e9s ejecuta init-agents en cualquier proyecto. Git y curl est\u00e1n activos hoy. npm y Homebrew llegan pronto.'
      },
      cta: {
        label: '07 / empezar',
        title: 'Dale a tu agente una puerta que no puede olvidar.',
        lead: 'Un comando. El instalador detecta tu agente y tu stack, y arma el enforcement.',
        copy: 'Copiar', live: 'activo', soon: 'pronto',
        social: 'Open source \u00b7 Licencia MIT \u00b7 Funciona offline \u00b7 Sin lock-in'
      },
      footer: {
        docs: 'Documentaci\u00f3n', github: 'GitHub',
        copy: 'v6.3.0 \u00b7 Licencia MIT \u00b7 Hecho por @juandelossantos'
      }
    }
  };

  function getNested(obj, path) {
    return path.split('.').reduce(function (o, k) {
      return o && o[k] !== undefined ? o[k] : null;
    }, obj);
  }

  var currentLang = 'en';

  function applyLang(lang) {
    var t = I18N[lang] || I18N.en;
    currentLang = lang;
    doc.setAttribute('lang', lang);
    try { localStorage.setItem('aas-lang', lang); } catch (e) {}

    var els = document.querySelectorAll('[data-i18n]');
    Array.prototype.forEach.call(els, function (el) {
      var val = getNested(t, el.getAttribute('data-i18n'));
      if (val !== null) el.textContent = val;
    });

    var langBtn = document.querySelector('[data-action="lang"]');
    if (langBtn) {
      var langText = langBtn.querySelector('[data-lang-text]');
      if (langText) langText.textContent = lang === 'en' ? 'ES' : 'EN';
      langBtn.setAttribute('aria-label', lang === 'en' ? t.a11y.langToEs : t.a11y.langToEn);
    }

    var themeBtn = document.querySelector('[data-action="theme"]');
    if (themeBtn) {
      themeBtn.setAttribute('aria-label', t.a11y.theme);
      updateThemeLabel();
    }

    var menuBtn = document.querySelector('[data-action="menu"]');
    if (menuBtn) menuBtn.setAttribute('aria-label', t.a11y.menu);

    var copyBtns = document.querySelectorAll('[data-action="copy"]');
    Array.prototype.forEach.call(copyBtns, function (b) { b.setAttribute('aria-label', t.a11y.copy); });
  }

  function toggleLang() {
    applyLang(currentLang === 'en' ? 'es' : 'en');
  }

  /* =========================================================
     Theme
     ========================================================= */

  function updateThemeLabel() {
    var theme = doc.getAttribute('data-theme') || 'dark';
    var t = (I18N[currentLang] || I18N.en).theme;
    var text = document.querySelector('[data-theme-text]');
    var btn = document.querySelector('[data-action="theme"]');
    if (text) text.textContent = theme === 'dark' ? t.dark : t.light;
    if (btn) btn.setAttribute('aria-pressed', theme === 'light' ? 'true' : 'false');
  }

  function toggleTheme() {
    var next = (doc.getAttribute('data-theme') === 'dark') ? 'light' : 'dark';
    doc.setAttribute('data-theme', next);
    try { localStorage.setItem('aas-theme', next); } catch (e) {}
    updateThemeLabel();
  }

  /* =========================================================
     Terminal animation (hero)
     ========================================================= */

  function initTerminal() {
    var terminal = document.querySelector('[data-terminal]');
    if (!terminal) return;
    if (reduceMotion) { terminal.setAttribute('data-done', 'true'); return; }

    var lines = terminal.querySelector('[data-terminal-lines]');
    var output = terminal.querySelector('[data-terminal-output]');
    var outLines = output.querySelectorAll('.terminal__out-line');

    var commands = [
      { text: 'git clone https://github.com/juandelossantos/another-agent-skills.git && cd another-agent-skills && bash install.sh' },
      { text: 'curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash' },
      { text: 'npx @juandelossantos/another-agent-skills install', soon: true }
    ];

    function showOutput() {
      output.hidden = false;
      Array.prototype.forEach.call(outLines, function (line, i) {
        line.style.opacity = '0';
        setTimeout(function () {
          line.style.opacity = '1';
          if (i === outLines.length - 1) {
            terminal.setAttribute('data-done', 'true');
          }
        }, (i + 1) * 360);
      });
    }

    function typeCommand(index) {
      if (index >= commands.length) { showOutput(); return; }
      var cmd = commands[index];
      var line = document.createElement('div');
      line.className = 'terminal__tline';
      line.innerHTML = '<span class="terminal__prompt">~ $</span><span class="terminal__typing"></span>' +
        (cmd.soon ? '<span class="terminal__soon">soon</span>' : '') +
        '<span class="terminal__cursor">\u258a</span>';
      lines.appendChild(line);

      var typing = line.querySelector('.terminal__typing');
      var cursor = line.querySelector('.terminal__cursor');
      var i = 0;
      (function typeChar() {
        if (i < cmd.text.length) {
          typing.textContent += cmd.text.charAt(i);
          i++;
          setTimeout(typeChar, 16);
        } else {
          cursor.remove();
          setTimeout(function () { typeCommand(index + 1); }, 420);
        }
      })();
    }

    lines.innerHTML = '';
    output.hidden = true;

    whenVisible(terminal, function () {
      setTimeout(function () { typeCommand(0); }, 400);
    });
  }

  /* =========================================================
     Flow animation
     ========================================================= */

  function initFlow() {
    var flow = document.querySelector('[data-flow]');
    if (!flow) return;
    var nodes = flow.querySelectorAll('.flow__node');
    var segs = flow.querySelectorAll('.flow__seg');

    function finish() {
      flow.setAttribute('data-state', 'run');
      Array.prototype.forEach.call(nodes, function (n) { n.classList.add('is-lit'); });
    }

    if (reduceMotion) { finish(); return; }

    flow.setAttribute('data-state', 'ready');

    whenVisible(flow, function () {
      flow.setAttribute('data-state', 'run');
      Array.prototype.forEach.call(nodes, function (node, i) {
        setTimeout(function () { node.classList.add('is-lit'); }, i * 170 + 90);
      });
    });
  }

  /* =========================================================
     Harness animation
     ========================================================= */

  function initHarness() {
    var harness = document.querySelector('[data-harness]');
    if (!harness) return;
    if (reduceMotion) return; // static state already shows the block

    var packet = harness.querySelector('[data-packet]');
    var guardrails = harness.querySelector('[data-guardrails]');
    var layers = harness.querySelectorAll('.harness__layer');

    harness.setAttribute('data-state', 'ready');

    function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }

    function packetY(layer) {
      var y = layer.offsetTop + layer.offsetHeight / 2 - packet.offsetHeight / 2;
      return Math.max(0, y);
    }

    function moveTo(layer) {
      packet.style.transform = 'translate(-50%, ' + packetY(layer) + 'px)';
    }

    whenVisible(harness, function () {
      requestAnimationFrame(function () {
        moveTo(layers[0]);
        (async function run() {
          await sleep(500);
          for (var i = 1; i <= 4; i++) {
            moveTo(layers[i]);
            await sleep(620);
          }
          // Guardrails catch
          packet.classList.add('is-blocked');
          guardrails.classList.add('is-caught');
          await sleep(500);
          harness.setAttribute('data-state', 'run');
        })();
      });
    });
  }

  /* =========================================================
     Loop animation
     ========================================================= */

  function initLoop() {
    var ring = document.querySelector('[data-loop-ring]');
    if (!ring) return;
    if (reduceMotion) return; // counters stay at final values

    var found = document.querySelector('[data-loop-found]');
    var fixed = document.querySelector('[data-loop-fixed]');
    var stops = ring.querySelectorAll('[data-loop-stop]');
    var steps = document.querySelectorAll('.step');

    function setActive(i) {
      Array.prototype.forEach.call(stops, function (s, j) { s.classList.toggle('is-active', j === i); });
      Array.prototype.forEach.call(steps, function (s, j) { s.classList.toggle('is-active', j === i); });
    }

    whenVisible(ring, function () {
      ring.classList.add('is-running');
      var target = 12, dur = 9000, start = null;
      function tick(now) {
        if (start === null) start = now;
        var p = Math.min((now - start) / dur, 1);
        var v = Math.round(p * target);
        found.textContent = String(v);
        fixed.textContent = String(v);
        setActive(Math.floor(p * 10) % 5);
        if (p < 1) {
          requestAnimationFrame(tick);
        } else {
          found.textContent = String(target);
          fixed.textContent = String(target);
          setActive(-1);
        }
      }
      requestAnimationFrame(tick);
    });
  }

  /* =========================================================
     Shared: run once when element scrolls into view
     ========================================================= */

  function whenVisible(el, cb) {
    if (!('IntersectionObserver' in window)) { cb(); return; }
    var obs = new IntersectionObserver(function (entries) {
      if (entries[0].isIntersecting) {
        obs.disconnect();
        cb();
      }
    }, { threshold: 0.25 });
    obs.observe(el);
  }

  /* =========================================================
     Scroll reveals
     ========================================================= */

  function initReveals() {
    var els = document.querySelectorAll('[data-reveal]');
    if (!els.length) return;
    if (reduceMotion || !('IntersectionObserver' in window)) {
      Array.prototype.forEach.call(els, function (el) { el.setAttribute('data-revealed', 'true'); });
      return;
    }
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.setAttribute('data-revealed', 'true');
          obs.unobserve(entry.target);
        }
      });
    }, { rootMargin: '0px 0px -10% 0px' });
    Array.prototype.forEach.call(els, function (el) { obs.observe(el); });
  }

  /* =========================================================
     Copy command
     ========================================================= */

  function copyCommand(btn) {
    var wrap = btn.closest('.command');
    var code = wrap ? wrap.querySelector('.command__code') : null;
    if (!code) return;
    var text = code.textContent.trim();

    function done() {
      btn.setAttribute('data-copied', 'true');
      var prev = btn.getAttribute('aria-label');
      setTimeout(function () {
        btn.removeAttribute('data-copied');
        if (prev) btn.setAttribute('aria-label', prev);
      }, 2000);
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, done);
    } else {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); } catch (e) {}
      document.body.removeChild(ta);
      done();
    }
  }

  /* =========================================================
     Mobile menu
     ========================================================= */

  function toggleMenu(btn) {
    var menu = document.querySelector('[data-mobile-menu]');
    if (!menu) return;
    var open = menu.getAttribute('aria-hidden') === 'true';
    menu.setAttribute('aria-hidden', open ? 'false' : 'true');
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    if (open) {
      var first = menu.querySelector('a');
      if (first) setTimeout(function () { first.focus(); }, 60);
    } else {
      btn.focus();
    }
  }

  function closeMenu() {
    var menu = document.querySelector('[data-mobile-menu]');
    var btn = document.querySelector('[data-action="menu"]');
    if (!menu || !btn) return;
    menu.setAttribute('aria-hidden', 'true');
    btn.setAttribute('aria-expanded', 'false');
  }

  /* =========================================================
     Init
     ========================================================= */

  function init() {
    doc.setAttribute('data-anim', 'on');
    var lang;
    try { lang = localStorage.getItem('aas-lang'); } catch (e) {}
    if (lang !== 'en' && lang !== 'es') {
      lang = (navigator.language || 'en').toLowerCase().indexOf('es') === 0 ? 'es' : 'en';
    }
    applyLang(lang);
    updateThemeLabel();

    initTerminal();
    initFlow();
    initHarness();
    initLoop();
    initReveals();

    document.addEventListener('click', function (e) {
      var target = e.target.closest('[data-action]');
      if (!target) return;
      switch (target.getAttribute('data-action')) {
        case 'theme': toggleTheme(); break;
        case 'lang': toggleLang(); break;
        case 'copy': copyCommand(target); break;
        case 'menu': toggleMenu(target); break;
      }
    });

    document.addEventListener('click', function (e) {
      if (e.target.closest('.header__mobile-links a')) closeMenu();
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        var menu = document.querySelector('[data-mobile-menu]');
        if (menu && menu.getAttribute('aria-hidden') === 'false') closeMenu();
      }
      if (e.key !== 'Tab') return;
      var menu = document.querySelector('[data-mobile-menu]');
      if (!menu || menu.getAttribute('aria-hidden') !== 'false') return;
      var links = menu.querySelectorAll('a');
      if (!links.length) return;
      var first = links[0], last = links[links.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
