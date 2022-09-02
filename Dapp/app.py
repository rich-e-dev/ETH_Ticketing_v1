# Imports
import os
import json
from web3 import Web3
import streamlit as st
from dotenv import load_dotenv
from ticketInfo import TicketInfo

# Call Contract
@st.experimental_singleton
def start():
    load_dotenv('dapp.env')
    # Get provider url from Ganache
    ganache_provider = Web3.HTTPProvider(os.environ["PROVIDER_URL"])
    w3 = Web3(ganache_provider)

    # Get contract abi
    with open("abi.txt") as f:
        # Save abi to json
        abi_json = json.load(f)

    # Create the ticket contract with deployed address and abi_json
    ticket_contract = w3.eth.contract(address=os.environ["CONTRACT_ADDRESS"], abi=abi_json)
    return w3, ticket_contract

# Call Start
w3, ticket_contract = start()

# Create ticket_info to hold the ticket information
ticket_info = TicketInfo(w3, ticket_contract)

# Streamlit App
st.header(f"{ticket_info.event_name} Event")
st.write(f"{ticket_info.total_supply}/{ticket_info.venue_size}")
ticket_info.adr = st.text_input("Enter Address")
amount = st.number_input("How many tickets would you like???", value=1, max_value=ticket_info.get_max(), step=1)

# The amount of eth the address will be paying
amountPaying = ticket_info.mint_rate * amount

# Proper grammar check
if amount == 1:
    st.write(f"{amountPaying / 10 ** 18} eth will be charged for {amount} ticket.")
else:
    st.write(f"{amountPaying / 10 ** 18} eth will be charged for {amount} tickets.")

# When button is pressed and if the user entered a valid email
if st.button("buy ticket") and ticket_info.valid_address():
    # Create transaction
    tx = {
        "from": ticket_info.adr,
        "value": w3.toWei(amountPaying, "wei"),
        "gas": 3000000,
        "gasPrice": w3.toWei(40, "gwei")
    }
    # Mint new tickets to address
    ticket_info.mint(amount=amount, tx=tx)

# Display error if contract is not valid
elif not ticket_info.valid_address():
    st.error("Enter a valid address")
