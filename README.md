# zpr-policy
ZPR Policy descriptor source

## How to create a new version

General idea is you need to first make your changes to `policy.proto`
here in this repo and commit that.  Then:

* Tag `main` in this repo with your new version, eg `v0.2.0`.
* In this repo, create a new release.  This will trigger a github action
  that will build the bindings and create PRs on the go and rust policy
  repos.
* In repo `zpr-policy-go` approve/commit the auto generated PR.
* In repo `zpr-policy-rs` approve/commit the auth generated PR.

At this point the new code is in the dependency repositories but it now
needs a tag so we can lock to the correct version in our build files.  
So: 

* In repo `zpr-policy-go` create a new tag, eg `v0.2.0`.
* In repo `zpr-policy-rs` create same new tag.

Now in code that needs the new policy format, you need to alter the
`Cargo.toml` or the `go.mod` to point to the correct tag.

