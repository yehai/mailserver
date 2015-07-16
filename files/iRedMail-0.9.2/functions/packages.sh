#!/usr/bin/env bash

# Author: Zhang Huangbin <zhb _at_ iredmail.org>

#---------------------------------------------------------------------
# This file is part of iRedMail, which is an open source mail server
# solution for Red Hat(R) Enterprise Linux, CentOS, Debian and Ubuntu.
#
# iRedMail is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# iRedMail is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with iRedMail.  If not, see <http://www.gnu.org/licenses/>.
#---------------------------------------------------------------------

install_all()
{
    ALL_PKGS=''
    ENABLED_SERVICES=''
    DISABLED_SERVICES=''

    # OpenBSD only
    PKG_SCRIPTS=''
    OB_PKG_POSTFIX_VER='-2.11.4'
    OB_PKG_OPENLDAP_VER='-2.4.40p1'
    OB_PKG_PHP_VER='-5.6.5'
    OB_PKG_NGINX_VER='-1.7.10'
    OB_PKG_MEMCACHED_VER='-1.4.21p1'

    # Enable syslog or rsyslog.
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ENABLED_SERVICES="rsyslog ${ENABLED_SERVICES}"
        DISABLED_SERVICES="${DISABLED_SERVICES} exim"
    elif [ X"${DISTRO}" == X'DEBIAN' ]; then
        # Debian.
        ENABLED_SERVICES="rsyslog ${ENABLED_SERVICES}"
    elif [ X"${DISTRO}" == X'UBUNTU' ]; then
        # Ubuntu >= 9.10.
        ENABLED_SERVICES="rsyslog ${ENABLED_SERVICES}"
    fi

    # Postfix.
    ENABLED_SERVICES="${ENABLED_SERVICES} ${POSTFIX_RC_SCRIPT_NAME}"
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ALL_PKGS="${ALL_PKGS} postfix"
    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} postfix postfix-pcre"
    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} postfix${OB_PKG_POSTFIX_VER}-ldap"
        [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} postfix${OB_PKG_POSTFIX_VER}-mysql"
        [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} postfix${OB_PKG_POSTFIX_VER}-pgsql"
    fi

    # Backend: OpenLDAP, MySQL, PGSQL and extra packages.
    if [ X"${BACKEND}" == X"OPENLDAP" ]; then
        # OpenLDAP server & client.
        ENABLED_SERVICES="${ENABLED_SERVICES} ${OPENLDAP_RC_SCRIPT_NAME} ${MYSQL_RC_SCRIPT_NAME}"

        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} openldap openldap-clients openldap-servers"
            if [ X"${DISTRO_VERSION}" == X'6' ]; then
                ALL_PKGS="${ALL_PKGS} mysql-server"
            else
                ALL_PKGS="${ALL_PKGS} mariadb-server mod_ldap"
            fi

        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} postfix-ldap slapd ldap-utils libnet-ldap-perl mysql-server mysql-client"

        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            if [ X"${BACKEND_ORIG}" == X'OPENLDAP' ]; then
                ALL_PKGS="${ALL_PKGS} openldap-server${OB_PKG_OPENLDAP_VER}"
                PKG_SCRIPTS="${PKG_SCRIPTS} ${OPENLDAP_RC_SCRIPT_NAME}"
            fi

            ALL_PKGS="${ALL_PKGS} openldap-client${OB_PKG_OPENLDAP_VER} mariadb-server mariadb-client p5-ldap p5-DBD-mysql"
            PKG_SCRIPTS="${PKG_SCRIPTS} ${MYSQL_RC_SCRIPT_NAME}"

        fi
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        # MySQL server & client.
        ENABLED_SERVICES="${ENABLED_SERVICES} ${MYSQL_RC_SCRIPT_NAME}"
        if [ X"${DISTRO}" == X'RHEL' ]; then
            if [ X"${USE_LOCAL_MYSQL_SERVER}" == X'YES' ]; then
                [ X"${BACKEND_ORIG}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} mysql-server"
                [ X"${BACKEND_ORIG}" == X'MARIADB' ] && ALL_PKGS="${ALL_PKGS} mariadb-server"
            fi

            # Client
            [ X"${BACKEND_ORIG}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} mysql"
            [ X"${BACKEND_ORIG}" == X'MARIADB' ] && ALL_PKGS="${ALL_PKGS} mariadb"

            # Perl module
            ALL_PKGS="${ALL_PKGS} perl-DBD-MySQL"

            if [ X"${USE_AWSTATS}" == X'YES' -o X"${USE_CLUEBRINGER}" == X'YES' ]; then
                if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
                    if [ X"${DISTRO_VERSION}" == X'6' ]; then
                        ALL_PKGS="${ALL_PKGS} mod_auth_mysql"
                    else
                        ALL_PKGS="${ALL_PKGS} apr-util-mysql"
                    fi
                fi
            fi

        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            # MySQL server and client.
            if [ X"${USE_LOCAL_MYSQL_SERVER}" == X'YES' ]; then
                if [ X"${BACKEND_ORIG}" == X'MARIADB' ]; then
                    ALL_PKGS="${ALL_PKGS} mariadb-server mariadb-client"
                else
                    ALL_PKGS="${ALL_PKGS} mysql-server mysql-client"
                fi
            fi

            ALL_PKGS="${ALL_PKGS} postfix-mysql"
            if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
                ALL_PKGS="${ALL_PKGS} libaprutil1-dbd-mysql"
            fi

        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            if [ X"${USE_LOCAL_MYSQL_SERVER}" == X'YES' ]; then
                ALL_PKGS="${ALL_PKGS} mariadb-server"
                PKG_SCRIPTS="${PKG_SCRIPTS} ${MYSQL_RC_SCRIPT_NAME}"
            fi
            ALL_PKGS="${ALL_PKGS} mariadb-client p5-DBD-mysql"
        fi
    elif [ X"${BACKEND}" == X"PGSQL" ]; then
        ENABLED_SERVICES="${ENABLED_SERVICES} ${PGSQL_RC_SCRIPT_NAME}"

        # PGSQL server & client.
        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} postgresql-server postgresql-contrib perl-DBD-Pg"

            if [ X"${USE_AWSTATS}" == X'YES' -o X"${USE_CLUEBRINGER}" == X'YES' ]; then
                if [ X"${DISTRO_VERSION}" == X'6' ]; then
                    ALL_PKGS="${ALL_PKGS} mod_auth_pgsql"
                else
                    ALL_PKGS="${ALL_PKGS} apr-util-pgsql"
                fi
            fi

        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            # postgresql-contrib provides extension 'dblink' used in Roundcube password plugin.
            ALL_PKGS="${ALL_PKGS} postgresql postgresql-client postgresql-contrib postfix-pgsql libdbd-pg-perl"

            if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
                ALL_PKGS="${ALL_PKGS} libaprutil1-dbd-pgsql"
            fi

        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            ALL_PKGS="${ALL_PKGS} postgresql-client postgresql-server postgresql-contrib p5-DBD-Pg"
            PKG_SCRIPTS="${PKG_SCRIPTS} ${PGSQL_RC_SCRIPT_NAME}"
        fi
    fi

    # PHP
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ALL_PKGS="${ALL_PKGS} php-common php-gd php-xml php-mysql php-ldap php-pgsql php-imap php-mbstring php-pecl-apc php-intl php-mcrypt"

        [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ] && ALL_PKGS="${ALL_PKGS} php"

    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} php5-imap php5-json php5-gd php5-mcrypt php5-curl mcrypt php-apc php5-intl"
        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} php5-ldap php5-mysql"
        [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} php5-mysql"
        [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} php5-pgsql"
    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        ALL_PKGS="${ALL_PKGS} php${OB_PKG_PHP_VER} php-bz2${OB_PKG_PHP_VER} php-imap${OB_PKG_PHP_VER} php-mcrypt${OB_PKG_PHP_VER} php-gd${OB_PKG_PHP_VER} php-intl${OB_PKG_PHP_VER}"

        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} php-ldap${OB_PKG_PHP_VER} php-pdo_mysql${OB_PKG_PHP_VER}"
        [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} php-pdo_mysql${OB_PKG_PHP_VER}"
        [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} php-pdo_pgsql${OB_PKG_PHP_VER}"
    fi

    # Apache. Always install Apache.
    if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} httpd mod_ssl"
        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            # Will be installed as dependency of 'libapache2-mod-php5'
            ALL_PKGS="${ALL_PKGS} libapache2-mod-php5"
        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            # Apache is not available in base system
            :
        fi
    fi

    # Nginx
    if [ X"${WEB_SERVER_IS_NGINX}" == X'YES' ]; then
        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} nginx php-fpm"
        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} nginx-full php5-fpm"
        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            ALL_PKGS="${ALL_PKGS} nginx${OB_PKG_NGINX_VER} php-fpm${OB_PKG_PHP_VER}"
            PKG_SCRIPTS="${PKG_SCRIPTS} ${NGINX_RC_SCRIPT_NAME} ${UWSGI_RC_SCRIPT_NAME} ${PHP_FPM_RC_SCRIPT_NAME}"
        fi
    fi

    if [ X"${WEB_SERVER_IS_NGINX}" == X'YES' ]; then
        ENABLED_SERVICES="${ENABLED_SERVICES} ${NGINX_RC_SCRIPT_NAME} ${PHP_FPM_RC_SCRIPT_NAME} ${UWSGI_RC_SCRIPT_NAME}"
        DISABLED_SERVICES="${DISABLED_SERVICES} ${APACHE_RC_SCRIPT_NAME}"
    else
        ENABLED_SERVICES="${ENABLED_SERVICES} ${APACHE_RC_SCRIPT_NAME}"
        DISABLED_SERVICES="${DISABLED_SERVICES} ${NGINX_RC_SCRIPT_NAME} ${PHP_FPM_RC_SCRIPT_NAME} ${UWSGI_RC_SCRIPT_NAME}"
    fi

    # Cluebringer
    if [ X"${USE_CLUEBRINGER}" == X'YES' ]; then
        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} cluebringer"
            ENABLED_SERVICES="${ENABLED_SERVICES} ${CLUEBRINGER_RC_SCRIPT_NAME}"

        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} postfix-cluebringer postfix-cluebringer-webui"
            ENABLED_SERVICES="${ENABLED_SERVICES} ${CLUEBRINGER_RC_SCRIPT_NAME}"

            if [ X"${BACKEND}" == X"OPENLDAP" -o X"${BACKEND}" == X"MYSQL" ]; then
                if [ X"${BACKEND_ORIG}" != X'MARIADB' ]; then
                    ALL_PKGS="${ALL_PKGS} postfix-cluebringer-mysql"
                fi
            elif [ X"${BACKEND}" == X"PGSQL" ]; then
                ALL_PKGS="${ALL_PKGS} postfix-cluebringer-pgsql"
            fi
        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            # No port available.
            :
        fi
    fi

    # Dovecot.
    ENABLED_SERVICES="${ENABLED_SERVICES} ${DOVECOT_RC_SCRIPT_NAME}"
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ALL_PKGS="${ALL_PKGS} dovecot dovecot-pigeonhole"

        if [ X"${DISTRO_VERSION}" == X'6' ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-managesieve"
        else
            ALL_PKGS="${ALL_PKGS} dovecot-mysql dovecot-pgsql"
        fi

        # We use Dovecot SASL auth instead of saslauthd
        DISABLED_SERVICES="${DISABLED_SERVICES} saslauthd"

    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-managesieved dovecot-sieve"

        if [ X"${BACKEND}" == X"OPENLDAP" ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-ldap dovecot-mysql"
        elif [ X"${BACKEND}" == X"MYSQL" ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-mysql"
        elif [ X"${BACKEND}" == X"PGSQL" ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-pgsql"
        fi

    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        ALL_PKGS="${ALL_PKGS} dovecot dovecot-pigeonhole"
        PKG_SCRIPTS="${PKG_SCRIPTS} ${DOVECOT_RC_SCRIPT_NAME}"

        if [ X"${BACKEND}" == X'OPENLDAP' ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-ldap dovecot-mysql"
        elif [ X"${BACKEND}" == X'MYSQL' ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-mysql"
        elif [ X"${BACKEND}" == X'PGSQL' ]; then
            ALL_PKGS="${ALL_PKGS} dovecot-postgresql"
        fi

        DISABLED_SERVICES="${DISABLED_SERVICES} saslauthd"
    fi

    # Amavisd-new & ClamAV & Altermime.
    ENABLED_SERVICES="${ENABLED_SERVICES} ${CLAMAV_CLAMD_RC_SCRIPT_NAME} ${AMAVISD_RC_SCRIPT_NAME}"
    if [ X"${DISTRO}" == X'RHEL' ]; then
        if [ X"${DISTRO_VERSION}" == X'6' ]; then
            ALL_PKGS="${ALL_PKGS} amavisd-new clamd clamav-db spamassassin altermime perl-LDAP perl-Mail-SPF unrar"
        else
            ALL_PKGS="${ALL_PKGS} clamav clamav-update clamav-server clamav-server-systemd amavisd-new spamassassin altermime perl-LDAP perl-Mail-SPF unrar"
            ENABLED_SERVICES="${ENABLED_SERVICES} clamd@amavisd"
        fi

        DISABLED_SERVICES="${DISABLED_SERVICES} spamassassin"

    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} amavisd-new libcrypt-openssl-rsa-perl libmail-dkim-perl clamav-freshclam clamav-daemon spamassassin altermime arj zoo nomarch cpio lzop cabextract p7zip rpm ripole libmail-spf-perl unrar-free"

        ENABLED_SERVICES="${ENABLED_SERVICES} ${CLAMAV_FRESHCLAMD_RC_SCRIPT_NAME}"
        DISABLED_SERVICES="${DISABLED_SERVICES} spamassassin"

    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        ALL_PKGS="${ALL_PKGS} rpm2cpio amavisd-new p5-Mail-SPF p5-Mail-SpamAssassin clamav unrar"
        PKG_SCRIPTS="${PKG_SCRIPTS} ${CLAMAV_CLAMD_RC_SCRIPT_NAME} ${CLAMAV_FRESHCLAMD_RC_SCRIPT_NAME} ${AMAVISD_RC_SCRIPT_NAME}"
    fi

    # Roundcube
    if [ X"${USE_RCM}" == X"YES" ]; then
        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} php-pear-Net-IDNA2"
            [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} php-pear-Net-LDAP2"
        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} php-pear php5-intl"
            [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} php-net-ldap2"

        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            ALL_PKGS="${ALL_PKGS} php-pspell${OB_PKG_PHP_VER} php-intl${OB_PKG_PHP_VER}"
        fi
    fi

    # SOGo
    if [ X"${USE_SOGO}" == X"YES" ]; then
        ENABLED_SERVICES="${ENABLED_SERVICES} ${SOGO_RC_SCRIPT_NAME} ${MEMCACHED_RC_SCRIPT_NAME}"

        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} sogo sogo-activesync libwbxml sogo-ealarms-notify sogo-tool"

            [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} sope49-gdl1-mysql sope49-ldap"
            [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} sope49-gdl1-mysql"
            [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} sope49-gdl1-postgresql"

            # Copy yum repo file
            ECHO_INFO "Add yum repo for SOGo: ${YUM_REPOS_DIR}/sogo.repo."
            cat > ${YUM_REPOS_DIR}/sogo.repo <<EOF
[SOGo]
name=Inverse SOGo Repository
baseurl=http://inverse.ca/downloads/SOGo/RHEL${DISTRO_VERSION}/\$basearch
enabled=1
gpgcheck=0
EOF

        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} sogo sogo-activesync"

            [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} sope4.9-gdl1-mysql"
            [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} sope4.9-gdl1-mysql"
            [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} sope4.9-gdl1-postgresql"

            ECHO_INFO "Add official apt repo for SOGo in /etc/apt/sources.list"
            if ! grep "http://inverse.ca ${DISTRO_CODENAME}" /etc/apt/sources.list &>/dev/null; then
                if [ X"${DISTRO}" == X'DEBIAN' ]; then
                    echo "deb http://inverse.ca/debian ${DISTRO_CODENAME} ${DISTRO_CODENAME}" >> /etc/apt/sources.list
                elif [ X"${DISTRO}" == X'UBUNTU' ]; then
                    echo "deb http://inverse.ca/ubuntu ${DISTRO_CODENAME} ${DISTRO_CODENAME}" >> /etc/apt/sources.list
                fi
            fi

            ECHO_INFO "Add SOGo GPG public key into apt keyring."
            apt-key adv --keyserver keys.gnupg.net --recv-key 0x810273C4

            ECHO_INFO "Resynchronizing the package index files (apt-get update) ..."
            apt-get update

        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            ALL_PKGS="${ALL_PKGS} sogo memcached${OB_PKG_MEMCACHED_VER}"

            [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} sope-mysql"
            [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} sope-mysql"
            [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} sope-postgres"

            PKG_SCRIPTS="${PKG_SCRIPTS} ${MEMCACHED_RC_SCRIPT_NAME} ${SOGO_RC_SCRIPT_NAME}"
        fi
    fi

    # iRedAPD.
    # Don't append 'iredapd' to ${ENABLED_SERVICES} since we don't have
    # RC script ready in early stage.
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ALL_PKGS="${ALL_PKGS} python-sqlalchemy python-setuptools"
        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} python-ldap MySQL-python"
        [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} MySQL-python"
        [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} python-psycopg2"

    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} python-sqlalchemy"
        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} python-ldap python-mysqldb"
        [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} python-mysqldb"
        [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} python-psycopg2"

    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        ALL_PKGS="${ALL_PKGS} py-sqlalchemy"
        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PKGS="${ALL_PKGS} py-ldap py-mysql"
        [ X"${BACKEND}" == X'MYSQL' ] && ALL_PKGS="${ALL_PKGS} py-mysql"
        [ X"${BACKEND}" == X'PGSQL' ] && ALL_PKGS="${ALL_PKGS} py-psycopg2"
        PKG_SCRIPTS="${PKG_SCRIPTS} iredapd"
    fi

    # OpenBSD: List postfix as last startup script.
    export PKG_SCRIPTS="${PKG_SCRIPTS} ${POSTFIX_RC_SCRIPT_NAME}"

    # iRedAdmin.
    # Force install all dependence to help customers install iRedAdmin-Pro.
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ALL_PKGS="${ALL_PKGS} python-jinja2 python-webpy python-netifaces python-beautifulsoup4 python-lxml"
        [ X"${DISTRO_VERSION}" == X'7' ] && ALL_PKGS="${ALL_PKGS} py-bcrypt"

        [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ] && ALL_PKGS="${ALL_PKGS} mod_wsgi"
        [ X"${WEB_SERVER_IS_NGINX}" == X'YES' ] && ALL_PKGS="${ALL_PKGS} uwsgi uwsgi-plugin-python"

    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} python-jinja2 python-netifaces python-webpy python-beautifulsoup python-lxml"

        [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ] && ALL_PKGS="${ALL_PKGS} libapache2-mod-wsgi"
        [ X"${WEB_SERVER_IS_NGINX}" == X'YES' ] && ALL_PKGS="${ALL_PKGS} uwsgi uwsgi-plugin-python"

        # Debian
        [ X"${DISTRO_CODENAME}" == X'jessie' ] && ALL_PKGS="${ALL_PKGS} python-bcrypt"
        # Ubuntu
        [ X"${DISTRO}" == X'UBUNTU' ] && ALL_PKGS="${ALL_PKGS} python-bcrypt"

    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        ALL_PKGS="${ALL_PKGS} py-jinja2 py-webpy py-flup py-bcrypt py-beautifulsoup4 py-lxml"
        # /etc/rc.d/uwsgi
        export PKG_SCRIPTS="${PKG_SCRIPTS} ${UWSGI_RC_SCRIPT_NAME}"
    fi

    # Awstats.
    if [ X"${USE_AWSTATS}" == X'YES' -a X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
        if [ X"${DISTRO}" == X'RHEL' ]; then
            ALL_PKGS="${ALL_PKGS} awstats"
        elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} awstats"
        fi
    fi

    # Fail2ban
    if [ X"${USE_FAIL2BAN}" == X"YES" ]; then
        if [ X"${DISTRO}" == X'OPENBSD' ]; then
            # No port available.
            :
        else
            ALL_PKGS="${ALL_PKGS} fail2ban"
            ENABLED_SERVICES="${ENABLED_SERVICES} ${FAIL2BAN_RC_SCRIPT_NAME}"

            if [ X"${DISTRO}" == X'RHEL' ]; then
                DISABLED_SERVICES="${DISABLED_SERVICES} shorewall gamin gamin-python"
            fi
        fi
    fi


    # Misc packages & services.
    if [ X"${DISTRO}" == X'RHEL' ]; then
        ALL_PKGS="${ALL_PKGS} unzip bzip2 acl patch tmpwatch crontabs dos2unix logwatch"
        ENABLED_SERVICES="${ENABLED_SERVICES} crond"
    elif [ X"${DISTRO}" == X'DEBIAN' -o X"${DISTRO}" == X'UBUNTU' ]; then
        ALL_PKGS="${ALL_PKGS} bzip2 acl patch cron tofrodos logwatch"
        ENABLED_SERVICES="${ENABLED_SERVICES} cron"
    elif [ X"${DISTRO}" == X'OPENBSD' ]; then
        ALL_PKGS="${ALL_PKGS} bzip2"
    fi

    # Disable Ubuntu firewall rules, we have iptables init script and rule file.
    [ X"${DISTRO}" == X'UBUNTU' ] && export DISABLED_SERVICES="${DISABLED_SERVICES} ufw"

    export ALL_PKGS ENABLED_SERVICES PKG_SCRIPTS

    # Install all packages.
    install_all_pkgs()
    {
        eval ${install_pkg} ${ALL_PKGS} | tee ${INSTALL_LOG}

        if [ -f ${RUNTIME_DIR}/.pkg_install_failed ]; then
            ECHO_ERROR "Installation failed, please check the terminal output."
            ECHO_ERROR "If you're not sure what the problem is, try to get help in iRedMail"
            ECHO_ERROR "forum: http://www.iredmail.org/forum/"
            exit 255
        else
            echo 'export status_install_all_pkgs="DONE"' >> ${STATUS_FILE}
        fi
    }

    # Enable/Disable services.
    enable_all_services()
    {
        if [ X"${DISTRO}" == X'RHEL' ]; then
            if [ -f /usr/lib/systemd/system/clamd\@.service ]; then
                if ! grep '\[Install\]' /usr/lib/systemd/system/clamd\@.service &>/dev/null; then
                    echo '[Install]' >> /usr/lib/systemd/system/clamd\@.service
                    echo 'WantedBy=multi-user.target' >> /usr/lib/systemd/system/clamd\@.service
                fi
            fi
        fi

        # Enable/Disable services.
        if [ X"${DISTRO}" == X'OPENBSD' ]; then
            service_control enable ${PKG_SCRIPTS} >> ${INSTALL_LOG} 2>&1
        else
            service_control enable ${ENABLED_SERVICES} >> ${INSTALL_LOG} 2>&1
            service_control disable ${DISABLED_SERVICES} >> ${INSTALL_LOG} 2>&1
        fi

        echo 'export status_enable_all_services="DONE"' >> ${STATUS_FILE}
    }

    after_package_installation()
    {
        if [ X"${DISTRO}" == X'RHEL' -o X"${DISTRO_VERSION}" == X'6' ]; then
            # Copy DNS related libs to chrooted Postfix directory, so that Postfix
            # can correctly resolve IP address under chroot.
            for i in '/lib' '/lib64'; do
                ls $i/*nss* &>/dev/null
                ret1=$?
                ls $i/*reso* &>/dev/null
                ret2=$?

                if [ X"${ret1}" == X'0' -o X"${ret2}" == X'0' ]; then
                    mkdir -p ${POSTFIX_CHROOT_DIR}${i}
                    cp ${i}/*nss* ${i}/*reso* ${POSTFIX_CHROOT_DIR}${i}/ &>/dev/null
                fi
            done
        elif [ X"${DISTRO}" == X'OPENBSD' ]; then
            # Create symbol links for Python.
            ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
            ln -sf /usr/local/bin/python2.7-2to3 /usr/local/bin/2to3
            ln -sf /usr/local/bin/python2.7-config /usr/local/bin/python-config
            ln -sf /usr/local/bin/pydoc2.7  /usr/local/bin/pydoc

            ECHO_INFO "Installing uWSGI from source tarball, depends on your hardware, it may take 1 to 5 minutes, please be patient."
            cd ${PKG_MISC_DIR}
            tar zxf uwsgi-*.tar.gz
            cd uwsgi-*/
            patch -p1 < ${PATCH_DIR}/uwsgi/core_logging_c.patch >> ${INSTALL_LOG} 2>&1
            python setup.py install > ${RUNTIME_DIR}/uwsgi_install.log 2>&1
        fi

        echo 'export status_after_package_installation="DONE"' >> ${STATUS_FILE}
    }

    check_status_before_run install_all_pkgs
    check_status_before_run enable_all_services
    check_status_before_run after_package_installation

    echo 'export status_install_all="DONE"' >> ${STATUS_FILE}
}
