//
//  CardsController.swift
//  App
//
//  Created by Luke Street on 2/13/19.
//

import Vapor
import CardsKit
import ZIPFoundation
import OpenSSL

extension Array where Element == Card {
    internal static var mock: [Card] {
        return [
            .init(
                firstName: "Luke",
                lastName: "Street",
                emailAddress: "ldstreet@me.com",
                phoneNumber: "574-904-1556",
                title: "Software Developer",
                address: "123 Somewhere Ave."
            ),
            .init(
                firstName: "David",
                lastName: "Street",
                emailAddress: "dastreet@me.com",
                phoneNumber: "555-555-5555",
                title: "Project Manager",
                address: "123 Somewhere Else St."
            ),
            .init(
                firstName: "Joe",
                lastName: "Shmo",
                emailAddress: "jshmo@me.com",
                phoneNumber: "555-555-5555",
                title: "Designer",
                address: "123 Somewhere Else Further Ln."
            ),
        ]
    }
}

extension Card: Content {}

//extension UUID: Parameter {
//
//}

import Crypto

internal final class CardsController {
     func index(_ req: Request) throws -> Future<[Card]> {
        return req.future(.mock)
    }
    
    func share(_ req: Request) throws -> Future<Response> {
        return
            try req.content
                .decode(Card.self)
                .map { return ($0, req, FileManager.default) }
                .thenThrowing(createPass)
                .map(req.response)
    }
    
    func stagePassDirectory(with container: Container, using fileManager: FileManager = .default) throws -> (parent: URL, pass: URL, certs: URL) {
        let workingDirectoryURL = URL(fileURLWithPath: try container.make(DirectoryConfig.self).workDir)
        let stagingDirectoryURL = workingDirectoryURL.appendingPathComponent("PassStaging").appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: stagingDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        let passTemplateURL = workingDirectoryURL.appendingPathComponent("PassTemplate")
        let certsTemplateURL = workingDirectoryURL.appendingPathComponent("PassCerts")
        
        let passURL = stagingDirectoryURL.appendingPathComponent("Pass")
        let certsURL = stagingDirectoryURL.appendingPathComponent("Certs")
        try fileManager.copyItem(at: passTemplateURL, to: passURL)
        try fileManager.copyItem(at: certsTemplateURL, to: certsURL)
        
        return (parent: stagingDirectoryURL, pass: passURL, certs: certsURL)
        
    }
    
    func createPass(from card: Card, with container: Container, using fileManager: FileManager = .default) throws -> File {

        
        
        let (workingDirectoryURL, passDirectoryURL, certsDirectoryURL) = try stagePassDirectory(with: container, using: fileManager)
        let encoder = JSONEncoder()
        let passJSONURL = passDirectoryURL.appendingPathComponent("pass").appendingPathExtension("json")
        let passJsonData = try encoder.encode(Pass.init(from: card))
        try passJsonData.write(to: passJSONURL)
        
        let manifest = try fileManager.contentsOfDirectory(atPath: passDirectoryURL.path).reduce([:], { (result, filename) -> [String: String] in
            var newManifest = result
            let filepath = passDirectoryURL.appendingPathComponent(filename).path
            let fileData = try Data(contentsOf: URL(fileURLWithPath: filepath))
            let hash = try SHA1.hash(fileData)
            newManifest[filename] = hash.hexEncodedString()
            return newManifest
        })
        
        let manifestData = try encoder.encode(manifest)
        
        let manifestURL = passDirectoryURL.appendingPathComponent("manifest").appendingPathExtension("json")
        
        
        try manifestData.write(to: manifestURL)
        
        
        let destinationURL = workingDirectoryURL.appendingPathComponent("Card").appendingPathExtension("zip")
        let signatureURL = passDirectoryURL.appendingPathComponent("signature")
        let wwdrURL = certsDirectoryURL.appendingPathComponent("WWDR").appendingPathExtension("pem")
        let passCertificateURL = certsDirectoryURL.appendingPathComponent("passcertificate").appendingPathExtension("pem")
        let passKeyURL = certsDirectoryURL.appendingPathComponent("passkey").appendingPathExtension("pem")
        let password = "thereisabetterway"
        
        let program = "openssl"
        let arguments = """
            smime -binary -sign
            -certfile \(wwdrURL.path)
            -signer \(passCertificateURL.path)
            -inkey \(passKeyURL.path)
            -in \(manifestURL.path)
            -out \(signatureURL.path)
            -outform DER
            -passin pass:\(password)
        """
            .split { return $0 == " " || $0 == "\n" }
            .map(String.init)

        _ = try Process.execute(program, arguments)

        try fileManager.zipItem(at: passDirectoryURL, to: destinationURL, shouldKeepParent: false)

        let zipData = try Data(contentsOf: destinationURL)
        
        try fileManager.removeItem(at: workingDirectoryURL)
        
        return File(data: zipData, filename: "Cards.pkpass")
        
    }
}

extension Request {
    func response(file: File) -> Response {
        let headers: HTTPHeaders = [
            "content-disposition": "attachment; filename=\"\(file.filename)\""
        ]
        let res = HTTPResponse(headers: headers, body: file.data)
        return response(http: res)
    }
}
