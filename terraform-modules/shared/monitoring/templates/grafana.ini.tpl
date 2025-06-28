# Grafana Configuration Template
[analytics]
check_for_updates = true

[grafana_net]
url = https://grafana.net

[log]
mode = console

[paths]
data = /var/lib/grafana/data
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins
provisioning = /etc/grafana/provisioning

%{ for section, settings in grafana_config ~}
[${section}]
%{ for key, value in settings ~}
${key} = ${value}
%{ endfor ~}

%{ endfor ~}