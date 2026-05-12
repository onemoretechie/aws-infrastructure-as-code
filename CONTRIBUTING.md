# Contributing

This repository is primarily a learning and reference resource. PRs and issues are welcome, especially for:

- Bug fixes in existing modules
- Documentation improvements
- New tutorial-aligned modules (open an issue first to discuss scope)

## Local checks before opening a PR

```bash
terraform fmt -recursive -check
terraform validate           # run inside each module / stack with a backend stub
```

If you have [`tflint`](https://github.com/terraform-linters/tflint) and [`tfsec`](https://github.com/aquasecurity/tfsec) installed, run them too — CI will eventually enforce them.

## Style

- Snake_case for variable, output, and resource names.
- Every variable has a `description` and a `type`.
- Every output has a `description`.
- Pin provider versions in `versions.tf` at the module level.
