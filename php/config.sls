{% from "php/default.yml" import rawmap with context %}
{% from "php/macros.jinja" import deep_merge %}
{% set rawmap = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('php')) %}

{% if 'fpm' in rawmap.pkgs and 'fpm' in rawmap.config%}
    {% set cfg = rawmap.config %}

    {% set vhosts = [] %}
    {% set fpm_vhosts_config = salt['pillar.get']('php:config:fpm:ini:vhosts') %}
fpm_config:
    {% if fpm_vhosts_config is mapping %}
        {% set tmp_vhosts_list = fpm_vhosts_config.keys() %}
    {% elif fpm_vhosts_config is iterable %}
        {% set tmp_vhosts_list = [] %}
        {% if fpm_vhosts_config is string or fpm_vhosts_config is number %}
            {% do tmp_vhosts_list.append(fpm_vhosts_config) %}
        {% else %}
            {% for item in fpm_vhosts_config %}
                {% if item is string or item is number %}
                    {% do tmp_vhosts_list.append(item) %}
                {% elif item is mapping %}
                    {% do tmp_vhosts_list.append(item.items()[0][0]) %}
                {% endif %}
            {% endfor %}
        {% endif %}
    {% else %}
        {% set tmp_vhosts_list = [] %}
    {% endif %}
    {% for vhost_id in tmp_vhosts_list %}
        {% set vhost_pillar = salt['pillar.get']('php:config:fpm:ini:vhosts:' ~ vhost_id, {}, merge=True) %}
        {% do deep_merge(vhost_pillar, cfg.fpm.ini.defaults_vhost) %}
        {% do vhosts.append({vhost_id: vhost_pillar}) %}
    {% endfor %}
    file.managed:
        - name: {{cfg.fpm.config_file}}
        - source: salt://php/files/php-fpm.conf
        - template: jinja
        - context:
            config: {{salt['pillar.get']('php:config:fpm:ini:global', cfg.fpm.ini.defaults, merge=True)}}
            vhosts_config: {{vhosts}}

fpm_php_config:
    file.managed:
        - name: {{cfg.fpm.php_file}}
        - source: salt://php/files/php.ini
        - template: jinja
        - context:
            config: {{salt['pillar.get']('php:config:php:ini', cfg.php.ini.defaults, merge=True)}}
{% endif %}
