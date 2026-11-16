
pass=0; fail=0

check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf "PASS  %s\n" "$desc"; pass=$((pass+1))
  else
    printf "FAIL  %s\n" "$desc"; fail=$((fail+1))
  fi
}

sshd_has() { sudo sshd -T 2>/dev/null | grep -qix "$1"; }
ufw_has()  { sudo ufw status verbose 2>/dev/null | grep -q "$1"; }

check "SSH root login disabled"        sshd_has "permitrootlogin no"
check "SSH password login disabled"     sshd_has "passwordauthentication no"
check "SSH on port 2222"                sshd_has "port 2222"
check "SSH max auth tries is 3"         sshd_has "maxauthtries 3"
check "UFW is active"                   ufw_has "Status: active"
check "UFW denies incoming by default"  ufw_has "deny (incoming)"
check "fail2ban is running"             systemctl is-active --quiet fail2ban
check "fail2ban sshd jail exists"       sudo fail2ban-client status sshd
check "ASLR is on"                      test "$(sysctl -n kernel.randomize_va_space)" = 2
check "SYN cookies are on"              test "$(sysctl -n net.ipv4.tcp_syncookies)" = 1
check "shadow file is 640 or stricter"  test "$(stat -c %a /etc/shadow)" -le 640
check "only root has UID 0"             test "$(awk -F: '$3==0' /etc/passwd | wc -l)" -eq 1
check "no empty passwords"              test -z "$(sudo awk -F: '($2=="")' /etc/shadow)"
check "SSH LogLevel is VERBOSE"         sshd_has "loglevel VERBOSE"
check "Unused protocol dccp blocked"    grep -q "install dccp /bin/false" /etc/modprobe.d/ironclad-protocols.conf
printf "\n%d passed, %d failed\n" "$pass" "$fail"
[ "$fail" -eq 0 ]
