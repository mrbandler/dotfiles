{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "install";

  runtimeInputs = with pkgs; [
    _1password-cli
    openssh
    util-linux # for lsblk
  ];

  text = ''
    FLAKE_URL="github:mrbandler/dotfiles"
    NIXOS_ANYWHERE="github:nix-community/nixos-anywhere"
    OP_VAULT_ITEM="op://Nix/Opnix Service Account/credential"

    # --- Validation ---

    if [ -z "''${1:-}" ]; then
      echo "Usage: install <hostname>"
      echo "Example: install zeus"
      exit 1
    fi

    HOSTNAME="$1"

    if ! grep -q 'VARIANT_ID=installer' /etc/os-release 2>/dev/null; then
      echo "Error: This script must be run from a NixOS installer image."
      exit 1
    fi

    echo "=== NixOS Install: $HOSTNAME ==="
    echo ""

    # --- Disk confirmation ---

    echo "Current disk layout:"
    echo ""
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
    echo ""
    read -rp "This will ERASE all disks configured for '$HOSTNAME'. Continue? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 0
    fi

    # --- 1Password authentication ---

    echo ""
    echo "Authenticating with 1Password to retrieve the opnix service account token..."
    echo "You will need: account address, email, secret key, and master password."
    echo ""

    eval "$(op account add --signin)"

    token=$(op read "$OP_VAULT_ITEM")

    if [ -z "$token" ]; then
      echo "Error: Failed to retrieve service account token from 1Password."
      exit 1
    fi

    echo "Service account token retrieved successfully."

    # --- SSH setup ---

    echo "root:nixos" | chpasswd
    systemctl start sshd

    # --- Prepare extra-files ---

    EXTRA_FILES=$(mktemp -d)
    mkdir -p "$EXTRA_FILES/home/mrbandler/.config/opnix"
    echo "$token" > "$EXTRA_FILES/home/mrbandler/.config/opnix/token"
    chmod 0600 "$EXTRA_FILES/home/mrbandler/.config/opnix/token"

    # --- Run nixos-anywhere ---

    echo ""
    echo "Starting nixos-anywhere installation..."
    echo ""

    nix run "$NIXOS_ANYWHERE" -- \
      --flake "$FLAKE_URL#$HOSTNAME" \
      --extra-files "$EXTRA_FILES" \
      --build-on-remote \
      --ssh-option "StrictHostKeyChecking=no" \
      root@localhost

    # Cleanup (only reached if nixos-anywhere doesn't reboot automatically)
    rm -rf "$EXTRA_FILES"
  '';
}
