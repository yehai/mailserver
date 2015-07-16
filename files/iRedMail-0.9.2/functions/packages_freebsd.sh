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
    # Port name under /usr/ports/. e.g. mail/dovecot2.
    ALL_PORTS=''

    # Extension used for backup file during in-place editing.
    SED_EXTENSION="iredmail"
    CMD_SED="sed -i ${SED_EXTENSION}"

    # Make it don't popup dialog while building ports.
    export PACKAGE_BUILDING='yes'
    export BATCH='yes'

    export PREFERRED_OPENLDAP_VER='24'
    export PREFERRED_MARIADB_VER='55'
    export PREFERRED_PGSQL_VER='94'
    export PREFERRED_BDB_VER='5'
    export PREFERRED_APACHE_VER='24'
    export PREFERRED_PHP_VER='55'

    export PREFERRED_MYSQL_VER='56'
    if [ X"${BACKEND_ORIG}" == X'MARIADB' ]; then
        export PREFERRED_MYSQL_VER='55m'
    fi

    freebsd_add_make_conf 'OPTIONS_SET' 'SASL'
    freebsd_add_make_conf 'OPTIONS_UNSET' 'X11'
    freebsd_add_make_conf 'WANT_OPENLDAP_VER' "${PREFERRED_OPENLDAP_VER}"
    freebsd_add_make_conf 'WANT_MYSQL_VER' "${PREFERRED_MYSQL_VER}"
    freebsd_add_make_conf 'WANT_MARIADB_VER' "${PREFERRED_MARIADB_VER}"
    freebsd_add_make_conf 'WANT_PGSQL_VER' "${PREFERRED_PGSQL_VER}"
    freebsd_add_make_conf 'APACHE_PORT' "www/apache${PREFERRED_APACHE_VER}"
    freebsd_add_make_conf 'WANT_BDB_VER' "${PREFERRED_BDB_VER}"
    freebsd_add_make_conf 'DEFAULT_VERSIONS' 'python=2.7 python2=2.7 apache=2.4 pgsql=9.3'

    for p in \
        archivers_p5-Archive-Tar \
        archivers_p7zip \
        archivers_rar \
        converters_libiconv \
        databases_postgresql${PREFERRED_PGSQL_VER}-client \
        databases_postgresql${PREFERRED_PGSQL_VER}-contrib \
        databases_postgresql${PREFERRED_PGSQL_VER}-server \
        databases_py-MySQLdb \
        databases_py-sqlalchemy \
        devel_cmake \
        devel_apr1 \
        devel_m4 \
        devel_py-Jinja2 \
        dns_p5-Net-DNS \
        ftp_curl \
        japanese_p5-Mail-SpamAssassin \
        lang_perl5.18 \
        lang_perl5.20 \
        lang_php${PREFERRED_PHP_VER} \
        lang_php${PREFERRED_PHP_VER}-extensions \
        www_mod_php${PREFERRED_PHP_VER} \
        graphics_php${PREFERRED_PHP_VER}-gd \
        www_pecl-APC \
        lang_python27 \
        mail_dovecot2 \
        mail_policyd2 \
        mail_postfix \
        mail_roundcube \
        net_openldap${PREFERRED_OPENLDAP_VER}-client \
        net_openldap${PREFERRED_OPENLDAP_VER}-sasl-client \
        net_openldap${PREFERRED_OPENLDAP_VER}-server \
        net_openslp \
        net_py-ldap2 \
        security_amavisd-new \
        security_ca_root_nss \
        security_clamav \
        security_cyrus-sasl2 \
        security_gnupg \
        security_libssh2 \
        security_p5-Authen-SASL \
        security_p5-IO-Socket-SSL \
        www_apache${PREFERRED_APACHE_VER} \
        www_nginx; do
        mkdir -p /var/db/ports/${p} >> ${INSTALL_LOG} 2>&1
    done

    # cmake. DEPENDENCE
    cat > /var/db/ports/devel_cmake/options <<EOF
OPTIONS_FILE_UNSET+=DOCS
EOF

    # m4. DEPENDENCE.
    cat > /var/db/ports/devel_m4/options <<EOF
OPTIONS_FILE_SET+=LIBSIGSEGV
EOF

    # libiconv. DEPENDENCE.
    cat > /var/db/ports/converters_libiconv/options <<EOF
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=ENCODINGS
OPTIONS_FILE_SET+=PATCHES
EOF

    # Cyrus-SASL2. DEPENDENCE.
    cat > /var/db/ports/security_cyrus-sasl2/options <<EOF
OPTIONS_FILE_UNSET+=ALWAYSTRUE
OPTIONS_FILE_UNSET+=AUTHDAEMOND
OPTIONS_FILE_UNSET+=KEEP_DB_OPEN
OPTIONS_FILE_UNSET+=OBSOLETE_CRAM_ATTR
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE2
OPTIONS_FILE_UNSET+=SQLITE3
OPTIONS_FILE_SET+=CRAM
OPTIONS_FILE_SET+=DIGEST
OPTIONS_FILE_SET+=LOGIN
OPTIONS_FILE_UNSET+=NTLM
OPTIONS_FILE_UNSET+=OTP
OPTIONS_FILE_SET+=PLAIN
OPTIONS_FILE_SET+=SCRAM
EOF

    # Perl. REQUIRED.
    cat > /var/db/ports/lang_perl5.18/options <<EOF
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=GDBM
OPTIONS_FILE_SET+=MULTIPLICITY
OPTIONS_FILE_SET+=PERL_64BITINT
OPTIONS_FILE_SET+=PTHREAD
OPTIONS_FILE_SET+=SITECUSTOMIZE
OPTIONS_FILE_SET+=USE_PERL
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=PERL_MALLOC
EOF

    cp -f /var/db/ports/lang_perl5.18/options /var/db/ports/lang_perl5.20/options

    # OpenSLP. DEPENDENCE.
    cat > /var/db/ports/net_openslp/options <<EOF
