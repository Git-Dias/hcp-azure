# Painel do lab: escolha o que será provisionado.
# Carregado automaticamente pelo Terraform/HCP (*.auto.tfvars). Não coloque segredos aqui.
# Os cenários PASS/FAIL de cada recurso ficam nos comentários "FAIL:" do main.tf.

enable_network          = true
enable_storage          = true
enable_bot              = true
enable_keyvault         = true
enable_keyvault_objects = true # key + secret (ver aviso sobre data plane no main.tf)
enable_vm               = true # exige enable_network
enable_vmss             = true # exige enable_network
