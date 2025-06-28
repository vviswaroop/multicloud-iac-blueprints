# AlertManager Configuration Template
global:
%{ for key, value in alertmanager_config.global ~}
  ${key}: ${value}
%{ endfor ~}

%{ if length(alertmanager_config.templates) > 0 ~}
templates:
%{ for template in alertmanager_config.templates ~}
  - '${template}'
%{ endfor ~}
%{ endif ~}

route:
  group_by: ${jsonencode(alertmanager_config.route.group_by)}
  group_wait: ${alertmanager_config.route.group_wait}
  group_interval: ${alertmanager_config.route.group_interval}
  repeat_interval: ${alertmanager_config.route.repeat_interval}
  receiver: '${alertmanager_config.route.receiver}'
%{ if length(alertmanager_config.route.routes) > 0 ~}
  routes:
%{ for route in alertmanager_config.route.routes ~}
    - match:
%{ for key, value in route.match ~}
        ${key}: '${value}'
%{ endfor ~}
      receiver: '${route.receiver}'
%{ if route.group_wait != null ~}
      group_wait: ${route.group_wait}
%{ endif ~}
%{ if route.group_interval != null ~}
      group_interval: ${route.group_interval}
%{ endif ~}
%{ if route.repeat_interval != null ~}
      repeat_interval: ${route.repeat_interval}
%{ endif ~}
%{ endfor ~}
%{ endif ~}

receivers:
%{ for receiver in alertmanager_config.receivers ~}
  - name: '${receiver.name}'
%{ if length(receiver.email_configs) > 0 ~}
    email_configs:
%{ for email_config in receiver.email_configs ~}
      - to: '${email_config.to}'
        from: '${email_config.from}'
        smarthost: '${email_config.smarthost}'
        subject: '${email_config.subject}'
        body: '${email_config.body}'
%{ if email_config.auth_username != null ~}
        auth_username: '${email_config.auth_username}'
        auth_password: '${email_config.auth_password}'
%{ endif ~}
%{ endfor ~}
%{ endif ~}
%{ if length(receiver.slack_configs) > 0 ~}
    slack_configs:
%{ for slack_config in receiver.slack_configs ~}
      - api_url: '${slack_config.api_url}'
        channel: '${slack_config.channel}'
        title: '${slack_config.title}'
        text: '${slack_config.text}'
%{ endfor ~}
%{ endif ~}
%{ if length(receiver.webhook_configs) > 0 ~}
    webhook_configs:
%{ for webhook_config in receiver.webhook_configs ~}
      - url: '${webhook_config.url}'
%{ if webhook_config.send_resolved != null ~}
        send_resolved: ${webhook_config.send_resolved}
%{ endif ~}
%{ endfor ~}
%{ endif ~}
%{ endfor ~}

%{ if length(alertmanager_config.inhibit_rules) > 0 ~}
inhibit_rules:
%{ for inhibit_rule in alertmanager_config.inhibit_rules ~}
  - source_match:
%{ for key, value in inhibit_rule.source_match ~}
      ${key}: '${value}'
%{ endfor ~}
    target_match:
%{ for key, value in inhibit_rule.target_match ~}
      ${key}: '${value}'
%{ endfor ~}
    equal: ${jsonencode(inhibit_rule.equal)}
%{ endfor ~}
%{ endif ~}