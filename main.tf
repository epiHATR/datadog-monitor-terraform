terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.20.0"
    }
  }
}

provider "datadog" {
  api_key = var.dd_api_key
  app_key = var.dd_app_key
}

locals {
  uptime_file         = fileset(path.module, "monitors/uptime/*.yaml")
  uptime_file_content = { for file in local.uptime_file : file => yamldecode(file(file)) }
  monitors            = flatten([for content in local.uptime_file_content : content["monitors"]])

  ssl_file         = fileset(path.module, "monitors/ssl/*.yaml")
  ssl_file_content = { for file in local.ssl_file : file => yamldecode(file(file)) }
  ssl_checks       = flatten([for content in local.ssl_file_content : content["ssl"]])
}

resource "datadog_synthetics_test" "api_ssl" {
  for_each = { for ssl in local.ssl_checks : ssl.name => ssl }

  name      = each.value.name
  type      = can(each.value.type) ? each.value.type : var.test_type
  subtype   = can(each.value.subtype) ? each.value.subtype : var.ssl_subtype
  status    = can(each.value.status) ? each.value.status : var.status
  locations = can(each.value.locations) ? each.value.locations : var.monitor_locations[can(each.value.region) ? each.value.region : "emea"]
  tags      = can(each.value.tags) ? each.value.tags : var.tags

  request_definition {
    host = each.value.host
    port = each.value.port
  }

  dynamic "assertion" {
    for_each = can(each.value.assertions) ? each.value.assertions : var.ssl_assertions
    content {
      type     = assertion.value.type
      operator = assertion.value.operator
      target   = assertion.value.target
    }
  }

  dynamic "options_list" {
    for_each = can(each.value.options_list) ? each.value.options_list[*] : var.ssl_options_list[*]
    content {
      tick_every          = options_list.value.tick_every
      monitor_name        = "[Synthetics] ${each.value.name}"
      monitor_priority    = options_list.value.monitor_priority
      min_location_failed = options_list.value.min_location_failed

      dynamic "retry" {
        for_each = can(options_list.value.retry) ? options_list.value.retry[*] : each.value.options_list[*].retry
        content {
          count    = retry.value.count
          interval = retry.value.interval
        }
      }

      dynamic "monitor_options" {
        for_each = can(options_list.value.monitor_options) ? options_list.value.monitor_options[*] : each.value.options_list[*].monitor_options
        content {
          renotify_interval = monitor_options.value.renotify_interval
        }
      }
    }
  }
}

resource "datadog_synthetics_test" "api_http" {
  for_each = { for monitor in local.monitors : monitor.name => monitor }

  name      = each.value.name
  type      = can(each.value.type) ? each.value.type : var.test_type
  subtype   = can(each.value.subtype) ? each.value.subtype : var.http_subtype
  message   = can(each.value.message) ? each.value.message : var.message
  status    = can(each.value.status) ? each.value.status : var.status
  tags      = can(each.value.tags) ? each.value.tags : var.tags
  locations = can(each.value.locations) ? each.value.locations : var.monitor_locations[can(each.value.region) ? each.value.region : "emea"]

  request_definition {
    method  = can(each.value.method) ? each.value.method : var.synthetics_test_method
    url     = each.value.url
    timeout = can(each.value.timeout) ? each.value.timeout : var.test_timeout
  }

  dynamic "assertion" {
    for_each = can(each.value.assertions) ? each.value.assertions : var.http_assertions
    content {
      type     = assertion.value.type
      operator = assertion.value.operator
      target   = assertion.value.target
    }
  }

  dynamic "options_list" {
    for_each = can(each.value.options_list) ? each.value.options_list[*] : var.http_options_list[*]
    content {
      tick_every          = options_list.value.tick_every
      monitor_name        = "[Synthetics] ${each.value.name}"
      monitor_priority    = options_list.value.monitor_priority
      min_location_failed = options_list.value.min_location_failed

      dynamic "retry" {
        for_each = can(options_list.value.retry) ? options_list.value.retry[*] : each.value.options_list[*].retry
        content {
          count    = retry.value.count
          interval = retry.value.interval
        }
      }

      dynamic "monitor_options" {
        for_each = can(options_list.value.monitor_options) ? options_list.value.monitor_options[*] : each.value.options_list[*].monitor_options
        content {
          renotify_interval = monitor_options.value.renotify_interval
        }
      }
    }
  }
}
