# Assignment 1
## Question 1
1. View `./pow2-merkle.circom`
2. Encountered errors:
  * `Error: Error: Too many signals set.` -> fixed by changing the `4` to `8` on L42 of `pow2-merkle.circom` and recompiling
3. Smart contracts on Ethereum are turing complete and can thus definitely
   verify merkle proofs or create them. In fact this is commonly done e.g. for
   token airdrops. However on-chain zero knowledge proofs can be useful as shown
   by Tornado.cash. Tornado.cash is a privacy protocol on Ethereum and other EVM
   compatible chains which leverages zero knowledge proofs and merkle proofs. 

   When depositing into a tornado pool a node is added to a merkle tree for
   that deposit. To ensure that privacy is not compromised upon withdrawing from
   the pool a zero knowledge proof is submitted proving that they have access
   to an un-claimed node in the tree without revealing which node is theirs.
