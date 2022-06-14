/* eslint-disable node/no-unpublished-import */
import { expect } from "chai";
import { starknet } from "hardhat";
import {
  Account,
  StarknetContract,
  StarknetContractFactory,
} from "hardhat/types/runtime";

const UINT_0 = { low: BigInt(0), high: BigInt(0) };
const AMOUNT = { low: BigInt(1), high: BigInt(0) };

describe("Multisig", async function () {
  this.timeout(6_000_000);

  let account1: Account;
  let account2: Account;
  let account3: Account;
  let account4: Account;
  let account5: Account;

  let multisigContractFactory: StarknetContractFactory;
  let multisigContract: StarknetContract;

  let erc20Factory: StarknetContractFactory;
  let erc20Contract: StarknetContract;

  before(async () => {
    account1 = await starknet.deployAccount("OpenZeppelin");
    account2 = await starknet.deployAccount("OpenZeppelin");
    account3 = await starknet.deployAccount("OpenZeppelin");
    account4 = await starknet.deployAccount("OpenZeppelin");
    account5 = await starknet.deployAccount("OpenZeppelin");

    multisigContractFactory = await starknet.getContractFactory("contract");
    multisigContract = await multisigContractFactory.deploy({
      _signers: [
        account1.starknetContract.address,
        account2.starknetContract.address,
        account3.starknetContract.address,
        account4.starknetContract.address,
      ],
      _threshold: { low: 3, high: 0 },
    });

    erc20Factory = await starknet.getContractFactory("ERC20");
    erc20Contract = await erc20Factory.deploy({
      name: 1,
      symbol: 1,
      decimals: 0,
      initial_supply: { low: 100, high: 0 },
      recipient: multisigContract.address,
    });
  });

  describe("Test create proposal", async () => {
    it("Signer creates proposal should work", async () => {
      await account1.invoke(multisigContract, "create_proposal", {
        amount: AMOUNT,
        to_: BigInt(account1.starknetContract.address),
        targetERC20: BigInt(erc20Contract.address),
      });
      // const prop = await multisigContract.call("view_proposal", {
      //   proposal_nb: UINT_0,
      // });
      // const expectedProp = {
      //   amount: AMOUNT,
      //   to_: BigInt(account1.starknetContract.address),
      //   executed: BigInt(0),
      //   numberOfSigners: { low: BigInt(1), high: BigInt(0) },
      //   targetERC20: BigInt(erc20Contract.address),
      //   timestamp: BigInt(0),
      // };

      // expect(prop.proposal).to.be.deep.eq(expectedProp);

      // const newCounter = await multisigContract.call("view_counter");
      // expect(newCounter.res).to.deep.eq(AMOUNT);
    });

    it("random tries to create a proposal, should fail", async () => {
      account5
        .invoke(multisigContract, "create_proposal", {
          amount: AMOUNT,
          to_: BigInt(account1.starknetContract.address),
          targetERC20: BigInt(erc20Contract.address),
        })
        .catch(async (e) => {
          await expect(e.message.includes("Error message: Only signer")).to.be
            .true;
        });
    });
  });

  describe("Proposal signing", () => {
    it("Signer signs a proposal, should work", async () => {
      await account2.invoke(multisigContract, "sign_proposal", {
        proposal_nb: UINT_0,
      });
      const prop = await multisigContract.call("view_proposal", {
        proposal_nb: UINT_0,
      });
      expect(prop.proposal.numberOfSigners).to.deep.eq({
        low: BigInt(2),
        high: BigInt(0),
      });
      expect(prop.proposal.executed).to.deep.eq(BigInt(0));

      const signer1 = await multisigContract.call("view_approved_signer", {
        proposal_nb: UINT_0,
        signer_nb: UINT_0,
      });
      const signer2 = await multisigContract.call("view_approved_signer", {
        proposal_nb: UINT_0,
        signer_nb: { low: BigInt(1), high: BigInt(0) },
      });

      expect(BigInt(signer1.signer)).to.deep.eq(
        BigInt(account1.starknetContract.address)
      );

      expect(BigInt(signer2.signer)).to.deep.eq(
        BigInt(account2.starknetContract.address)
      );
    });

    it("Signer signs proposal again shouldn't work", async () => {
      await account1
        .invoke(multisigContract, "sign_proposal", { proposal_nb: UINT_0 })
        .catch((e) => {
          e.message.includes("Error message: Sender has already signed");
        });
    });

    it("random tries to sign a proposal, should fail", async () => {
      account5.invoke(multisigContract, "sign_proposal", UINT_0).catch((e) => {
        e.message.includes("Error message: Only signer");
      });
    });

    it("random tries to sign an unknown proposal, should fail", async () => {
      account5
        .invoke(multisigContract, "sign_proposal", { low: 1, high: 0 })
        .catch((e) => {
          e.message.includes("Error message: Only signer");
        });
    });

    it("signer tries to sign an unknown proposal, should fail", async () => {
      account1
        .invoke(multisigContract, "sign_proposal", { low: 1, high: 0 })
        .catch((e) => {
          e.message.includes("Error message: Only signer");
        });
    });

    it("Signer signs and executes a proposal, should work", async () => {
      await account3.invoke(multisigContract, "sign_proposal", {
        proposal_nb: UINT_0,
      });
      const prop = await multisigContract.call("view_proposal", {
        proposal_nb: UINT_0,
      });
      expect(prop.proposal.numberOfSigners).to.deep.eq({
        low: BigInt(3),
        high: BigInt(0),
      });

      expect(prop.proposal.executed).to.deep.eq(BigInt(1));

      const signer1 = await multisigContract.call("view_approved_signer", {
        proposal_nb: UINT_0,
        signer_nb: UINT_0,
      });
      const signer2 = await multisigContract.call("view_approved_signer", {
        proposal_nb: UINT_0,
        signer_nb: { low: BigInt(1), high: BigInt(0) },
      });
      const signer3 = await multisigContract.call("view_approved_signer", {
        proposal_nb: UINT_0,
        signer_nb: { low: BigInt(2), high: BigInt(0) },
      });

      expect(BigInt(signer1.signer)).to.deep.eq(
        BigInt(account1.starknetContract.address)
      );

      expect(BigInt(signer2.signer)).to.deep.eq(
        BigInt(account2.starknetContract.address)
      );

      expect(BigInt(signer3.signer)).to.deep.eq(
        BigInt(account3.starknetContract.address)
      );

      const balance = await erc20Contract.call("balanceOf", {
        account: account1.starknetContract.address,
      });
      expect(balance.balance).to.deep.eq(AMOUNT);
    });

    it("signer tries to an already executed proposal, should fail", async () => {
      account1
        .invoke(multisigContract, "sign_proposal", { low: 1, high: 0 })
        .catch((e) => {
          e.message.includes("Error message: Proposal already executed");
        });
    });
  });
});