OPTIONS_FILE_SET+=ASYNC_API
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=SLP_SECURITY
EOF

    # OpenLDAP. REQUIRED for LDAP backend.
    cat > /var/db/ports/net_openldap${PREFERRED_OPENLDAP_VER}-server/options <<EOF
OPTIONS_FILE_SET+=ACCESSLOG
OPTIONS_FILE_SET+=ACI
OPTIONS_FILE_SET+=AUDITLOG
OPTIONS_FILE_SET+=BDB
OPTIONS_FILE_UNSET+=COLLECT
OPTIONS_FILE_UNSET+=CONSTRAINT
OPTIONS_FILE_UNSET+=DDS
OPTIONS_FILE_UNSET+=DEREF
OPTIONS_FILE_UNSET+=DNSSRV
OPTIONS_FILE_UNSET+=DYNACL
OPTIONS_FILE_SET+=DYNAMIC_BACKENDS
OPTIONS_FILE_UNSET+=DYNGROUP
OPTIONS_FILE_UNSET+=DYNLIST
OPTIONS_FILE_UNSET+=FETCH
OPTIONS_FILE_UNSET+=MDB
OPTIONS_FILE_UNSET+=MEMBEROF
OPTIONS_FILE_UNSET+=ODBC
OPTIONS_FILE_SET+=PASSWD
OPTIONS_FILE_SET+=PERL
OPTIONS_FILE_SET+=PPOLICY
OPTIONS_FILE_UNSET+=PROXYCACHE
OPTIONS_FILE_UNSET+=REFINT
OPTIONS_FILE_UNSET+=RELAY
OPTIONS_FILE_UNSET+=RETCODE
OPTIONS_FILE_UNSET+=RLOOKUPS
OPTIONS_FILE_UNSET+=RWM
OPTIONS_FILE_SET+=SASL
OPTIONS_FILE_SET+=SEQMOD
OPTIONS_FILE_UNSET+=SHELL
OPTIONS_FILE_SET+=SLAPI
OPTIONS_FILE_UNSET+=SLP
OPTIONS_FILE_UNSET+=SMBPWD
OPTIONS_FILE_UNSET+=SOCK
OPTIONS_FILE_SET+=SSSVLV
OPTIONS_FILE_SET+=SYNCPROV
OPTIONS_FILE_SET+=TCP_WRAPPERS
OPTIONS_FILE_UNSET+=TRANSLUCENT
OPTIONS_FILE_UNSET+=UNIQUE
OPTIONS_FILE_SET+=VALSORT
EOF

    cat > /var/db/ports/net_openldap${PREFERRED_OPENLDAP_VER}-client/options <<EOF
OPTIONS_FILE_UNSET+=FETCH
EOF

    cat > /var/db/ports/net_openldap${PREFERRED_OPENLDAP_VER}-sasl-client/options <<EOF
OPTIONS_FILE_UNSET+=FETCH
EOF

    # No options for MySQL server.
    # PostgreSQL
    cat > /var/db/ports/databases_postgresql${PREFERRED_PGSQL_VER}-server/options <<EOF
OPTIONS_FILE_SET+=INTDATE
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_SET+=TZDATA
OPTIONS_FILE_SET+=XML
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_UNSET+=GSSAPI
OPTIONS_FILE_UNSET+=HEIMDAL_KRB5
OPTIONS_FILE_UNSET+=ICU
OPTIONS_FILE_UNSET+=KRB5
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=MIT_KRB5
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=PAM
EOF

    cat > /var/db/ports/databases_postgresql${PREFERRED_PGSQL_VER}-client/options <<EOF
OPTIONS_FILE_SET+=INTDATE
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_SET+=TZDATA
OPTIONS_FILE_SET+=XML
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_UNSET+=GSSAPI
OPTIONS_FILE_UNSET+=HEIMDAL_KRB5
OPTIONS_FILE_UNSET+=ICU
OPTIONS_FILE_UNSET+=KRB5
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=MIT_KRB5
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=PAM
EOF

    cat > /var/db/ports/databases_postgresql${PREFERRED_PGSQL_VER}-contrib/options <<EOF
OPTIONS_FILE_UNSET+=OSSP_UUID
EOF

    if [ X"${BACKEND}" == X"OPENLDAP" ]; then
        ALL_PORTS="${ALL_PORTS} net/openldap${PREFERRED_OPENLDAP_VER}-sasl-client net/openldap${PREFERRED_OPENLDAP_VER}-server databases/mysql${PREFERRED_MYSQL_VER}-server"
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        if [ X"${BACKEND_ORIG}" == X'MARIADB' ]; then
            ALL_PORTS="${ALL_PORTS} databases/mariadb${PREFERRED_MARIADB_VER}-server"
        else
            ALL_PORTS="${ALL_PORTS} databases/mysql${PREFERRED_MYSQL_VER}-server"
        fi
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ALL_PORTS="${ALL_PORTS} databases/postgresql${PREFERRED_PGSQL_VER}-server databases/postgresql${PREFERRED_PGSQL_VER}-contrib"
    fi

    # Dovecot v2.0.x. REQUIRED.
    cat > /var/db/ports/mail_dovecot2/options <<EOF
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_UNSET+=GSSAPI
OPTIONS_FILE_SET+=KQUEUE
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=LIBWRAP
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SOLR
OPTIONS_FILE_UNSET+=SQLITE
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=VPOPMAIL
EOF

    # Note: dovecot-sieve will install dovecot first.
    ALL_PORTS="${ALL_PORTS} mail/dovecot2 mail/dovecot2-pigeonhole"

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP#OPTIONS_FILE_SET+=LDAP#' /var/db/ports/mail_dovecot2/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/mail_dovecot2/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/mail_dovecot2/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/mail_dovecot2/options
    fi
    rm -f /var/db/ports/mail_dovecot2/options${SED_EXTENSION} &>/dev/null

    # ca_root_nss. DEPENDENCE.
    cat > /var/db/ports/security_ca_root_nss/options <<EOF
