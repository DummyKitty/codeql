
// --- stubs ---

struct Locale {
}

struct AnyRegexOutput {
}

protocol RegexComponent<RegexOutput> {
	associatedtype RegexOutput
}

struct Regex<Output> : RegexComponent {
	struct Match {
	}

	init(_ pattern: String) throws where Output == AnyRegexOutput { }

	func firstMatch(in string: String) throws -> Regex<Output>.Match? { return nil}
	func prefixMatch(in string: String) throws -> Regex<Output>.Match? { return nil}
	func wholeMatch(in string: String) throws -> Regex<Output>.Match? { return nil}

	typealias RegexOutput = Output
}

extension RangeReplaceableCollection {
	mutating func replace<Replacement>(_ regex: some RegexComponent, with replacement: Replacement, maxReplacements: Int = .max) where Replacement : Collection, Replacement.Element == Character { }
	func replacing<Replacement>(_ regex: some RegexComponent, with replacement: Replacement, maxReplacements: Int = .max) -> Self where Replacement: Collection, Replacement.Element == Character { return self }
	mutating func trimPrefix(_ regex: some RegexComponent) { }
}

extension StringProtocol {
	func range<T>(of aString: T, options mask:String.CompareOptions = [], range searchRange: Range<Self.Index>? = nil, locale: Locale? = nil) -> Range<Self.Index>? where T : StringProtocol { return nil }
	func replacingOccurrences<Target, Replacement>(of target: Target, with replacement: Replacement, options: String.CompareOptions = [], range searchRange: Range<Self.Index>? = nil) -> String where Target : StringProtocol, Replacement : StringProtocol { return "" }
}

extension String : RegexComponent {
	typealias CompareOptions = NSString.CompareOptions
	typealias Output = Substring
	typealias RegexOutput = String.Output
}

class NSObject {
}

class NSString : NSObject {
	struct CompareOptions : OptionSet {
	    var rawValue: UInt

		static var regularExpression: NSString.CompareOptions { get { return CompareOptions(rawValue: 1) } }
	}

	convenience init(string aString: String) { self.init() }

	func range(of searchString: String, options mask: NSString.CompareOptions = []) -> NSRange { return NSRange(location: 0, length: 0) }
	func replacingOccurrences(of target: String, with replacement: String, options: NSString.CompareOptions = [], range searchRange: NSRange) -> String { return "" }

	var length: Int { get { return 0 } }
}

class NSMutableString : NSString {
}

struct _NSRange {
	init(location: Int, length: Int) { }
}

typealias NSRange = _NSRange

func NSMakeRange(_ loc: Int, _ len: Int) -> NSRange { return NSRange(location: loc, length: len) }

class NSTextCheckingResult : NSObject {
}

class NSRegularExpression : NSObject {
	struct Options : OptionSet {
	    var rawValue: UInt
	}

	struct MatchingOptions : OptionSet {
	    var rawValue: UInt
	}

	init(pattern: String, options: NSRegularExpression.Options = []) throws { }

	// some types have been simplified a little here
	func numberOfMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> Int { return 0 }
	func enumerateMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange, using block: (Int, Int, Int) -> Void) { }
	func matches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> [NSTextCheckingResult] { return [] }
	func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> NSTextCheckingResult? { return nil }
	func rangeOfFirstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> NSRange { return NSRange(location: 0, length: 0) }
	func replaceMatches(in string: NSMutableString, options: NSRegularExpression.MatchingOptions = [], range: NSRange, withTemplate templ: String) -> Int { return 0 }
	func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange, withTemplate templ: String) -> String { return "" }
}

// --- tests ---
//
// the focus for these tests is different ways of evaluating regexps.

