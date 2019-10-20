import Fluent
import Vapor

func routes(_ r: Routes, _ c: Container) throws {
    r.get { req in
        return "It works!"
    }

    r.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    let workDir = try c.make(DirectoryConfiguration.self).workingDirectory
    let cardsController = try CardsController(db: c.make(), logger: c.make(), workDir: workDir)
    r.post("share", use: cardsController.share)
    r.get("sharedCard", ":id", use: cardsController.sharedCard)
    r.get("sharedCardInApp", ":id", use: cardsController.sharedCardInApp)
}
