sudo yum localinstall --disablerepo=* /home/admin/srl-ndk-git_0.1.0_linux_amd64.rpm -y
sleep 2
sudo sed -i "s/failure-threshold: 10/failure-action: wait=1/g" /etc/opt/srlinux/appmgr/ndk-git.yml
sr_cli  "/ tools system app-management application app_mgr reload"
sleep 5
sr_cli --candidate-mode < /home/admin/agent_config_leaf1.txt
sr_cli --candidate-mode < /home/admin/git_token_setup.txt
sr_cli --candidate-mode --commit-at-end '/ git-client branch '$GROUP'-branch'
sleep 4

while [[ ! $(sr_cli 'info from state / git-client') ]];
do
    sudo pkill ndk-git
    sleep 4
done


#Install Neofetch
sudo ip netns exec srbase-mgmt sudo curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
sudo chmod +x /usr/bin/neofetch

/home/admin/check_ndk_agent.sh  >  /home/admin/check_ndk_output.log 2>&1 &
