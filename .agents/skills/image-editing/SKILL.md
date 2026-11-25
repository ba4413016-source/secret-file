---
name: image-editing
description: Edit a supplied image while preserving the user's specified identity, pose, framing, outfit, composition, orientation, and scene details; use for targeted image changes and fidelity checks.
---

# Image Editing

Use this skill when the user supplies an image to edit, asks to change only part of an image, or emphasizes keeping the original look, person, product, pose, or composition.

## Preserve first

Before editing, write down two short lists:

- **Change:** exactly what the user asked to alter.
- **Preserve:** all other relevant source details, including identity, pose, expression, camera angle, framing, orientation, outfit, background, lighting, colors, labels, logos, and object count.

Apply the user's explicit constraints over this default list. Do not add unrequested objects, retouch unrelated features, change the crop, flip the image, or alter the scene. Work non-destructively and do not overwrite the source unless the user explicitly requests replacement.

## Choose only a supported path

1. Inspect the source image and the requested edit.
2. Check which image-editing or image-variation tools are actually available in the current environment, and read their current input requirements. Never assume a provider, tool name, parameter, or connection from another skill.
3. Prefer an edit/variation operation that accepts the source image when fidelity matters. If only text-to-image generation is available, explain that it cannot guarantee a faithful edit and ask before substituting a new generation.
4. Before any paid or externally processed operation, follow the host's confirmation and privacy rules. Do not send private or sensitive source images to a provider without authorization.
5. Make one bounded edit. Keep the requested change first in the prompt, followed by the preservation list and unwanted-change constraints.
6. Compare the result with the source at the same orientation and crop. Check identity, pose, geometry, labels, edges, lighting, artifacts, and the requested region. If a fixed detail drifted, report it rather than claiming it was preserved.

## Deliver

Return the edited artifact and a concise note covering what changed, what was checked, any visible drift, and any post-production still needed. Keep the original available. For exact text, logos, or fine geometry, recommend compositing or deterministic editing when generation is unreliable.

## Upstream inspiration

This repository includes an optional, provider-specific reference adapted from [SamurAIGPT/open-ai-image-agent](https://github.com/SamurAIGPT/open-ai-image-agent/tree/1805c81580ab48113a9295676300587bb3cfb5a2/agents/image-editing). Its MuAPI-specific version is stored under `docs/agent-skills/integrations-pending/image-editing-samurai/` and is not active unless that connection is configured.
