class TicketInfo:
    def __init__(self, w3, ticket_contract):
        # Info from deployed contract
        self.w3 = w3
        self.ticket_contract = ticket_contract
        self.event_name = self.ticket_contract.functions.name().call()
        self.venue_size = self.ticket_contract.functions.venueSize().call()
        self.total_supply = self.ticket_contract.functions.totalSupply().call()
        self.mint_rate = self.ticket_contract.functions.mintRate().call()
        self.adr = ""

    # Get the max amount of tickets that can be purchased
    def get_max(self):
        return self.venue_size - self.total_supply

    # Check if user entered a valid address
    def valid_address(self):
        if self.adr[0:1] != "0x" and len(self.adr) != 42:
            return False
        return True

    # Mint new tickets
    def mint(self, amount, tx):
        self.ticket_contract.functions.safeMint(to=self.adr, _amount=amount).transact(tx)

    # Displays current address balance
    def balance_of(self):
        return self.ticket_contract.functions.balanceOf(owner=self.adr).call()
