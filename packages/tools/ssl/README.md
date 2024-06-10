
# SSL

The SSL service is a central place to define and obtain SSL certificates.

Services which require SSL activation are encouraged to leverage this service. It
can also upload the certificates into the host filesystem.

# Configuration

## Example

```json
{
  "ssl": {
    "cacert": "/path/to/remote/certificate_authority",
    "cert": "/path/to/remote/certificate",
    "key": "/path/to/remote/private_key"
  }
}
```
