//import Crypto
import Vapor
import Models
//import LoginModule

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // public routes
//    let userController = UserController()
//    router.post("users", use: userController.create)
    
    let cardsController = CardsController()
    router.post("share", use: cardsController.share)
    router.get("sharedCard", String.parameter, use: cardsController.sharedCard)
    router.get("cards", use: cardsController.index)
    
    
    // basic / password auth protected routes
//    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
//    basic.post("login", use: userController.login)
    
    // bearer / token auth protected routes
//    let bearer = router.grouped(User.tokenAuthMiddleware())
    
    
}
