# Prometheus Configuration Template
global:
%{ for key, value in global_config ~}
  ${key}: ${value}
%{ endfor ~}

rule_files:
%{ for rule_file in rule_files ~}
  - "${rule_file}"
%{ endfor ~}

%{ if length(alerting_config) > 0 ~}
alerting:
  alertmanagers:
%{ for alertmanager in alerting_config ~}
    - static_configs:
        - targets:
%{ for target in alertmanager.targets ~}
            - "${target}"
%{ endfor ~}
%{ endfor ~}
%{ endif ~}

scrape_configs:
%{ for scrape_config in scrape_configs ~}
  - job_name: '${scrape_config.job_name}'
    scrape_interval: ${scrape_config.scrape_interval}
    metrics_path: ${scrape_config.metrics_path}
    static_configs:
      - targets:
%{ for target in scrape_config.targets ~}
          - '${target}'
%{ endfor ~}
%{ if length(scrape_config.labels) > 0 ~}
        labels:
%{ for key, value in scrape_config.labels ~}
          ${key}: '${value}'
%{ endfor ~}
%{ endif ~}
%{ if length(scrape_config.relabel_configs) > 0 ~}
    relabel_configs:
%{ for relabel_config in scrape_config.relabel_configs ~}
      - source_labels: [${join(", ", relabel_config.source_labels)}]
        target_label: ${relabel_config.target_label}
        regex: '${relabel_config.regex}'
        replacement: '${relabel_config.replacement}'
        action: ${relabel_config.action}
%{ endfor ~}
%{ endif ~}
%{ endfor ~}

%{ if length(remote_write_configs) > 0 ~}
remote_write:
%{ for remote_write in remote_write_configs ~}
  - url: "${remote_write.url}"
    name: "${remote_write.name}"
%{ if remote_write.basic_auth != null ~}
    basic_auth:
      username: "${remote_write.basic_auth.username}"
      password: "${remote_write.basic_auth.password}"
%{ endif ~}
%{ if length(remote_write.headers) > 0 ~}
    headers:
%{ for key, value in remote_write.headers ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ endfor ~}
%{ endif ~}

%{ if length(remote_read_configs) > 0 ~}
remote_read:
%{ for remote_read in remote_read_configs ~}
  - url: "${remote_read.url}"
    name: "${remote_read.name}"
%{ if remote_read.basic_auth != null ~}
    basic_auth:
      username: "${remote_read.basic_auth.username}"
      password: "${remote_read.basic_auth.password}"
%{ endif ~}
%{ if length(remote_read.headers) > 0 ~}
    headers:
%{ for key, value in remote_read.headers ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ endfor ~}
%{ endif ~}