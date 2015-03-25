{% from "php/default.yml" import rawmap with context %}
{% set rawmap = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('php')) %}

php_package:
    pkg.installed:
        - name: {{rawmap.lookup.php_package}}

{% if rawmap.pkgs is iterable %}
    {% for pkg in rawmap.pkgs %}
        {% set pkg_name = pkg ~ '_package' %}
        {% if pkg_name in rawmap.lookup %}
{{pkg ~ '_install_status'}}:
    pkg.installed:
        - name: {{rawmap.lookup[pkg_name]}}
        - require:
            - pkg: php_package
        {% endif %}
    {% endfor %}
{% endif %}
