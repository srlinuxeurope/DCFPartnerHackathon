sudo yum localinstall --disablerepo=* /home/admin/srl-ndk-git_0.1.0_linux_amd64.rpm -y
sleep 2
sudo sed -i "s/failure-threshold: 10/failure-action: wait=1/g" /etc/opt/srlinux/appmgr/ndk-git.yml
sr_cli  "/ tools system app-management application app_mgr reload"
sleep 5
sr_cli --candidate-mode < /home/admin/agent_config_leaf1.txt
sr_cli --candidate-mode < /home/admin/git_token_setup.txt
sr_cli --candidate-mode --commit-at-end '/ git-client branch '$GROUP'-branch'

#while [[ ! $(sr_cli 'info from state / git-client') ]];
#do
#    sudo pkill ndk-git
#    sleep 2
#done


#Install Neofetch
sudo ip netns exec srbase-mgmt dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo ip netns exec srbase-mgmt dnf -y install neofetch

