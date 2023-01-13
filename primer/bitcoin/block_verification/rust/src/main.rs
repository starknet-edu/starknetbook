use core::str;
use hex::FromHex;
use serde::Deserialize;
use sha2::{Digest, Sha256};

#[derive(Debug, Deserialize)]
#[serde()]
struct Transaction {
    hash: String,
}

#[derive(Debug, Deserialize)]
#[serde()]
struct Block {
    hash: String,
    ver: u32,
    prev_block: String,
    mrkl_root: String,
    time: u32,
    bits: u32,
    nonce: u32,
    tx: Vec<Transaction>,
}

impl Block {
    fn compute_hash(&self) -> String {
        let mut buffer = vec![];

        let ver = self.ver.to_le_bytes();
        let prev = hex_to_bytes(&self.prev_block);
        let mrkl_root = hex_to_bytes(&self.mrkl_root);
        let time = self.time.to_le_bytes();
        let bits = self.bits.to_le_bytes();
        let nonce = self.nonce.to_le_bytes();

        buffer.extend_from_slice(&ver);
        buffer.extend_from_slice(&prev);
        buffer.extend_from_slice(&mrkl_root);
        buffer.extend_from_slice(&time);
        buffer.extend_from_slice(&bits);
        buffer.extend_from_slice(&nonce);

        let mut hash = Sha256::digest(buffer);
        hash = Sha256::digest(hash);
        hash.reverse();

        format!("{:x}", hash)
    }

    fn get_merkle_root(&self) -> String {
        let mut merkle_hold: Vec<[u8; 32]> = vec![];
        let mut merkle_pass: Vec<[u8; 32]> = vec![];

        self.tx.iter().for_each(|tx| {
            merkle_hold.push(hex_to_bytes(&tx.hash));
        });

        if (merkle_hold.len() % 2) != 0 {
            let last_hash = merkle_hold.last().expect("No value");
            merkle_hold.push(*last_hash);
        }

        let height = (merkle_hold.len() as f32).log2().ceil() as usize;

        println!("Num leaves: {}", merkle_hold.len());
        println!("Rounds: {}", height);

        (0..height).for_each(|i| {
            if i % 2 == 0 {
                if merkle_hold.len() % 2 == 1 {
                    let last_hash = merkle_hold.last().expect("No value");
                    merkle_hold.push(*last_hash);
                }

                (0..merkle_hold.len()).step_by(2).for_each(|j| {
                    let mut hashed_nodes = hash_fun([merkle_hold[j], merkle_hold[j + 1]].concat());
                    merkle_pass.append(&mut hashed_nodes);
                });

                println!(
                    "Round {}: {} 0x{} {} 0x{}",
                    i,
                    "  ".repeat(i as usize),
                    &(hex::encode(merkle_pass[0]))[0..8],
                    "....".repeat((height - i) as usize),
                    &(hex::encode(merkle_pass.last().take().unwrap()))[0..8]
                );

                merkle_hold = vec![];
            } else {
                if merkle_pass.len() % 2 == 1 {
                    let last_hash = merkle_pass.last().expect("No value");
                    merkle_pass.append(&mut vec![*last_hash]);
                }

                (0..merkle_pass.len()).step_by(2).for_each(|j| {
                    let mut hashed_nodes = hash_fun([merkle_pass[j], merkle_pass[j + 1]].concat());
                    merkle_hold.append(&mut hashed_nodes);
                });

                println!(
                    "Round {}: {} 0x{} {} 0x{}",
                    i,
                    "  ".repeat(i as usize),
                    &(hex::encode(merkle_hold[0]))[0..8],
                    "....".repeat((height - i) as usize),
                    &(hex::encode(merkle_hold.last().take().unwrap()))[0..8]
                );

                merkle_pass = vec![];
            }
        });

        if height % 2 == 0 {
            merkle_hold[0].reverse();
            hex::encode(merkle_hold[0])
        } else {
            merkle_pass[0].reverse();
            hex::encode(merkle_pass[0])
        }
    }
}

#[tokio::main]
async fn main() {
    const BLOCK_HASH: &str = "0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947";

    if let Ok(block) = pull_block(BLOCK_HASH).await {
        let hash = block.compute_hash();

        println!("Given Hash:\t {}", block.hash);
        println!("Calculated Hash: {}", hash);
        println!("Match: {}", block.hash == hash);

        println!();

        let root = block.get_merkle_root();

        println!("Given Merkle Root:\t {}", block.mrkl_root);
        println!("Calculated Merkle Root:  {}", root);
        println!("Match: {}", root == block.mrkl_root);
    }
}

fn hash_fun(data: Vec<u8>) -> Vec<[u8; 32]> {
    let intermediate_hash = Sha256::digest(data);
    let hash: [u8; 32] = Sha256::digest(intermediate_hash)
        .as_slice()
        .try_into()
        .expect("wrong length");

    vec![hash]
}

fn hex_to_bytes(hex_string: &str) -> [u8; 32] {
    let mut num_str = hex_string.replace("0x", "");

    if (num_str.len() % 2) != 0 {
        num_str.insert(0, '0');
    }

    let mut decoded = <[u8; 32]>::from_hex(num_str).expect("Decoding failed");

    decoded.reverse();

    decoded
}

async fn pull_block(block_hash: &str) -> Result<Block, Box<dyn std::error::Error>> {
    let res = reqwest::get(format!("https://blockchain.info/rawblock/{}", block_hash)).await?;

    let block = res.json().await?;

    Ok(block)
}

#[cfg(test)]
mod tests {
    use crate::{Block, Transaction};

    fn mock() -> Block {
        Block {
            hash: "0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947".to_string(),
            ver: 541065220,
            prev_block: "00000000000000000004cd25aa2b9f364086c1f7b0511979b23fbe8db617933c"
                .to_string(),
            mrkl_root: "5516e0944cb1f007b9d4efc8cbc407a7387e6596c023db71f331840dadd71606"
                .to_string(),
            time: 1649415588,
            bits: 386521239,
            nonce: 2447168103,
            tx: vec![
                Transaction {
                    hash: "023f35f909ca4248292cf5f0cbfa6cd40958b9dd843fda6839da0156420ebf97"
                        .to_string(),
                },
                Transaction {
                    hash: "d15a9cad18dd8427ff4e253677c8b83de198bbba9f0700d5a7f2b852cac4956b"
                        .to_string(),
                },
            ],
        }
    }

    #[test]
    fn hash_block() {
        assert_eq!(
            mock().compute_hash(),
            "0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947"
        );
    }

    #[test]
    fn get_merkle_root() {
        let block = mock();

        assert_eq!(
            block.get_merkle_root(),
            "b92adffbb12cadaf1d1db1e0de150b4895cc1e2134424b9410d7474cf2725255"
        );
    }
}
