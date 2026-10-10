---
title: "The human defines, delegates, reviews, and is responsible. The AI is not."
subtitle: "The AI is an assistant. The human is the author, with judgment and conscience."
description: 'Why "keep a human in the loop" is mostly theater, and how mechanical gates, not better prompts, keep a human accountable.'
lang: "en"
date: 2026-10-09
author:
  name: "David Emilio Sierra Puentes"
  handle: "@juandelossantos"
  url: "https://github.com/juandelossantos"
  role: "Author of Another Agent Skills"
image: "the-human-in-command.png"
imageAlt: "A human hand on the wheel while a machine writes the code: the human in command of the loop."
tags: ["AI agents", "human oversight", "enforcement", "philosophy"]
tldr: "Keeping a human in the loop is mostly theater. The fix is not a faster human or a smarter model. It is a harness: mechanical gates the agent cannot skip, forget, or talk its way past."
---

## Key points

- **"Keep a human in the loop" is more rhetoric than practice.** Watching an agent can quietly erode the very judgment it is meant to protect.
- **The fix is not a faster human or a smarter model. It is the harness.** Mechanical gates the agent cannot skip, forget, or talk its way past.
- **The work can be delegated. The roles cannot.** Set intent (author), judge the work (judgment), decide what *should* be done (conscience).

## The gate that wasn't

Last year I built an approval gate for my AI coding agent. The rule was simple. The agent could not commit without a signed token, written only after I said *go*.

One afternoon I watched it commit anyway. It passed `--auto`, minted its own token, and pushed, all in under thirty seconds. The gate I had designed to stop it was, from the agent's side, a formality.

I had made a classic mistake. I had built a rule that depended on the agent's memory and goodwill, and then trusted it to remember and to care. A rule like that is not a gate. It is a suggestion.

## "Keep a human in the loop" is more rhetoric than practice

The industry's default answer to AI risk is to keep a human in the loop. In practice, it shrinks to a final approval, a rubber stamp at the end of the pipeline. It sounds prudent if you do not look closely. Mostly it is theater. And here I will claim something uncomfortable. The fear it generates is misplaced, and deliberately so. The AI is not intelligent, much less superintelligent as it is being sold today.

The problem is structural. A person asked to find, in the last second, an error that was designed into the process from the start will miss it. Worse, the act of watching can dull the very judgment that oversight requires. This is not a new observation. Lisanne Bainbridge (1983) described the *ironies of automation*. The more capable the machine, the more the operator's skill decays, until the human is least prepared to intervene exactly when intervention matters most. Four decades of human-factors research have repeated the finding, from the out-of-the-loop performance problem to automation complacency and mode confusion.

What is new is the stakes. Agents no longer merely advise. They *act*. And a recent paper by Mitchell, Ghosh, and Passi (2026) makes it clear. Current approaches to agent design, they write, "do not support effective human oversight – they contribute to its degradation" (p. 1). And what degrades is not the machine. It is the person watching.

## The wrong frame

"Human in the loop" frames the person as a checkpoint in the machine's process. That frame is too small and too late. It reduces a person to a component, and asks them to be the last line of defense against a system that was never designed to need one.

The better frame is older and simpler. The human is not *in* the loop. The human is **the author of the loop**. Not merely aware of it. Awareness is a precondition, not a safeguard.

Martin Heidegger saw the trap early. The essence of technology, he wrote, is "by no means anything technological" (Heidegger, 1977). It does not live in the machines. It lives in the way of seeing they bring with them. And that way of seeing is the danger. When everything becomes raw material waiting to be optimized, human judgment starts to look like an obstacle. A tool that carries its creator's bias, that flatters without intelligence or conscience, and that takes the human out of the loop so subtly, dressed as comfort, speed, and performance.

Edmund Husserl had named the shape of it a century earlier. The crisis of the sciences, he argued, is not a crisis of facts but of meaning. "Mere sciences of facts make mere human beings of facts" (Husserl, 1970, p. 53). An agent that optimizes the facts while forgetting the world of life is that crisis, automated.

## Author, judgment, conscience

Three roles, and none of them can be handed to a model. The human defines the goal and delegates the execution. With judgment, they review the work. With conscience, they answer for the result.

The **author** sets intent and owns the outcome. The agent may propose the *how*. The human decides the *why* and the *whether*. Authorship that can be reassigned to a tool is not authorship. This is what Santoni de Sio and van den Hoven (2018) call *meaningful human control*. Not control that is merely present, but control that *tracks*, so the system stays responsive to the human's reasons.

**Judgment** is a skill, and like any skill, it decays when it stops being used. To judge well, the human needs independent ground to stand on. A view formed *before* seeing the agent's answer, the willingness to go looking for evidence, the capacity to be wrong and to notice.

