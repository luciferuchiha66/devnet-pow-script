#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Install Rust and Cargo
step1() {
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
step2() {
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
step3() {
    echo "Configuring Solana CLI..."
    if ! command_exists solana; then
        echo "Installing Solana CLI..."
        sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
        export PATH="/home/$USER/.local/share/solana/install/active_release/bin:$PATH"
    fi

    echo "Setting Solana CLI to Devnet..."
    solana config set --url https://api.devnet.solana.com

    if [ ! -f ~/my-solana-wallet.json ]; then
        echo "Generating a new wallet..."
        solana-keygen new --outfile ~/my-solana-wallet.json
    fi

    echo "Setting wallet as default..."
    solana config set --keypair ~/my-solana-wallet.json
    echo "Your wallet address is: $(solana address)"
}

# Step 4: Start Mining Devnet SOL
step4() {
    echo "Starting Devnet SOL mining..."
    if command_exists devnet-pow; then
        read -p "Enter your wallet address: " WALLET_ADDRESS
        devnet-pow mine --wallet "$WALLET_ADDRESS"
    else
        echo "Devnet POW is not installed. Please run Step 2 first."
    fi
}

while true; do
    echo "\nSelect an option:"
    echo "1. Install Rust and Cargo"
    echo "2. Install Devnet POW Crate"
    echo "3. Configure Solana CLI"
    echo "4. Start Mining Devnet SOL"
    echo "5. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            step1
            ;;
        2)
            step2
            ;;
        3)
            step3
            ;;
        4)
            step4
            ;;
        5)
            echo "Exiting script. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

done
