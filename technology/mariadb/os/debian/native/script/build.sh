#!/usr/bin/env bash

# ============================================================ #
# Tool Created date: 10 jan 2023                               #
# Tool Created by: Henrique Silva (rick.0x00@gmail.com)        #
# Tool Name: mariadb Install                                       #
# Description: My simple script to provision MariaDB Server    #
# License: software = MIT License                              #
# Remote repository 1: https://github.com/rick0x00/srv_db      #
# Remote repository 2: https://gitlab.com/rick0x00/srv_db      #
# ============================================================ #
# base content:
#   

# ============================================================ #
# start root user checking
if [ $(id -u) -ne 0 ]; then
    echo "Please use root user to run the script."
    exit 1
fi
# end root user checking
# ============================================================ #
# start set variables

DATE_NOW="$(date +Y%Ym%md%d-H%HM%MS%S)" # extracting date and time now

### database vars
database_bind_address="127.0.0.1" # setting to listen only localhost
#database_bind_address="0.0.0.0" # setting to listen for everybody
database_bind_port="3306" # setting to listen on default MySQL port

database_host="localhost"
database_root_user="root"
database_root_pass="supersecret123"

database_user="mariadb_db_user"
database_pass="mariadb_db_pass"
database_user_access_host="localhost"
database_db_name="mariadb_db_name"
database_db_charset="utf8mb4"
database_db_collate="utf8mb4_unicode_ci"


os_distribution="Debian"
os_version=("11" "bullseye")

database_engine="mysql"

port_mariadb[0]="${database_bind_port}" # http number Port
port_mariadb[1]="tcp" # tcp protocol Port 


build_path="/usr/local/src"
workdir="/var/www/"
persistence_volumes=("/var/www/" "/var/log/")
expose_ports="${port_mariadb[0]}/${port_mariadb[1]}}"
# end set variables
# ============================================================ #
# start definition functions
# ============================== #
# start complement functions

