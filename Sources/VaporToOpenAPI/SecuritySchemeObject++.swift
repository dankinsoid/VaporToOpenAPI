import Foundation
import SwiftOpenAPI
import Vapor

extension SecuritySchemeObject {
    
    var autoName: String {
        [
            type.rawValue,
            scheme?.rawValue,
            bearerFormat,
            `in`?.rawValue,
            (flows?.password).map { _ in "password" },
            (flows?.clientCredentials).map { _ in "clientCredentials" },
            (flows?.authorizationCode).map { _ in "authorizationCode" },
            (flows?.implicit).map { _ in "implicit" }
        ]
            .compactMap { $0 }
            .joined(separator: "_")
    }
    
    var allScopes: [String] {
        [
        	flows?.implicit?.scopes,
        	flows?.authorizationCode?.scopes,
        	flows?.clientCredentials?.scopes,
        	flows?.password?.scopes
        ].flatMap { ($0 ?? [:]).keys }
    }
}
    
extension Route {
    
    func setNew(
        auth: [SecuritySchemeObject],
        scopes: [String]
    ) -> Route {
        let newAuth = (auths + auth).removeEquals
        return set(\.auths, to: newAuth)
            .openAPI(custom: \.security, securities(auth: newAuth, scopes: scopes, old: operationObject.security))
    }
    
}

func securities(
    auth: [SecuritySchemeObject],
    scopes: [String] = [],
    old: [SecurityRequirementObject]? = nil
) -> [SecurityRequirementObject]? {
    auth.map { auth in
        let name = auth.autoName
        return SecurityRequirementObject(
            name,
            ((old?.first(where: { $0.name == name })?.values ?? []) + scopes).nilIfEmpty ?? auth.allScopes
        )
    }.nilIfEmpty
}
