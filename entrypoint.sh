#!/bin/bash
WHITELIST_FILE="${WHITELIST_FILE:-/config/domains.txt}"

# Default DENY all
iptables -F && iptables -X
iptables -P INPUT DROP && iptables -P FORWARD DROP && iptables -P OUTPUT DROP

# Allow loopback + established
iptables -A INPUT -i lo -j ACCEPT && iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Read domains from file and whitelist
if [ -f "$WHITELIST_FILE" ]; then
    echo "Loading whitelisted domains from $WHITELIST_FILE..."
    while IFS= read -r domain || [ -n "$domain" ]; do
        [ -z "$domain" ] && continue
        [[ "$domain" =~ ^# ]] && continue
        domain=$(echo "$domain" | tr -d '[:space:]')
        [ -z "$domain" ] && continue
        echo "Whitelisting: $domain"
        for ip in $(dig +short "$domain" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+'); do
            iptables -A OUTPUT -d "$ip" -j ACCEPT
        done
    done < "$WHITELIST_FILE"
    echo "Firewall configured."
else
    echo "Warning: No whitelist file found at $WHITELIST_FILE"
    echo "All outbound traffic will be blocked except DNS."
fi

# Run opencode as non-root user
exec su - opencode-user -c "cd /workspace && opencode"
