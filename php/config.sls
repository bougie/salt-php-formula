{% from "php/default.yml" import rawmap with context %}
{% set rawmap = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('php')) %}

{% if 'fpm' in rawmap.pkgs and 'fpm' in rawmap.config%}
{% set cfg = rawmap.config %}
fpm_config:
    file.managed:
        - name: {{cfg.fpm.config_file}}
        - source: salt://php/files/php-fpm.conf
        - template: jinja
        - context:
            config: {{salt['pillar.get']('php:config:fpm:ini', cfg.fpm.ini.defaults, merge=True)}}

fpm_php_config:
    file.managed:
        - name: {{cfg.fpm.php_file}}
        - source: salt://php/files/php.ini
        - template: jinja
        - context:
            config: {{salt['pillar.get']('php:config:php:ini', cfg.php.ini.defaults, merge=True)}}
{% endif %}
