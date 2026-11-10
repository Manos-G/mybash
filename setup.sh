#!/bin/sh -e

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

if [ ! -d "$LINUXTOOLBOXDIR" ]; then
    echo "${YELLOW}Creating linuxtoolbox directory: $LINUXTOOLBOXDIR${RC}"
    mkdir -p "$LINUXTOOLBOXDIR"
    echo "${GREEN}linuxtoolbox directory created: $LINUXTOOLBOXDIR${RC}"
fi

# --upgrade (used by bash_upgrade): work on this existing checkout instead of
# re-cloning, skip first-time questions, and only install what is missing.
UPGRADE=0
if [ "$1" = "--upgrade" ]; then
    UPGRADE=1
fi

if [ "$UPGRADE" -eq 0 ]; then
    if [ -d "$LINUXTOOLBOXDIR/mybash" ]; then rm -rf "$LINUXTOOLBOXDIR/mybash"; fi

    echo "${YELLOW}Cloning mybash repository into: $LINUXTOOLBOXDIR/mybash${RC}"
    git clone git@github.com:Manos-G/mybash.git "$LINUXTOOLBOXDIR/mybash"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Successfully cloned mybash repository${RC}"
    else
        echo "${RED}Failed to clone mybash repository${RC}"
        exit 1
    fi
fi

# add variables to top level so can easily be accessed by all functions
PACKAGER=""
SUDO_CMD=""
SUGROUP=""
GITPATH=""

if [ "$UPGRADE" -eq 1 ]; then
    cd "$(dirname "$(realpath "$0")")" || exit
else
    cd "$LINUXTOOLBOXDIR/mybash" || exit
fi

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo "${RED}To run me, you need: $REQUIREMENTS${RC}"
            exit 1
        fi
    done

    ## Check Package Handler
    PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install nix-env'
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo "Using $pgm"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        echo "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    echo "Using $SUDO_CMD as privilege escalation software"

    ## Check if the current directory is writable.
    GITPATH=$(dirname "$(realpath "$0")")
    if [ ! -w "$GITPATH" ]; then
        echo "${RED}Can't write to $GITPATH${RC}"
        exit 1
    fi

    ## Check SuperUser Group

    SUPERUSERGROUP='wheel sudo root'
    for sug in $SUPERUSERGROUP; do
        if groups | grep -q "$sug"; then
            SUGROUP="$sug"
            echo "Super user group $SUGROUP"
            break
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep -q "$SUGROUP"; then
        echo "${RED}You need to be a member of the sudo group to run me!${RC}"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='bash bash-completion tar bat tree multitail wget unzip fontconfig btop trash-cli nano xclip'
    if ! command_exists nvim; then
        DEPENDENCIES="${DEPENDENCIES} neovim"
    fi

    ## Extra apps listed in packages.txt (one package per line, # for comments).
    if [ -f "$GITPATH/packages.txt" ]; then
        DEPENDENCIES="${DEPENDENCIES} $(sed -e 's/#.*//' "$GITPATH/packages.txt" | tr '\n' ' ')"
    fi

    ## On apt/nala, only ask for the packages that aren't installed yet, so a
    ## re-run with nothing new never needs sudo.
    if [ "$PACKAGER" = "apt" ] || [ "$PACKAGER" = "nala" ]; then
        MISSING=""
        for pkg in $DEPENDENCIES; do
            dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed" || MISSING="$MISSING $pkg"
        done
        DEPENDENCIES="$MISSING"
    fi

    if [ -z "$(echo $DEPENDENCIES)" ]; then
        echo "All dependencies already installed"
    else
    echo "${YELLOW}Installing dependencies:${DEPENDENCIES}${RC}"
    if [ "$PACKAGER" = "pacman" ]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            ${SUDO_CMD} ${PACKAGER} --noconfirm -S base-devel
            cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "AUR helper already installed"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "No AUR helper found. Please install yay or paru."
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
    elif [ "$PACKAGER" = "nala" ]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
    elif [ "$PACKAGER" = "emerge" ]; then
        ${SUDO_CMD} ${PACKAGER} -v app-shells/bash app-shells/bash-completion app-arch/tar app-editors/neovim sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch sys-process/btop
    elif [ "$PACKAGER" = "xbps-install" ]; then
        ${SUDO_CMD} ${PACKAGER} -v ${DEPENDENCIES}
    elif [ "$PACKAGER" = "nix-env" ]; then
        ${SUDO_CMD} ${PACKAGER} -iA nixos.bash nixos.bash-completion nixos.gnutar nixos.neovim nixos.bat nixos.tree nixos.multitail nixos.fastfetch nixos.btop nixos.pkgs.starship
    elif [ "$PACKAGER" = "dnf" ]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
    else
        ${SUDO_CMD} ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
    fi

    # MesloLGS is used by fastfetch, JetBrainsMono by the terminals (Yakuake, Ghostty)
    installNerdFont "MesloLGS Nerd Font Mono" "Meslo"
    installNerdFont "JetBrainsMono Nerd Font" "JetBrainsMono"
}

