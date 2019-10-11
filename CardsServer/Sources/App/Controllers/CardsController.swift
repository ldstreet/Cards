//
//  CardsController.swift
//  App
//
//  Created by Luke Street on 2/13/19.
//

import Vapor
import Models
import ZIPFoundation

extension Card: Content {}
extension ShareLink: Content {}

import Crypto

internal final class CardsController {
    
    enum CardsError: Error {
        case unavailable
    }
    
    func share(_ req: Request) throws -> Future<ShareLink> {
        return
            try req.content
                .decode(Card.self)
                .flatMap { card in
                    let cacheID = UUID()
                    return try req
                        .keyedCache(for: .psql)
                        .set(cacheID.uuidString, to: card)
                        .transform(to: ShareLink(path: "/sharedCard/\(cacheID.uuidString)"))
                }
    }
    
    func sharedCard(_ req: Request) throws -> Future<Response> {
        let uuidString = try req.parameters.next(String.self)
        return try req
            .keyedCache(for: .psql)
            .get(uuidString, as: Card.self)
            .unwrap(or: CardsError.unavailable)
            .map { return ($0, req, FileManager.default) }
            .thenThrowing(createPass)
            .map(req.response)
    }
    
    private func stagePassDirectory(with container: Container, using fileManager: FileManager = .default) throws -> (parent: URL, pass: URL, certs: URL) {
        let workingDirectoryURL = URL(fileURLWithPath: try container.make(DirectoryConfig.self).workDir).appendingPathComponent("Resources")
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
