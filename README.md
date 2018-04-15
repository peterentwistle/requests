
# Requests
![Swift](http://img.shields.io/badge/swift-4.0-brightgreen.svg)
[![Build Status](https://travis-ci.org/peterentwistle/requests.svg?branch=master)](https://travis-ci.org/peterentwistle/requests)
[![Licence](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://github.com/peterentwistle/requests/blob/master/LICENSE)

Requests is a lightweight asynchronous HTTP Requests library written in Swift.

#### Currently supported HTTP request methods
- [Get](#examples)
- [Post](#post-data)

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

### Post data
```Swift
Requests.post("http://httpbin.org/post", data: ["key": "value"]) { response in
    print(response.text())
}
```
