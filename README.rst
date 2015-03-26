===
PHP
===

Setup PHP and various PHP extensions (like PHP-FPM).

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``php``
-------

Runs the state to install PHP and extensions.

``php.install``
---------------

Install PHP and extensions (included PHP-FPM if specified).

``php.service``
---------------

Manage the startup and running state of the PHP-FPM service.

``php.config``
---------------

Manage PHP and PHP-FPM main configuration file.
