# Introduction
For creating Datadog uptime monitor(http) and SSL check(ssl) from multiple YAML files in a specific folder using Terraform.

# Prerequisites
- Terraform 1.3.x

# Getting started
### 1. Create yaml files with content for Datadog Synthetics checks
You can create multiple files in folder ```monitors/uptime/*.yaml```, use full and compact definition as bellow
```yaml
# full definition
monitors:
- name: #Unique monitor name
  type: #test type (api/browser)
  subtype: #test subtype
  message: #message to notify
  url: #url to monitor
  region: # region (emea, apac, us)
  locations: # list of datadog locations (required if no region provided)
  - aws:eu-north-1
  - aws:eu-west-2
  assertions: # assertions
  - operator: is
    type: statusCode
    target: 200
  - operator: lessThan
    type: responseTime
    target: 30000
  tags: #list of tags
  - priority:P1
  options_list:
    monitor_priority: 1 #monitor priority
    monitor_options: 
      renotify_interval: # renotify option in seconds
    tick_every: 60 #check frequency in seconds
    min_location_failed: 2 #failed location condition
    retry:
      interval: 60 #retry frequency
      count: 2 # retry failed
```
```yaml
# compact definition
monitors:
- name: #Unique monitor name
  url: #url to monitor
```
Or create a SSL check for a specific host

```yaml
ssl:
  - name: SSL check for voz.vn
    host: voz.vn
    port: 443
    # accepted region: emea, us, apac
    region: emea
    tags:
      - service:web
      - env:prod
```

### 2. Run Terraform commands
Create parameter.tfvars file with following content
```yaml
dd_api_key = "<your datadog API key>"
dd_app_key = "your datadog APP key"
```

Run ```terraform init``` to initialize terraform template

Run ```terraform plan -var-file=parameter.tfvars``` to plan your changes

Run ```terraform apply -var-file=parameter.tfvars``` to apply your changes