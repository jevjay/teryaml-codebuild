## Inputs

Module input variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| config | Path to the pipeline configuration file | string | n/a | yes |
| raw_config | RAW Yaml configuration for the module. **IMPORTANT** Overwrites 'config' variable | string | "\"config\": []" | no |
| shared_tags | Tags shared between provisioned resources | map{any} | \{\} | no |
