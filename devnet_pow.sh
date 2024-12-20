#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Install Rust and Cargo
install_rust() {
    echo "Installing Rust and Cargo..."
    if command_exists rustc && command_exists cargo; then
        echo "Rust and Cargo are already installed."
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
        echo "Rust and Cargo installed successfully."
    fi
    echo "Rust version: $(rustc --version)"
    echo "Cargo version: $(cargo --version)"
}

# Step 2: Install the Devnet POW Crate
install_devnet_pow() {
    echo "Installing Devnet POW Crate..."
    if command_exists devnet-pow; then
        echo "Devnet POW is already installed."
    else
        cargo install devnet-pow
        echo "Devnet POW installed successfully."
    fi
    echo "Devnet POW version: $(devnet-pow --help | head -n 1)"
}

# Step 3: Configure Solana CLI
configure_solana() {
    echo "Configuring Solana CLI..."
    if ! command_exists solana; then
        echo "Installing Solana CLI..."
        sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
        export PATH="/home/$USER/.local/share/solana/install/active_release/bin:$PATH"
    fi

    echo "Setting Solana CLI to Devnet..."
    solana config set --url https://api.devnet.solana.com
}

# Step 4: Generate a new Solana wallet
create_wallet() {
    echo "Generating a new Solana wallet..."
    if [ ! -f ~/my-solana-wallet.json ]; then
        solana-keygen new --outfile ~/my-solana-wallet.json --force
        echo "New wallet generated at ~/my-solana-wallet.json"
    else
        echo "Wallet already exists at ~/my-solana-wallet.json"
    fi
    # Set the generated wallet as the default for Solana CLI
    solana config set --keypair ~/my-solana-wallet.json
    echo "Wallet address is: $(solana address)"
}

# Step 5: Start mining Devnet SOL
start_mining() {
    echo "Starting Devnet SOL mining..."
    if [ ! -f ~/my-solana-wallet.json ]; then
        echo "No wallet found. Please create a wallet first (Step 4)."
        return 1
    fi

    echo "Starting mining with the keypair from ~/my-solana-wallet.json..."
    devnet-pow mine --keypair-path ~/my-solana-wallet.json
}

# Step 6: View wallet details
view_wallet_details() {
    echo "Viewing wallet details..."
    if [ -f ~/my-solana-wallet.json ]; then
        echo "Wallet file exists at ~/my-solana-wallet.json"
        echo "Wallet Address: $(solana address)"
        echo "Wallet Keypair: $(cat ~/my-solana-wallet.json)"
    else
        echo "No wallet found. Please create a wallet first (Step 4)."
    fi
}

# Step 7: View wallet balance
view_balance() {
    echo "Viewing wallet balance..."
    if [ -f ~/my-solana-wallet.json ]; then
        # Ensure the Solana CLI uses the correct keypair
        solana config set --keypair ~/my-solana-wallet.json
        solana balance
    else
        echo "No wallet found. Please create a wallet first (Step 4)."
    fi
}

# Main menu
while true; do
    echo "\nSelect an option:"
    echo "1. Install Rust and Cargo"
    echo "2. Install Devnet POW Crate"
    echo "3. Configure Solana CLI"
    echo "4. Create a new wallet"
    echo "5. Start Mining Devnet SOL"
    echo "6. View Wallet Details"
    echo "7. View Wallet Balance"
    echo "8. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_rust
            ;;
        2)
            install_devnet_pow
            ;;
        3)
            configure_solana
            ;;
        4)
            create_wallet
            ;;
        5)
            start_mining
            ;;
        6)
            view_wallet_details
            ;;
        7)
            view_balance
            ;;
        8)
            echo "Exiting script. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
