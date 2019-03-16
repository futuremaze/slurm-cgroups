#!/bin/bash -xeu

# cgroups のインストール
sudo -E apt-get update -y
sudo -E apt-get install -y cgroup-bin cgroup-tools

# cgroups 動作確認用の stress コマンドインストール
sudo -E apt-get install -y stress

# cgrules.conf をPAMで適用する libpam-cgroup のインストール
sudo -E apt-get install -y libpam-cgroup
sudo sh -c "cat >> /etc/pam.d/common-session" <<EOF
session optional        pam_cgroup.so
EOF

# grub.conf 書き換え(http://rolk.github.io/2015/04/20/slurm-cluster)
sudo sed -i 's,\(^GRUB_CMDLINE_LINUX_DEFAULT\)=\"\(.*\)",\1=\"\2 cgroup_enable=memory swapaccount=1\",' /etc/default/grub
sudo update-grub

# cgroups 設定
sudo sh -c "cat > /etc/cgconfig.conf" <<EOF
group slurm {
  cpuset {
    cpuset.cpus = "0";
    cpuset.cpu_exclusive = "1";
  }
}
group other {
  cpuset {
    cpuset.cpus = "1";
  }
}
EOF

sudo sh -c "cat > /etc/cgrules.conf" <<EOF
#<user/group:bin> <controller(s)>      <cgroup>
root              cpu,cpuset,memory    /
slurm             cpu,cpuset,memory    /slurm
mysql             cpu,cpuset,memory    /slurm
munge             cpu,cpuset,memory    /slurm
*                 cpu,cpuset,memory    /other
EOF

sudo cp /usr/share/doc/cgroup-tools/examples/cgred.conf /etc/

# cgconfig.conf 設定反映用 systemd
sudo sh -c "cat > /etc/systemd/system/cgconfigparser.service" <<EOF
[Unit]
Description=cgroup config parser
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/sbin/cgconfigparser -l /etc/cgconfig.conf
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

# cgrulesengd 管理用 systemd
sudo sh -c "cat > /etc/systemd/system/cgrulesengd.service" <<EOF
[Unit]
Description=cgroup rules generator
After=network.target cgconfigparser.service

[Service]
User=root
Group=root
Type=forking
EnvironmentFile=-/etc/cgred.conf
ExecStart=/usr/sbin/cgrulesengd
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# systemd 登録
sudo systemctl daemon-reload
sudo systemctl enable cgconfigparser
sudo systemctl enable cgrulesengd
sudo systemctl start cgconfigparser
sudo systemctl start cgrulesengd
