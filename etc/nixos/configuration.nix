# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  # enable nested virtualisation
  boot.extraModprobeConfig = "options kvm_intel nested=1";
  # used by lxd to communicate with instances
  boot.kernelModules = [ "vhost_vsock" ];

  networking.hostName = "nixxy"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno2.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # zfs needs this
  networking.hostId = "0123abcd";

  # lxd works with nftables, should work with iptables/ebtables, but not so easily on NixOS
  networking.firewall.enable = false;
  networking.nftables.enable = true;
  networking.nftables.ruleset = "";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # my main user account, can use lxc (lxd) without sudo
  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" "lxd" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa mykey" ];
  };
  security.sudo.wheelNeedsPassword = false;  # no passwords yo!

  # my choices, maybe not yours
  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    tcpdump
    socat
    psmisc
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  # my choices, maybe not yours
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
  nix.gc.automatic = true;

  # lxcfs will give your lxd containers a limited view of /proc and /sys
  # including making them aware of their CPU and memory limits!
  #
  # WARNING: If you enable this, and later run nixos-generate-config, be sure to
  # edit hardware-configuration.nix and remove the /var/lib/lxcfs filesystem or
  # your system will fail to boot!
  #
  virtualisation.lxc.lxcfs.enable = true;

  # the good stuff...
  virtualisation.lxd.enable = true;
  virtualisation.lxd.zfsSupport = true;  # zfs is recommended
  virtualisation.lxd.recommendedSysctlSettings = true;
  systemd.services.lxd.path = with pkgs; [

    # the lxd-agent in nixpkgs is dynamically linked and will fail in your guest VM!
    # this builds a statically compiled version
    ( import ./lxd-agent.nix )

    # lxd won't find virtiofsd or virtfs-proxy-helper without making sure they're in the path
    ( import ./virtiofsd.nix )

    # the lxd nixpkg doesn't know it needs kvm in its path to run qemu!
    kvm

    # the lxd nixpkg doesn't know it needs gptfisk in its path
    # to create the right partitions on the vm block device
    gptfdisk

    # optionally, if you want to mount your cloud-init stuff by virtual CD, lxd
    # will use mkisofs, which the nixpkg doesn't know about
    cdrkit

  ];
  systemd.services.lxd.environment = {

    # lxd will look for EFI firmware in /usr/share, but will not find it there
    # so we need to tell it about our metapackage
    LXD_OVMF_PATH = ( import ./ovmf-meta.nix );

  };

}
