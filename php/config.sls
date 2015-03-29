{% from "php/default.yml" import rawmap with context %}
{% from "php/macros.jinja" import deep_merge %}
{% set rawmap = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('php')) %}

{% if 'fpm' in rawmap.pkgs and 'fpm' in rawmap.config%}
    {% set cfg = rawmap.config %}

    {% set pools = [] %}
    {% set fpm_pools_config = salt['pillar.get']('php:config:fpm:ini:pools') %}
fpm_config:
    {% if fpm_pools_config is mapping %}
        {% set tmp_pools_list = fpm_pools_config.keys() %}
    {% elif fpm_pools_config is iterable %}
        {% set tmp_pools_list = [] %}
        {% if fpm_pools_config is string or fpm_pools_config is number %}
            {% do tmp_pools_list.append(fpm_pools_config) %}
        {% else %}
            {% for item in fpm_pools_config %}
                {% if item is string or item is number %}
                    {% do tmp_pools_list.append(item) %}
                {% elif item is mapping %}
                    {% do tmp_pools_list.append(item.items()[0][0]) %}
                {% endif %}
            {% endfor %}
        {% endif %}
    {% else %}
        {% set tmp_pools_list = [] %}
    {% endif %}
    {% for pool_id in tmp_pools_list %}
        {% set pool_pillar = salt['pillar.get']('php:config:fpm:ini:pools:' ~ pool_id, {}, merge=True) %}
        {% do deep_merge(pool_pillar, cfg.fpm.ini.defaults_pool) %}
        {% do pools.append({pool_id: pool_pillar}) %}
    {% endfor %}
    file.managed:
        - name: {{cfg.fpm.config_file}}
        - source: salt://php/files/php-fpm.conf
        - template: jinja
        - context:
            config: {{salt['pillar.get']('php:config:fpm:ini:global', cfg.fpm.ini.defaults, merge=True)}}
            pools_config: {{pools}}

fpm_php_config:
    file.managed:
        - name: {{cfg.fpm.php_file}}
        - source: salt://php/files/php.ini
        - template: jinja
        - context:
            config: {{salt['pillar.get']('php:config:php:ini', cfg.php.ini.defaults, merge=True)}}
{% endif %}