function remove_space_from_beginning_of_line {
    #correct execution
    #remove_space_from_beginning_of_line "<number of spaces>" "<file to remove spaces>"

    # Remove a white apace from beginning of line
    #sed -i 's/^[[:space:]]\+//' "$1"
    #sed -i 's/^[[:blank:]]\+//' "$1"
    #sed -i 's/^ \+//' "$1"

    # check if 2 arguments exist
    if [ $# -eq 2 ]; then
        #echo "correct quantity of args"
        local spaces="${1}"
        local file="${2}"
    else
        #echo "incorrect quantity of args"
        local spaces="4"
        local file="${1}"
    fi 
    sed -i "s/^[[:space:]]\{${spaces}\}//" "${file}"
}

function massager_sharp() {
    line_divisor="###########################################################################################"
    echo "${line_divisor}"
    echo "$*"
    echo "${line_divisor}"
}

function massager_line() {
    line_divisor="-------------------------------------------------------------------------------------------"
    echo "${line_divisor}"
    echo "$*"
    echo "${line_divisor}"
}

function massager_plus() {
    line_divisor="++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "${line_divisor}"
    echo "$*"
    echo "${line_divisor}"
}

# end complement functions
# ============================== #
# start main functions

function pre_install_server () {
    massager_line "Pre install server step"

    function install_generic_tools() {
        # update repository
        apt update

        #### start generic tools
        # install basic network tools
        apt install -y net-tools iproute2 traceroute iputils-ping mtr
        # install advanced network tools
        apt install -y tcpdump nmap netcat
        # install DNS tools
        apt install -y dnsutils
        # install process inspector
        apt install -y procps htop
        # install text editors
        apt install -y nano vim 
        # install web-content downloader tools
        apt install -y wget curl
        # install uncompression tools
        apt install -y unzip tar
        # install file explorer with CLI
        apt install -y mc
        # install task scheduler 
        apt install -y cron
        # install log register 
        apt install -y rsyslog
        #### stop generic tools
    }

    function install_dependencies () {
        echo "step not necessary"
        exit 1;
    }

    function install_complements () {
        echo "step not necessary"
        exit 1;
    }

    apt update
    install_generic_tools
    #install_dependencies;
    #install_complements;
}

##########################
## install steps

function install_mariadb () {
    # installing MariaDB
    massager_plus "Installing MariaDB"

    function install_from_source () {
        echo "step not configured"
        exit 1;
    }

    function install_from_apt () {
        apt install -y mariadb-common mariadb-server mariadb-server mariadb-client mariadb-backup
    }

    ## Installing MariaDB From Source ##
    #install_from_source

    ## Installing MariaDB From APT (Debian package manager) ##
    install_from_apt
}
#############################

function install_server () {
    massager_line "Install server step"

    ##  mariadb
    install_mariadb
}

#############################
## start/stop steps ##

function start_mariadb () {
    # starting MariaDB
    massager_plus "Starting MariaDB"

    #service mariadb start
    #systemctl start mariadb
    /etc/init.d/mariadb start

    # Daemon running on foreground mode
    #/usr/sbin/mariadbd
}

function stop_mariadb () {
    # stopping mariadb
    massager_plus "Stopping MariaDB"

    #service mariadb stop
    #systemctl stop mariadb
    /etc/init.d/mariadb stop

    # ensuring it will be stopped
    # for Daemon running on foreground mode
    killall mariadbd
}

################################

function start_server () {
    massager_line "Starting server step"
    # Starting Service

    # starting mariadb
    start_mariadb
}

function stop_server () {
    massager_line "Stopping server step"

    # stopping server
    stop_mariadb
}

################################
## configuration steps ##

function configure_mariadb() {
    # Configuring MariaDB
    massager_plus "Configuring MariaDB"

    local database_bind_address="${database_bind_address:-127.0.0.1}" # setting to listen only localhost
    #local database_bind_address="0.0.0.0" # setting to listen for everybody
    local database_bind_port="${database_bind_port:-3306}" # setting to listen on default MySQL port


    local database_host="${database_host:-localhost}"
    local database_port="${database_port:-${database_bind_port}}"
    local database_root_user="${database_root_user:-root}"
    local database_root_pass="${database_root_pass:-supersecret123}"

    local database_user="${database_user:-sysadmin}"
    local database_pass="${database_pass:-masterpassword123}"
    local database_user_access_host="${database_user_access_host:-'%'}" # grant access by database for any host
    local database_db_name="${database_db_name:-xpto}"
    local database_db_charset="${database_db_charset:-utf8mb4}"
    local database_db_collate="${database_db_collate:-utf8mb4_unicode_ci}"

    function check_mariadb_is_alive() {
        # Checking if MariaDB Server is alive
        massager_plus "Checking if MariaDB Server is alive"
        # Retry settings
        local max_retries=5
        local delay_between_retries=2

        for ((i=1; i<=$max_retries; i++)); do
            # Try to connect to MySQL
            echo "port: ${database_port}"
            echo "host: ${database_host}"
            #mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "SELECT VERSION();"
            mysqladmin -h ${database_host} -P ${database_port} ping

            # Check the exit code of the previous command
            if [ $? -eq 0 ]; then
                echo "MySQL server is responding."
                break
            else
                echo "Attempt $i of $max_retries: Unable to connect to MySQL server."
                if [ $i -lt $max_retries ]; then
                    echo "Waiting $delay_between_retries seconds before the next attempt..."
                    sleep $delay_between_retries
                else
                    echo "Exceeded the maximum number of retries. Aborting the script."
                    exit 1
                fi
            fi
        done
    }

    function configure_mariadb_server() {
        # Configuring MariaDB Server
        massager_plus "Configuring MariaDB Server"

        echo "
        [mysqld]
        sql-mode="STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
        #character-set-server=utf8
        default-authentication-plugin=mysql_native_password
        bind-address=${database_bind_address}
        port=${database_bind_port}

        # log configurations    
        log_error=/var/log/mysql/error.log
        general_log_file=/var/log/mysql/general.log
        general_log=1

        # security configurations
        version = 10

        " > /etc/mysql/mariadb.conf.d/99-server.cnf
        remove_space_from_beginning_of_line "8" "/etc/mysql/mariadb.conf.d/99-server.cnf"

    }

    function configure_mariadb_security() {
        # Configuring MariaDB Security
        massager_plus "Configuring MariaDB Security"

        #  Enables to improve the security of MariaDB
        #mysql_secure_installation
        # Automating `mysql_secure_installation`
        
        # setting root password
        #mysql -uroot -p
        mysql -e "SET PASSWORD FOR '$database_root_user'@localhost = PASSWORD('$database_root_pass');"
        # Make sure that NOBODY can access the server without a password
        mysql -e "ALTER USER '$database_root_user'@'localhost' IDENTIFIED BY '$database_root_pass';"

        # Delete anonymous users
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "DELETE FROM mysql.user WHERE User='';"

        # disallow remote login for root
        #mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'sua_senha';"
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

        # Remove the test database
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "DROP DATABASE IF EXISTS test;"

        # Make our changes take effect
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "FLUSH PRIVILEGES;"

        # EOF(end-of-file) IS ALTERNATIVE METHOD, MORE VERBOSE
        #mysql --user=root << EOF
        #    SET PASSWORD FOR 'root'@localhost = PASSWORD("$database_root_pass");
        #    ALTER USER 'root'@'localhost' IDENTIFIED BY '$database_root_pass';
        #    DELETE FROM mysql.user WHERE User='';
        #    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        #    DROP DATABASE IF EXISTS test;
        #    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
        #    FLUSH PRIVILEGES;
        #EOF
    }

    function creating_mariadb_user() {
        # Configuring MariaDB user
        massager_plus "Configuring MariaDB user"

        # making new user
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "CREATE USER ${database_user}@'${database_user_access_host}' IDENTIFIED BY '$database_pass';"
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "FLUSH PRIVILEGES;"
    }

    function creating_mariadb_database() {
        # Creating New Database
        massager_plus "Creating New Database"

        # making new database
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "CREATE DATABASE ${database_db_name} CHARACTER SET ${database_db_charset} COLLATE ${database_db_collate};"
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "GRANT ALL PRIVILEGES ON ${database_db_name}.* TO ${database_user}@'${database_user_access_host}';"
        mysql -h ${database_host} -P ${database_port} -u ${database_root_user} -p"${database_root_pass}" -e "FLUSH PRIVILEGES;"
    }

    start_mariadb;
    check_mariadb_is_alive;
    configure_mariadb_server;
    configure_mariadb_security;
    creating_mariadb_user;
    creating_mariadb_database;
    stop_mariadb;

}


################################

function configure_server () {
    # configure server
    massager_line "Configure server"

    # configure mariadb 
    configure_mariadb
}

################################
## check steps ##

function check_configs_mariadb() {
    # Check config of Database
    massager_plus "Check config of Database"

    echo "step not configured"
    exit 1;
}


#####################

function check_configs () {
    massager_line "Check Configs server"

    # check if the configuration file is ok.
    #check_configs_mariadb

}

################################
## test steps ##

function test_mariadb () {
    # Testing MariaDB
    massager_plus "Testing of MariaDB"

    # is running ????
    #service mariadb status
    #systemctl status  --no-pager -l mariadb
    /etc/init.d/mariadb status
    ps -ef --forest | grep mariadb

    # is listening ?
    ss -pultan | grep :${database_bind_port}

    # is creating logs ????
    tail /var/log/mysql/*

    # Validating...

    ## scanning mariadb ports using NETCAT
    nc -zv localhost ${database_bind_port}
    #root@wordpress:~# nc -zv localhost 3306
    #nc: connect to localhost (::1) port 3306 (tcp) failed: Connection refused
    #Connection to localhost (127.0.0.1) 3306 port [tcp/mysql] succeeded!


    ## scanning mariadb ports using NMAP
    nmap -A localhost -sT -p ${database_bind_port}
    #root@wordpress:~# nmap -A localhost -sT -p 3306
	#Starting Nmap 7.80 ( https://nmap.org ) at 2024-01-07 15:49 UTC
	#Nmap scan report for localhost (127.0.0.1)
	#Host is up (0.00013s latency).
	#Other addresses for localhost (not scanned): ::1
	#
	#PORT     STATE SERVICE VERSION
	# 3306/tcp open  mysql   MySQL 5.5.5-10.5.21-MariaDB-0+deb11u1-log
	#| mysql-info: 
	#|   Protocol: 10
	#|   Version: 5.5.5-10.5.21-MariaDB-0+deb11u1-log
	#|   Thread ID: 8
	#|   Capabilities flags: 63486
	#|   Some Capabilities: IgnoreSigpipes, Speaks41ProtocolOld, Support41Auth, SupportsTransactions, ConnectWithDatabase, ODBCClient, SupportsLoadDataLocal, Speaks41ProtocolNew, IgnoreSpaceBeforeParenthesis, InteractiveClient, LongColumnFlag, SupportsCompression, DontAllowDatabaseTableColumn, FoundRows, SupportsMultipleStatments, SupportsAuthPlugins, SupportsMultipleResults
	#|   Status: Autocommit
	#|   Salt: 5C.[bZ})P6\LHeBZ~-`~
	#|_  Auth Plugin Name: mysql_native_password
	#Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
	#Device type: general purpose
	#Running: Linux 2.6.X
	#OS CPE: cpe:/o:linux:linux_kernel:2.6.32
	#OS details: Linux 2.6.32
	#Network Distance: 0 hops
	#
	#OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
	#Nmap done: 1 IP address (1 host up) scanned in 2.66 seconds

    echo -e "\n" | telnet localhost ${database_bind_port}
}

################################

function test_server () {
    massager_line "Testing server"

    # testing mariadb
    test_mariadb

}

################################

# end main functions
# ============================== #

# end definition functions
# ============================================================ #
# start argument reading

# end argument reading
# ============================================================ #
# start main executions of code
massager_sharp "Starting mariadb installation script"
pre_install_server;
install_server;
stop_server;
configure_server;
check_configs;
start_server;
test_server;
massager_sharp "Finished mariadb installation script"


