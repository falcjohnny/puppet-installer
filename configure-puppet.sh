#!/bin/bash
#
# Helper script to configure Puppet tools.
#
# @package Test Utilities / Puppet Configuration
# @version 1.00
# @author Johnny Wu <johnny.wu@falconstor.com>., 2016
#
script_path="/puppet-installer"

# include bash commons
if [ ! -f $script_path/common_functions.sh ]; then
    echo "$0: cannot find common_functions.sh! cannot continue. please put the folder $script_path under /";
    exit 1;
else
    . $script_path/common_functions.sh
fi

error_file=$script_path/logs/configure-puppet.log

#PEAR_RPM_PATH="$script_path/deps"
#PHPUNIT_PEAR_PACKAGES="$script_path/deps/puppet"
#PEAR_Functional_Test="pear_status"

program_name="Puppet Installation Tool"
program_written="- Johnny Wu<johnny.wu@falconstor.com>., 2016\n"
program_version="1.0"

# ===========================================================
#  functions
# ===========================================================
#
# Installs Puppet on an IPStor server or FreeStor server.
#
# install_puppet()
# IN: nothing
# OUT: nothing
#
function install_puppet
{
    # check if resolv.conf has data
    rm -f /etc/resolv.conf 
    if [ ! -s /etc/resolv.conf ]; then
        echo "search host.local" >> /etc/resolv.conf
        echo "nameserver 172.22.6.139" >> /etc/resolv.conf   # ip address of puppet master
    fi

    fqdn=$short_hostname.$domain_name
    echo "------> hostname = $short_hostname"
    echo "------> FQDN = $fqdn"
    log "* Set FQDN to /etc/hosts..."
        sed -i '/'$short_hostname'/d' /etc/hosts
        echo "127.0.0.1 $fqdn $short_hostname " >> /etc/hosts

    log "* Enable the Puppet Collection 1 repository..."
        rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

    log "* Installing puppet agent..."
        yum install -y puppet

        sleep 5
        echo
        log "* Installation complete"

    log "* Configuring puppet configuration and auth file..."
        yes | cp $script_path/puppet.conf /etc/puppet
        yes | cp $script_path/auth.conf /etc/puppet
    
        sed -c -i "s/\(certname *= *\).*/\1$fqdn/" /etc/puppet/puppet.conf

    log "* Starting puppet service..."
        puppet resource service puppet ensure=running enable=true

    log "* Step 1 : Please go to puppet web console https://172.22.6.139/, browse Infrastructure -> Smart Proxies -> host-puppetmaster.host.local -> Select Action -> Certificates, Selecting your FMS/FSS hostname and click Sign for certificate. "
    log "        Note: Please make sure the time between the Puppet-agent and the Puppetmaster is in sync."
    log "* Step 2 : Run 'puppet agent -t' on your server" 
}

# ===========================================================
#  start program running
# ===========================================================
check_root

print_header

install_puppet
exit 0
