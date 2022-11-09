
import { ethers } from "ethers";
import React, { useEffect, useState } from "react";
import "./styles/App.css";
import twitterLogo from "./assets/twitter-logo.svg";
import BechaNft from "./utils/becha.json";

const TWITTER_HANDLE = "bechabecha_nft";
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const OPENSEA_LINK = "";
const CONTRACT_ADDRESS = '0x9461ea81f3FAf8D171673610B11bcaa80C458C84'
const TOTAL_MINT_COUNT = 100;
const App = () => {
const [CONFIG, SET_CONFIG] = useState({
    CONTRACT_ADDRESS: '',
    SCAN_LINK: '',
    NETWORK: {
      NAME: '',
      SYMBOL: '',
      ID: 0,
    },
    NFT_NAME: '',
    SYMBOL: '',
    MAX_SUPPLY: 100,
    GAS_LIMIT: 0,
  })
  
  const [currentAccount, setCurrentAccount] = useState("");

  console.log("currentAccount: ", currentAccount);
  
  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;
    if (!ethereum) {
      console.log("Make sure you have MetaMask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }
    const accounts = await ethereum.request({ method: "eth_accounts" });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      setCurrentAccount(account);
      
    } else {
      console.log("No authorized account found");
    }
  };

 
  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }

      const accounts = await ethereum.request({ method: "eth_requestAccounts" });
  
      console.log("Connected", accounts[0]);
  

      setCurrentAccount(accounts[0]);
  

    } catch (error) {
      console.log(error);
    }
  };

const askContractToMintNft = async () => {
  try {
    const { ethereum } = window;

    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const connectedContract = new ethers.Contract(
        CONTRACT_ADDRESS,
        BechaNft.abi,
        signer
      );

      console.log("Going to pop wallet now to pay gas...");

      let nftTxn = await connectedContract.presale();

      console.log("Mining...please wait.");
      await nftTxn.await();
      console.log(nftTxn);
      console.log(
        `Mined, see transaction: https://goerli.etherscan.io/tx/${nftTxn.hash}`
      );
    } else {
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    console.log(error);
  }
};


  const renderNotConnectedContainer = () => (
    <button
      onClick={connectWallet}
      className="cta-button connect-wallet-button"
    >
      Connect to Wallet
    </button>
  );
  
  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);
  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">BechaBecha</p>
          <p className="sub-text">お一人様2つまでミント可能💫</p>
          {currentAccount === "" ? (renderNotConnectedContainer()) : 
          (
            <button onClick={askContractToMintNft} className="cta-button connect-wallet-button">
              You can MINT!
            </button>
          )}
        </div>
        <div className="footer-container">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`@${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
  
};
export default App;