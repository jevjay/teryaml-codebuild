# === Required variables ===

variable "config" {
  type    = string
  default = "Path to the pipeline configuration file"
}

# === Optional variables ===

variable "raw_config" {
  type        = string
  description = "RAW Yaml configuration for the module. **IMPORTANT** Overwrites 'config' variable"
  default     = "\"config\": []"
}

variable "shared_tags" {
  type        = map(any)
  description = "Additional user defiend resoirce tags"
  default     = {}
}