func myRegexpMethodsTests(b: Bool, str_unknown: String) throws {
	let input = "abcdef"
	let regex = try Regex(".*")

	// --- Regex ---

	_ = try regex.firstMatch(in: input) // $ regex=.* input=input
	_ = try regex.prefixMatch(in: input) // $ regex=.* input=input
	_ = try regex.wholeMatch(in: input) // $ regex=.* input=input

	// --- RangeReplaceableCollection ---

	var inputVar = input
	inputVar.replace(regex, with: "") // $ regex=.* input=&...
	_ = input.replacing(regex, with: "") // $ regex=.* input=input
	inputVar.trimPrefix(regex) // $ regex=.* input=&...

	// --- StringProtocol ---

	_ = input.range(of: ".*", options: .regularExpression, range: nil, locale: nil) // $ MISSING: regex=.* input=input
	_ = input.replacingOccurrences(of: ".*", with: "", options: .regularExpression) // $ MISSING: regex=.* input=input

	// --- NSRegularExpression ---

	let nsregex = try NSRegularExpression(pattern: ".*")
	_ = nsregex.numberOfMatches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) // $ regex=.* input=input
	nsregex.enumerateMatches(in: input, range: NSMakeRange(0, input.utf16.count), using: {a, b, c in } ) // $ regex=.* input=input
	_ = nsregex.matches(in: input, range: NSMakeRange(0, input.utf16.count)) // $ regex=.* input=input
	_ = nsregex.firstMatch(in: input, range: NSMakeRange(0, input.utf16.count)) // $ regex=.* input=input
	_ = nsregex.rangeOfFirstMatch(in: input, range: NSMakeRange(0, input.utf16.count)) // $ regex=.* input=input
	_ = nsregex.replaceMatches(in: NSMutableString(string: input), range: NSMakeRange(0, input.utf16.count), withTemplate: "") // $ regex=.* input="call to NSString.init(string:)"
	_ = nsregex.stringByReplacingMatches(in: input, range: NSMakeRange(0, input.utf16.count), withTemplate: "") // $ regex=.* input=input

	// --- NSString ---

	let inputNS = NSString(string: "abcdef")
	_ = inputNS.range(of: "*", options: .regularExpression) // $ MISSING: regex=.* input=inputNS
	_ = inputNS.replacingOccurrences(of: ".*", with: "", options: .regularExpression, range: NSMakeRange(0, inputNS.length)) // $ MISSING: regex=.* input=inputNS

	// --- flow ---

	let either_regex = try Regex(b ? ".*" : ".+")
	_ = try either_regex.firstMatch(in: input) // $ regex=.* regex=.+ input=input

	let base_str = "a"
	let appended_regex = try Regex(base_str + "b")
	_ = try appended_regex.firstMatch(in: input) // $ input=input MISSING: regex=ab

	let multiple_evaluated_regex = try Regex(#"([\w.]+)*"#)
	try _ = multiple_evaluated_regex.firstMatch(in: input) // $ input=input regex=([\w.]+)*
	try _ = multiple_evaluated_regex.prefixMatch(in: input) // $ input=input regex=([\w.]+)*
	try _ = multiple_evaluated_regex.wholeMatch(in: input) // $ input=input regex=([\w.]+)* MISSING: redos-vulnerable=

	// --- escape sequences ---

	_ = try Regex("\n").firstMatch(in: input) // $ regex=NEWLINE input=input
	_ = try Regex("\\n").firstMatch(in: input) // $ regex=\n input=input
	_ = try Regex(#"\n"#).firstMatch(in: input) // $ regex=\n input=input

	// --- interpolated values ---

	let str_constant = "aa"
	_ = try Regex("\(str_constant))|bb").firstMatch(in: input) // $ input=input MISSING: regex=aa|bb
	_ = try Regex("\(str_unknown))|bb").firstMatch(in: input) // $ input=input

	// --- multi-line ---

	_ = try Regex("""
		aa|bb
		""").firstMatch(in: input) // $ input=input regex=aa|bb

	_ = try Regex("""
		aa|
		bb
		""").firstMatch(in: input) // $ input=input regex=aa|NEWLINEbb

    // --- exploring parser correctness ---

    // ranges
    _ = try Regex("[a-z]").firstMatch(in: input) // $ input=input regex=[a-z]
    _ = try Regex("[a-zA-Z]").firstMatch(in: input) // $ input=input regex=[a-zA-Z]

    // character classes
    _ = try Regex("[a-]").firstMatch(in: input) // $ input=input regex=[a-]
    _ = try Regex("[-a]").firstMatch(in: input) // $ input=input regex=[-a]
    _ = try Regex("[-]").firstMatch(in: input) // $ input=input regex=[-]
    _ = try Regex("[*]").firstMatch(in: input) // $ input=input regex=[*]
    _ = try Regex("[^a]").firstMatch(in: input) // $ input=input regex=[^a]
    _ = try Regex("[a^]").firstMatch(in: input) // $ input=input regex=[a^]
    _ = try Regex(#"[\\]"#).firstMatch(in: input) // $ input=input regex=[\\]
    _ = try Regex(#"[\\\]]"#).firstMatch(in: input) // $ input=input regex=[\\\]]
    _ = try Regex("[:]").firstMatch(in: input) // $ input=input regex=[:]
    _ = try Regex("[:digit:]").firstMatch(in: input) // $ input=input regex=[:digit:] SPURIOUS: $hasParseFailure
    _ = try Regex("[:alnum:]").firstMatch(in: input) // $ input=input regex=[:alnum:] SPURIOUS: $hasParseFailure

	// invalid (Swift doesn't like these regexs)
    _ = try Regex("[]a]").firstMatch(in: input) // this is valid in other regex implementations, and is likely harmless to accept
    _ = try Regex("[:aaaaa:]").firstMatch(in: input) // $ hasParseFailure
}
