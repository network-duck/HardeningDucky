#!/bin/bash

################################################################################################
# Prerequisite stuff                                                                           #
################################################################################################

#Making sure script was run with root
if [ $(id -u) == "0" ]; then
    echo "Running with root permissions"

#Not run with root - root is necessary for script so exit
else
    echo "Please run the script with root permissions."
    exit
fi

#Getting ubuntu version
OSNAME=$(lsb_release -a | grep "Distributor ID" | cut -d $'\t' -f 2)
VERSION=$(lsb_release -a | grep "Codename" | cut -d $'\t' -f 2)

#Detects Jammy Ubuntu
if [ "$OSNAME" == "Ubuntu" ] && [ "$VERSION" == "jammy" ]; then
    echo "Running on version Jammy Jellyfish"

#Detects Focal Ubuntu
elif [ "$OSNAME" == "Ubuntu" ] && [ $VERSION == "focal" ]; then
        echo "Running on version Focal Fossa"

#Detects Bionic Ubuntu
elif [ "$OSNAME" == "Ubuntu" ] && [ $VERSION == "bionic" ]; then
        echo "Running on version Bionic Beaver"

#Detects Debian
elif [ "$OSNAME" == "Debian" ]; then
    VERSION="debian"
    echo "Running on Debian 11 / Bullseye"

#Version not detected - file broken
else
    echo "Version not found - was lsb_release tampered with or inaccessible?"

    #Check if the user says yes or no
    echo "Input version manually? (y/n)" 
    read yninput

    #User will manually input version number
    if [ $yninput == "y" ]; then
        echo "Enter version codename (ex. jammy): "
        read VERSION
         
    #User does not manually input version number - necessary for script so exit
    else
        echo "Exiting."
        exit
    fi
fi

################################################################################################
# Dependency installation                                                                      #
################################################################################################

#Verify whiptail is installed on the system
if [[ $(which whiptail) ]]; then
    echo "Whiptail installed"
else
    echo "Whiptail is not installed."

    apt install whiptail
fi

#Changing the colors cause everything's gotta be pretty
export NEWT_COLORS='
window=blue,white
border=black,white
textbox=black,white
button=black,white
'

whiptail --msgbox \
'
              Welcome To
    __  __               __           _             ____             __        
   / / / /___ __________/ /__  ____  (_)___  ____ _/ __ \__  _______/ /____  __
  / /_/ / __ `/ ___/ __  / _ \/ __ \/ / __ \/ __ `/ / / / / / / ___/ //_/ / / /
 / __  / /_/ / /  / /_/ /  __/ / / / / / / / /_/ / /_/ / /_/ / /__/ ,< / /_/ / 
/_/ /_/\__,_/_/   \__,_/\___/_/ /_/_/_/ /_/\__, /_____/\__,_/\___/_/|_|\__, /  
                                          /____/                      /____/   

network-duck's Linux Security Helper' 16 42

################################################################################################
# Scans loop                                                                                   #
################################################################################################

mkdir logs

touch logs/output.log

chmod 666 logs/output.log

