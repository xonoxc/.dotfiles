/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
static int fuzzy = 1;                      /* -F  option; if 0, dmenu doesn't use fuzzy matching     */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
        "JetBrains Mono SemiBold:size=9:antialias=true:autohint:true",
	"Noto Color Emoji:size=8:antialias=true;autohint:true",
	"monospace:size=10"
};
static const char *prompt      = " ";      /* -p  option; prompt to the left of input field */
static const char *colors[SchemeLast][2] = {
	/*     fg         bg       */
	[SchemeNorm] = { "#ddd", "#0f1014" },
	[SchemeSel] = { "#000000", "#abb2bf" },
	[SchemeOut] = { "#abb2bf", "#0f1014" },
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 0;
/* -h option; minimum height of a menu line */
static unsigned int lineheight = 20;
static unsigned int min_lineheight = 8;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";


