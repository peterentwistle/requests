
# Requests
![Swift](https://img.shields.io/badge/swift-6-brightgreen.svg)
[![Swift](https://github.com/peterentwistle/requests/actions/workflows/swift.yml/badge.svg)](https://github.com/peterentwistle/requests/actions/workflows/swift.yml)
[![Licence](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://github.com/peterentwistle/requests/blob/master/LICENSE)

Requests is a lightweight asynchronous HTTP Requests library written in Swift.

## Installation

### Swift Package Manager

Add `Requests` to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    name: "YourPackage",
    dependencies: [
        .package(url: "https://github.com/peterentwistle/requests", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "YourPackage",
            dependencies: [
                .product(name: "Requests", package: "requests"),
            ]
        ),
    ]
)
```

Then import the module in the code that needs it:

```swift
import Requests
```

You can also add it from the command line:

```bash
swift package add-dependency https://github.com/peterentwistle/requests
```

#### Currently supported HTTP request methods
- [GET](#get)
- [POST](#post)
- [PUT](#put)
- [PATCH](#patch)
- [DELETE](#delete)
- [HEAD](#head)

Further HTTP request methods will be implemented at a later date.

---

## Examples:
### Basic usage
```swift
import Requests

func example() async throws {
    let response = try await Requests.get("https://example.com")
    print(response.text)
    
    let ipResponse = try await Requests.get("https://httpbin.org/ip")
    print(ipResponse.text)
}
```

### Basic usage output
```html
<!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
...
```

```json
{
    "origin": "127.0.0.1"
}
```

### JSON Decoding Example
```swift
import Requests

struct IP: Decodable {
    var origin: String
}

func example() async throws {
    let response = try await Requests.get("https://httpbin.org/ip")
    let ip: IP = try response.json()
    
    print(ip.origin)
}
```

### JSON decoding output
```
127.0.0.1
```

---
## HTTP methods

### GET
```Swift
let response = try await Requests.get("https://httpbin.org/get")
print(response.text)
```

---
### POST
```Swift
let response = try await Requests.post("https://httpbin.org/post")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.post("https://httpbin.org/post",
                                       data: ["key": "value"])
print(response.text)
```
#### With a JSON object
```Swift
struct Test: Encodable {
    let value: String
}

let response = try await Requests.post("https://httpbin.org/post",
                                       json: Test(value: "Test123"))
print(response.text)
```

---
### PUT
```Swift
let response = try await Requests.put("https://httpbin.org/put")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.put("https://httpbin.org/put",
                                      data: ["key": "value"])
print(response.text)
```
#### With a JSON object
```Swift
struct Test: Encodable {
    let value: String
}

let response = try await Requests.put("https://httpbin.org/put",
                                      json: Test(value: "Test123"))
print(response.text)
```

---
### PATCH
```Swift
let response = try await Requests.patch("https://httpbin.org/patch")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.patch("https://httpbin.org/patch",
                                        data: ["key": "value"])
print(response.text)
```
#### With a JSON object
```Swift
struct Test: Encodable {
    let value: String
}

let response = try await Requests.patch("https://httpbin.org/patch",
                                       json: Test(value: "Test123"))
print(response.text)
```

---
### DELETE
```Swift
let response = try await Requests.delete("https://httpbin.org/delete")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.delete("https://httpbin.org/delete",
                                         data: ["key": "value"])
print(response.text)
```
#### With a JSON object
```Swift
struct Test: Encodable {
    let value: String
}

let response = try await Requests.delete("https://httpbin.org/delete",
                                         json: Test(value: "Test123"))
print(response.text)
```

### HEAD
```Swift
let response = try await Requests.head("https://httpbin.org/head")
print(response.headers)
```

---
## Authentication
### Bearer Authentication
```Swift
let bearerAuthentication = BearerAuthentication(token: "your-token")

let response = try await Requests.get("https://httpbin.org/bearer",
                                      authentication: bearerAuthentication)
print(response.text)
```

---
## Response

Every request returns a `Response` object. Its body can be read as text (`print(response.text)`) or decoded from JSON (`let value = try response.json()`), and it also exposes the raw `url`, `data`, and underlying `response` fields. The HTTP response can be inspected through its status code and headers.

### Status code
```swift
let response = try await Requests.get("https://httpbin.org/get")

let statusCode = try response.statusCode
print(statusCode)  // 200
```

### Headers
```swift
let response = try await Requests.get("https://httpbin.org/get")

let contentType = response.headers["Content-Type"]
print(contentType)  // "application/json"
```

### Errors

`json()` throws `ResponseError.noData` when there is no body to decode, and `statusCode` throws `ResponseError.invalidResponse` when the underlying response is not an `HTTPURLResponse`. A malformed URL string passed to a request throws `RequestError.invalidURL`.

```swift
import Requests

func example() async throws {
    do {
        let response = try await Requests.get("https://httpbin.org/missing")
        print(try response.statusCode)  // throws if the response is not HTTP
    } catch let error as ResponseError {
        print("Response error: \(error)")
    } catch {
        print("Request error: \(error)")  // e.g. RequestError.invalidURL, URLError, ...
    }
}
```

---
## Testability

All request methods accept a `session:` parameter (defaulting to `URLSession.shared`). Any type conforming to `URLSessionProtocol` can be injected, which is handy for testing without making real network requests:

```swift
struct MockSession: URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: URL(string: "https://localhost/")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )!
        return (Data(), response)
    }
}

let response = try await Requests.get("https://httpbin.org/get",
                                      session: MockSession())
print(response.text)
```

---
## Development

```bash
swift build        # Build the package
swift test         # Run all tests
```

### Linting

Code style is enforced with [SwiftLint](https://github.com/realm/SwiftLint). Install it locally with Homebrew:

```bash
brew install swiftlint
```

Then run the hook installer once (it wires the shared hook and installs swiftlint if needed):

```bash
./scripts/install-hooks.sh
```

This activates a `pre-commit` hook (`.githooks/pre-commit`) that runs
`swiftlint --strict` on every commit, so style issues are caught locally before they reach CI. 

To lint on demand:

```bash
swiftlint lint --strict
```

SwiftLint is configured in `.swiftlint.yml` and excluded paths (`.build/`, `DerivedData/`,
`.swiftpm/`) keep it fast. The same `swiftlint --strict` step also runs in CI
(`.github/workflows/swift.yml`). To disable the hook locally:

```bash
git config --unset core.hooksPath
```
