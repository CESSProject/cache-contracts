const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CacheProtocol", (m) => {
  const contract = m.contract("CacheProtocol", ["0xDc5950C626bdB597E586CEaa91117579cb10688D"]);

  return { contract };
});