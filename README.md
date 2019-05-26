
# Requests
![Swift](http://img.shields.io/badge/swift-5-brightgreen.svg)
[![Build Status](https://travis-ci.org/peterentwistle/requests.svg?branch=master)](https://travis-ci.org/peterentwistle/requests)
[![Licence](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://github.com/peterentwistle/requests/blob/master/LICENSE)

Requests is a lightweight asynchronous HTTP Requests library written in Swift.

#### Currently supported HTTP request methods
- [GET](#get)
- [POST](#post)
- [PUT](#put)
- [PATCH](#patch)
- [DELETE](#delete)

Further HTTP request methods are going to be implemented soon.

---

## Examples:
### Basic usage
```swift
import Requests

Requests.get("http://example.com") { response in
  print(response.text())
}

Requests.get("http://httpbin.org/ip") { response in
  print(response.text())
}
```

### Output
```
<!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
...
```

```
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

Requests.get("http://httpbin.org/ip") { response in
  let json: IP = response.json()

  print(json.origin)
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
Requests.get("http://httpbin.org/get") { response in
    print(response.text())
}
```

### POST
```Swift
Requests.post("http://httpbin.org/post") { response in
    print(response.text())
}
```
#### With data
```Swift
Requests.post("http://httpbin.org/post", data: ["key": "value"]) { response in
    print(response.text())
}
```

### PUT
```Swift
Requests.put("http://httpbin.org/put") { response in
    print(response.text())
}
```
#### With data
```Swift
Requests.put("http://httpbin.org/put", data: ["key": "value"]) { response in
    print(response.text())
}
```

### PATCH
```Swift
Requests.patch("http://httpbin.org/patch") { response in
    print(response.text())
}
```
#### With data
```Swift
Requests.patch("http://httpbin.org/patch", data: ["key": "value"]) { response in
    print(response.text())
}
```

### DELETE
```Swift
Requests.delete("http://httpbin.org/delete"]) { response in
    print(response.text())
}
```
#### With data
```Swift
Requests.delete("http://httpbin.org/delete", data: ["key": "value"]) { response in
    print(response.text())
}
```
