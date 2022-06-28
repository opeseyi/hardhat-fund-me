const { getNamedAccounts } = require('hardhat');

async function main() {
  const { deployer } = await getNamedAccounts();
  const fundMe = await ether.getContract('FundMe', deployer);
  console.log('funding...');
  const transactionResponse = await fundMe.withraw();
  await transactionResponse.wait(1);
  console.log('Got it back');
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
