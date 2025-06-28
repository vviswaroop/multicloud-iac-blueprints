# Grafana Datasources Configuration Template
apiVersion: 1

datasources:
%{ for datasource in datasources ~}
  - name: ${datasource.name}
    type: ${datasource.type}
    access: ${datasource.access}
    url: ${datasource.url}
    isDefault: ${datasource.is_default}
%{ if datasource.basic_auth_enabled ~}
    basicAuth: true
    basicAuthUser: ${datasource.basic_auth_user}
    secureJsonData:
      basicAuthPassword: ${datasource.basic_auth_password}
%{ endif ~}
%{ if length(datasource.json_data) > 0 ~}
    jsonData:
%{ for key, value in datasource.json_data ~}
      ${key}: ${value}
%{ endfor ~}
%{ endif ~}
%{ if length(datasource.secure_json_data) > 0 ~}
    secureJsonData:
%{ for key, value in datasource.secure_json_data ~}
      ${key}: ${value}
%{ endfor ~}
%{ endif ~}
%{ endfor ~}