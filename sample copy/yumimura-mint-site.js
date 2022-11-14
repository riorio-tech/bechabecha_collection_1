import "./App.css";
import { ethers } from "ethers";
import contract from "./contracts/LorthernLights.json";
import React, { useEffect, useState } from "react";
import image from './assets/nlights.svg';
import Footer from './components/Footer';
import Header from './components/Header';

const OPENSEA_LINK = 'https://opensea.io/collection/nlights';
const CONTRACT_ADDRESS = "0x5d4202864FaddA856aE729785FbEacC1d956A187";
const abi = contract.abi;

const App = () => {

  const [currentAccount, setCurrentAccount] = useState(null);
  const [networkError, setnetworkError] = useState(null);
  const [mineStatus, setMineStatus] = useState(null);
  const [saleStatus, setSaleStatus] = useState(false);
  const [whitelist, setWhitelist] = useState(false);
  const [taxnHash, setTxnhash] = useState(null);
  const [maxPerWallet, setMaxPerWallet] = useState(null);

  const checkWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have Metamask installed!");
      return;
    } else {
      console.log("wallet exists.")
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });
    const network = await ethereum.request({ method: 'eth_chainId' });

    if (accounts.length !== 0 && network.toString() === '0x1') {
      const account = accounts[0];
      setCurrentAccount(account);
    }
  }

  const connectWallet = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      alert("Please install Metamask!");
    }

    try {
      const network = await ethereum.request({ method: 'eth_chainId' });

      if (network.toString() === '0x1') {
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
        setnetworkError(null);
        setCurrentAccount(accounts[0]);
      }

      else {
        setnetworkError(true);
      }

    } catch (err) {
      console.log(err)
    }
  }

  const mintNFT = async () => {
    try {
        setMineStatus('mining');

        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const contract = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

          let mint = await contract.mintNFT({ gasLimit: 270000, value: ethers.utils.parseEther("0.01") });
          await mint.wait();
          
          setTxnhash(mint.hash);
          setMineStatus('success');

        } else {
          setMineStatus('error');
        }

      } catch (err) {
        setMineStatus('error');
      }
  }

  const checkActive = async () => {
    const { ethereum } = window;
    try {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner()
      const contract = new ethers.Contract(
        CONTRACT_ADDRESS,
        abi,
        signer
      );
      // call your address    
      const address = await signer.getAddress();
      
      // bool: whitelist
      const whitelist = await contract.whitelist(address);
      setWhitelist(whitelist)
      
      // int: mintedPerWallet
      const mintedPerWallet= await contract.mintedPerWallet(address);
      setMaxPerWallet(mintedPerWallet.toString());

      // bool: sale
      const bool = await contract.whitelistSale();
      setSaleStatus(bool);

    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    checkWalletIsConnected();

    if (window.ethereum) {
      window.ethereum.on('chainChanged', (_chainId) => window.location.reload());
    }
  }, [])

  // Render Methods
  const renderNotConnectedContainer = () => (
    <button onClick={connectWallet} className="bn29">Connect to Wallet</button>
  );

  const renderMintUI = () => {
    checkActive()
    
    if (whitelist) {
      if (saleStatus) {
        if (maxPerWallet < 2) {
          return (<div>
            <button onClick={mintNFT} className="bn29">Mint NFT</button>
            
            <p>{currentAccount}<br/>Your address can mint NFT: Remaining {2-maxPerWallet}</p></div>
            );    
        } else {
          return (<div><p class="success" >Thank you!🐑</p></div>);
        }
      } else {
        return (<div>
          <p>Not on sale<br/>{currentAccount}<br/>You have whitelist</p></div>
          );
      }
    } else {
      return (<div><p>Not on sale<br/>{currentAccount}<br/>Your address don't have whitelist</p></div>);
    }
  }

  return (
    <React.Fragment>
      <div className="App">
        <div className="container">
          <Header opensea={OPENSEA_LINK} />
          <div className="header-container">
            <p> Fully on-chain, CC0 Public Domain, Generative Art</p>
            <p> No Roadmap, No Discord, No Utility, No Rarity</p>
            <p> <a href="https://yuk6ra.com/northern-lights-project/">Document</a></p>
            <br/>
            <p> Sale: 2022/10/21 21:00 JST ~ (Open: 48 hours)</p>
            <p> Whitelist Price: 0.01 ETH + gas</p>
            <p> 2 mint Per Wallet</p>
            <p> Supply: 150</p>
            {/* <p className="warning">ホワイトリストはまだ反映されてません。</p> */}
            <div className='banner-img'>
              <a href={OPENSEA_LINK}><img src={image}/></a>
            </div>
            {currentAccount && mineStatus !== 'mining' && renderMintUI()}
            {!currentAccount && !mineStatus && renderNotConnectedContainer()}
            {networkError && <p class="error">Need to switch Ethereum network</p>}
            <div className='mine-submission'>
              {mineStatus === 'success' && <div className={mineStatus}>
              <p className='success-link'>
                  {taxnHash}<br/>Transaction is successful!<br/>
                  <a href={OPENSEA_LINK}>View Opensea</a>
                </p>
              </div>}
              {mineStatus === 'mining' && <div className={mineStatus}>
                <div className='loader'/></div>}
              {mineStatus === 'error' && <div className={mineStatus}>
                <p>Transaction failed</p>
              </div>}
            </div>
          </div>
          <Footer address={CONTRACT_ADDRESS} />
        </div>
      </div>
    </React.Fragment>
  );
}

export default App;
