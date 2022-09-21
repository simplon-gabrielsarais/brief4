variable "rg" {
  default = "testchargeg2"
}

variable "location" {
  default = "westus"
}

variable "subdomain-prefix" {
  default = "votingappg2"
}

data "cloudinit_config" "cloud-init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("cloud-init.yml", {REDIS_HOST = azurerm_redis_cache.redis.hostname,
                                                   REDIS_PWD = azurerm_redis_cache.redis.primary_access_key})
  }
}
