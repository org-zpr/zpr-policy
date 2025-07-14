# Policy "compiled form" Protocol Buffer Format

## [0.3.0] - 2025-06-11

- Remove container_version and serial_version in favor of three fields
  to hold the compiler version (major, minor, patch).

## [0.2.2] - 2025-06-05

- New fields on the service to store returned and identity attributes.


## [0.2.0] - 2025-06-02

- Support for new service type `SVC_ACTOR_AUTH` for an actor facting 
  authentication service.
- Remove some of the old zds service propoerties and add in properties for 
  the query URI and validate URI.


[0.2.2]: https://github.com/org-zpr/zpr-policy/releases/tag/v0.2.2
[0.2.0]: https://github.com/org-zpr/zpr-policy/releases/tag/v0.2.0

