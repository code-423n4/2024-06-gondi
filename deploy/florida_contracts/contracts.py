from typing import Any, List, NamedTuple, Optional


class Contract(NamedTuple):
    filename: str
    contract_name: str
    arguments: Optional[List[Any]] = None
    name: Optional[str] = None

    def with_arguments(self, *arguments):
        return self.__class__(
            self.filename, self.contract_name, [str(arg) for arg in arguments]
        )

    def with_name(self, name: str):
        return self.__class__(self.filename, self.contract_name, self.arguments, name)

    @property
    def name_str(self) -> str:
        return self.name or self.contract_name


AddressManager = Contract("src/lib/AddressManager.sol", "AddressManager")
LiquidationDistributor = Contract(
    "src/lib/LiquidationDistributor.sol", "LiquidationDistributor"
)
AuctionLoanLiquidator = Contract(
    "src/lib/AuctionLoanLiquidator.sol", "AuctionLoanLiquidator"
)
MultiSourceLoan = Contract("src/lib/loans/MultiSourceLoan.sol", "MultiSourceLoan")
SampleCollection = Contract("test/utils/SampleCollection.sol", "SampleCollection")
SampleToken = Contract("test/utils/SampleToken.sol", "SampleToken")
USDCSampleToken = Contract("test/utils/USDCSampleToken.sol", "USDCSampleToken")
SingleSourceLoan = Contract("src/lib/loans/SingleSourceLoan.sol", "SingleSourceLoan")
VaultLoanValidator = Contract("src/lib/VaultLoanValidator.sol", "VaultLoanValidator")
VaultFactory = Contract("src/lib/VaultFactory.sol", "VaultFactory")
RangeValidator = Contract("src/lib/validators/RangeValidator.sol", "RangeValidator")
DelegateRegistry = Contract(
    "lib/delegate-registry/src/DelegateRegistry.sol", "DelegateRegistry"
)
Leverage = Contract("src/lib/callbacks/Leverage.sol", "Leverage")
WETH = Contract("lib/solmate/src/tokens/WETH.sol", "WETH")
UserVault = Contract("src/lib/UserVault.sol", "UserVault")
