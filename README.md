###  CI Automation for Fathm

Steps to be running:

1) Have Terraform Envvars ready so you can access digitalocean:

```
TF_VAR_do_token=DIGITAL_OCEAN_TOKEN
TF_VAR_ssh_fingerprint=MD5_PUBLIC_SSH_KEY_FINGERPRINT
TF_VAR_pvt_key=PRIVATE_SSH_KEY_PATH
TF_VAR_pub_key=PUBLIC_SSH_KEY_PATH
```

2)

```
./get_discovery_token.sh # TODO: automate this part away as well
terraform plan   # Dry run
terraform graph  # See a graphical tree representation of how resources inter-depend
terraform apply  # Fork out a cluster
```