while true; do
    CHOICE=$(
        whiptail --title "What scans do you want to run?" --menu "" 18 50 10 \
            "1)" "Scans." \
            "2)" "Auto-policies." \
            "3)" "Critical service configurations." \
            "4)" "Browser configurations." \
            "5)" "Policies." \
            "X)" "Exit." 3>&2 2>&1 1>&3	
    )

    case $CHOICE in
        "1)")
            while true; do
                SUBCHOICE=$(
                    whiptail --title "What scans do you want to run?" --menu "" 18 50 10 \
                        "1)" "User scan." \
                        "2)" "Package/snap scan." \
                        "3)" "Home directories scan." \
                        "4)" "/usr files scan." \
                        "5)" "/etc baseline scan." \
                        "X)" "Exit." 3>&2 2>&1 1>&3	
                )

                case $SUBCHOICE in
                    "1)")
                        ./subscripts/scans/users.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "2)")
                        ./subscripts/scans/packages.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "3)")
                        ./subscripts/scans/homedirs.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "4)")
                        ./subscripts/scans/files.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "5)")
                        ./subscripts/scans/etcscan.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "X)")
                        break
                    ;;
                esac
            done
        ;;
        "2)")
            while true; do
                CHOICE=$(
                    whiptail --title "What policies do you want to enforce?" --menu "" 18 50 10 \
                        "1)" "Apt security." \
                        "2)" "Secure gnome." \
                        "3)" "Configure UFW." \
                        "4)" "Secure kernel sysctl settings." \
                        "X)" "Exit." 3>&2 2>&1 1>&3	
                )

                case $CHOICE in
                    "1)")
                        ./subscripts/autopols/apt.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "2)")
                        ./subscripts/autopols/gsettings.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "3)")
                        ./subscripts/autopols/firewall.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "4)")
                        ./subscripts/autopols/kernel.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "X)")
                        break
                    ;;
                esac
            done
        ;;
        "3)")
            #Verify meld is installed on the system
            if [[ $(which meld) ]]; then
                echo "Meld installed"
            else
                echo "Meld is not installed."

                apt install meld
            fi

            while true; do
                CHOICE=$(
                    whiptail --title "What configs do you want to diff?" --menu "" 18 50 10 \
                        "1)" "sshd" \
                        "2)" "vsftpd" \
                        "3)" "apache" \
                        "4)" "dovecot" \
                        "5)" "nginx" \
                        "6)" "postfix" \
                        "7)" "squid" \
                        "8)" "mysql" \
                        "9)" "samba" \
                        "10)" "postgresql" \
                        "X)" "Exit." 3>&2 2>&1 1>&3	
                )

                case $CHOICE in
                    "1)")
                        meld "$(pwd)/baselines/services/ssh" /etc/ssh
                    ;;
                    "2)")
                        meld "$(pwd)/baselines/services/vsftpd.conf" /etc/vsftpd.conf
                    ;;
                    "3)")
                        meld "$(pwd)/baselines/services/apache2" /etc/apache2
                    ;;
                    "4)")
                        meld "$(pwd)/baselines/services/dovecot" /etc/dovecot
                    ;;
                    "5)")
                        meld "$(pwd)/baselines/services/nginx" /etc/nginx
                    ;;
                    "6)")
                        meld "$(pwd)/baselines/services/postfix" /etc/postfix
                    ;;
                    "7)")
                        meld "$(pwd)/baselines/services/squid" /etc/squid
                    ;;
                    "8)")
                        meld "$(pwd)/baselines/services/mysql" /etc/mysql
                    ;;
                    "9)")
                        meld "$(pwd)/baselines/services/samba" /etc/samba
                    ;;
                    "10)")
                        meld "$(pwd)/baselines/services/postgresql" /etc/postgresql
                    ;;
                    "X)")
                        break
                    ;;
                esac
            done
        ;;
        "4)")
            while true; do
                CHOICE=$(
                    whiptail --title "What browsers do you want to harden?" --menu "" 18 50 10 \
                        "1)" "Firefox" \
                        "2)" "Chromium" \
                        "X)" "Exit." 3>&2 2>&1 1>&3	
                )

                case $CHOICE in
                    "1)")
                        ./subscripts/policies/firefox.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "2)")
                        ./subscripts/policies/chromium.sh "$(pwd)/baselines/$VERSION"
                    ;;
                    "X)")
                        break
                    ;;
                esac
            done
        ;;
        "5)")
            while true; do
                CHOICE=$(
                    whiptail --title "What policy folders do you want to diff?" --menu "" 18 50 10 \
                        "1)" "/etc/pam.d/" \
                        "2)" "/etc/login.defs" \
                        "3)" "/etc/apt/" \
                        "4)" "/etc/security/" \
                        "5)" "/etc/gdm3/" \
                        "6)" "/etc/grub.d/" \
                        "7)" "/etc/polkit-1/" \
                        "8)" "/etc/sudoers" \
                        "9)" "/etc/sysctl.conf" \
                        "10)" "/etc/ufw" \
                        "X)" "Exit." 3>&2 2>&1 1>&3	
                )

                case $CHOICE in
                    "1)")
                        meld "$(pwd)/baselines/$VERSION/pam.d" /etc/pam.d
                    ;;
                    "2)")
                        meld "$(pwd)/baselines/$VERSION/login.defs" /etc/login.defs
                    ;;
                    "3)")
                        meld "$(pwd)/baselines/$VERSION/apt" /etc/apt
                    ;;
                    "4)")
                        meld "$(pwd)/baselines/$VERSION/security" /etc/security
                    ;;
                    "5)")
                        meld "$(pwd)/baselines/$VERSION/gdm3" /etc/gdm3
                    ;;
                    "6)")
                        meld "$(pwd)/baselines/$VERSION/grub.d" /etc/grub.d
                    ;;
                    "7)")
                        meld "$(pwd)/baselines/$VERSION/polkit-1" /etc/polkit-1
                    ;;
                    "8)")
                        meld "$(pwd)/baselines/$VERSION/sudoers" /etc/sudoers
                    ;;
                    "9)")
                        meld "$(pwd)/baselines/$VERSION/sysctl.conf" /etc/sysctl.conf
                    ;;
                    "10)")
                        meld "$(pwd)/baselines/$VERSION/ufw" /etc/ufw
                    ;;
                    "X)")
                        break
                    ;;
                esac
            done
        ;;
        "X)")
            break
        ;;
    esac
done
