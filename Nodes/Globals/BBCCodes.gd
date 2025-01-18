class_name BBCCodes

## Dialog types.
enum BBC_EFFECT { NONE, WAIT }

# BBCode effects.
const BBC_CODES_MAP: Dictionary[String, BBC_EFFECT] = {
	"wait": BBC_EFFECT.WAIT,
}

# BBCode regular expression.
const BBC_REXP: String = "\\[(wait)(?:=([\\w\\d]+))?\\]"

# Any BBCode regular expression.
# Used in case a wrong one was read and we need to remove it.
# It matches any BBCode, even not supported.
const BBC_ANY_REXP: String = "\\[.*\\]"
