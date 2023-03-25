import App
import Vapor

let app = Application()
app.environment = try Environment.detect()

defer {
	app.shutdown()
}

try await configure(app)
try app.run()
