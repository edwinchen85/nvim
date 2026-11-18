# Kulala guide

Kulala sends HTTP requests from Neovim. You write requests in a `.http` file,
put the cursor on one, and send it. The answer shows up in a side window.

This config pins kulala at **v6.23.0** (`lua/plugins/kulala.lua`). It is the
last version that runs without a license token. Everything below was tested
on that version. Newer kulala docs online may show features this version
doesn't have.

## 1. Keys

All keys start with `<leader>R`. They work in any buffer.

| Key           | What it does                                     |
| ------------- | ------------------------------------------------ |
| `<leader>Rs`  | Send the request under the cursor (or selection) |
| `<leader>Ra`  | Send every request in the file (or selection)    |
| `<leader>Rr`  | Send the last request again                      |
| `<leader>Re`  | Pick an environment (`dev`, `prod`, ...)         |
| `<leader>Ri`  | Show the request with variables filled in        |
| `<leader>Rb`  | Open the scratchpad (a throwaway `.http` buffer) |
| `<leader>Rc`  | Copy the request as a `curl` command             |
| `<leader>Rp`  | Paste a `curl` command from the clipboard as a request |

Inside the response window:

| Key       | What it shows / does              |
| --------- | --------------------------------- |
| `B`       | Body                              |
| `H`       | Headers                           |
| `A`       | Headers and body                  |
| `V`       | Verbose (the full curl exchange)  |
| `S`       | Stats (timings)                   |
| `O`       | Output of your scripts            |
| `R`       | Report (test results)             |
| `F`       | Filter the body with a jq query   |
| `[` / `]` | Older / newer response            |
| `<CR>`    | Jump to the request that made it  |
| `X`       | Clear the response history        |
| `?`       | Help                              |
| `q`       | Close                             |

Commands with no key: `:lua require("kulala").open_cookies_jar()`,
`:lua require("kulala").scripts_clear_global()` (forget saved tokens),
`:lua require("kulala").open()` (reopen the response window).

## 2. A `.http` file in 60 seconds

```http
### Get one product
GET https://dummyjson.com/products/1

### Create a product
POST https://dummyjson.com/products/add
Content-Type: application/json

{
  "title": "Pencil",
  "price": 1
}
```

- `###` starts a new request. Text after it is the request's name.
- First line: method, then URL.
- Next lines: headers, one per line.
- Then **one empty line**, then the body.
- `#` or `//` at the start of a line is a comment.

Put the cursor anywhere inside a block and press `<leader>Rs`.

## 3. Variables

### In the file

```http
@base = https://dummyjson.com

### Product
GET {{base}}/products/1
```

### Magic variables

```http
POST https://httpbin.org/post
Content-Type: application/json

{ "id": "{{$uuid}}", "ts": "{{$timestamp}}", "date": "{{$date}}", "n": "{{$randomInt}}" }
```

### Environment files

Two JSON files next to your `.http` file (or in any parent folder):

- `http-client.env.json`: normal settings. Safe to commit.
- `http-client.private.env.json`: passwords and secrets. **Add it to
  `.gitignore`.** Kulala also saves OAuth2 tokens here.

Kulala merges both. The top-level keys (`dev`, `prod`, ...) are environment
names. This config starts on `dev`. Switch with `<leader>Re`.
`$shared` applies to every environment, and `$default_headers` gets added to
every request.

Lookup order when names clash: system env vars, then `http-client.env.json`,
then `.env`.

## 4. Practice APIs (free, no sign-up)

