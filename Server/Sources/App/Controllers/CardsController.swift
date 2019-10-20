//
//  CardsController.swift
//  App
//
//  Created by Luke Street on 2/13/19.
//

import Vapor
import Models
import ZIPFoundation
import Fluent

extension Card: Content {}
extension ShareLink: Content {}

internal final class CardsController {
    
    let db: Database
    let logger: Logger
    let workDir: String

    init(db: Database, logger: Logger, workDir: String) {
        self.db = db
        self.workDir = workDir
        self.logger = logger
    }
    
    enum CardsError: Error {
        case unavailable
    }
    
    func share(_ req: Request) throws -> EventLoopFuture<ShareLink> {
        let card = CardModel(card: try req.content.decode(Card.self))
        return card
            .create(on: self.db)
            .map { ShareLink(path: "/sharedCard/\(card.id?.uuidString ?? "")") }
    }
    
    func sharedCard(_ req: Request) throws -> EventLoopFuture<Response> {
        guard
            let uuidString = req.parameters.get("id"),
            let uuid = UUID(uuidString: uuidString)
        else { return req.eventLoop.makeFailedFuture(CardsError.unavailable) }
        
        return CardModel
            .find(uuid, on: db)
            .map { $0.map { ($0.card, self.workDir, FileManager.default) } }
            .unwrap(or: CardsError.unavailable)
            .flatMapThrowing(createPass)
            .map(response)
    }
    
    func sharedCardInApp(_ req: Request) throws -> EventLoopFuture<Card> {
        guard
            let uuidString = req.parameters.get("id"),
            let uuid = UUID(uuidString: uuidString)
        else { return req.eventLoop.makeFailedFuture(CardsError.unavailable) }
        
        return CardModel
            .find(uuid, on: db)
            .unwrap(or: CardsError.unavailable)
            .map { $0.card }
    }
    
    private func stagePassDirectory(with workDir: String, using fileManager: FileManager = .default) throws -> (parent: URL, pass: URL, certs: URL) {
        let workingDirectoryURL = URL(fileURLWithPath: workDir).appendingPathComponent("Resources")
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
    
    func createPass(from card: Card, with workDir: String, using fileManager: FileManager = .default) throws -> (fileData: Data, fileName: String) {
        
        let (workingDirectoryURL, passDirectoryURL, certsDirectoryURL) = try stagePassDirectory(with: workDir, using: fileManager)
        
        let encoder = JSONEncoder()
        let passJSONURL = passDirectoryURL.appendingPathComponent("pass").appendingPathExtension("json")
        let passJsonData = try encoder.encode(Pass.init(from: card))
        try passJsonData.write(to: passJSONURL)
        
        let manifest = try fileManager.contentsOfDirectory(atPath: passDirectoryURL.path).reduce([:], { (result, filename) -> [String: String] in
            var newManifest = result
            let filepath = passDirectoryURL.appendingPathComponent(filename).path
            let fileData = try Data(contentsOf: URL(fileURLWithPath: filepath))
            
            let hash = Insecure.SHA1.hash(data: fileData)
            newManifest[filename] = hash.description
            return newManifest
        })
        
        logger.info("Created manifest dictionary.")
        
        let manifestData = try encoder.encode(manifest)
        
        let manifestURL = passDirectoryURL.appendingPathComponent("manifest").appendingPathExtension("json")
        
        
        try manifestData.write(to: manifestURL)
        
        let destinationURL = workingDirectoryURL.appendingPathComponent("Card").appendingPathExtension("zip")
        let signatureURL = passDirectoryURL.appendingPathComponent("signature")
        let wwdrURL = certsDirectoryURL.appendingPathComponent("WWDR").appendingPathExtension("pem")
        let passCertificateURL = certsDirectoryURL.appendingPathComponent("passcertificate").appendingPathExtension("pem")
        let passKeyURL = certsDirectoryURL.appendingPathComponent("passkey").appendingPathExtension("pem")
        let password = "thereisabetterway"
        
        let program = "/usr/bin/openssl"
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

        
        if #available(OSX 10.13, *) {
            do {
                _ = try Process.run(URL(fileURLWithPath: program), arguments: arguments)
            } catch {
                logger.critical("OpenSSL cannot be found at `\(program)`")
            }
            
        } else {
            // Fallback on earlier versions
        }

        try fileManager.zipItem(at: passDirectoryURL, to: destinationURL, shouldKeepParent: false)

        let zipData = try Data(contentsOf: destinationURL)
        
        try fileManager.removeItem(at: workingDirectoryURL)
        
        return (fileData: zipData, fileName: "Cards.pkpass")
        
    }
}

func response(fileData: Data, fileName: String) -> Response {
        let headers: HTTPHeaders = [
            "content-disposition": "attachment; filename=\"\(fileName)\""
        ]
        return Response(status: .accepted, headers: headers, body: .init(data: fileData))
}
