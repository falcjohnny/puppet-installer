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
        echo "search $domain_name" >> /etc/resolv.conf
        echo "nameserver $puppetmaster_ip" >> /etc/resolv.conf   # ip address of puppet master
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
        log "* Puppet Agent Installation complete!"

    log "* Configuring puppet configuration and auth file..."
        yes | cp $script_path/puppet.conf /etc/puppet
        yes | cp $script_path/auth.conf /etc/puppet
    
        sed -c -i "s/\(certname *= *\).*/\1$fqdn/" /etc/puppet/puppet.conf

    log "* Starting puppet service..."
        puppet resource service puppet ensure=running enable=true

    log "* Copy SSH RSA Public Key to Puppet master for passwordless login..."
        ssh-keyscan -H $puppetmaster_ip >> /root/.ssh/known_hosts
        ssh-copy-id -i /root/.ssh/id_rsa.pub $puppetmaster_ip
        #Based on the security, do not put the puppetmaster password on github with below commented method.
#/usr/bin/expect <<EOD
#spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $puppetmaster_ip
#expect "*password:*"
#send "$puppetmaster_pass\n"
#expect eof
#EOD
        
    log "* Step 1 : Please go to puppet web console https://$puppetmaster_ip/, browse Infrastructure -> Smart Proxies -> host-puppetmaster.host.local -> Select Action -> Certificates, finding your FMS/FSS hostname and click Sign for certificate. "
    log "        Note: Please make sure the time between the Puppet-agent and the Puppetmaster is in sync."
    log "* Step 2 : Run 'puppet agent -t' on your FSS/FMS server" 
}

# ===========================================================
#  start program running
# ===========================================================
check_root

print_header

install_puppet
exit 0

