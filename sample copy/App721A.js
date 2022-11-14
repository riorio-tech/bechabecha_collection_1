import React, { useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useLoading, Oval } from '@agney/react-loading'
import { fetchData } from './redux/data/dataActions'
import { ethers } from "ethers";
import React, { useEffect, useState } from "react";
import "./styles/App.css";
import twitterLogo from "./assets/twitter-logo.svg";
import myEpicNft from "./utils/becha.json";

const truncate = (input, len) =>
  input.length > len ? `${input.substring(0, len)}...` : input

  const Mint = () => {
    const dispatch = useDispatch()
    const blockchain = useSelector((state) => state.blockchain)
    const data = useSelector((state) => state.data)
    const [merkle, setMerkle] = useState([])
    const [claimingNft, setClaimingNft] = useState(false)
    const [feedback, setFeedback] = useState(`Click buy to mint your NFT.`)
    const [mintAmount, setMintAmount] = useState(1)
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
      MAX_SUPPLY: 1,
      GAS_LIMIT: 0,
      MARKETPLACE: '',
      MARKETPLACE_LINK: '',
    })
  
    const { indicatorEl } = useLoading({
      loading: claimingNft,
      indicator: <Oval width="24" />,
    })
  
    const claimNFTs = () => {
      let cost = data.cost
      let gasLimit = CONFIG.GAS_LIMIT
      let method = null
      let totalCostWei = new BN(cost.toString()).muln(mintAmount)
      let totalGasLimit = String(gasLimit * mintAmount)
      setFeedback(`Minting your ${CONFIG.NFT_NAME}...`)
      setClaimingNft(true)
      if (data.presale) {
        method = blockchain.smartContract.methods.preMint(
          mintAmount,
          merkle.hexProof
        )
      } else {
        method = blockchain.smartContract.methods.publicMint(mintAmount)
      }
      method
        .send({
          gasLimit: String(totalGasLimit),
          to: CONFIG.CONTRACT_ADDRESS,
          from: blockchain.account,
          value: totalCostWei,
        })
        .once('error', (err) => {
          console.log(err)
          setFeedback('Sorry, something went wrong please try again later.')
          setClaimingNft(false)
        })
        .then((receipt) => {
          console.log(receipt)
          setFeedback(
            `WOW, the ${CONFIG.NFT_NAME} is yours! go visit ${CONFIG.MARKETPLACE} to view it.`
          )
          setClaimingNft(false)
          dispatch(fetchData(blockchain.account))
        })
    }
  }
