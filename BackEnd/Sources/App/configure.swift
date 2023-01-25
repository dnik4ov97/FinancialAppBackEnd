import Vapor
import Fluent
import FluentMongoDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.databases.use(.mongo(connectionString: "mongodb+srv://dnikiforov:VBRlkBTZC9RAw9Np@users1.ocuefjd.mongodb.net/user_names"), as: .mongo)
//    try app.databases.use(.mongo(connectionString: "mongodb+srv://dnikiforov:VBRlkBTZC9RAw9Np@users1.ocuefjd.mongodb.net/user_emails"), as: .mongo)
    // reguster migrations
    
    app.migrations.add(CreateUserNames())
    
    // register routes
    try routes(app)
}