## installNerdFont <fc-list family name> <nerd-fonts release zip name>
installNerdFont() {
    FONT_NAME="$1"
    if fc-list :family | grep -iq "$FONT_NAME"; then
        echo "Font '$FONT_NAME' is installed."
    else
        echo "Installing font '$FONT_NAME'"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$2.zip"
        FONT_DIR="$HOME/.local/share/fonts"
        # check if the file is accessible
        if wget -q --spider "$FONT_URL"; then
            TEMP_DIR=$(mktemp -d)
            wget -q --show-progress $FONT_URL -O "$TEMP_DIR"/"${FONT_NAME}".zip
            unzip "$TEMP_DIR"/"${FONT_NAME}".zip -d "$TEMP_DIR"
            mkdir -p "$FONT_DIR"/"$FONT_NAME"
            mv "${TEMP_DIR}"/*.ttf "$FONT_DIR"/"$FONT_NAME"
            # Update the font cache
            fc-cache -fv
            # delete the files created from this
            rm -rf "${TEMP_DIR}"
            echo "'$FONT_NAME' installed successfully."
        else
            echo "Font '$FONT_NAME' not installed. Font URL is not accessible."
        fi
    fi
}

installYakuake() {
    ## Only install yakuake on KDE Plasma desktops.
    if ! echo "${XDG_CURRENT_DESKTOP}${DESKTOP_SESSION}" | grep -qiE 'kde|plasma' && ! command_exists plasmashell; then
        echo "KDE not detected, skipping yakuake."
        return
    fi

    if command_exists yakuake; then
        echo "Yakuake already installed"
        return
    fi

    echo "${YELLOW}KDE detected, installing yakuake...${RC}"
    case "$PACKAGER" in
        pacman)
            if command_exists yay; then
                yay --noconfirm -S yakuake
            elif command_exists paru; then
                paru --noconfirm -S yakuake
            else
                ${SUDO_CMD} ${PACKAGER} --noconfirm -S yakuake
            fi
            ;;
        emerge)
            ${SUDO_CMD} ${PACKAGER} -v kde-apps/yakuake
            ;;
        nix-env)
            ${SUDO_CMD} ${PACKAGER} -iA nixos.yakuake
            ;;
        nala|dnf)
            ${SUDO_CMD} ${PACKAGER} install -y yakuake
            ;;
        *)
            ${SUDO_CMD} ${PACKAGER} install -yq yakuake
            ;;
    esac
}

## Yakuake look: JetBrains profile (linked from the repo), ROUNDED-DARK skin and
## the Meta+` shortcut. Settings are only written when not already set, so
## changes made later in the Yakuake GUI are kept.
installYakuakeConfig() {
    if ! command_exists yakuake; then
        return
    fi
    if command_exists kwriteconfig6; then
        KWRITE=kwriteconfig6; KREAD=kreadconfig6
    elif command_exists kwriteconfig5; then
        KWRITE=kwriteconfig5; KREAD=kreadconfig5
    else
        echo "${YELLOW}kwriteconfig not found, skipping Yakuake settings${RC}"
        return
    fi
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)

    ## Profile: link to the repo copy, unless a different local one exists.
    PROFILE_DIR="$USER_HOME/.local/share/konsole"
    PROFILE="$PROFILE_DIR/JetBrains.profile"
    mkdir -p "$PROFILE_DIR"
    if [ "$(readlink -f "$PROFILE")" = "$(readlink -f "$GITPATH/yakuake/JetBrains.profile")" ]; then
        echo "Yakuake profile already linked"
    elif [ -e "$PROFILE" ] && ! cmp -s "$PROFILE" "$GITPATH/yakuake/JetBrains.profile"; then
        echo "${YELLOW}$PROFILE differs from the repo copy, leaving it alone${RC}"
    else
        ln -svf "$GITPATH/yakuake/JetBrains.profile" "$PROFILE"
    fi

    ## Skin: copy if missing.
    SKIN_DIR="$USER_HOME/.local/share/yakuake/kns_skins"
    if [ ! -d "$SKIN_DIR/ROUNDED-DARK" ]; then
        mkdir -p "$SKIN_DIR"
        cp -r "$GITPATH/yakuake/skins/ROUNDED-DARK" "$SKIN_DIR/"
        echo "Installed Yakuake skin ROUNDED-DARK"
    fi

    ## yakuakerc keys, only if unset.
    setYakuakeKey() {
        if [ -z "$($KREAD --file yakuakerc --group "$1" --key "$2")" ]; then
            $KWRITE --file yakuakerc --group "$1" --key "$2" "$3"
        fi
    }
    setYakuakeKey "Desktop Entry" DefaultProfile JetBrains.profile
    setYakuakeKey Appearance Skin ROUNDED-DARK
    setYakuakeKey Appearance SkinInstalledWithKns true
    setYakuakeKey Window Height 100

    ## Shortcut Meta+` (keeping F12), unless it was already customised.
    CURRENT=$($KREAD --file kglobalshortcutsrc --group yakuake --key toggle-window-state)
    case "$CURRENT" in
        ""|F12,*)
            $KWRITE --file kglobalshortcutsrc --group yakuake --key toggle-window-state "Meta+\`,F12,Open/Retract Yakuake"
            echo "Yakuake shortcut set to Meta+\` (applies after logging in again)"
            ;;
    esac
    echo "Yakuake config done (restart Yakuake to see changes)"
}

installYazi() {
    if command_exists yazi; then
        echo "Yazi already installed"
        return
    fi

    echo "${YELLOW}Installing yazi...${RC}"
    case "$PACKAGER" in
        pacman)
            if command_exists yay; then
                yay --noconfirm -S yazi || true
            elif command_exists paru; then
                paru --noconfirm -S yazi || true
            else
                ${SUDO_CMD} ${PACKAGER} --noconfirm -S yazi || true
            fi
            ;;
        emerge)
            ${SUDO_CMD} ${PACKAGER} -v app-misc/yazi || true
            ;;
        nix-env)
            ${SUDO_CMD} ${PACKAGER} -iA nixos.yazi || true
            ;;
        nala|dnf)
            ${SUDO_CMD} ${PACKAGER} install -y yazi || true
            ;;
        *)
            ${SUDO_CMD} ${PACKAGER} install -yq yazi || true
            ;;
    esac

    ## Fall back to cargo if the package manager didn't provide yazi.
    if ! command_exists yazi; then
        echo "${YELLOW}Yazi not available from package manager, installing via cargo...${RC}"
        if ! command_exists cargo; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            . "$HOME/.cargo/env"
        fi
        # yazi-fm/yazi-cli can't be built directly from crates.io (their own
        # build.rs refuses); the crates.io-published fix is to install the
        # yazi-build meta-crate with --force instead.
        cargo install --locked --force yazi-build
    fi
}

installFastfetch() {
    if command_exists fastfetch; then
        echo "Fastfetch already installed"
        return
    fi

    echo "${YELLOW}Installing fastfetch...${RC}"
    case "$PACKAGER" in
        apt|nala)
            ## Not in older Debian/Ubuntu repos, grab the latest .deb from GitHub.
            ## Pick the asset that matches this machine's architecture.
            case "$(uname -m)" in
                x86_64)          FF_ARCH="amd64" ;;
                aarch64|arm64)   FF_ARCH="aarch64" ;;
                armv7l)          FF_ARCH="armv7l" ;;
                *)               FF_ARCH="amd64" ;;
            esac
            FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-${FF_ARCH}.deb" | cut -d '"' -f 4)
            if [ -n "$FASTFETCH_URL" ]; then
                TEMP_DIR=$(mktemp -d)
                curl -sL "$FASTFETCH_URL" -o "$TEMP_DIR/fastfetch.deb"
                ${SUDO_CMD} apt-get install -y "$TEMP_DIR/fastfetch.deb" || ${SUDO_CMD} dpkg -i "$TEMP_DIR/fastfetch.deb"
                rm -rf "$TEMP_DIR"
            else
                echo "${RED}Could not determine fastfetch download URL${RC}"
            fi
            ;;
        pacman)
            if command_exists yay; then
                yay --noconfirm -S fastfetch || true
            elif command_exists paru; then
                paru --noconfirm -S fastfetch || true
            else
                ${SUDO_CMD} ${PACKAGER} --noconfirm -S fastfetch || true
            fi
            ;;
        emerge)
            ${SUDO_CMD} ${PACKAGER} -v app-misc/fastfetch || true
            ;;
        nix-env)
            ${SUDO_CMD} ${PACKAGER} -iA nixos.fastfetch || true
            ;;
        *)
            ${SUDO_CMD} ${PACKAGER} install -y fastfetch || true
            ;;
    esac
}

installEza() {
    if command_exists eza; then
        echo "Eza already installed"
        return
    fi

    echo "${YELLOW}Installing eza...${RC}"
    case "$PACKAGER" in
        pacman)
            if command_exists yay; then
                yay --noconfirm -S eza || true
            elif command_exists paru; then
                paru --noconfirm -S eza || true
            else
                ${SUDO_CMD} ${PACKAGER} --noconfirm -S eza || true
            fi
            ;;
        emerge)
            ${SUDO_CMD} ${PACKAGER} -v sys-apps/eza || true
            ;;
        nix-env)
            ${SUDO_CMD} ${PACKAGER} -iA nixos.eza || true
            ;;
        nala|dnf)
            ${SUDO_CMD} ${PACKAGER} install -y eza || true
            ;;
        *)
            ${SUDO_CMD} ${PACKAGER} install -yq eza || true
            ;;
    esac

    ## Fall back to cargo if the package manager didn't provide eza.
    if ! command_exists eza; then
        echo "${YELLOW}Eza not available from package manager, installing via cargo...${RC}"
        if ! command_exists cargo; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            . "$HOME/.cargo/env"
        fi
        cargo install eza
    fi
}

installLazygit() {
    if command_exists lazygit; then
        echo "Lazygit already installed"
        return
    fi

    echo "${YELLOW}Installing lazygit...${RC}"
    ## Pick the release asset that matches this machine's architecture.
    case "$(uname -m)" in
        x86_64)          LG_ARCH="x86_64" ;;
        aarch64|arm64)   LG_ARCH="arm64" ;;
        armv7l|armv6l)   LG_ARCH="armv6" ;;
        *)               LG_ARCH="x86_64" ;;
    esac
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    TEMP_DIR=$(mktemp -d)
    curl -Lo "$TEMP_DIR/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_linux_${LG_ARCH}.tar.gz"
    tar xf "$TEMP_DIR/lazygit.tar.gz" -C "$TEMP_DIR" lazygit
    ${SUDO_CMD} install "$TEMP_DIR/lazygit" /usr/local/bin
    rm -rf "$TEMP_DIR"
}

## Filee (github.com/KnifeLemon/Filee): offline file converter. Installed per
## user by its own install.sh (no root); after that it updates itself, so this
## only runs when it's missing.
installFilee() {
    if [ -d "$HOME/.local/share/filee/application" ] || command_exists filee; then
        echo "Filee already installed"
        return
    fi

    case "$(uname -m)" in
        x86_64)          FILEE_ARCH="x64" ;;
        aarch64|arm64)   FILEE_ARCH="arm64" ;;
        *)
            echo "${YELLOW}Filee has no Linux build for $(uname -m), skipping${RC}"
            return
            ;;
    esac

    echo "${YELLOW}Installing Filee...${RC}"
    FILEE_VERSION=$(curl -s "https://api.github.com/repos/KnifeLemon/Filee/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || true)
    if [ -z "$FILEE_VERSION" ]; then
        echo "${RED}Could not find the latest Filee release, skipping${RC}"
        return
    fi
    FILEE_BASE="https://github.com/KnifeLemon/Filee/releases/download/v${FILEE_VERSION}"
    FILEE_TAR="Filee-${FILEE_VERSION}-linux-${FILEE_ARCH}.tar.gz"
    TEMP_DIR=$(mktemp -d)
    if ! curl -fL --progress-bar -o "$TEMP_DIR/$FILEE_TAR" "$FILEE_BASE/$FILEE_TAR" \
        || ! curl -fsL -o "$TEMP_DIR/SHA256SUMS.txt" "$FILEE_BASE/Filee-${FILEE_VERSION}-linux-${FILEE_ARCH}-SHA256SUMS.txt"; then
        echo "${RED}Filee download failed, skipping${RC}"
        rm -rf "$TEMP_DIR"
        return
    fi
    if ! (cd "$TEMP_DIR" && grep " $FILEE_TAR\$" SHA256SUMS.txt | sha256sum -c --quiet -); then
        echo "${RED}Filee checksum mismatch, not installing${RC}"
        rm -rf "$TEMP_DIR"
        return
    fi
    mkdir "$TEMP_DIR/x"
    tar -xzf "$TEMP_DIR/$FILEE_TAR" -C "$TEMP_DIR/x"
    FILEE_INSTALLER=$(find "$TEMP_DIR/x" -maxdepth 2 -name install.sh | head -n 1)
    if [ -n "$FILEE_INSTALLER" ]; then
        sh "$FILEE_INSTALLER" || echo "${RED}Filee install.sh failed${RC}"
    else
        echo "${RED}Filee package has no install.sh, skipping${RC}"
    fi
    rm -rf "$TEMP_DIR"
}

installLazydocker() {
    if command_exists lazydocker; then
        echo "Lazydocker already installed"
        return
    fi

    echo "${YELLOW}Installing lazydocker...${RC}"
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}

installStarshipAndFzf() {
    if command_exists starship; then
        echo "Starship already installed"
    elif
        ! curl -sS https://starship.rs/install.sh | sh -s -- --yes; then
        echo "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
    if command_exists fzf; then
        echo "Fzf already installed"
    else
        echo "Fzf not installed, installing..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
}

installZoxide() {
    if command_exists zoxide; then
        echo "Zoxide already installed"
        return
    fi

    echo "${YELLOW}Installing zoxide...${RC}"
    case "$PACKAGER" in
        pacman)
            if command_exists yay; then
                yay --noconfirm -S zoxide || true
            elif command_exists paru; then
                paru --noconfirm -S zoxide || true
            else
                ${SUDO_CMD} ${PACKAGER} --noconfirm -S zoxide || true
            fi
            ;;
        emerge)
            ${SUDO_CMD} ${PACKAGER} -v app-shells/zoxide || true
            ;;
        nix-env)
            ${SUDO_CMD} ${PACKAGER} -iA nixos.zoxide || true
            ;;
        nala|dnf)
            ${SUDO_CMD} ${PACKAGER} install -y zoxide || true
            ;;
        *)
            ${SUDO_CMD} ${PACKAGER} install -yq zoxide || true
            ;;
    esac

    ## Fall back to the upstream install script if the package manager didn't provide zoxide.
    if ! command_exists zoxide; then
        echo "${YELLOW}Zoxide not available from package manager, installing via upstream script...${RC}"
        if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
            echo "${RED}Something went wrong during zoxide install!${RC}"
            exit 1
        fi
    fi
}

install_additional_dependencies() {
    # we have PACKAGER so just use it
    # for now just going to return early as we have already installed neovim in `installDepend`
    # so I am not sure why we are trying to install it again
    return
   case "$PACKAGER" in
        *apt)
            if [ ! -d "/opt/neovim" ]; then
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                chmod u+x nvim.appimage
                ./nvim.appimage --appimage-extract
                ${SUDO_CMD} mv squashfs-root /opt/neovim
                ${SUDO_CMD} ln -s /opt/neovim/AppRun /usr/bin/nvim
            fi
            ;;
        *zypper)
            ${SUDO_CMD} zypper refresh
            ${SUDO_CMD} zypper -n install neovim # -y doesn't work on opensuse -n is short for -non-interactive which is equivalent to -y
            ;;
        *dnf)
            ${SUDO_CMD} dnf check-update
            ${SUDO_CMD} dnf install -y neovim
            ;;
        *pacman)
            ${SUDO_CMD} pacman -Syu
            ${SUDO_CMD} pacman -S --noconfirm neovim
            ;;
        *)
            echo "No supported package manager found. Please install neovim manually."
            exit 1
            ;;
    esac
}

installRosTools() {
    ## colcon_cd powers the rpkg command; it comes from the ROS apt repository.
    case "$PACKAGER" in
        apt|nala)
            if dpkg-query -W -f='${Status}' python3-colcon-cd 2>/dev/null | grep -q "install ok installed"; then
                echo "colcon_cd already installed"
                return
            fi
            ${SUDO_CMD} ${PACKAGER} install -y python3-colcon-cd || \
                echo "${YELLOW}python3-colcon-cd not installed; rpkg needs it once ROS 2 is set up${RC}"
            ;;
    esac
}

create_fastfetch_config() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    
    if [ ! -d "$USER_HOME/.config/fastfetch" ]; then
        mkdir -p "$USER_HOME/.config/fastfetch"
    fi
    # Check if the fastfetch config file exists
    if [ -e "$USER_HOME/.config/fastfetch/config.jsonc" ]; then
        rm -f "$USER_HOME/.config/fastfetch/config.jsonc"
    fi
    ln -svf "$GITPATH/config.jsonc" "$USER_HOME/.config/fastfetch/config.jsonc" || {
        echo "${RED}Failed to create symbolic link for fastfetch config${RC}"
        exit 1
    }
    ln -svf "$GITPATH/hmu_h.txt" "$USER_HOME/.config/fastfetch/hmu_h.txt" || {
        echo "${RED}Failed to create symbolic link for fastfetch logo${RC}"
        exit 1
    }
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    ## Check if a bashrc file is already there.
    OLD_BASHRC="$USER_HOME/.bashrc"
    ## Already linked to this checkout: nothing to back up.
    if [ "$(readlink -f "$OLD_BASHRC")" = "$(readlink -f "$GITPATH/.bashrc")" ]; then
        echo ".bashrc already linked to $GITPATH"
    elif [ -e "$OLD_BASHRC" ]; then
        echo "${YELLOW}Moving old bash config file to $USER_HOME/.bashrc.bak${RC}"
        if ! mv "$OLD_BASHRC" "$USER_HOME/.bashrc.bak"; then
            echo "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    if [ "$(readlink -f "$OLD_BASHRC")" != "$(readlink -f "$GITPATH/.bashrc")" ]; then
        echo "${YELLOW}Linking new bash config file...${RC}"
        ln -svf "$GITPATH/.bashrc" "$USER_HOME/.bashrc" || {
            echo "${RED}Failed to create symbolic link for .bashrc${RC}"
            exit 1
        }
    fi
    ln -svf "$GITPATH/starship.toml" "$USER_HOME/.config/starship.toml" || {
        echo "${RED}Failed to create symbolic link for starship.toml${RC}"
        exit 1
    }
}

configureRosDomainId() {
    ## Ask the user for a permanent ROS_DOMAIN_ID and persist it so every
    ## shell picks it up (ros2.bash sources ~/.ros_domain_id).
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    ROS_ID_FILE="$USER_HOME/.ros_domain_id"

    ## Only asked on a fresh setup; use `rosid` to change it later.
    if [ "$UPGRADE" -eq 1 ]; then
        echo "Skipping ROS_DOMAIN_ID question (upgrade)"
        return
    fi

    printf "%bSelect your permanent ROS_DOMAIN_ID [0-232, default 0]: %b" "$YELLOW" "$RC"
    read -r ROS_DOMAIN_ID_INPUT || ROS_DOMAIN_ID_INPUT=""

    if [ -z "$ROS_DOMAIN_ID_INPUT" ]; then
        ROS_DOMAIN_ID_INPUT=0
    fi

    if ! echo "$ROS_DOMAIN_ID_INPUT" | grep -qE '^[0-9]+$' || [ "$ROS_DOMAIN_ID_INPUT" -gt 232 ]; then
        echo "${RED}Invalid ROS_DOMAIN_ID '$ROS_DOMAIN_ID_INPUT', defaulting to 0${RC}"
        ROS_DOMAIN_ID_INPUT=0
    fi

    echo "export ROS_DOMAIN_ID=$ROS_DOMAIN_ID_INPUT" > "$ROS_ID_FILE"
    echo "${GREEN}ROS_DOMAIN_ID set to $ROS_DOMAIN_ID_INPUT (saved to $ROS_ID_FILE)${RC}"
}

checkEnv
installDepend
configureRosDomainId
installFastfetch
installYakuake
installYazi
installEza
installLazygit
installLazydocker
installFilee
installStarshipAndFzf
installZoxide
install_additional_dependencies
installRosTools
create_fastfetch_config
installYakuakeConfig

if linkConfig; then
    if [ "$UPGRADE" -eq 1 ]; then
        echo "${GREEN}mybash upgrade done.${RC}"
    else
        echo "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
    fi
else
    echo "${RED}Something went wrong!${RC}"
fi
