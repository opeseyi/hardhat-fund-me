// function deployfunc(){
//     console.log('hi')
// }

const { network } = require('hardhat');
const {
  networkConfig,
  developmentChain,
} = require('../helper-harrdhat-config');
const { verify } = require('../utills/verify');

// module.exports.default = deployfunc

// or

// module.exports = async (hre) => {
//     const {getNamedAccounts, deployments} = hre
// };

// or

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  //   const ethUsdPriceFeedAddress = networkConfig[chainId]['ethUsdPriceFeed'];

  let ethUsdPriceFeedAddress;
  if (developmentChain.includes(network.name)) {
    const ethUsdAggregator = await deployments.get('MockV3Aggregator');
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]['ethUsdPriceFeed'];
  }

  const args = [ethUsdPriceFeedAddress];
  const fundMe = await deploy('FundMe', {
    from: deployer,
    args: args,
    log: true,
    waitConfirmation: network.config.blockConfirmation || 1,
  });

  if (
    !developmentChain.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, args);
  }

  log('.............................................');
};

module.exports.tags = ['all', 'fund-me'];
