{% from "php/default.yml" import rawmap with context %}
{% set rawmap = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('php')) %}

{% if 'fpm' in rawmap.pkgs %}
fpm_service_status:
    service:
        - name : {{rawmap.config.fpm.service}}
        - running
{% endif %}
