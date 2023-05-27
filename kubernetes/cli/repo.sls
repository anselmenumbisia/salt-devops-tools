# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kubectl with context %}

{% set repoState = 'absent' %}
{% if kubectl.enabled %}
  {% set repoState = 'managed' %}
{% endif %}

{%- if grains['os_family']|lower in ('debian',) %}
  {%- if grains['os']|lower in ('ubuntu',) %}
    {% set url = 'https://apt.kubernetes.io/ ' ~ 'kubernetes' ~ '-' ~ 'xenial' ~ ' main' %}
  {% else %}
    {% set url = 'https://apt.kubernetes.io/ ' ~ 'kubernetes' ~ '-' ~ grains["oscodename"] ~ ' main' %}
  {% endif %}

kubernetes-repo:
  cmd.run:
    - name: |
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  pkgrepo.{{ repoState }}:
    - require:
      - cmd: kubernetes-repo
    - humanname: {{ grains["os"] }} {{ grains["oscodename"] | capitalize }} Kubernetes Package Repository
    - name: deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] {{ url }}
    - file: /etc/apt/sources.list.d/kubernetes.list
    - aptkey: False
    - clean_file: True
    {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
    {%- else %}
    - refresh_db: True
    {%- endif %}

{%- elif grains['os_family']|lower in ('redhat',) %}
{% set url = 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64' %}

kubernetes-repo:
  pkgrepo.{{ repoState }}:
    - name: kubernetes
    - humanname: {{ grains["os"] }} {{ grains["oscodename"] | capitalize }} Kubernetes Package Repository
    - base_url: {{ url }}
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg
    - file: kubernetes.repo
    {%- if grains['saltversioninfo'] >= [2018, 3, 0] %}
    - refresh: True
    {%- else %}
    - refresh_db: True
    {%- endif %}

{% endif %}