### Useful commands

Apply with var file:
```bash
terraform apply -var-file envs/dev.tfvars
```

Destroy with var file:
```bash
terraform destroy -var-file envs/dev.tfvars
```

Create workspace:
```bash
terraform workspace new dev
```

Change workspace:
```bash
terraform workspace select dev
```
