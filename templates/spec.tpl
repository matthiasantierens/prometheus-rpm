#############################
# AUTOGENERATED FROM TEMPLATE
#############################
{%- block definitions %}
%global debug_package %{nil}
%global user {{user}}
%global group {{group}}
{% endblock definitions %}

{%- block amble %}
Name:    {{name}}
Version: {{version}}
Release: {{release}}%{?dist}
Summary: {{summary}}
License: {{license}}
URL:     {{URL}}
{% endblock amble %}

{%- block sources %}
{%- for source in sources %}
Source{{loop.index - 1}}: {{source}}
{%- endfor %}
{%- if additional_sources is defined %}
{%-   for additional_source in additional_sources %}
{%-     if not additional_source.from_tarball|d(false) %}
Source{{ loop.index - 1 + sources | length }}: {{ additional_source.path }}
{%-     endif %}
{%-   endfor %}
{%- endif %}
{% endblock sources %}

{%- block requires %}
%{?systemd_requires}
Requires(pre): shadow-utils
%if 0%{?el6} || 0%{?el5}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
%endif
{% endblock requires %}

%description
{%- block description %}
{{description}}
{% endblock description %}

%prep
{%- block prep %}
{%- if tarball_has_subdirectory %}
%setup -q -n {{package}}
{%- else %}
%setup -q -D -c {{package}}
{%- endif %}
{%- if fix_name is defined %}
mv -v {{fix_name}} %{name}
{%- endif %}
{%- for prep_cmd in prep_cmds %}
{{ prep_cmd }}
{%- endfor %}
{% endblock prep %}

%build
{%- block build %}
{%- for build_cmd in build_cmds %}
{{ build_cmd }}
{%- endfor %}
{% endblock build %}

%install
{%- block install %}
{%- if user == "prometheus" and group == "prometheus" %}
mkdir -vp %{buildroot}%{_sharedstatedir}/prometheus
{%- else %}
mkdir -vp %{buildroot}%{_sharedstatedir}/%{name}
{%- endif %}
install -D -m 755 %{name} %{buildroot}%{_bindir}/%{name}
install -D -m 644 %{SOURCE2} %{buildroot}%{_sysconfdir}/default/%{name}
%if 0%{?el5}
install -D -m 755 %{SOURCE3} %{buildroot}%{_initrddir}/%{name}
%else
    %if 0%{?el6}
    install -D -m 755 %{SOURCE3} %{buildroot}%{_initddir}/%{name}
    %else
    install -D -m 644 %{SOURCE1} %{buildroot}%{_unitdir}/%{name}.service
    %endif
%endif
{%- if additional_sources is defined %}
{%- for additional_source in additional_sources %}
install -D -m {{ additional_source.mode|d('644') }} {{ additional_source.path if additional_source.from_tarball|d(false) else '%{SOURCE' ~ (loop.index - 1 + sources | length) ~ '}' }} %{buildroot}{{ additional_source.dest }}
{%- endfor %}
{%- endif %}
{%- for install_cmd in install_cmds %}
{{ install_cmd }}
{%- endfor %}
{% endblock install %}

%pre
{%- block pre %}
{%- if group != "root" %}
getent group {{ group }} >/dev/null || groupadd -r {{ group }}
{%- endif %}
{%- if user != "root" %}
{%-   if user == "prometheus" %}
getent passwd {{ user }} >/dev/null || \
  useradd -r -g {{ group }} -d %{_sharedstatedir}/prometheus -s /sbin/nologin \
          -c "Prometheus services" {{ user }}
{%-   else %}
getent passwd {{ user }} >/dev/null || \
  useradd -r -g {{ group }} -d %{_sharedstatedir}/%{name} -s /sbin/nologin \
          -c "{{ name }} service" {{ user }}
{%-   endif %}
{%- endif %}
exit 0
{%- for pre_cmd in pre_cmds %}
{{ pre_cmd }}
{%- endfor %}
{% endblock pre %}

%post
{%- block post %}
%if 0%{?el6} || 0%{?el5}
chkconfig --add %{name}
%else
%systemd_post %{name}.service
%endif
{%- for post_cmd in post_cmds %}
{{ post_cmd }}
{%- endfor %}
{% endblock post %}

%preun
{%- block preun %}
%if 0%{?el6} || 0%{?el5}
if [ $1 -eq 0 ] ; then
    service %{name} stop > /dev/null 2>&1
    chkconfig --del %{name}
fi
%else
%systemd_preun %{name}.service
%endif
{%- for preun_cmd in preun_cmds %}
{{ preun_cmd }}
{%- endfor %}
{% endblock preun %}

%postun
{%- block postun %}
%if 0%{?el6} || 0%{?el5}
if [ "$1" -ge "1" ] ; then
    service %{name} condrestart >/dev/null 2>&1 || :
fi
%else
%systemd_postun %{name}.service
%endif
{%- for postun_cmd in postun_cmds %}
{{ postun_cmd }}
{%- endfor %}
{% endblock postun %}

%files
{%- block files %}
%defattr(-,root,root,-)
%{_bindir}/%{name}
%config(noreplace) %{_sysconfdir}/default/%{name}
{%- if user == "prometheus" and group == "prometheus" %}
%dir %attr(755, %{user}, %{group}) %{_sharedstatedir}/prometheus
{%- else %}
%dir %attr(755, %{user}, %{group}) %{_sharedstatedir}/%{name}
{%- endif %}
%if 0%{?el5}
%{_initrdddir}/%{name}
%else
    %if 0%{?el6}
    %{_initddir}/%{name}
    %else
    %{_unitdir}/%{name}.service
    %endif
%endif
{%- if additional_sources is defined %}
{%-   for additional_source in additional_sources %}
{% if additional_source.config|d(true) %}%config(noreplace) {% endif %}{% if additional_source.mode is defined or additional_source.user is defined or additional_source.group is defined %}%attr({{ additional_source.mode|d('-') }}, {{ additional_source.user|d('-') }}, {{ additional_source.group|d('-') }}){% endif %}{{ additional_source.dest }}
{%-   endfor %}
{%- endif %}
{% endblock files %}
