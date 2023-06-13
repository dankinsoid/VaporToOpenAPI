import Foundation

func prettyPrint(_ codable: some Encodable) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        try print(
            String(
                data: encoder.encode(codable),
                encoding: .utf8
            ) ?? ""
        )
    } catch {
        print(codable)
    }
}
