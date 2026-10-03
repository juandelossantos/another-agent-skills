/*
 * JSON-LD serialization for inline `<script type="application/ld+json">`.
 *
 * `JSON.stringify` does not escape the characters that can close a `<script>`
 * element, so any string containing `</script>` (or `<`, `>`, `&`) could break
 * out of the tag. Escaping them as JSON unicode escapes keeps the output valid
 * JSON while making the tag impossible to close from its own data. All current
 * data is author-controlled, but this keeps the inline-script surface safe by
 * construction rather than by convention.
 */
export function jsonLdScript(value: unknown): string {
  return JSON.stringify(value)
    .replace(/</g, '\\u003c')
    .replace(/>/g, '\\u003e')
    .replace(/&/g, '\\u0026');
}