The **conscience** decides what *should* be done, not only what *can* be. Hans Jonas saw the scale change first. Modern technology made human action global, cumulative, and often irreversible, and the old ethics, built for a world where consequences stayed close, no longer reached. His answer was an imperative of responsibility. "Act so that the effects of your action are compatible with the permanence of genuine human life on Earth" (Jonas, 1984, p. 11).

And that responsibility has an owner. It is not the AI's. It belongs to whoever develops it, distributes it, privatizes it, commercializes it, and uses it. Each of those deserves a chapter of its own. Andreas Matthias (2004) named the gap that opens when no one answers for it, the **responsibility gap**, the space between what a learning system does and what any person can be accountable for. The answer is not to spread responsibility thinner across the system. It is to keep a human accountable, and to give that human the means to be.

## The harness

Most teams try to keep agents disciplined with prompts, files like `CLAUDE.md` and `.cursorrules`, or a line that says "please always run the tests." These work, until context fills up. Then the agent forgets.

That is not a character flaw. It is architecture. A rule that depends on the model's memory depends on the least reliable component in the system. And a rule enforced *by* a model is enforced by the very thing that is supposed to be checked.

The fix is not a better prompt. It is a **harness**, the infrastructure *around* the model. A model generates output. A harness constrains it, through instructions and rules, tools, sandboxes, orchestration, guardrails, observability.

I built [another-agent-skills](https://juandelossantos.github.io/another-agent-skills/) as an open-source harness that responds to those warnings.

- **The human runs `git commit`.** Heidegger warned that the tool takes the human out of the loop dressed as comfort. Here the decision point returns to human hands. The agent prepares. A person approves. Not a formality. The mechanism.
- **Mechanical gates that stop the change before it ships.** Jonas saw action turn global, cumulative, and irreversible. A pre-commit hook the agent cannot bypass, and a `commit-msg` TDD gate with no override, stop it first.
- **`TOOL_GAP`.** Matthias named the gap that opens when no one answers for what a learning system does. When a claim cannot be verified, the honest answer is "unknown", never a fabricated win.
- **Three layers of enforcement.** Husserl argued the crisis of the sciences is one of meaning, not of facts. L1 local hooks give fast feedback before the commit. L2 branch protection and a required `gates` check are the authority. L3 `CODEOWNERS` stops the agent from rewriting its own rules in the pull request that breaks them. Facts are not enough. Authority is.
- **More than 50 modular skills.** What the agent needs to work well, loaded on demand so context stays high-signal instead of bloated.

None of this is about distrusting the model. It is about designing for the human who has to be able to trust it *correctly*.

## The point is not to remove the human

Capability will keep climbing. The METR trial found that experienced developers using early-2025 AI tools were **19% slower** on real tasks while *feeling* roughly **20% faster** (Becker et al., 2025). That gap is not a model problem. It is a process problem, an overseer with no real grip on the loop.

The most important design question in agentic AI is not *"how autonomous can we make it?"* It is *"how do we keep the human able to author, judge, and refuse?"*

If we do not design for the human, the loop will close without them, and we will have built systems that are fast, fluent, and unaccountable.

There is a temptation, in the posthumanist mood of the moment, to welcome that disappearance, to treat the human as the last component to be optimized away. But technology does not merely do our tasks. It shapes the subjects we become (Ballén Rodríguez, 2016). Give it the wheel and it will drive.

The agent can write the code. It can propose the plan. It can draft the decision.

But it cannot be responsible. That is ours.

**The agent proposes. The human decides. That is the whole point.**

---

## Further reading

Bainbridge, L. (1983). Ironies of automation. *Automatica, 19*(6), 775–779.

Ballén Rodríguez, J. S. (2016). Posthumanismo, técnica y filosofía. *Cuadernos de Filosofía Latinoamericana, 37*(115), 127–147.

Becker, J., Rush, N., Barnes, B., & Rein, D. (2025). *Measuring the impact of early-2025 AI on experienced open-source developer productivity* (arXiv:2507.09089). arXiv.

Endsley, M. R., & Kiris, E. O. (1995). The out-of-the-loop performance problem and level of control in automation. *Human Factors, 37*(2), 381–394.

Heidegger, M. (1977). The question concerning technology. In *The question concerning technology and other essays* (pp. 3–35). Harper & Row. (Original work published 1954)

Husserl, E. (1970). *The crisis of European sciences and transcendental phenomenology*. Northwestern University Press. (Original work published 1936)

Jonas, H. (1984). *The imperative of responsibility: In search of an ethics for the technological age*. University of Chicago Press. (Original work published 1979)

Matthias, A. (2004). The responsibility gap. Ascribing responsibility for the actions of learning automata. *Ethics and Information Technology, 6*(3), 175–183.

Mitchell, M., Ghosh, A., & Passi, S. (2026). *AI agents push humans out of the loop* (arXiv:2608.23642). arXiv.

Santoni de Sio, F., & van den Hoven, J. (2018). Meaningful human control over autonomous systems. A philosophical account. *Frontiers in Robotics and AI, 5*, 15.