OPTIONS_FILE_SET+=ETCSYMLINK
EOF

    # libssh2. DEPENDENCE.
    cat > /var/db/ports/security_libssh2/options <<EOF
OPTIONS_FILE_UNSET+=GCRYPT
OPTIONS_FILE_UNSET+=TRACE
OPTIONS_FILE_SET+=ZLIB
EOF

    # Curl. DEPENDENCE.
    cat > /var/db/ports/ftp_curl/options <<EOF
OPTIONS_FILE_UNSET+=CARES
OPTIONS_FILE_UNSET+=CURL_DEBUG
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=KERBEROS4
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=LDAPS
OPTIONS_FILE_SET+=LIBIDN
OPTIONS_FILE_SET+=LIBSSH2
OPTIONS_FILE_UNSET+=NTLM
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_SET+=CA_BUNDLE
OPTIONS_FILE_SET+=PROXY
OPTIONS_FILE_UNSET+=RTMP
OPTIONS_FILE_UNSET+=TRACKMEMORY
EOF

    # GnuPG. DEPENDENCE.
    cat > /var/db/ports/security_gnupg/options <<EOF
OPTIONS_FILE_UNSET+=PINENTRY
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=SCDAEMON
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_UNSET+=GPGSM
OPTIONS_FILE_SET+=KDNS
OPTIONS_FILE_UNSET+=STD_SOCKET
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=NLS
EOF

    # p5-IO-Socket-SSL. DEPENDENCE.
    cat > /var/db/ports/security_p5-IO-Socket-SSL/options <<EOF
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_SET+=IDN
OPTIONS_FILE_SET+=IPV6
EOF

    cat > /var/db/ports/archivers_p5-Archive-Tar/options <<EOF
OPTIONS_FILE_SET+=TEXTDIFF
EOF

    cat > /var/db/ports/archivers_p7zip/options <<EOF
OPTIONS_FILE_SET+=DOCS
EOF

    cat > /var/db/ports/archivers_rar/options <<EOF
OPTIONS_FILE_SET+=DOCS
EOF

    cat > /var/db/ports/dns_p5-Net-DNS/options <<EOF
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=IDN
EOF

    # SpamAssassin. REQUIRED.
    cat > /var/db/ports/japanese_p5-Mail-SpamAssassin/options <<EOF
OPTIONS_FILE_SET+=AS_ROOT
OPTIONS_FILE_SET+=DCC
OPTIONS_FILE_SET+=DKIM
OPTIONS_FILE_SET+=GNUPG
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=RAZOR
OPTIONS_FILE_SET+=RELAY_COUNTRY
OPTIONS_FILE_SET+=SACOMPILE
OPTIONS_FILE_SET+=SPAMC
OPTIONS_FILE_SET+=SPF_QUERY
OPTIONS_FILE_SET+=SSL
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' -o X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/japanese_p5-Mail-SpamAssassin/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/japanese_p5-Mail-SpamAssassin/options
    fi
    rm -f /var/db/ports/japanese_p5-Mail-SpamAssassin/options${SED_EXTENSION} &>/dev/null

    ALL_PORTS="${ALL_PORTS} mail/spamassassin"

    cat > /var/db/ports/security_p5-Authen-SASL/options <<EOF
OPTIONS_FILE_SET+=KERBEROS
EOF

    # Amavisd-new. REQUIRED.
    cat > /var/db/ports/security_amavisd-new/options <<EOF
