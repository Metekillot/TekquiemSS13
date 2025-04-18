/**
 * Uses DOMPurify to purify/sanitise HTML.
 */

import DOMPurify from 'dompurify';

// Default values
const defTag = [
  'b',
  'br',
  'center',
  'code',
  'div',
  'font',
  'hr',
  'i',
  'li',
  'menu',
  'ol',
  'p',
  'pre',
  'span',
  'table',
  'td',
  'th',
  'tr',
  'u',
  'ul',
];

const defAttr = ['class', 'style'];

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param input - Input HTML string to sanitize
 * @param advHtml - Flag to enable/disable advanced HTML
 * @param tags - List of allowed HTML tags
 * @param forbidAttr - List of forbidden HTML attributes
 * @param advTags - List of advanced HTML tags allowed for trusted sources
 */
export function sanitizeText(
  input: string,
  advHtml = false,
  tags = defTag,
  forbidAttr = defAttr,
  advTags = advTag,
) {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it doesn't
  // kill href links or such
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr,
  });
}
