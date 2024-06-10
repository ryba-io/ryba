
# Node.js

Deploy multiple version of [NodeJs] using [N].

It depends on the "masson/core/git" and "masson/commons/users" modules. The former
is used to download n and the latest is used to write a "~/.npmrc" file in the
home of each users.

## Configuration

*   `nodejs.version` (string)   
    Any NodeJs version with the addition of "latest" and "stable", see the [N] 
    documentation for more information, default to "stable".
*   `nodejs.merge` (boolean)   
    Merge the properties defined in "nodejs.config" with the one present on
    the existing "~/.npmrc" file, default to true
*   `nodejs.config.http_proxy` (string)
    The HTTP proxy connection url, default to the one defined by the 
    "masson/core/proxy" module.
*   `nodejs.config.https-proxy` (string)
    The HTTPS proxy connection url, default to the one defined by the 
    "masson/core/proxy" module.
*   `nodejs.version` (string)
*   `nodejs.version` (string)

## Example

```json
{
  "nodejs": {
    "version": "stable",
    "config": {
      "registry": "http://some.aternative.registry"
    }
  }
}
```

## resources

- [nodejs](http://www.nodejs.org)
- [n](https://github.com/visionmedia/n)