OPTIONS_FILE_SET+=ALTERMIME
OPTIONS_FILE_SET+=ARC
OPTIONS_FILE_SET+=ARJ
OPTIONS_FILE_SET+=BDB
OPTIONS_FILE_SET+=CAB
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=FILE
OPTIONS_FILE_SET+=FREEZE
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=LHA
OPTIONS_FILE_SET+=LZOP
OPTIONS_FILE_SET+=MSWORD
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_SET+=NOMARCH
OPTIONS_FILE_SET+=P0F
OPTIONS_FILE_SET+=P7ZIP
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=RAR
OPTIONS_FILE_SET+=RPM
OPTIONS_FILE_SET+=SASL
OPTIONS_FILE_SET+=SNMP
OPTIONS_FILE_SET+=SPAMASSASSIN
OPTIONS_FILE_SET+=SQLITE
OPTIONS_FILE_SET+=TNEF
OPTIONS_FILE_SET+=UNARJ
OPTIONS_FILE_SET+=UNRAR
OPTIONS_FILE_SET+=UNZOO
OPTIONS_FILE_SET+=ZOO
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP#OPTIONS_FILE_SET+=LDAP#' /var/db/ports/security_amavisd-new/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/security_amavisd-new/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/security_amavisd-new/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/security_amavisd-new/options
    fi

    # Enable RAR support on i386 only since it requires 32-bit libraries
    # installed under /usr/lib32.
    if [ X"${OS_ARCH}" == X'i386' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=RAR#OPTIONS_FILE_SET+=RAR#' /var/db/ports/security_amavisd-new/options
    fi
    rm -f /var/db/ports/security_amavisd-new/options${SED_EXTENSION} &>/dev/null

    ALL_PORTS="${ALL_PORTS} security/amavisd-new"

    # Postfix. REQUIRED.
    cat > /var/db/ports/mail_postfix/options <<EOF
OPTIONS_FILE_SET+=BDB
OPTIONS_FILE_SET+=CDB
OPTIONS_FILE_UNSET+=INST_BASE
OPTIONS_FILE_UNSET+=LDAP_SASL
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=NIS
OPTIONS_FILE_UNSET+=OPENLDAP
OPTIONS_FILE_SET+=PCRE
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=SASL2
OPTIONS_FILE_UNSET+=SPF
OPTIONS_FILE_UNSET+=SQLITE
OPTIONS_FILE_SET+=TEST
OPTIONS_FILE_SET+=TLS
OPTIONS_FILE_UNSET+=VDA
OPTIONS_FILE_UNSET+=DOVECOT
OPTIONS_FILE_SET+=DOVECOT2
OPTIONS_FILE_UNSET+=SASLKRB5
OPTIONS_FILE_UNSET+=SASLKMIT
EOF

    # Enable ldap/mysql/pgsql support in Postfix
    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=OPENLDAP#OPTIONS_FILE_SET+=OPENLDAP#' /var/db/ports/mail_postfix/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP_SASL#OPTIONS_FILE_SET+=LDAP_SASL#' /var/db/ports/mail_postfix/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/mail_postfix/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/mail_postfix/options
    fi
    rm -f /var/db/ports/mail_postfix/options${SED_EXTENSION} &>/dev/null

    ALL_PORTS="${ALL_PORTS} mail/postfix"

    # Apr. DEPENDENCE.
    cat > /var/db/ports/devel_apr1/options <<EOF
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=NSS
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=DEVRANDOM
OPTIONS_FILE_SET+=BDB
OPTIONS_FILE_SET+=GDBM
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=NDBM
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE
OPTIONS_FILE_UNSET+=FREETDS
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP#OPTIONS_FILE_SET+=LDAP#' /var/db/ports/devel_apr1/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/devel_apr1/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/devel_apr1/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/devel_apr1/options
    fi
    rm -f /var/db/ports/devel_apr1/options${SED_EXTENSION} &>/dev/null

    # Python v2.7
    cat > /var/db/ports/lang_python27/options <<EOF
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=PYMALLOC
OPTIONS_FILE_SET+=SEM
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=UCS2
OPTIONS_FILE_SET+=UCS4
EOF

    # Apache v2.2.x. REQUIRED.
    cat > /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options <<EOF
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=BDB
OPTIONS_FILE_SET+=AUTH_BASIC
OPTIONS_FILE_SET+=AUTH_DIGEST
OPTIONS_FILE_SET+=AUTHN_FILE
OPTIONS_FILE_SET+=AUTHN_DBD
OPTIONS_FILE_SET+=AUTHN_DBM
OPTIONS_FILE_SET+=AUTHN_ANON
OPTIONS_FILE_SET+=AUTHN_DEFAULT
OPTIONS_FILE_SET+=AUTHN_ALIAS
OPTIONS_FILE_SET+=AUTHZ_HOST
OPTIONS_FILE_SET+=AUTHZ_GROUPFILE
OPTIONS_FILE_SET+=AUTHZ_USER
OPTIONS_FILE_SET+=AUTHZ_DBM
OPTIONS_FILE_SET+=AUTHZ_OWNER
OPTIONS_FILE_SET+=AUTHZ_DEFAULT
OPTIONS_FILE_SET+=CACHE
OPTIONS_FILE_SET+=DISK_CACHE
OPTIONS_FILE_SET+=FILE_CACHE
OPTIONS_FILE_SET+=MEM_CACHE
OPTIONS_FILE_SET+=DAV
OPTIONS_FILE_SET+=DAV_FS
OPTIONS_FILE_SET+=BUCKETEER
OPTIONS_FILE_UNSET+=CASE_FILTER
OPTIONS_FILE_UNSET+=CASE_FILTER_IN
OPTIONS_FILE_SET+=EXT_FILTER
OPTIONS_FILE_SET+=LOG_FORENSIC
OPTIONS_FILE_SET+=OPTIONAL_HOOK_EXPORT
OPTIONS_FILE_SET+=OPTIONAL_HOOK_IMPORT
OPTIONS_FILE_SET+=OPTIONAL_FN_IMPORT
OPTIONS_FILE_SET+=OPTIONAL_FN_EXPORT
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=AUTHNZ_LDAP
OPTIONS_FILE_SET+=ACTIONS
OPTIONS_FILE_SET+=ALIAS
OPTIONS_FILE_SET+=ASIS
OPTIONS_FILE_SET+=AUTOINDEX
OPTIONS_FILE_SET+=CERN_META
OPTIONS_FILE_SET+=CGI
OPTIONS_FILE_SET+=CHARSET_LITE
OPTIONS_FILE_SET+=DBD
OPTIONS_FILE_SET+=DEFLATE
OPTIONS_FILE_SET+=DIR
OPTIONS_FILE_SET+=DUMPIO
OPTIONS_FILE_SET+=ENV
OPTIONS_FILE_SET+=EXPIRES
OPTIONS_FILE_SET+=HEADERS
OPTIONS_FILE_SET+=IMAGEMAP
OPTIONS_FILE_SET+=INCLUDE
OPTIONS_FILE_SET+=INFO
OPTIONS_FILE_SET+=LOG_CONFIG
OPTIONS_FILE_SET+=LOGIO
OPTIONS_FILE_SET+=MIME
OPTIONS_FILE_SET+=MIME_MAGIC
OPTIONS_FILE_SET+=NEGOTIATION
OPTIONS_FILE_SET+=REWRITE
OPTIONS_FILE_SET+=SETENVIF
OPTIONS_FILE_SET+=SPELING
OPTIONS_FILE_SET+=STATUS
OPTIONS_FILE_SET+=UNIQUE_ID
OPTIONS_FILE_SET+=USERDIR
OPTIONS_FILE_SET+=USERTRACK
OPTIONS_FILE_SET+=VHOST_ALIAS
OPTIONS_FILE_SET+=FILTER
OPTIONS_FILE_SET+=SUBSTITUTE
OPTIONS_FILE_SET+=VERSION
OPTIONS_FILE_SET+=PROXY
OPTIONS_FILE_SET+=PROXY_CONNECT
OPTIONS_FILE_SET+=PROXY_FTP
OPTIONS_FILE_SET+=PROXY_HTTP
OPTIONS_FILE_SET+=PROXY_AJP
OPTIONS_FILE_SET+=PROXY_BALANCER
OPTIONS_FILE_UNSET+=PROXY_SCGI
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_SET+=SUEXEC
OPTIONS_FILE_UNSET+=SUEXEC_RSRCLIMIT
OPTIONS_FILE_SET+=SUEXEC_USERDIR
OPTIONS_FILE_SET+=REQTIMEOUT
OPTIONS_FILE_SET+=CGID
OPTIONS_FILE_UNSET+=ECHO
OPTIONS_FILE_UNSET+=EXAMPLE_HOOKS
OPTIONS_FILE_UNSET+=EXAMPLE_IPC
OPTIONS_FILE_UNSET+=OPTIONAL_FN_EXPORT
OPTIONS_FILE_UNSET+=OPTIONAL_FN_IMPORT
OPTIONS_FILE_UNSET+=OPTIONAL_HOOK_EXPORT
OPTIONS_FILE_UNSET+=OPTIONAL_HOOK_IMPORT
OPTIONS_FILE_UNSET+=BUCKETEER
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        # apr bdb
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options
        # ldap auth module
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP#OPTIONS_FILE_SET+=LDAP#' /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=AUTHNZ_LDAP#OPTIONS_FILE_SET+=AUTHNZ_LDAP#' /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options
    fi
    rm -f /var/db/ports/www_apache${PREFERRED_APACHE_VER}/options${SED_EXTENSION} &>/dev/null

    if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
        ALL_PORTS="${ALL_PORTS} www/apache${PREFERRED_APACHE_VER}"
    fi

    # Nginx
    cat > /var/db/ports/www_nginx/options <<EOF
OPTIONS_FILE_SET+=DEBUG
OPTIONS_FILE_SET+=DEBUGLOG
OPTIONS_FILE_SET+=FILE_AIO
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=GOOGLE_PERFTOOLS
OPTIONS_FILE_SET+=HTTP
OPTIONS_FILE_UNSET+=HTTP_ADDITION
OPTIONS_FILE_SET+=HTTP_CACHE
OPTIONS_FILE_SET+=HTTP_DAV
OPTIONS_FILE_SET+=HTTP_FLV
OPTIONS_FILE_SET+=HTTP_GEOIP
OPTIONS_FILE_SET+=HTTP_GZIP_STATIC
OPTIONS_FILE_SET+=HTTP_GUNZIP_FILTER
OPTIONS_FILE_SET+=HTTP_IMAGE_FILTER
OPTIONS_FILE_SET+=HTTP_PERL
OPTIONS_FILE_SET+=HTTP_RANDOM_INDEX
OPTIONS_FILE_SET+=HTTP_REALIP
OPTIONS_FILE_SET+=HTTP_REWRITE
OPTIONS_FILE_SET+=HTTP_SECURE_LINK
OPTIONS_FILE_SET+=HTTP_SSL
OPTIONS_FILE_SET+=HTTP_STATUS
OPTIONS_FILE_SET+=HTTP_SUB
OPTIONS_FILE_UNSET+=HTTP_XSLT
OPTIONS_FILE_SET+=MAIL
OPTIONS_FILE_SET+=MAIL_IMAP
OPTIONS_FILE_SET+=MAIL_POP3
OPTIONS_FILE_SET+=MAIL_SMTP
OPTIONS_FILE_SET+=MAIL_SSL
OPTIONS_FILE_SET+=SPDY
OPTIONS_FILE_UNSET+=WWW
OPTIONS_FILE_UNSET+=CACHE_PURGE
OPTIONS_FILE_UNSET+=CTPP2
OPTIONS_FILE_UNSET+=ECHO
OPTIONS_FILE_UNSET+=HEADERS_MORE
OPTIONS_FILE_UNSET+=HTTP_ACCEPT_LANGUAGE
OPTIONS_FILE_UNSET+=HTTP_ACCESSKEY
OPTIONS_FILE_UNSET+=HTTP_AUTH_DIGEST
OPTIONS_FILE_UNSET+=HTTP_AUTH_LDAP
OPTIONS_FILE_UNSET+=HTTP_AUTH_PAM
OPTIONS_FILE_UNSET+=HTTP_AUTH_REQ
OPTIONS_FILE_UNSET+=HTTP_DAV_EXT
OPTIONS_FILE_UNSET+=HTTP_EVAL
OPTIONS_FILE_UNSET+=HTTP_FANCYINDEX
OPTIONS_FILE_UNSET+=HTTP_FOOTER
OPTIONS_FILE_UNSET+=HTTP_MOGILEFS
OPTIONS_FILE_UNSET+=HTTP_NOTICE
OPTIONS_FILE_UNSET+=HTTP_PUSH
OPTIONS_FILE_UNSET+=HTTP_PUSH_STREAM
OPTIONS_FILE_UNSET+=HTTP_REDIS
OPTIONS_FILE_UNSET+=HTTP_RESPONSE
OPTIONS_FILE_UNSET+=HTTP_SUBS_FILTER
OPTIONS_FILE_UNSET+=HTTP_UPLOAD
OPTIONS_FILE_UNSET+=HTTP_UPLOAD_PROGRESS
OPTIONS_FILE_UNSET+=HTTP_UPSTREAM_FAIR
OPTIONS_FILE_UNSET+=HTTP_UPSTREAM_HASH
OPTIONS_FILE_UNSET+=HTTP_UPSTREAM_STICKY
OPTIONS_FILE_UNSET+=HTTP_ZIP
OPTIONS_FILE_UNSET+=ARRAYVAR
OPTIONS_FILE_UNSET+=DRIZZLE
OPTIONS_FILE_UNSET+=ENCRYPTSESSION
OPTIONS_FILE_UNSET+=FORMINPUT
OPTIONS_FILE_UNSET+=GRIDFS
OPTIONS_FILE_UNSET+=ICONV
OPTIONS_FILE_UNSET+=LET
OPTIONS_FILE_UNSET+=LUA
OPTIONS_FILE_UNSET+=MEMC
OPTIONS_FILE_UNSET+=MODSECURITY
OPTIONS_FILE_UNSET+=NAXSI
OPTIONS_FILE_UNSET+=PASSENGER
OPTIONS_FILE_UNSET+=POSTGRES
OPTIONS_FILE_UNSET+=RDS_CSV
OPTIONS_FILE_UNSET+=RDS_JSON
OPTIONS_FILE_UNSET+=REDIS2
OPTIONS_FILE_UNSET+=RTMP
OPTIONS_FILE_UNSET+=SET_MISC
OPTIONS_FILE_UNSET+=SFLOW
OPTIONS_FILE_UNSET+=SLOWFS_CACHE
OPTIONS_FILE_UNSET+=SRCACHE
OPTIONS_FILE_UNSET+=SUPERVISORD
OPTIONS_FILE_UNSET+=SYSLOG_SUPPORT
OPTIONS_FILE_UNSET+=TCP_PROXY
OPTIONS_FILE_UNSET+=UDPLOG
OPTIONS_FILE_UNSET+=XRID_HEADER
OPTIONS_FILE_UNSET+=XSS
OPTIONS_FILE_UNSET+=VIDEO
OPTIONS_FILE_UNSET+=HTTP_MP4
OPTIONS_FILE_UNSET+=HTTP_MP4_H264
EOF

    if [ X"${WEB_SERVER_IS_NGINX}" == X'YES' ]; then
        ALL_PORTS="${ALL_PORTS} www/nginx www/uwsgi"
    fi

    # PHP5. REQUIRED.
    cat > /var/db/ports/lang_php${PREFERRED_PHP_VER}/options <<EOF
OPTIONS_FILE_SET+=CLI
OPTIONS_FILE_SET+=CGI
OPTIONS_FILE_SET+=FPM
OPTIONS_FILE_UNSET+=EMBED
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=MAILHEAD
OPTIONS_FILE_SET+=LINKTHR
OPTIONS_FILE_UNSET+=ZTS
EOF

    ALL_PORTS="${ALL_PORTS} lang/php${PREFERRED_PHP_VER}"
    if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
        ALL_PORTS="${ALL_PORTS} www/mod_php${PREFERRED_PHP_VER}"
    fi

    cat > /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options <<EOF
OPTIONS_FILE_SET+=BCMATH
OPTIONS_FILE_SET+=BZ2
OPTIONS_FILE_SET+=CALENDAR
OPTIONS_FILE_SET+=CTYPE
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_UNSET+=DBA
OPTIONS_FILE_SET+=DOM
OPTIONS_FILE_SET+=EXIF
OPTIONS_FILE_SET+=FILEINFO
OPTIONS_FILE_SET+=FILTER
OPTIONS_FILE_SET+=FTP
OPTIONS_FILE_SET+=GD
OPTIONS_FILE_SET+=GETTEXT
OPTIONS_FILE_UNSET+=GMP
OPTIONS_FILE_SET+=HASH
OPTIONS_FILE_SET+=ICONV
OPTIONS_FILE_SET+=IMAP
OPTIONS_FILE_UNSET+=INTERBASE
OPTIONS_FILE_SET+=JSON
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=MBSTRING
OPTIONS_FILE_SET+=MCRYPT
OPTIONS_FILE_UNSET+=MSSQL
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=MYSQLI
OPTIONS_FILE_UNSET+=ODBC
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_UNSET+=PCNTL
OPTIONS_FILE_UNSET+=PDF
OPTIONS_FILE_SET+=PDO
OPTIONS_FILE_SET+=PDO_SQLITE
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=PHAR
OPTIONS_FILE_SET+=POSIX
OPTIONS_FILE_SET+=PSPELL
OPTIONS_FILE_UNSET+=READLINE
OPTIONS_FILE_SET+=RECODE
OPTIONS_FILE_SET+=SESSION
OPTIONS_FILE_UNSET+=SHMOP
OPTIONS_FILE_SET+=SIMPLEXML
OPTIONS_FILE_SET+=SNMP
OPTIONS_FILE_SET+=SOAP
OPTIONS_FILE_SET+=SOCKETS
OPTIONS_FILE_SET+=SQLITE3
OPTIONS_FILE_UNSET+=SYBASE_CT
OPTIONS_FILE_UNSET+=SYSVMSG
OPTIONS_FILE_UNSET+=SYSVSEM
OPTIONS_FILE_UNSET+=SYSVSHM
OPTIONS_FILE_UNSET+=TIDY
OPTIONS_FILE_SET+=TOKENIZER
OPTIONS_FILE_UNSET+=WDDX
OPTIONS_FILE_SET+=XML
OPTIONS_FILE_SET+=XMLREADER
OPTIONS_FILE_SET+=XMLRPC
OPTIONS_FILE_SET+=XMLWRITER
OPTIONS_FILE_SET+=XSL
OPTIONS_FILE_SET+=ZIP
OPTIONS_FILE_SET+=ZLIB
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP#OPTIONS_FILE_SET+=LDAP#' /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQLI#OPTIONS_FILE_SET+=MYSQLI#' /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQLI#OPTIONS_FILE_SET+=MYSQLI#' /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options
    fi
    rm -f /var/db/ports/lang_php${PREFERRED_PHP_VER}-extensions/options${SED_EXTENSION} &>/dev/null

    cat > /var/db/ports/graphics_php${PREFERRED_PHP_VER}-gd/options <<EOF
OPTIONS_FILE_SET+=T1LIB
OPTIONS_FILE_UNSET+=TRUETYPE
OPTIONS_FILE_UNSET+=JIS
OPTIONS_FILE_UNSET+=X11
OPTIONS_FILE_UNSET+=VPX
EOF

    # PHP extensions
    ALL_PORTS="${ALL_PORTS} mail/php${PREFERRED_PHP_VER}-imap archivers/php${PREFERRED_PHP_VER}-zip archivers/php${PREFERRED_PHP_VER}-bz2 archivers/php${PREFERRED_PHP_VER}-zlib devel/php${PREFERRED_PHP_VER}-gettext converters/php${PREFERRED_PHP_VER}-mbstring security/php${PREFERRED_PHP_VER}-mcrypt security/php${PREFERRED_PHP_VER}-openssl www/php${PREFERRED_PHP_VER}-session textproc/php${PREFERRED_PHP_VER}-ctype security/php${PREFERRED_PHP_VER}-hash converters/php${PREFERRED_PHP_VER}-iconv textproc/php${PREFERRED_PHP_VER}-pspell textproc/php${PREFERRED_PHP_VER}-dom textproc/php${PREFERRED_PHP_VER}-xml"

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ALL_PORTS="${ALL_PORTS} net/php${PREFERRED_PHP_VER}-ldap databases/php${PREFERRED_PHP_VER}-mysql databases/php${PREFERRED_PHP_VER}-mysqli"
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ALL_PORTS="${ALL_PORTS} databases/php${PREFERRED_PHP_VER}-mysql databases/php${PREFERRED_PHP_VER}-mysqli"
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ALL_PORTS="${ALL_PORTS} databases/php${PREFERRED_PHP_VER}-pgsql"
    fi

    cat > /var/db/ports/www_mod_php${PREFERRED_PHP_VER}/options <<EOF
OPTIONS_FILE_UNSET+=AP2FILTER
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=MAILHEAD
OPTIONS_FILE_SET+=LINKTHR
OPTIONS_FILE_UNSET+=ZTS
EOF

    cat > /var/db/ports/www_pecl-APC/options <<EOF
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=FILEHITS
OPTIONS_FILE_UNSET+=IPC
OPTIONS_FILE_UNSET+=SEMAPHORES
OPTIONS_FILE_UNSET+=SPINLOCKS
EOF

    # Policyd v2.x
    cat > /var/db/ports/mail_policyd2/options <<EOF
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PostgreSQL
OPTIONS_FILE_UNSET+=SQLite
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' -o X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/mail_policyd2/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/mail_policyd2/options
    fi
    rm -f /var/db/ports/mail_policyd2/options${SED_EXTENSION} &>/dev/null

    ALL_PORTS="${ALL_PORTS} devel/p5-Exporter-Tiny mail/policyd2"

    # ClamAV. REQUIRED.
    cat > /var/db/ports/security_clamav/options <<EOF
OPTIONS_FILE_SET+=ARC
OPTIONS_FILE_SET+=ARJ
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=EXPERIMENTAL
OPTIONS_FILE_SET+=ICONV
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=LHA
OPTIONS_FILE_UNSET+=LLVM
OPTIONS_FILE_UNSET+=MILTER
OPTIONS_FILE_UNSET+=STDERR
OPTIONS_FILE_SET+=TESTS
OPTIONS_FILE_SET+=UNRAR
OPTIONS_FILE_SET+=UNZOO
EOF

    ALL_PORTS="${ALL_PORTS} security/clamav"

    # Roundcube.
    cat > /var/db/ports/mail_roundcube/options <<EOF
OPTIONS_FILE_UNSET+=GD
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=NSC
OPTIONS_FILE_SET+=PSPELL
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=LDAP#OPTIONS_FILE_SET+=LDAP#' /var/db/ports/mail_roundcube/options
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/mail_roundcube/options
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/mail_roundcube/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/mail_roundcube/options
    fi
    rm -f /var/db/ports/mail_roundcube/options${SED_EXTENSION} &>/dev/null

    # Python-MySQLdb
    cat > /var/db/ports/databases_py-MySQLdb/options <<EOF
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=MYSQLCLIENT_R
EOF

    # py-sqlalchemy
    ALL_PORTS="${ALL_PORTS} databases/py-sqlalchemy"
    cat > /var/db/ports/databases_py-sqlalchemy/options <<EOF
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_UNSET+=TESTS
OPTIONS_FILE_UNSET+=MSSQL
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE
OPTIONS_FILE_UNSET+=SYBASE
EOF

    if [ X"${BACKEND}" == X'OPENLDAP' -o X"${BACKEND}" == X'MYSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=MYSQL#OPTIONS_FILE_SET+=MYSQL#' /var/db/ports/databases_py-sqlalchemy/options
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ${CMD_SED} -e 's#OPTIONS_FILE_UNSET+=PGSQL#OPTIONS_FILE_SET+=PGSQL#' /var/db/ports/databases_py-sqlalchemy/options
    fi

    cat > /var/db/ports/devel_py-Jinja2/options <<EOF
OPTIONS_FILE_SET+=BABEL
OPTIONS_FILE_UNSET+=EXAMPLES
EOF

    # Roundcube webmail.
    if [ X"${USE_RCM}" == X"YES" ]; then
        ALL_PORTS="${ALL_PORTS} mail/roundcube"
        [ X"${BACKEND}" == X'OPENLDAP' ] && ALL_PORTS="${ALL_PORTS} net/pear-Net_LDAP2"
    fi

    # Awstats.
    if [ X"${USE_AWSTATS}" == X'YES' -a X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
        ALL_PORTS="${ALL_PORTS} www/awstats"
    fi

    # Python database interfaces
    if [ X"${BACKEND}" == X'OPENLDAP' ]; then
        ALL_PORTS="${ALL_PORTS} net/py-ldap2 databases/py-MySQLdb"
    elif [ X"${BACKEND}" == X'MYSQL' ]; then
        ALL_PORTS="${ALL_PORTS} databases/py-MySQLdb"
    elif [ X"${BACKEND}" == X'PGSQL' ]; then
        ALL_PORTS="${ALL_PORTS} databases/py-psycopg2"
    fi

    # iRedAdmin
    # mod_wsgi
    ALL_PORTS="${ALL_PORTS} www/webpy net/py-netifaces devel/py-lxml www/py-beautifulsoup security/py-bcrypt"

    if [ X"${WEB_SERVER_IS_APACHE}" == X'YES' ]; then
        ALL_PORTS="${ALL_PORTS} www/mod_wsgi3"
    fi

    # Fail2ban.
    #if [ X"${USE_FAIL2BAN}" == X"YES" ]; then
    #    # python-ldap.
    #    ALL_PORTS="${ALL_PORTS} security/py-fail2ban"
    #fi

    cat > /var/db/ports/net_py-ldap2/options <<EOF
OPTIONS_FILE_SET+=SASL
EOF

    # Misc
    ALL_PORTS="${ALL_PORTS} sysutils/logwatch sysutils/logrotate"

    # Fetch all source tarballs.
    ECHO_INFO "Ports tree: ${PORT_WRKDIRPREFIX}"
    ECHO_INFO "Fetching all distfiles for required ports (make fetch-recursive)"

    for i in ${ALL_PORTS}; do
        if [ X"${i}" != X'' ]; then
            portname="$( echo ${i} | tr '/' '_' | tr -d '[-\.]')"
            status="\$status_fetch_port_$portname"
            if [ X"$(eval echo ${status})" != X"DONE" ]; then
                ECHO_INFO "Fetching all distfiles for port ${i} and dependencies"
                cd ${PORT_WRKDIRPREFIX}/${i}

                # Get time as a UNIX timestamp (seconds elapsed since Jan 1, 1970 0:00 UTC)
                port_start_time="$(date +%s)"

                make DISABLE_LICENSES=yes fetch-recursive
                if [ X"$?" == X"0" ]; then
                    # Log used time
                    used_time="$(($(date +%s)-port_start_time))"
                    echo "export status_fetch_port_${portname}='DONE'  # ${used_time} seconds, ~= $((used_time/60)) minute(s)" >> ${STATUS_FILE}
                else
                    ECHO_ERROR "Tarballs were not downloaded correctly, please fix it manually and then re-execute iRedMail.sh."
                    exit 255
                fi
            else
                ECHO_SKIP "Fetching all distfiles for port ${i} and dependencies"
            fi
        fi
    done

    # Install all packages.
    ECHO_INFO "==== Install packages ===="

    start_time="$(date +%s)"
    for i in ${ALL_PORTS}; do
        if [ X"${i}" != X'' ]; then
            # Remove special characters in port name: -, /, '.'.
            portname="$( echo ${i} | tr '/' '_' | tr -d '[-\.]')"

            status="\$status_install_port_$portname"
            if [ X"$(eval echo ${status})" != X"DONE" ]; then
                cd ${PORT_WRKDIRPREFIX}/${i} && \
                    ECHO_INFO "Installing port: ${i} ($(date '+%Y-%m-%d %H:%M:%S')) ..."
                    echo "export status_install_port_${portname}='processing'" >> ${STATUS_FILE}

                    # Get time as a UNIX timestamp (seconds elapsed since Jan 1, 1970 0:00 UTC)
                    port_start_time="$(date +%s)"

                    # Clean up and compile
                    make clean && make DISABLE_MAKE_JOBS=yes install clean

                    if [ X"$?" == X"0" ]; then
                        # Log used time
                        used_time="$(($(date +%s)-port_start_time))"

                        # Recent all used time
                        recent_all_used_time="$(($(date +%s)-start_time))"

                        echo "export status_install_port_${portname}='DONE'  # ${used_time} seconds, ~= $((used_time/60)) minute(s). Recent ~= $((recent_all_used_time/60)) minutes" >> ${STATUS_FILE}
                    else
                        ECHO_ERROR "Port was not successfully installed, please fix it manually and then re-execute this script."
                        exit 255
                    fi
            else
                ECHO_SKIP "Installing port: ${i}."
            fi
        fi
    done

    # Create symbol link for Python.
    ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
    ln -sf /usr/local/bin/python2.7 /usr/local/bin/python2
    ln -sf /usr/local/bin/pydoc2.7  /usr/local/bin/pydoc
    ln -sf /usr/local/bin/2to3-2.7 /usr/local/bin/2to3
    ln -sf /usr/local/bin/python2.7-config /usr/local/bin/python-config

    # Create logrotate.d
    mkdir -p ${LOGROTATE_DIR} >> ${INSTALL_LOG} 2>&1

    # Log and print used time
    all_used_time="$(($(date +%s)-start_time))"
    ECHO_INFO "Total time of ports compiling: ${all_used_time} seconds, ~= $((all_used_time/60)) minute(s)"

    echo 'export status_install_all="DONE"' >> ${STATUS_FILE}
}