| API | Good for | Login |
| --- | --- | --- |
| [DummyJSON](https://dummyjson.com/docs/auth) | Login → bearer token → refresh token | `emilys` / `emilyspass` (any user from `/users`) |
| [httpbin](https://httpbin.org) | Basic auth, checking a bearer header | Any user/pass you put in the URL |
| [Restful-booker](https://restful-booker.herokuapp.com/apidoc/index.html) | Token sent as a cookie | `admin` / `password123` |
| [Duende demo](https://demo.duendesoftware.com) | Real OAuth2 server | client `m2m` / secret `secret`, scope `api` |

These are public toys. Never send real passwords to them. Restful-booker is
buggy on purpose and resets now and then.

## 5. Ready-to-run playground

Make a folder (e.g. `~/kulala-playground`) and put these three files in it.
Open `auth-playground.http` and press `<leader>Ra` to run it all. Every
request should pass.

`http-client.env.json`:

```json
{
  "$schema": "https://getkulala.net/http-client.env.schema.json",
  "$shared": {
    "$default_headers": {
      "Accept": "application/json"
    }
  },
  "dev": {
    "DUMMY_URL": "https://dummyjson.com",
    "DUMMY_USER": "emilys",
    "Security": {
      "Auth": {
        "duende": {
          "Type": "OAuth2",
          "Grant Type": "Client Credentials",
          "Token URL": "https://demo.duendesoftware.com/connect/token",
          "Client ID": "m2m",
          "Client Credentials": "in body",
          "Scope": "api"
        }
      }
    }
  }
}
```

`http-client.private.env.json`:

```json
{
  "$schema": "https://getkulala.net/http-client.private.env.schema.json",
  "dev": {
    "DUMMY_PASS": "emilyspass",
    "Security": {
      "Auth": {
        "duende": {
          "Client Secret": "secret"
        }
      }
    },
    "auth_data": {
      "duende": {
        "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjM3RTlERDIwMjc1MDZGRUVERThGRDFDODY5NjgwMTM1IiwieDV0IjoiY0NyR0pVNjJVS2FOci1yQXRpS3JKcXlKT2VFIiwidHlwIjoiYXQrand0In0.eyJpc3MiOiJodHRwczovL2RlbW8uZHVlbmRlc29mdHdhcmUuY29tIiwibmJmIjoxNzk1MDA2MTgyLCJpYXQiOjE3OTUwMDYxODIsImV4cCI6MTc5NTAwOTc4MiwiYXVkIjoiYXBpIiwic2NvcGUiOlsiYXBpIl0sImNsaWVudF9pZCI6Im0ybSIsImp0aSI6IkNBOEJGQzQyMkI5MDk4NDVEMTJBNzg1RDQyRDhDQUI4In0.GV7TkhCHBGcw4O51VWMxL5e7bs-VWrwguoCKln8MBgmN4NcPgVX1JT98fIqHpE5lD9h9HEdGJ5q3pKyUTDP_-UnS8pTjrb_H7i4iSRTwl6rp92reh4CDVE1XxzQF8_NZCQM5nCDpN_VhdrPdblmaYEjIBNBmH8LmCqLCGNuDPhKCK1WHY_uqwOURzETCBTuc9uElYYZ4xdgLlVuMAIhTx6zkf-GTTmZLLelrdmMQ3JSN6_9hI_K-iBKMFA_P0GULmE6N9ykNZSNLKnNtenA5rNi7OiJkURLurwqDiPTX3b8_0eB9x1OU6wBdb5agPVzdpoVMCL--vIksOPGuRt6XCg",
        "expires_in": 3600,
        "token_type": "Bearer",
        "scope": "api",
        "expires_at": 1795009782
      }
    }
  }
}
```

`auth-playground.http`:

```http
### Plain GET (no auth)
GET https://dummyjson.com/products/1

### Basic auth (kulala base64-encodes user:pass for you)
GET https://httpbin.org/basic-auth/alice/s3cret
Authorization: Basic alice:s3cret

### Bearer header check (httpbin accepts any token)
GET https://httpbin.org/bearer
Authorization: Bearer hello-kulala

### DummyJSON login
POST {{DUMMY_URL}}/auth/login
Content-Type: application/json

{
  "username": "{{DUMMY_USER}}",
  "password": "{{DUMMY_PASS}}",
  "expiresInMins": 30
}

> {%
  client.global.set("access_token", response.body.accessToken);
  client.global.set("refresh_token", response.body.refreshToken);
  client.test("login works", function () {
    client.assert(response.status === 200, "status is 200");
    client.assert(response.body.username === "emilys", "right user");
  });
%}

### Who am I
GET {{DUMMY_URL}}/auth/me
Authorization: Bearer {{access_token}}

### Protected list
GET {{DUMMY_URL}}/auth/products?limit=2&select=title,price
Authorization: Bearer {{access_token}}

> {%
  client.test("got 2 products", function () {
    client.assert(response.body.products.length === 2, "2 products");
  });
%}

### No token -> 401
GET https://httpbin.org/bearer

> {%
  client.test("blocked without token", function () {
    client.assert(response.status === 401, "status is 401");
  });
%}

### Refresh the tokens
POST {{DUMMY_URL}}/auth/refresh
Content-Type: application/json

{
  "refreshToken": "{{refresh_token}}",
  "expiresInMins": 30
}

> {%
  client.global.set("access_token", response.body.accessToken);
  client.global.set("refresh_token", response.body.refreshToken);
%}

### Restful-booker login
POST https://restful-booker.herokuapp.com/auth
Content-Type: application/json

{ "username": "admin", "password": "password123" }

> {%
  client.global.set("booker_token", response.body.token);
%}

### Restful-booker: token goes in a Cookie
PATCH https://restful-booker.herokuapp.com/booking/1
Content-Type: application/json
Cookie: token={{booker_token}}

{ "additionalneeds": "Breakfast" }

### OAuth2 client credentials (config "duende" lives in the env files)
GET https://demo.duendesoftware.com/api/test
Authorization: Bearer {{$auth.token("duende")}}

### jq filter: keep only what you want
# @jq { title: .title, price: .price }
GET https://dummyjson.com/products/1

### Magic variables
POST https://httpbin.org/post
Content-Type: application/json

{ "id": "{{$uuid}}", "ts": "{{$timestamp}}", "date": "{{$date}}", "n": "{{$randomInt}}" }
```

## 6. Auth recipes

### Basic

```http
GET https://httpbin.org/basic-auth/alice/s3cret
Authorization: Basic alice:s3cret
```

Write `user:pass` in plain text. Kulala base64-encodes it.

### Bearer token you already have

Keep the token in `http-client.private.env.json`, then:

```http
GET https://api.example.com/me
Authorization: Bearer {{API_TOKEN}}
```

### Log in, save the token, use it everywhere

This is the main pattern. A **post-request script** runs after the response
arrives. `client.global.set` saves a value, and later requests read it as
`{{name}}`.

```http
### Login
POST https://dummyjson.com/auth/login
Content-Type: application/json

{ "username": "emilys", "password": "emilyspass" }

> {%
  client.global.set("access_token", response.body.accessToken);
  client.global.set("refresh_token", response.body.refreshToken);
%}

### Any protected call
GET https://dummyjson.com/auth/me
Authorization: Bearer {{access_token}}
```

Run **Login** once. After that, every request can use `{{access_token}}`.
When it expires, run the refresh request (see the playground) or log in again.

### Token in a cookie

```http
PATCH https://restful-booker.herokuapp.com/booking/1
Content-Type: application/json
Cookie: token={{booker_token}}

{ "additionalneeds": "Breakfast" }
```

### OAuth2 (built in)

1. Describe the provider under `Security.Auth.<id>` in
   `http-client.env.json`. Put the secret under the same `<id>` in the
   private file (see the playground files).
2. Use `{{$auth.token("<id>")}}` in a header.

Kulala gets the token, caches it in the private file, and refreshes it when
needed. Supported grant types: `Client Credentials`, `Password`,
`Authorization Code` (opens your browser; add `"PKCE": true` if the provider
wants it), `Device Authorization`, `Implicit`.

Shape for a browser login (fill in your provider's values):

```json
"my-login": {
  "Type": "OAuth2",
  "Grant Type": "Authorization Code",
  "Auth URL": "https://provider/authorize",
  "Token URL": "https://provider/token",
  "Redirect URL": "http://localhost:1234/callback",
  "Client ID": "my-app",
  "Scope": "openid profile",
  "PKCE": true
}
```

## 7. Testing responses

Add asserts in a post-request script. Results show in the report view (`R`).

```http
GET https://dummyjson.com/products/1

> {%
  client.test("product looks right", function () {
    client.assert(response.status === 200, "status is 200");
    client.assert(response.body.id === 1, "id is 1");
    client.assert(response.headers.valueOf("Content-Type").includes("json"), "json");
  });
  client.log("price: " + response.body.price);
%}
```

`client.log` output shows in the script view (`O`). Run a whole file with
`<leader>Ra` to use it as a small test suite.

## 8. Other handy bits

- **jq filter**: put `# @jq { title: .title }` above the URL to trim the body.
  You can also press `F` in the response window.
- **cURL in/out**: `<leader>Rc` copies the current request as `curl`.
  `<leader>Rp` turns a `curl` command on the clipboard into a request
  (handy with "Copy as cURL" from browser devtools).
- **Scratchpad**: `<leader>Rb` for quick one-off requests.
- **Inspect**: `<leader>Ri` shows exactly what will be sent, with variables
  filled in. Use it when `{{var}}` comes out empty.

## 9. Gotchas in v6.23.0

Kulala's online docs promise these, but they **don't work** in this version:

| Doesn't work | Do this instead |
| --- | --- |
| `{{login.response.body.$.token}}` (using one request's response in another) | Save it with `client.global.set(...)` in a `> {% %}` script |
| Lua scripts (`-- lua` blocks or `.lua` script files) | Write scripts in JavaScript (as above) |
| `Authorization: Digest user:pass` | Not supported here. Test Digest with plain `curl --digest` |
| `# @curl-...` flags | Ignored |

Other things to know:

- **Cookies stick.** Kulala keeps a cookie jar. If a login sets a cookie
  (DummyJSON does), later requests stay logged in even without a token. Use
  the cookie jar command from section 1 to look at it.
- **Saved tokens stick too.** `client.global` values survive until you clear
  them with `scripts_clear_global()`.
- **`{{VAR}}` is empty?** Check the environment (`<leader>Re`) and that the env
  files sit in the same folder as the `.http` file or a parent folder.
- **Don't update past v6.23.0.** Newer versions need a license token and will
  stop working. The pin in `lua/plugins/kulala.lua` blocks that.
