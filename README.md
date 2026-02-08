
# Requests
![Swift](http://img.shields.io/badge/swift-5-brightgreen.svg)
[![Swift](https://github.com/peterentwistle/requests/actions/workflows/swift.yml/badge.svg)](https://github.com/peterentwistle/requests/actions/workflows/swift.yml)
[![Licence](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://github.com/peterentwistle/requests/blob/master/LICENSE)

Requests is a lightweight asynchronous HTTP Requests library written in Swift.

#### Currently supported HTTP request methods
- [GET](#get)
- [POST](#post)
- [PUT](#put)
- [PATCH](#patch)
- [DELETE](#delete)

Further HTTP request methods will be implemented at a later date.

---

## Examples:
### Basic usage
```swift
import Requests

func example() async throws {
    let response = try await Requests.get("http://example.com")
    print(response.text)
    
    let ipResponse = try await Requests.get("http://httpbin.org/ip")
    print(ipResponse.text)
}
```

### Output
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
    let response = try await Requests.get("http://httpbin.org/ip")
    let ip: IP = response.json()
    
    print(ip.origin)
}
```

### Output
```
127.0.0.1
```

---
## HTTP methods

### GET
```Swift
let response = try await Requests.get("http://httpbin.org/get")
print(response.text)
```

---
### POST
```Swift
let response = try await Requests.post("http://httpbin.org/post")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.post("http://httpbin.org/post", data: ["key": "value"])
print(response.text)
```
#### With json
```Swift
struct Test: Codable {
    let value: String
}

let response = try await Requests.post("http://httpbin.org/post", json: Test(value: "Test123"))
print(response.text)
```

---
### PUT
```Swift
let response = try await Requests.put("http://httpbin.org/put")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.put("http://httpbin.org/put", data: ["key": "value"])
print(response.text)
```
#### With json
```Swift
struct Test: Codable {
    let value: String
}

let response = try await Requests.put("http://httpbin.org/put", json: Test(value: "Test123"))
print(response.text)
```

---
### PATCH
```Swift
let response = try await Requests.patch("http://httpbin.org/patch")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.patch("http://httpbin.org/patch", data: ["key": "value"])
print(response.text)
```
#### With json
```Swift
struct Test: Codable {
    let value: String
}

let response = try await Requests.patch("http://httpbin.org/patch", json: Test(value: "Test123"))
print(response.text)
```

---
### DELETE
```Swift
let response = try await Requests.delete("http://httpbin.org/delete")
print(response.text)
```
#### With data
```Swift
let response = try await Requests.delete("http://httpbin.org/delete", data: ["key": "value"])
print(response.text)
```
#### With json
```Swift
struct Test: Codable {
    let value: String
}

let response = try await Requests.delete("http://httpbin.org/delete", json: Test(value: "Test123"))
print(response.text)
```

---
## Authentication
### Bearer Authentication
```Swift
let bearerAuthentication = BearerAuthentication(token: "your-token")

let response = try await Requests.get("https://httpbin.org/bearer", authentication: bearerAuthentication)
print(response.text)
```
