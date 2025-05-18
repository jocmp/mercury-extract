# Extract

Extract just the content from a web page.

Extract is a wrapper to turn the [Mercury Parser](https://github.com/jocmp/mercury-parser) into a web service.

## Why?

Postlight used to offer a [API component](https://github.com/postlight/parser-api), meant to be deployed to AWS Lambda. There are a few reasons why this exists as an alternative.

1. Deploy elsewhere. Extract is a vanilla Node.js app, that is meant to run in a VM, and has no platform specific dependencies.

1. Built-in authorization system.

1. Performance. Running it on a VM can be faster than the lambda version.

Here's a graph where you can see a decrease in average response time around the `17. Feb` mark. This is when Feedbin switched from the lambda hosted version, to extract running on a VPS.

![Response Time](https://user-images.githubusercontent.com/133809/53254496-54e85b00-3678-11e9-949a-f61824a4ac96.png)

## Installation

1. Install [Node.js](https://nodejs.org/en/) and [npm](https://www.npmjs.com/).

2. Clone extract

   ```bash
   git clone https://github.com/jocmp/mercury-extract.git
   ```

3. Install the dependencies.

   ```bash
   make install
   ```

4. Run the server

   ```bash
   make build run
   ```

## Usage

Extract has a simple, file-based system for creating users and secret keys. This allows users to be added/removed while the system is running. In the `./users` directory, the filename is the username and the contents is the secret key. To make a new user, run the following:

```
cd extract
mkdir users

# use your own secret key and username
echo "SECRET_KEY" > users/USERNAME
```

Once a username and password has been created, you can make a request.

An example request looks like:

```
http://localhost:8080/parser/:username/:signature?base64_url=:base64_url
```

The parts that you need are:

- `username` your username
- `signature` the hexadecimal HMAC-SHA1 signature of the URL you want to parse
- `base64_url` base64 encoded version of the URL you want to parse

The URL is base64-encoded to avoid any issues in the way different systems encode URLs. It must use the [RFC 4648](https://tools.ietf.org/html/rfc4648#section-5) url-safe variant with no newlines.

If your platform does not offer a URL safe base64 option, you can replicate it. First create the base64 encoded string. Then replace the following characters:

- `+` => `-`
- `/` => `_`
- `\n` => `""`

Here's a sample implementation in ruby. You can use this as a reference for matching your implementation.

```ruby
require "uri"
require "openssl"
require "base64"

username = "username"
secret = "secret"
host = "localhost"
port = 3000
url = "https://feedbin.com/blog/2018/09/11/private-by-default/"

digest = OpenSSL::Digest.new("sha1")
signature = OpenSSL::HMAC.hexdigest(digest, secret, url)

base64_url = Base64.urlsafe_encode64(url).gsub("\n", "")

URI::HTTPS.build({
  host: host,
  port: port,
  path: "/parser/#{username}/#{signature}",
  query: "base64_url=#{base64_url}"
}).to_s
```

The above example would produce:

```
https://localhost:3000/parser/username/e4696f8630bb68c21d77a9629ce8d063d8e5f81c?base64_url=aHR0cHM6Ly9mZWVkYmluLmNvbS9ibG9nLzIwMTgvMDkvMTEvcHJpdmF0ZS1ieS1kZWZhdWx0Lw==
```

With the output:

```json
{
  "title": "Private by Default",
  "author": null,
  "date_published": "2018-09-11T00:00:00.000Z",
  "dek": null,
  "lead_image_url": "https://assets.feedbin.com/assets-site/blog/2018-09-11/embed-3f43088538ae5ed7e585c00013adc13a915fd35de31990b3081a085b963ed7dd.png",
  "content": "<div>content</div>",
  "next_page_url": null,
  "url": "https://feedbin.com/blog/2018/09/11/private-by-default/",
  "domain": "feedbin.com",
  "excerpt": "September 11, 2018 by Ben Ubois I want Feedbin to be the opposite of Big Social. I think people should have the right not to be tracked on the Internet and Feedbin can help facilitate that. Since&hellip;",
  "word_count": 787,
  "direction": "ltr",
  "total_pages": 1,
  "rendered_pages": 1
}
```

## Attribution

Like with most things related to [Capy Reader](https://github.com/jocmp/capyreader), this repo was forked from [Feedbin](https://github.com/feedbin/feedbin). You can find the maintained source code for that at <https://github.com/feedbin/extract>.
