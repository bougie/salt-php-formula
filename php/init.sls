# Meta-state to fully install php.
#
{% from "php/default.yml" import rawmap with context %}
{% set rawmap = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('php')) %}

include:
    - php.install
    - php.service
    - php.config

{% if 'fpm' in rawmap.pkgs %}
extend:
    fpm_service_status:
        service:
            - watch:
                - pkg: php_package
                - pkg: fpm_install_status
                - file: fpm_config
                - file: fpm_php_config
            - require:
                - pkg: fpm_install_status
{% endif %}
