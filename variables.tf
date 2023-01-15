variable "dd_api_key" {
  type = string
}

variable "dd_app_key" {
  type = string
}

variable "port" {
  type    = number
  default = 443
}

variable "test_type" {
  type    = string
  default = "api"
}

variable "http_subtype" {
  type    = string
  default = "http"
}

variable "ssl_subtype" {
  type    = string
  default = "ssl"
}

variable "status" {
  type    = string
  default = "live"
}

variable "region" {
  type    = string
  default = "emea"
}

variable "monitor_locations" {
  type = map(any)
  default = {
    "us"   = ["aws:us-west-1", "aws:ca-central-1"]
    "emea" = ["aws:eu-west-1", "aws:eu-north-1"]
    "apac" = ["aws:ap-northeast-1", "aws:ap-east-1"]
  }
}

variable "synthetics_test_method" {
  type    = string
  default = "GET"
}

variable "message" {
  type    = string
  default = "Synthetics monitor message"
}

variable "tags" {
  type    = list(string)
  default = ["env:production"]
}

variable "test_timeout" {
  type    = number
  default = 60
}

variable "ssl_assertions" {
  type = list(object({
    type     = string
    operator = string
    target   = string
  }))

  default = [
    {
      type     = "certificate"
      operator = "isInMoreThan"
      target   = "60"
    },
    {
      type     = "certificate"
      operator = "isInMoreThan"
      target   = "30"
    },
    {
      type     = "certificate"
      operator = "isInMoreThan"
      target   = "15"
    },
    {
      type     = "certificate"
      operator = "isInMoreThan"
      target   = "7"
    }
  ]
}

variable "http_assertions" {
  type = list(object({
    type     = string
    operator = string
    target   = string
  }))

  default = [
    {
      type     = "statusCode"
      operator = "is"
      target   = "200"
    },
    {
      type     = "responseTime"
      operator = "lessThan"
      target   = "30000"
  }]
}

variable "http_options_list" {
  type = object({
    min_location_failed = number
    tick_every          = number
    monitor_priority    = number
    retry = object({
      count    = number
      interval = number
    })
    monitor_options = object({
      renotify_interval = number
    })
  })

  default = {
    min_location_failed = 2
    tick_every          = 60
    monitor_priority    = 1
    retry = {
      count    = 0
      interval = 300
    }
    monitor_options = {
      renotify_interval = 0
    }
  }
}

variable "ssl_options_list" {
  type = object({
    min_location_failed = number
    tick_every          = number
    monitor_priority    = number
    retry = object({
      count    = number
      interval = number
    })
    monitor_options = object({
      renotify_interval = number
    })
  })

  default = {
    min_location_failed = 2
    tick_every          = 86400
    monitor_priority    = 1
    retry = {
      count    = 0
      interval = 300
    }
    monitor_options = {
      renotify_interval = 0
    }
  }
}
