import Foundation

public struct Version: Codable, Comparable, LosslessStringConvertible, ExpressibleByStringLiteral {
 
    public static let zero = Version(0, 0, 0)
    
    /// version when you make incompatible API changes
    public var major: UInt
    
    /// version when you add functionality in a backwards compatible manner
    public var minor: UInt
    
    /// version when you make backwards compatible bug fixes
    public var patch: UInt
    
    /// The pre-release identifier according to the semantic versioning standard, such as -beta.1.
    public var prereleaseIdentifiers: [String]
    
    /// The build metadata of this version according to the semantic versioning standard, such as a commit hash.
    public var buildMetadataIdentifiers: [String]
    
    public init(
        _ major: UInt,
        _ minor: UInt,
        _ patch: UInt,
        prereleaseIdentifiers: [String] = [],
        buildMetadataIdentifiers: [String] = []
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prereleaseIdentifiers = prereleaseIdentifiers
        self.buildMetadataIdentifiers = buildMetadataIdentifiers
    }
    
    public init?(_ string: String) {
        let prereleaseStartIndex = string.firstIndex(of: "-")
        let metadataStartIndex = string.firstIndex(of: "+")
        
        let requiredEndIndex = prereleaseStartIndex ?? metadataStartIndex ?? string.endIndex
        let requiredCharacters = string.prefix(upTo: requiredEndIndex)
        let requiredComponents = requiredCharacters
            .split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
            .compactMap({ UInt($0) })
        
        guard requiredComponents.count == 3 else { return nil }
        
        let major = requiredComponents[0]
        let minor = requiredComponents[1]
        let patch = requiredComponents[2]
        
        func identifiers(start: String.Index?, end: String.Index) -> [String] {
            guard let start = start else { return [] }
            let identifiers = string[string.index(after: start)..<end]
            return identifiers.split(separator: ".").map(String.init(_:))
        }
        
        let prereleaseIdentifiers = identifiers(
            start: prereleaseStartIndex,
            end: metadataStartIndex ?? string.endIndex
        )
    		let buildMetadataIdentifiers = identifiers(
            start: metadataStartIndex,
            end: string.endIndex
        )
        self.init(
            major,
            minor,
            patch,
            prereleaseIdentifiers: prereleaseIdentifiers,
            buildMetadataIdentifiers: buildMetadataIdentifiers
        )
    }
    
    public init(stringLiteral value: String) {
        self = Version(value) ?? .zero
    }
    
    public init(from decoder: Decoder) throws {
        let string = try String(from: decoder)
        guard let version = Version(string) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid version string \(string)"
                )
            )
        }
        self = version
    }
    
    public var description: String {
        var base = "\(major).\(minor).\(patch)"
        if !prereleaseIdentifiers.isEmpty {
            base += "-" + prereleaseIdentifiers.joined(separator: ".")
        }
        if !buildMetadataIdentifiers.isEmpty {
            base += "+" + buildMetadataIdentifiers.joined(separator: ".")
        }
        return base
    }
    
    public func encode(to encoder: Encoder) throws {
        try description.encode(to: encoder)
    }
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
        let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
        
        if lhsComparators != rhsComparators {
            return lhsComparators.lexicographicallyPrecedes(rhsComparators)
        }
        
        guard lhs.prereleaseIdentifiers.count > 0 else {
            return false // Non-prerelease lhs >= potentially prerelease rhs
        }
        
        guard rhs.prereleaseIdentifiers.count > 0 else {
            return true // Prerelease lhs < non-prerelease rhs
        }
        
        let zippedIdentifiers = zip(lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers)
        for (lhsPrereleaseIdentifier, rhsPrereleaseIdentifier) in zippedIdentifiers {
            if lhsPrereleaseIdentifier == rhsPrereleaseIdentifier {
                continue
            }
            
            let typedLhsIdentifier: Any = Int(lhsPrereleaseIdentifier) ?? lhsPrereleaseIdentifier
            let typedRhsIdentifier: Any = Int(rhsPrereleaseIdentifier) ?? rhsPrereleaseIdentifier
            
            switch (typedLhsIdentifier, typedRhsIdentifier) {
            case let (int1 as Int, int2 as Int): return int1 < int2
            case let (string1 as String, string2 as String): return string1 < string2
            case (is Int, is String): return true // Int prereleases < String prereleases
            case (is String, is Int): return false
            default: return false
            }
        }
        
        return lhs.prereleaseIdentifiers.count < rhs.prereleaseIdentifiers.count
    }
}
